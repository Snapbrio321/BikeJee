import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../core/config/app_config.dart';
import '../models/lat_lng.dart';

/// Real-time socket connection for live ride tracking.
/// No-ops gracefully when no backend is configured (mock mode simulates
/// movement instead — see RideRepository).
class SocketService {
  io.Socket? _socket;

  final _driverLocationCtrl = StreamController<GeoPoint>.broadcast();
  final _rideStatusCtrl = StreamController<String>.broadcast();

  Stream<GeoPoint> get driverLocation => _driverLocationCtrl.stream;
  Stream<String> get rideStatus => _rideStatusCtrl.stream;

  bool get isConnected => _socket?.connected ?? false;

  void connect() {
    if (!AppConfig.hasBackend || _socket != null) return;

    _socket = io.io(
      AppConfig.apiBaseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
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
      });
  }

  /// Customer subscribes to live updates for a ride.
  void joinRide(String rideId) {
    _socket?.emit('ride:join', {'rideId': rideId});
  }

  /// Driver publishes its live location.
  void publishDriverLocation(String rideId, GeoPoint p) {
    _socket?.emit('driver:location', {
      'rideId': rideId,
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
  }
}
