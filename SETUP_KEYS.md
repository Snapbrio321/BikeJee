# BikeJee — Production Keys & Setup Guide

The app runs **fully in mock mode** with no keys. Add keys below to switch on real features one at a time.

---

## 1. Google Maps + GPS (Step 2)

Get a key from **Google Cloud Console** → enable these APIs:
- Maps SDK for Android
- Maps SDK for iOS
- Maps JavaScript API (for web)
- Places API (for search — Step 3)
- Distance Matrix API (for fares — Step 3)

### Android
```bash
flutter run -Pmaps.key=YOUR_KEY
# or build:
flutter build apk -Pmaps.key=YOUR_KEY
```
(Reads into `manifestPlaceholders["MAPS_API_KEY"]` in `android/app/build.gradle.kts`)

### iOS
Add to `ios/Runner/AppDelegate.swift`:
```swift
import GoogleMaps
// in application(_:didFinishLaunchingWithOptions:)
GMSServices.provideAPIKey("YOUR_KEY")
```

### Web
Uncomment the maps `<script>` in `web/index.html` and paste your key.

### Flutter runtime flag (enables map switch in AppConfig)
```bash
flutter run --dart-define=GOOGLE_MAPS_KEY=YOUR_KEY -Pmaps.key=YOUR_KEY
```

---

## 2. Backend API (Steps 4, 5, 7)
```bash
flutter run --dart-define=API_BASE_URL=https://api.yourdomain.com
```
When set, `AppConfig.hasBackend` becomes true and repositories call the real API instead of mock data.

---

## 3. Razorpay Payments (Step 6)

### App side
```bash
flutter run --dart-define=RAZORPAY_KEY=rzp_live_xxxxx --dart-define=API_BASE_URL=https://api.bikejee.com
```
(App uses the key to open checkout; the backend creates the order & verifies the signature.)

### Backend side (backend/.env)
```
RAZORPAY_KEY_ID=rzp_live_xxxxx
RAZORPAY_KEY_SECRET=your_secret
```
Endpoints added:
- `POST /payments/create-order` → `{ orderId }`
- `POST /payments/verify` → `{ verified: true|false }` (HMAC-SHA256 signature check)

Without keys, payments run in **mock mode** — checkout is simulated and always succeeds, so the wallet/ride flow is testable end-to-end.

---

## Full production run (all keys)
```bash
flutter run \
  --dart-define=GOOGLE_MAPS_KEY=YOUR_MAPS_KEY \
  --dart-define=API_BASE_URL=https://api.bikejee.com \
  --dart-define=RAZORPAY_KEY=rzp_live_xxxxx \
  --dart-define=PRODUCTION=true \
  -Pmaps.key=YOUR_MAPS_KEY
```
