import 'dart:async';
import 'package:flutter/foundation.dart';
import '../data/models/lat_lng.dart';
import '../data/services/location_service.dart';

/// Holds the user's current GPS location and streams live updates.
class LocationProvider extends ChangeNotifier {
  final LocationService _service = LocationService();

  GeoPoint? _current;
  bool _loading = false;
  StreamSubscription<GeoPoint>? _sub;

  GeoPoint? get current => _current;
  bool get loading => _loading;
  bool get hasLocation => _current != null;

  /// One-shot fetch of the current location.
  Future<void> fetchOnce() async {
    _loading = true;
    notifyListeners();
    _current = await _service.getCurrentLocation();
    _loading = false;
    notifyListeners();
  }

  /// Begin streaming live location updates.
  void startTracking() {
    _sub?.cancel();
    _sub = _service.watchLocation().listen((point) {
      _current = point;
      notifyListeners();
    });
  }

  void stopTracking() {
    _sub?.cancel();
    _sub = null;
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
