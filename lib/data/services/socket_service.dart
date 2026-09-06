import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/config/app_config.dart';
import '../models/lat_lng.dart';

/// Real-time socket connection for live ride tracking (customer) and
/// driver availability / job dispatch (driver).
///
/// Authenticates with the same JWT as the REST API (backend reads
/// `handshake.auth.token`). No-ops gracefully when no backend is configured
/// (mock mode simulates behaviour in the repositories/providers instead).
class SocketService {
  io.Socket? _socket;

  // Customer-facing streams
  final _driverLocationCtrl = StreamController<GeoPoint>.broadcast();
  final _rideStatusCtrl = StreamController<String>.broadcast();

  // Driver-facing stream: incoming ride jobs (ride:new payloads)
  final _newRideCtrl = StreamController<Map<String, dynamic>>.broadcast();

  Stream<GeoPoint> get driverLocation => _driverLocationCtrl.stream;
  Stream<String> get rideStatus => _rideStatusCtrl.stream;
  Stream<Map<String, dynamic>> get newRide => _newRideCtrl.stream;

  bool get isConnected => _socket?.connected ?? false;

  /// Connects (once) with the stored JWT attached to the handshake so the
  /// backend can identify the driver and route jobs to their private room.
  Future<void> connect() async {
    if (!AppConfig.hasBackend || _socket != null) return;

    String? token;
    try {
      final prefs = await SharedPreferences.getInstance();
      token = prefs.getString('bikejee_token');
    } catch (_) {
      token = null;
    }

    _socket = io.io(
      AppConfig.apiBaseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth(token != null ? {'token': token} : {})
          .build(),
    );

    _socket!
      ..connect()
      ..on('ride:driverLocation', (data) {
        if (data is Map) {
          _driverLocationCtrl.add(GeoPoint(
            latitude: (data['lat'] as num).toDouble(),
            longitude: (data['lng'] as num).toDouble(),
          ));
        }
      })
      ..on('ride:status', (data) {
        if (data is Map && data['status'] != null) {
          _rideStatusCtrl.add(data['status'].toString());
        }
      })
      ..on('ride:new', (data) {
        if (data is Map) {
          _newRideCtrl.add(Map<String, dynamic>.from(data));
        }
      });
  }

  // ── Customer ────────────────────────────────────────────────────────────
  /// Customer subscribes to live updates for a ride.
  void joinRide(String rideId) {
    _socket?.emit('ride:join', {'rideId': rideId});
  }

  // ── Driver ──────────────────────────────────────────────────────────────
  /// Driver announces availability with a starting location so they appear
  /// in the matching pool (backend writes this to the Redis GEO index).
  void goOnline(GeoPoint p) {
    _socket?.emit('driver:online', {'lat': p.latitude, 'lng': p.longitude});
  }

  /// Driver goes off-duty (removed from the matching pool).
  void goOffline() {
    _socket?.emit('driver:offline', {});
  }

  /// Driver publishes its live location. When [rideId] is set it also fans out
  /// to the customer tracking that ride; always refreshes the geo index.
  void publishDriverLocation(GeoPoint p, {String? rideId}) {
    _socket?.emit('driver:location', {
      if (rideId != null) 'rideId': rideId,
      'lat': p.latitude,
      'lng': p.longitude,
    });
  }

  void disconnect() {
    _socket?.dispose();
    _socket = null;
  }

  void dispose() {
    disconnect();
    _driverLocationCtrl.close();
    _rideStatusCtrl.close();
    _newRideCtrl.close();
  }
}
