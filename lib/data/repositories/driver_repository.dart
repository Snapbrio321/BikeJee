import 'dart:async';
import '../../core/config/app_config.dart';
import '../models/ride_model.dart';
import '../services/api_client.dart';

/// Aggregated dashboard numbers for the driver home screen.
class DriverStats {
  final int todayEarnings;
  final int ridesCompleted;
  final int incentives;
  final double cancellationRate;
  final List<RideModel> recentTrips;

  const DriverStats({
    this.todayEarnings = 0,
    this.ridesCompleted = 0,
    this.incentives = 0,
    this.cancellationRate = 0,
    this.recentTrips = const [],
  });
}

/// Backend calls for the driver flow. Real REST when a backend is configured,
/// else safe mock values so the UI still renders during development.
class DriverRepository {
  final ApiClient _api = ApiClient.instance;

  /// Accepts a dispatched ride. Backend atomically assigns it to this driver.
  Future<bool> acceptRide(String rideId) async {
    if (!AppConfig.hasBackend) return true;
    try {
      await _api.post('/rides/$rideId/accept');
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Declines a dispatched ride so it can be offered to another driver.
  Future<void> declineRide(String rideId) async {
    if (!AppConfig.hasBackend) return;
    try {
      await _api.post('/rides/$rideId/decline');
    } catch (_) {}
  }

  /// Marks the driver as arrived at the pickup point.
  Future<void> markArrived(String rideId) async {
    if (!AppConfig.hasBackend) return;
    try {
      await _api.post('/rides/$rideId/arrived');
    } catch (_) {}
  }

  /// Starts the trip (customer picked up).
  Future<void> startTrip(String rideId) async {
    if (!AppConfig.hasBackend) return;
    try {
      await _api.post('/rides/$rideId/start');
    } catch (_) {}
  }

  /// Completes the ride and finalizes fare / counters on the backend.
  Future<void> completeRide(String rideId) async {
    if (!AppConfig.hasBackend) return;
    try {
      await _api.post('/rides/$rideId/complete');
    } catch (_) {}
  }

  /// Loads today's dashboard stats. Falls back to seeded demo numbers.
  Future<DriverStats> loadStats() async {
    if (!AppConfig.hasBackend) return _mockStats();
    try {
      final res = await _api.get('/drivers/me/stats');
      final d = res.data as Map<String, dynamic>;
      final trips = (d['recentTrips'] as List? ?? [])
          .map((t) => RideModel.fromJson(t as Map<String, dynamic>))
          .toList();
      return DriverStats(
        todayEarnings: d['todayEarnings'] ?? 0,
        ridesCompleted: d['ridesCompleted'] ?? 0,
        incentives: d['incentives'] ?? 0,
        cancellationRate: (d['cancellationRate'] as num?)?.toDouble() ?? 0,
        recentTrips: trips,
      );
    } catch (_) {
      return const DriverStats();
    }
  }

  DriverStats _mockStats() => const DriverStats(
        todayEarnings: 1420,
        ridesCompleted: 12,
        incentives: 150,
        cancellationRate: 2,
        recentTrips: [],
      );
}
