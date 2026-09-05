import 'package:geolocator/geolocator.dart';
import '../models/lat_lng.dart';

/// Wraps device GPS. Falls back to a default city location when permission is
/// denied or on web without geolocation.
class LocationService {
  // Default: Bangalore city center (used as fallback)
  static const GeoPoint _fallback =
      GeoPoint(latitude: 12.9716, longitude: 77.5946);

  /// Requests permission and returns the current position.
  Future<GeoPoint> getCurrentLocation() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) return _fallback;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return _fallback;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      return GeoPoint(latitude: pos.latitude, longitude: pos.longitude);
    } catch (_) {
      return _fallback;
    }
  }

  /// Streams live position updates (used for driver tracking / your own dot).
  Stream<GeoPoint> watchLocation() async* {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        yield _fallback;
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        yield _fallback;
        return;
      }

      yield* Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      ).map((p) => GeoPoint(latitude: p.latitude, longitude: p.longitude));
    } catch (_) {
      yield _fallback;
    }
  }
}
