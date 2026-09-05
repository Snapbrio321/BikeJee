# BikeJee — Production Build Script (Windows PowerShell)
# Usage: edit the keys below, then run:  ./build_production.ps1

# ── Fill in your production keys ─────────────────────────────────────────────
$API_BASE_URL   = "https://api.yourdomain.com"
$GOOGLE_MAPS_KEY = "YOUR_MAPS_KEY"
$RAZORPAY_KEY   = "rzp_live_xxxxx"

# ── Web build ────────────────────────────────────────────────────────────────
Write-Host "Building web..." -ForegroundColor Cyan
flutter build web --release `
  --dart-define=API_BASE_URL=$API_BASE_URL `
  --dart-define=GOOGLE_MAPS_KEY=$GOOGLE_MAPS_KEY `
  --dart-define=RAZORPAY_KEY=$RAZORPAY_KEY `
  --dart-define=PRODUCTION=true

# ── Android APK ────────────────────────────────────────────────────────────────
Write-Host "Building Android APK..." -ForegroundColor Cyan
flutter build apk --release `
  -Pmaps.key=$GOOGLE_MAPS_KEY `
  --dart-define=API_BASE_URL=$API_BASE_URL `
  --dart-define=GOOGLE_MAPS_KEY=$GOOGLE_MAPS_KEY `
  --dart-define=RAZORPAY_KEY=$RAZORPAY_KEY `
  --dart-define=PRODUCTION=true

Write-Host "Done. Outputs:" -ForegroundColor Green
Write-Host "  Web: build/web/"
Write-Host "  APK: build/app/outputs/flutter-apk/app-release.apk"
