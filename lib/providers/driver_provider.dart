import 'dart:async';
import 'package:flutter/foundation.dart';
import '../core/config/app_config.dart';
import '../data/models/lat_lng.dart';
import '../data/models/place_model.dart';
import '../data/models/ride_model.dart';
import '../data/repositories/driver_repository.dart';
import '../data/services/location_service.dart';
import '../data/services/socket_service.dart';

/// Drives the driver-side experience end-to-end:
/// online/offline, GPS heartbeat into the matching pool, incoming ride jobs
/// (via the `ride:new` socket event), and the accept → arrive → start →
/// complete ride flow. Pushes live location to the customer while on a ride.
///
/// Real backend + Socket.IO when configured; a self-contained mock simulation
/// otherwise so the driver UI is fully usable in development.
class DriverProvider extends ChangeNotifier {
  final DriverRepository _repo = DriverRepository();
  final SocketService _socket = SocketService();
  final LocationService _location = LocationService();

  bool _isOnline = false;
  bool _busy = false;
  GeoPoint? _currentLocation;
  DriverStats _stats = const DriverStats();

  RideModel? _incomingRide; // a dispatched job awaiting accept/decline
  RideModel? _activeRide;   // the ride currently being served

  StreamSubscription<GeoPoint>? _locSub;
  StreamSubscription<Map<String, dynamic>>? _newRideSub;
  Timer? _mockDispatchTimer;

  // ── Getters ───────────────────────────────────────────────────────────────
  bool get isOnline => _isOnline;
  bool get busy => _busy;
  GeoPoint? get currentLocation => _currentLocation;
  DriverStats get stats => _stats;
  RideModel? get incomingRide => _incomingRide;
  RideModel? get activeRide => _activeRide;
  bool get hasIncoming => _incomingRide != null;
  bool get hasActive => _activeRide != null;

  // ── Lifecycle ──────────────────────────────────────────────────────────────
  Future<void> init() async {
    _stats = await _repo.loadStats();
    if (AppConfig.hasBackend) {
      await _socket.connect();
      _newRideSub = _socket.newRide.listen(_onDispatchedRide);
    }
    notifyListeners();
  }

  /// Go online: fetch location, announce availability, start the GPS heartbeat
  /// so the driver stays in the matching pool.
  Future<void> goOnline() async {
    if (_isOnline) return;
    _busy = true;
    notifyListeners();

    _currentLocation = await _location.getCurrentLocation();
    _isOnline = true;
    _busy = false;

    if (AppConfig.hasBackend) {
      await _socket.connect();
      _socket.goOnline(_currentLocation!);
      // Heartbeat: push location as the device moves.
      _locSub = _location.watchLocation().listen((p) {
        _currentLocation = p;
        _socket.publishDriverLocation(p, rideId: _activeRide?.id);
      });
    } else {
      _startMockDispatch();
    }
    notifyListeners();
  }

  /// Go offline: leave the matching pool, stop the heartbeat.
  Future<void> goOffline() async {
    if (!_isOnline) return;
    _isOnline = false;
    _incomingRide = null;
    if (AppConfig.hasBackend) {
      _socket.goOffline();
      await _locSub?.cancel();
      _locSub = null;
    } else {
      _mockDispatchTimer?.cancel();
    }
    notifyListeners();
  }

  // ── Incoming job ────────────────────────────────────────────────────────────
  void _onDispatchedRide(Map<String, dynamic> data) {
    // Ignore new offers while already serving a ride.
    if (_activeRide != null) return;
    try {
      _incomingRide = RideModel.fromJson(data);
      notifyListeners();
    } catch (_) {/* malformed payload — ignore */}
  }

  /// Accept the dispatched ride → it becomes the active ride.
  Future<bool> acceptIncoming() async {
    final ride = _incomingRide;
    if (ride == null) return false;
    final ok = await _repo.acceptRide(ride.id);
    if (ok) {
      _activeRide = ride.copyWith(status: RideStatus.accepted);
      _incomingRide = null;
      notifyListeners();
    }
    return ok;
  }

  /// Decline the dispatched ride so it goes back to matching.
  Future<void> declineIncoming() async {
    final ride = _incomingRide;
    _incomingRide = null;
    notifyListeners();
    if (ride != null) await _repo.declineRide(ride.id);
  }

  // ── Active ride transitions (push status to backend + customer) ─────────────
  Future<void> markArrived() async {
    if (_activeRide == null) return;
    _activeRide = _activeRide!.copyWith(status: RideStatus.arrived);
    notifyListeners();
    await _repo.markArrived(_activeRide!.id);
  }

  Future<void> startTrip() async {
    if (_activeRide == null) return;
    _activeRide = _activeRide!.copyWith(status: RideStatus.onTrip);
    notifyListeners();
    await _repo.startTrip(_activeRide!.id);
  }

  /// End the trip: mark completed on the backend and locally flip status to
  /// completed (keeps the ride so the completion sheet can render).
  Future<void> completeRide() async {
    final ride = _activeRide;
    if (ride == null) return;
    _activeRide = ride.copyWith(status: RideStatus.completed);
    notifyListeners();
    await _repo.completeRide(ride.id);
  }

  /// Dismiss the completed ride and refresh dashboard numbers.
  Future<void> finishRide() async {
    _activeRide = null;
    _stats = await _repo.loadStats();
    notifyListeners();
  }

  // ── Mock dispatch (no backend) ──────────────────────────────────────────────
  void _startMockDispatch() {
    _mockDispatchTimer?.cancel();
    // Offer a simulated ride ~4s after going online.
    _mockDispatchTimer = Timer(const Duration(seconds: 4), () {
      if (!_isOnline || _activeRide != null) return;
      _incomingRide = _mockRide();
      notifyListeners();
    });
  }

  RideModel _mockRide() => RideModel(
        id: 'r_mock_${DateTime.now().millisecondsSinceEpoch}',
        customerId: 'c_mock',
        pickup: _mockPlace('Koramangala, Bangalore', 12.9352, 77.6245),
        drop: _mockPlace('MG Road, Bangalore', 12.9758, 77.6096),
        serviceType: ServiceType.bike,
        distanceKm: 5.2,
        fare: 45,
        status: RideStatus.searching,
      );

  PlaceModel _mockPlace(String name, double lat, double lng) => PlaceModel(
        id: name,
        name: name,
        address: name,
        location: GeoPoint(latitude: lat, longitude: lng),
      );

  @override
  void dispose() {
    _locSub?.cancel();
    _newRideSub?.cancel();
    _mockDispatchTimer?.cancel();
    _socket.dispose();
    super.dispose();
  }
}
