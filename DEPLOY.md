# BikeJee — Build & Deploy Guide

Complete guide to build and deploy BikeJee (Flutter apps + Node backend) to production on AWS.

---

## Architecture

```
┌─────────────┐     HTTPS      ┌──────────────────┐
│  Web app    │ ─────────────► │  AWS EC2         │
│ (S3/CF/EC2) │                │  Node + Socket.IO│
├─────────────┤     WSS        │  (BikeJee API)   │
│ Android app │ ─────────────► │                  │
├─────────────┤                │  + Razorpay,     │
│  iOS app    │ ─────────────► │    MSG91/SNS     │
└─────────────┘                └──────────────────┘
```

---

## Part 1 — Deploy the Backend (AWS EC2)

```bash
# SSH into your EC2 (Ubuntu)
ssh -i your-key.pem ubuntu@YOUR_EC2_IP

# Install Node.js 20 + git + pm2
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs git nginx
sudo npm i -g pm2

# Clone & configure
git clone https://github.com/Snapbrio321/BikeJee.git
cd BikeJee/backend
cp .env.example .env
nano .env      # set JWT_SECRET, SMS_PROVIDER, RAZORPAY_KEY_ID/SECRET
npm install
# For AWS SNS SMS: npm i @aws-sdk/client-sns

# Run with pm2 (survives reboots)
pm2 start src/server.js --name bikejee-api
pm2 save && pm2 startup
```

### Nginx reverse proxy + HTTPS
```nginx
# /etc/nginx/sites-available/bikejee
server {
    server_name api.yourdomain.com;
    location / {
        proxy_pass http://localhost:4000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";     # WebSocket support
        proxy_set_header Host $host;
    }
}
```
```bash
sudo ln -s /etc/nginx/sites-available/bikejee /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx
sudo apt install -y certbot python3-certbot-nginx
sudo certbot --nginx -d api.yourdomain.com   # free HTTPS
```

Open ports **80, 443** (and 4000 if testing directly) in the EC2 Security Group.

---

## Part 2 — Build & Deploy the Web App

### Build (with production keys)
```bash
cd bikejee_app
flutter build web --release \
  --dart-define=API_BASE_URL=https://api.yourdomain.com \
  --dart-define=GOOGLE_MAPS_KEY=YOUR_MAPS_KEY \
  --dart-define=RAZORPAY_KEY=rzp_live_xxxxx \
  --dart-define=PRODUCTION=true
# Also uncomment the Maps <script> in web/index.html with your key
```
Output → `build/web/`

### Option A — S3 + CloudFront (recommended, cheapest)
```bash
aws s3 mb s3://bikejee-web
aws s3 sync build/web/ s3://bikejee-web --delete
# Create a CloudFront distribution pointing at the bucket,
# set default root object = index.html,
# add a custom error response: 404 → /index.html (200) for SPA routing.
```

### Option B — Same EC2 via Nginx
```bash
scp -i your-key.pem -r build/web/* ubuntu@YOUR_EC2_IP:/var/www/bikejee/
```
```nginx
server {
    server_name app.yourdomain.com;
    root /var/www/bikejee;
    location / { try_files $uri $uri/ /index.html; }
}
```

---

## Part 3 — Build the Mobile Apps

### Android
```bash
flutter build apk --release \
  -Pmaps.key=YOUR_MAPS_KEY \
  --dart-define=API_BASE_URL=https://api.yourdomain.com \
  --dart-define=GOOGLE_MAPS_KEY=YOUR_MAPS_KEY \
  --dart-define=RAZORPAY_KEY=rzp_live_xxxxx \
  --dart-define=PRODUCTION=true
# Output: build/app/outputs/flutter-apk/app-release.apk

# For Play Store (App Bundle):
flutter build appbundle --release -Pmaps.key=YOUR_MAPS_KEY --dart-define=...
```
Before release: add a real signing config in `android/app/build.gradle.kts` (currently uses debug keys).

### iOS (needs a Mac + Xcode)
```bash
# add Maps key to ios/Runner/AppDelegate.swift: GMSServices.provideAPIKey("KEY")
flutter build ios --release --dart-define=API_BASE_URL=https://api.yourdomain.com ...
# then archive & upload via Xcode
```

---

## Verification Checklist

- [ ] Backend health: `curl https://api.yourdomain.com/` → `{"status":"BikeJee API running"}`
- [ ] OTP: request + verify with a real number (SMS_PROVIDER not console)
- [ ] Maps render (not the placeholder) → key wired on all platforms
- [ ] Book a ride → driver matches → live tracking moves → completes
- [ ] Add money → Razorpay checkout opens → wallet updates
- [ ] Session persists after closing/reopening the app

---

## Cost estimate (small scale)
- EC2 t3.small: ~$15/mo
- S3 + CloudFront: ~$1–5/mo
- Google Maps: free $200/mo credit
- MSG91 SMS: ~₹0.15/SMS
- Razorpay: 2% per transaction
