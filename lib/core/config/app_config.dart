/// Central config for API keys, backend URLs, and environment flags.
///
/// In production, prefer passing these via --dart-define at build time:
///   flutter build web --dart-define=GOOGLE_MAPS_KEY=xxx --dart-define=API_BASE_URL=https://api.bikejee.com
///
/// For now they default to placeholders so the app runs; the service layer
/// falls back to local/mock behaviour when keys are absent.
class AppConfig {
  // ── Environment ───────────────────────────────────────────────────────────
  static const bool isProduction =
      bool.fromEnvironment('PRODUCTION', defaultValue: false);

  // ── Backend API ───────────────────────────────────────────────────────────
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '', // empty → services run in mock/local mode
  );

  // ── Google Maps / Places / Distance Matrix ───────────────────────────────
  static const String googleMapsKey = String.fromEnvironment(
    'GOOGLE_MAPS_KEY',
    defaultValue: '', // empty → map falls back to painted placeholder
  );

  // ── Razorpay ──────────────────────────────────────────────────────────────
  static const String razorpayKey = String.fromEnvironment(
    'RAZORPAY_KEY',
    defaultValue: '',
  );

  // ── Feature flags — flip these on as each backend piece goes live ─────────
  static bool get hasBackend  => apiBaseUrl.isNotEmpty;
  static bool get hasMapsKey  => googleMapsKey.isNotEmpty;
  static bool get hasPayments => razorpayKey.isNotEmpty;

  // ── Fare configuration (server-authoritative in production) ───────────────
  static const Map<String, Map<String, double>> fareTable = {
    'bike': {'base': 20, 'perKm': 8,  'min': 30},
    'auto': {'base': 30, 'perKm': 12, 'min': 45},
    'cab':  {'base': 50, 'perKm': 15, 'min': 80},
    'parcel': {'base': 25, 'perKm': 9, 'min': 40},
  };

  // Tier multipliers on top of the base service rate
  static const Map<String, double> tierMultiplier = {
    'go': 1.0,
    'plus': 1.35,
    'premium': 1.7,
  };

  // App meta
  static const String appName = 'BikeJee';
  static const String supportPhone = '080 1234 5678';
}
