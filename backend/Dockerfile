# BikeJee backend — production image
FROM node:20-alpine

# curl (HEALTHCHECK) + PM2 for cluster mode — installed as root.
RUN apk add --no-cache curl && npm i -g pm2@5

WORKDIR /app

# Install prod deps only (leverages layer caching).
# Uses `npm install` (not `npm ci`) because the repo has no package-lock.json.
COPY package*.json ./
RUN npm install --omit=dev

# App source
COPY . .

# Non-root user for safety (created after global installs / deps)
RUN addgroup -g 1001 nodejs && adduser -S -u 1001 -G nodejs nodejs \
  && mkdir -p logs && chown -R nodejs:nodejs /app
USER nodejs

ENV NODE_ENV=production
EXPOSE 4000

# Container-level health check (Docker/ECS uses this to gate traffic)
HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
  CMD curl -fsS http://localhost:4000/health || exit 1

# Cluster mode via PM2 (one worker per core). pm2-runtime keeps PID 1 alive
# and forwards SIGTERM for graceful shutdown.
CMD ["pm2-runtime", "start", "ecosystem.config.cjs"]
