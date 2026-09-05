# BikeJee Backend (AWS-ready)

Node.js + Express + Socket.IO backend for BikeJee — OTP auth and real-time ride tracking. Runs on your AWS EC2.

## Endpoints

| Method | Path | Body | Returns |
|---|---|---|---|
| POST | `/auth/send-otp` | `{ phone }` | `{ verificationId }` |
| POST | `/auth/verify-otp` | `{ phone, otp, role }` | `{ token, user }` |
| GET | `/` | — | health check |

Socket.IO events (Step 5):
- `ride:join` `{ rideId }` — customer subscribes to a ride
- `driver:location` `{ rideId, lat, lng }` — driver pushes position
- `ride:driverLocation` `{ lat, lng }` — pushed to customers in that ride

## Run locally
```bash
cd backend
cp .env.example .env        # edit values; SMS_PROVIDER=console prints OTP to logs
npm install
npm run dev
# API on http://localhost:4000
```

With `SMS_PROVIDER=console`, the OTP is printed in the server logs — no SMS gateway needed for testing.

## Point the app at it
```bash
cd bikejee_app
flutter run --dart-define=API_BASE_URL=http://YOUR_EC2_PUBLIC_IP:4000
```

## Deploy to AWS EC2 (quick)
```bash
# on your EC2 (Ubuntu):
sudo apt update && sudo apt install -y nodejs npm
git clone <your-repo> && cd backend
cp .env.example .env && nano .env   # set JWT_SECRET, SMS provider
npm install
sudo npm i -g pm2
pm2 start src/server.js --name bikejee-api
pm2 save && pm2 startup
# open port 4000 in your EC2 security group
```

For real SMS in India, set `SMS_PROVIDER=msg91` and add MSG91 keys, or `SMS_PROVIDER=sns` to use AWS SNS (requires `npm i @aws-sdk/client-sns`).

## Production hardening (later)
- Replace in-memory OTP store with **Redis** (TTL)
- Replace in-memory users with **PostgreSQL** / **DynamoDB**
- Put **Nginx** in front + HTTPS via Let's Encrypt
- Rate-limit `/auth/send-otp` to prevent SMS abuse
