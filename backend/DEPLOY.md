# BikeJee Backend — Production Deployment (scaled for 1 lakh users)

This guide deploys the backend on AWS so it stays up under real traffic and
scales horizontally. The architecture keeps **no state in the app process** —
all state lives in **RDS (Postgres)** and **ElastiCache (Redis)** — so you can
run many app instances behind a load balancer and add/remove them freely.

```
                    ┌──────────────────────────────┐
   Customers &      │   Application Load Balancer   │  (HTTPS, sticky sessions
   Drivers  ───────▶│            (ALB)              │   for Socket.IO)
                    └──────────────┬───────────────┘
                                   │
              ┌────────────────────┼────────────────────┐
              ▼                    ▼                    ▼
       ┌────────────┐      ┌────────────┐       ┌────────────┐
       │  App EC2   │      │  App EC2   │  ...  │  App EC2   │   Auto Scaling Group
       │ (PM2 x N)  │      │ (PM2 x N)  │       │ (PM2 x N)  │   (2 → 10 instances)
       └─────┬──────┘      └─────┬──────┘       └─────┬──────┘
             └───────────────────┼─────────────────────┘
                    ┌────────────┴────────────┐
                    ▼                          ▼
          ┌───────────────────┐     ┌────────────────────┐
          │  RDS PostgreSQL   │     │ ElastiCache Redis  │
          │ (Multi-AZ + read  │     │ (OTP, geo, socket  │
          │  replica)         │     │  pub/sub, limits)  │
          └───────────────────┘     └────────────────────┘
```

---

## 1. Provision managed data stores

### RDS PostgreSQL
- Engine: PostgreSQL 16
- Instance: start `db.t3.medium` (2 vCPU / 4 GB). Scale to `db.m6g.large`+ under load.
- **Multi-AZ: ON** (automatic failover — no crash if one AZ dies).
- Add one **read replica** later if read load grows (ride history, profiles).
- Storage: gp3, 100 GB, autoscaling enabled.
- Security group: allow 5432 **only** from the app instances' security group.
- After creation, connect once and enable required extensions (the migration
  does this, but the DB user needs permission):
  ```sql
  CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
  CREATE EXTENSION IF NOT EXISTS cube;
  CREATE EXTENSION IF NOT EXISTS earthdistance;
  ```

### ElastiCache Redis
- Engine: Redis 7, **cluster mode disabled** is fine to start (1 primary + 1 replica).
- Node: `cache.t3.small` to start; scale node size or enable cluster mode later.
- Enable **Multi-AZ with automatic failover**.
- Security group: allow 6379 **only** from the app instances' security group.

---

## 2. Configure environment

On each app instance (or in the ECS task definition / launch template user-data),
set the environment from `.env.example`:

```
PORT=4000
JWT_SECRET=<long-random-string>
DATABASE_URL=postgres://USER:PASS@<rds-endpoint>:5432/bikejee
PG_SSL=true                 # RDS requires SSL
PG_POOL_MAX=20              # per instance; see connection math below
REDIS_URL=redis://<elasticache-endpoint>:6379
PM2_INSTANCES=max           # one worker per vCPU
CORS_ORIGIN=https://your-web-app.com
SMS_PROVIDER=sns            # or msg91
AWS_REGION=ap-south-1
RAZORPAY_KEY_ID=...
RAZORPAY_KEY_SECRET=...
```

**Postgres connection math (important):** total DB connections =
`instances × PM2 workers × PG_POOL_MAX`. Example: 4 instances × 4 workers × 20 =
320 connections. Keep this under the RDS `max_connections` (≈ for t3.medium it's
~340). If you scale wider, **lower `PG_POOL_MAX`** (e.g. 10) or put **PgBouncer**
in front of RDS. Do not skip this — connection exhaustion is the #1 cause of
crashes at scale.

---

## 3. Run database migration (once)

From any machine that can reach RDS:
```bash
DATABASE_URL=postgres://USER:PASS@<rds-endpoint>:5432/bikejee PG_SSL=true \
  npm run migrate
```

---

## 4. Deploy the app instances

**Option A — Docker on EC2 (simplest):**
```bash
# build & push to ECR, then on each instance:
docker run -d --restart unless-stopped -p 4000:4000 --env-file .env \
  <your-ecr-repo>/bikejee-backend:latest
```
The image runs PM2 in cluster mode (one worker per core) with a container
`HEALTHCHECK` on `/health`.

**Option B — EC2 without Docker:**
```bash
npm ci --omit=dev
pm2 start ecosystem.config.cjs
pm2 startup && pm2 save   # survive reboots
```

Bake this into a **Launch Template** for the Auto Scaling Group.

---

## 5. Load balancer + Auto Scaling

### Application Load Balancer
- Listener: HTTPS 443 (attach an ACM certificate). Redirect 80 → 443.
- Target group: HTTP 4000, **health check path `/health`** (healthy threshold 2,
  interval 15s). Unhealthy instances are automatically drained — no crash reaches
  users.
- **Enable stickiness** (duration-based cookie) on the target group. Socket.IO's
  long-polling upgrade needs the handshake and upgrade to hit the same instance.
  (The Redis adapter still fans out events across instances.)

### Auto Scaling Group
- Min 2, Desired 2, Max 10 (tune to budget).
- Spread across **≥ 2 Availability Zones**.
- Scaling policy: target tracking on **average CPU 60%** (add a request-count
  policy too if CPU stays low but latency rises).
- Instance type: `t3.large` (2 vCPU / 8 GB) or `c6g.large` for CPU-bound socket
  fan-out. 2 vCPU → PM2 runs 2 workers per instance.

---

## 6. Capacity planning for 1 lakh (100,000) users

Rough sizing — validate with a load test (see below). "1 lakh users" means
registered users; concurrent load is far lower.

| Metric | Estimate | Notes |
|---|---|---|
| Registered users | 100,000 | total accounts |
| Daily active | ~20,000 (20%) | typical for a ride app |
| Peak concurrent | ~5,000 (5%) | rush hours |
| Peak API req/s | ~1,000–2,000 | booking, tracking, wallet |
| Peak socket connections | ~5,000–10,000 | riders + drivers live |

**What handles each:**
- **API + sockets:** ~4–6 app instances (t3.large, 2 workers each) behind the
  ALB comfortably serve a few thousand req/s. ASG adds more on CPU spikes.
- **Postgres:** the hot path (driver matching, OTP) is **not** on Postgres — it's
  on Redis. Postgres handles writes (rides, wallet) + history reads. A
  `db.m6g.large` Multi-AZ with a read replica covers this load; indexes on
  `rides(customer_id)`, `rides(status)`, `wallet_transactions(user_id)` keep
  queries fast.
- **Redis:** driver geo matching (`GEORADIUS`), OTP TTL, and rate-limit counters
  are all O(log N)/O(1). A single `cache.t3.small` primary handles tens of
  thousands of ops/sec. Enable a replica for failover.

**Why it won't crash:**
- No in-memory state → any instance can die and be replaced; ASG + ALB health
  checks route around failures.
- Connection pooling + capped `PG_POOL_MAX` → DB connections never exhaust.
- Redis-backed rate limiting → abuse/spikes are throttled cluster-wide before
  they reach the DB.
- Multi-AZ RDS + Redis → an AZ outage triggers automatic failover.
- Graceful shutdown (SIGTERM) → in-flight requests finish during deploys/scale-in.

---

## 7. Load test before launch

```bash
# Install k6 (https://k6.io) and test the booking + OTP paths.
# Ramp to your expected peak req/s and watch:
#   - ALB target 5xx rate (should stay ~0)
#   - RDS connections (must stay under max_connections)
#   - Redis CPU/memory
#   - app instance CPU (ASG should add instances at 60%)
```
Fix any bottleneck (usually: raise ASG max, add RDS read replica, or lower
`PG_POOL_MAX`) before going live.

---

## 8. Observability (do not skip)

- **CloudWatch alarms:** RDS CPU/connections, Redis CPU/evictions, ALB 5xx,
  ASG unhealthy hosts.
- **PM2 logs** ship to CloudWatch via the CloudWatch agent.
- Add `pm2 install pm2-logrotate` so logs don't fill the disk.

---

## Local / single-box testing

```bash
cp .env.example .env         # fill JWT_SECRET at minimum
docker compose up -d         # starts app + postgres + redis
docker compose run --rm migrate   # apply schema
curl http://localhost:4000/health
```
