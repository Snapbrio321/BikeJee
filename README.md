# BikeJee — Ride Fast. Deliver Smart.

A production-grade ride-hailing & parcel-delivery app (Rapido/Ola style) for **Android, iOS, and Web**, built with Flutter + a Node.js/Socket.IO backend.

Two experiences in one codebase: **Customer App** and **Driver Partner App**.

---

## Highlights

- **Rapido-style booking** — destination on home, 3-tap booking, live fare, surge pricing
- **Real Google Maps + GPS** (falls back to an animated placeholder with no key)
- **Distance-based fares** — ₹8/km (Bike) with tier multipliers, via Distance Matrix + haversine fallback
- **Phone OTP auth** — pluggable (AWS backend / MSG91 / AWS SNS), session persistence
- **Real-time ride matching & live tracking** over Socket.IO
- **Razorpay payments** — secure order + signature verification
- **Wallet, bookings history, profile** — all backed by real providers

Everything runs in **mock mode with zero keys**, and upgrades to real services as you add keys — see `SETUP_KEYS.md`.

---

## Architecture

```
lib/
├── main.dart                  # MultiProvider + state-machine navigator
├── core/
│   ├── config/app_config.dart # keys via --dart-define, feature flags, fare table
│   ├── utils/                 # fare calculator (haversine, ETA)
│   ├── theme/                 # colors, text styles, ThemeData
│   └── widgets/               # BikeJeeMap, shared UI components
├── data/
│   ├── models/                # User, Place, Ride, Driver, GeoPoint
│   ├── services/              # location, api_client, otp, places, socket, payment
│   └── repositories/          # auth, ride
├── providers/                 # Auth, Location, Ride, Wallet, Bookings (ChangeNotifier)
└── features/
    ├── auth/screens/          # splash, onboarding, role, login, otp
    ├── customer/screens/      # home, book, finding, tracking, completed, wallet…
    └── driver/screens/        # dashboard, subscription, ride flow, earnings…

backend/                       # Node.js + Express + Socket.IO (deploy to AWS EC2)
├── src/routes/                # auth, rides, payments
├── src/services/sms.js        # MSG91 / SNS / console
└── src/server.js
```

State management: **Provider (ChangeNotifier)**.

---

## Run (mock mode — no keys)
```bash
flutter pub get
flutter run            # or: flutter run -d chrome
```
OTP: any 4-digit code except `0000`.

## Run (production — real services)
See **`SETUP_KEYS.md`** for keys and **`DEPLOY.md`** for AWS deployment.
```bash
flutter run \
  --dart-define=API_BASE_URL=https://api.yourdomain.com \
  --dart-define=GOOGLE_MAPS_KEY=YOUR_KEY \
  --dart-define=RAZORPAY_KEY=rzp_live_xxx \
  -Pmaps.key=YOUR_KEY
```

---

## Docs
- `SETUP_KEYS.md` — how to obtain & inject Maps / backend / Razorpay keys
- `DEPLOY.md` — full AWS deployment (EC2 backend, S3/CloudFront web, app stores)
- `backend/README.md` — backend API reference & EC2 setup
