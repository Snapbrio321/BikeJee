import 'package:flutter/foundation.dart';
import '../core/config/app_config.dart';
import '../data/models/place_model.dart';
import '../data/models/ride_model.dart';
import '../data/services/api_client.dart';

/// Loads and holds the user's ride/parcel booking history.
class BookingsProvider extends ChangeNotifier {
  final ApiClient _api = ApiClient.instance;

  List<RideModel> _bookings = [];
  bool _loading = false;

  List<RideModel> get bookings => List.unmodifiable(_bookings);
  bool get loading => _loading;

  List<RideModel> byService(ServiceType? type) =>
      type == null ? _bookings : _bookings.where((b) => b.serviceType == type).toList();

  Future<void> load() async {
    _loading = true;
    notifyListeners();

    if (AppConfig.hasBackend) {
      try {
        final res = await _api.get('/rides/history');
        final list = (res.data['rides'] as List?) ?? [];
        _bookings = list.map((r) => RideModel.fromJson(r)).toList();
      } catch (_) {
        _bookings = _mock();
      }
    } else {
      await Future.delayed(const Duration(milliseconds: 300));
      _bookings = _mock();
    }

    _loading = false;
    notifyListeners();
  }

  /// Adds a just-completed ride to the top of the history.
  void addCompleted(RideModel ride) {
    _bookings.insert(0, ride.copyWith(status: RideStatus.completed));
    notifyListeners();
  }

  List<RideModel> _mock() => [
        RideModel(
          id: '#BJ001', customerId: 'u1',
          pickup: const PlaceModel(id: '1', name: 'Koramangala', address: 'Koramangala, Bangalore'),
          drop: const PlaceModel(id: '2', name: 'MG Road', address: 'MG Road, Bangalore'),
          serviceType: ServiceType.bike, distanceKm: 4.2, fare: 45,
          status: RideStatus.completed, rating: 4.8,
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        RideModel(
          id: '#BJ002', customerId: 'u1',
          pickup: const PlaceModel(id: '3', name: 'Indiranagar', address: 'Indiranagar'),
          drop: const PlaceModel(id: '4', name: 'Airport', address: 'Kempegowda Airport'),
          serviceType: ServiceType.auto, distanceKm: 18.0, fare: 210,
          status: RideStatus.completed, rating: 4.5,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        RideModel(
          id: '#BJ003', customerId: 'u1',
          pickup: const PlaceModel(id: '5', name: 'HSR Layout', address: 'HSR Layout'),
          drop: const PlaceModel(id: '6', name: 'BTM Layout', address: 'BTM Layout'),
          serviceType: ServiceType.bike, distanceKm: 3.5, fare: 60,
          status: RideStatus.cancelled,
          createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
        ),
        RideModel(
          id: '#BJ004', customerId: 'u1',
          pickup: const PlaceModel(id: '7', name: 'Koramangala', address: 'Koramangala'),
          drop: const PlaceModel(id: '8', name: 'HSR Layout', address: 'HSR → BTM Layout'),
          serviceType: ServiceType.parcel, distanceKm: 5.0, fare: 50,
          status: RideStatus.completed, rating: 5.0,
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
        RideModel(
          id: '#BJ005', customerId: 'u1',
          pickup: const PlaceModel(id: '9', name: 'Whitefield', address: 'Whitefield'),
          drop: const PlaceModel(id: '10', name: 'Electronic City', address: 'Electronic City'),
          serviceType: ServiceType.bike, distanceKm: 22.0, fare: 120,
          status: RideStatus.completed, rating: 4.2,
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
      ];
}
