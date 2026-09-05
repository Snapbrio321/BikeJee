import 'dart:async';
import 'dart:math' as math;
import '../../core/config/app_config.dart';
import '../models/lat_lng.dart';
import '../models/ride_model.dart';
import '../services/api_client.dart';
import '../services/socket_service.dart';

/// A live ride update pushed to the UI while a ride is active.
class RideUpdate {
  final RideStatus status;
  final DriverModel? driver;
  final GeoPoint? driverLocation;
  final int? etaMinutes;

  const RideUpdate({
    required this.status,
    this.driver,
    this.driverLocation,
    this.etaMinutes,
  });
}

/// Handles ride lifecycle: create → match driver → live track → complete.
/// Real backend + Socket.IO when configured, else a realistic mock simulation.
class RideRepository {
  final ApiClient _api = ApiClient.instance;
  final SocketService _socket = SocketService();

  StreamController<RideUpdate>? _updateCtrl;
  Timer? _mockTimer;

  /// Books a ride. Returns the created ride (with server id in real mode).
  Future<RideModel> createRide(RideModel ride) async {
    if (!AppConfig.hasBackend) {
      await Future.delayed(const Duration(milliseconds: 500));
      return ride; // mock: use the locally built ride
    }
    final res = await _api.post('/rides', data: ride.toJson());
    return RideModel.fromJson(res.data['ride'] ?? res.data);
  }

  /// Streams live updates for a ride (driver matched, location, status).
  Stream<RideUpdate> trackRide(RideModel ride) {
    _updateCtrl = StreamController<RideUpdate>.broadcast(
      onCancel: _stopTracking,
    );

    if (AppConfig.hasBackend) {
      _trackViaSocket(ride);
    } else {
      _trackViaMock(ride);
    }

    return _updateCtrl!.stream;
  }

  // ── Real-time via Socket.IO ─────────────────────────────────────────────
  void _trackViaSocket(RideModel ride) {
    _socket.connect();
    _socket.joinRide(ride.id);

    _socket.driverLocation.listen((loc) {
      _updateCtrl?.add(RideUpdate(
        status: RideStatus.arriving,
        driverLocation: loc,
      ));
    });

    _socket.rideStatus.listen((statusStr) {
      final status = RideStatus.values.firstWhere(
        (s) => s.name == statusStr,
        orElse: () => RideStatus.arriving,
      );
      _updateCtrl?.add(RideUpdate(status: status));
    });
  }

  // ── Mock simulation (no backend) ────────────────────────────────────────
  void _trackViaMock(RideModel ride) {
    final rng = math.Random();
    // Driver starts ~1.5km from pickup, moves toward pickup then drop
    final pickup = ride.pickup.location ??
        const GeoPoint(latitude: 12.9716, longitude: 77.5946);
    final drop = ride.drop.location ??
        const GeoPoint(latitude: 12.9352, longitude: 77.6245);

    var driverPos = GeoPoint(
      latitude: pickup.latitude + 0.012 + rng.nextDouble() * 0.005,
      longitude: pickup.longitude + 0.012 + rng.nextDouble() * 0.005,
    );

    final driver = DriverModel(
      id: 'd_1',
      name: 'Arjun Kumar',
      phone: '+91 98765-43210',
      vehicleName: 'Honda Activa',
      vehicleNumber: 'KA 03 JE 1234',
      rating: 4.8,
      location: driverPos,
    );

    int tick = 0;
    RideStatus status = RideStatus.searching;

    _mockTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      tick++;

      // 1. Searching for 3s
      if (tick == 3) {
        status = RideStatus.accepted;
        _updateCtrl?.add(RideUpdate(
          status: status, driver: driver, driverLocation: driverPos,
          etaMinutes: 3,
        ));
        return;
      }

      // 2. Driver approaching pickup (ticks 4–12)
      if (tick > 3 && tick <= 12) {
        status = RideStatus.arriving;
        driverPos = _moveToward(driverPos, pickup, 0.15);
        final eta = (12 - tick).clamp(1, 9);
        _updateCtrl?.add(RideUpdate(
          status: status, driver: driver, driverLocation: driverPos,
          etaMinutes: eta,
        ));
        return;
      }

      // 3. Arrived at pickup
      if (tick == 13) {
        status = RideStatus.arrived;
        _updateCtrl?.add(RideUpdate(
          status: status, driver: driver, driverLocation: pickup,
          etaMinutes: 0,
        ));
        return;
      }

      // 4. On trip toward drop (ticks 14–24)
      if (tick > 13 && tick <= 24) {
        status = RideStatus.onTrip;
        driverPos = _moveToward(driverPos, drop, 0.12);
        _updateCtrl?.add(RideUpdate(
          status: status, driver: driver, driverLocation: driverPos,
        ));
        return;
      }

      // 5. Completed
      if (tick >= 25) {
        status = RideStatus.completed;
        _updateCtrl?.add(RideUpdate(
          status: status, driver: driver, driverLocation: drop,
        ));
        t.cancel();
      }
    });

    // Initial searching emit
    _updateCtrl?.add(const RideUpdate(status: RideStatus.searching));
  }

  GeoPoint _moveToward(GeoPoint from, GeoPoint to, double fraction) {
    return GeoPoint(
      latitude: from.latitude + (to.latitude - from.latitude) * fraction,
      longitude: from.longitude + (to.longitude - from.longitude) * fraction,
    );
  }

  Future<void> cancelRide(String rideId) async {
    if (AppConfig.hasBackend) {
      try {
        await _api.post('/rides/$rideId/cancel');
      } catch (_) {}
    }
    _stopTracking();
  }

  void _stopTracking() {
    _mockTimer?.cancel();
    _mockTimer = null;
    _socket.disconnect();
  }

  void dispose() {
    _stopTracking();
    _updateCtrl?.close();
    _socket.dispose();
  }
}
