import 'dart:math' as math;
import '../config/app_config.dart';
import '../../data/models/lat_lng.dart';
import '../../data/models/ride_model.dart';

/// Computes distances and fares. In production the server is authoritative,
/// but this gives instant client-side estimates (like Rapido shows upfront).
class FareCalculator {
  /// Haversine distance in kilometres between two geo points.
  static double distanceKm(GeoPoint a, GeoPoint b) {
    const earthRadius = 6371.0; // km
    final dLat = _rad(b.latitude - a.latitude);
    final dLng = _rad(b.longitude - a.longitude);
    final lat1 = _rad(a.latitude);
    final lat2 = _rad(b.latitude);

    final h = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) * math.cos(lat2) *
            math.sin(dLng / 2) * math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(h), math.sqrt(1 - h));
    return earthRadius * c;
  }

  static double _rad(double deg) => deg * (math.pi / 180.0);

  /// Fare = (base + perKm × distance) × tierMultiplier × surge, clamped to min.
  static int fare({
    required ServiceType service,
    required RideTier tier,
    required double distanceKm,
    double surge = 1.0,
  }) {
    final cfg = AppConfig.fareTable[service.name] ??
        AppConfig.fareTable['bike']!;
    final base = cfg['base']!;
    final perKm = cfg['perKm']!;
    final min = cfg['min']!;
    final mult = AppConfig.tierMultiplier[tier.name] ?? 1.0;

    final raw = (base + perKm * distanceKm) * mult * surge;
    return (raw < min ? min : raw).round();
  }

  /// Rough ETA in minutes assuming ~22 km/h average city speed.
  static int etaMinutes(double distanceKm) {
    final mins = (distanceKm / 22.0) * 60.0;
    return mins.ceil().clamp(1, 240);
  }
}
