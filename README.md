# BikeJee Flutter App

**Ride Fast. Deliver Smart.**

A complete, production-ready Flutter application for both Android and iOS — built from the BikeJee design system. The app ships two experiences in a single codebase: a **Customer App** and a **Driver Partner App**, switchable at launch via a role-selection screen.

---

## Quick Start

```bash
# Install dependencies
flutter pub get

# Run on a connected device / emulator
flutter run

# Build Android APK (debug)
flutter build apk --debug

# Build iOS (requires macOS + Xcode)
flutter build ios --debug
```

---

## Project Structure

```
lib/
├── main.dart                          # App entry point + state-machine navigator
├── core/
│   ├── constants/
│   │   ├── app_colors.dart            # Brand color palette
│   │   ├── app_constants.dart         # Spacing, radius, icon sizes
│   │   └── app_text_styles.dart       # Typography scale
│   ├── theme/
│   │   └── app_theme.dart             # MaterialApp ThemeData
│   └── widgets/                       # Shared reusable components
│       ├── app_bottom_nav.dart        # Customer & Driver bottom navbars
│       ├── app_button.dart            # AppButton, AppGradientButton
│       ├── app_card.dart              # AppCard, ServiceCard, RideOptionCard…
│       ├── app_map_placeholder.dart   # Animated map with route drawing
│       ├── app_text_field.dart        # AppTextField, LocationTextField
│       ├── app_widgets.dart           # Barrel export
│       ├── bikejee_logo.dart          # BikeJeeLogo, BikeJeeLogoCenter
│       ├── rating_stars.dart          # RatingStars, TappableRatingStars
│       └── step_indicator.dart        # StepProgressIndicator, RouteTimeline
│
├── features/
│   ├── auth/screens/
│   │   ├── splash_screen.dart         # Animated city-skyline splash
│   │   ├── onboarding_screen.dart     # 4-page floating-icon onboarding
│   │   ├── role_select_screen.dart    # Customer vs Driver picker
│   │   ├── login_screen.dart          # Phone + country code + social login
│   │   └── otp_screen.dart            # 4-digit OTP with shake animation
│   │
│   ├── customer/screens/
│   │   ├── customer_shell.dart        # Bottom-nav shell + flow routing
│   │   ├── home_screen.dart           # Home with SliverAppBar, services, promos
│   │   ├── ride_options_screen.dart   # Service selector (Bike/Auto/Parcel/Cab)
│   │   ├── book_ride_screen.dart      # Fullscreen map + draggable booking sheet
│   │   ├── finding_driver_screen.dart # Radar pulse animation + driver card
│   │   ├── live_tracking_screen.dart  # Real-time ETA tracking with state machine
│   │   ├── ride_completed_screen.dart # Confetti + fare breakdown + rating
│   │   ├── my_bookings_screen.dart    # Tabbed booking history
│   │   ├── parcel_delivery_screen.dart# Parcel booking flow
│   │   ├── parcel_tracking_screen.dart# Live parcel tracking timeline
│   │   ├── offers_screen.dart         # Tabbed offers with copy-code
│   │   ├── wallet_screen.dart         # Wallet with animated balance counter
│   │   ├── payments_screen.dart       # Payment method selector
│   │   ├── profile_screen.dart        # Profile with stats & menu sections
│   │   └── help_support_screen.dart   # FAQ accordion + chat with us
│   │
│   └── driver/screens/
│       ├── driver_shell.dart          # Driver bottom-nav shell
│       ├── driver_welcome_screen.dart # Dark hero with floating bike animation
│       ├── driver_create_profile_screen.dart # Step-indicator profile setup
│       ├── driver_dashboard_screen.dart # Online toggle + stats + ride request overlay
│       ├── driver_subscription_screen.dart  # 3-plan selector → payment → success
│       ├── driver_ride_flow_screen.dart     # 4-state ride flow (pickup→trip→done)
│       ├── driver_earnings_screen.dart      # Bar chart + Daily/Weekly/Monthly tabs
│       ├── driver_wallet_screen.dart        # Driver wallet with withdraw sheet
│       └── driver_profile_screen.dart       # 4-tab profile (Profile/Vehicle/Docs/Settings)
```

---

## Features

### Customer App
| Screen | Highlights |
|--------|-----------|
| Splash | Animated city skyline + elastic logo scale |
| Onboarding | 4 floating-icon pages, smooth page dots |
| Home | SliverAppBar, service grid, promo banners, safe-rides section |
| Ride Booking | Full-screen map, draggable sheet, 3 ride tiers, payment picker |
| Finding Driver | Radar pulse animation, 20-second countdown |
| Live Tracking | ETA ticker, on_way → arriving → completed states |
| Ride Completed | Confetti CustomPainter, 5-star rating, tip selector |
| Parcel | Type picker, weight selector, fare estimate |
| Parcel Tracking | Animated timeline steps, live progress simulation |
| Offers | Copy-to-clipboard codes, HOT DEAL badges |
| Wallet | Animated balance counter, quick-add amounts |
| Payments | Radio-button method selector, UPI ID input |
| Profile | Gradient header, stats row, grouped menu |
| Help & Support | Search bar, FAQ accordion, live chat CTA |

### Driver Partner App
| Screen | Highlights |
|--------|-----------|
| Welcome | Dark gradient, floating bike, perks row |
| Dashboard | Animated online/offline toggle, new-ride overlay with countdown |
| Subscription | 3-plan flow (Daily ₹39 / Weekly / Monthly) → payment → success |
| Ride Flow | 4-state machine: to-pickup → arrived → on-trip → completed |
| Earnings | Animated bar chart, Daily/Weekly/Monthly history |
| Wallet | Dark card, add money + withdraw sheets |
| Profile | Vehicle info, document verification status, settings with toggles |

---

## Design System

- **Primary:** `#FF6B00` (BikeJee Orange)
- **Secondary:** `#1A1A2E` (Deep Navy)  
- **Success:** `#00C853` (Green)
- **Font:** Poppins (via `google_fonts`)
- **Components:** All custom — no third-party UI libraries
- **Animations:** Flutter's built-in `AnimationController`, `CustomPainter`, `AnimatedSwitcher`

---

## Navigation

The app uses a single `AppNavigator` state machine in `main.dart` — no external routing library. All screen transitions are handled by `AnimatedSwitcher` with fade transitions. Each shell (`CustomerShell`, `DriverShell`) manages its own internal flow state.

---

## Adding Real Functionality

| Feature | What to add |
|---------|------------|
| Maps | Replace `AppMapPlaceholder` with `google_maps_flutter` + API key |
| Auth | Replace fake OTP delays with Firebase Auth / custom backend |
| Payments | Integrate Razorpay / Stripe SDK |
| Real-time tracking | Add Firebase Realtime DB or WebSocket service |
| Push notifications | Add `firebase_messaging` |
| State management | Wrap shells with `Provider` / `Riverpod` / `Bloc` |
