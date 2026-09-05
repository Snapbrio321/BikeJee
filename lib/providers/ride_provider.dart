import 'dart:async';
import 'package:flutter/foundation.dart';
import '../core/utils/fare_calculator.dart';
import '../data/models/lat_lng.dart';
import '../data/models/place_model.dart';
import '../data/models/ride_model.dart';
import '../data/services/places_service.dart';
import '../data/repositories/ride_repository.dart';

/// A fare quote for one tier.
class FareQuote {
  final RideTier tier;
  final String name;
  final int fare;
  final int etaMinutes;
  final double perKm;

  const FareQuote({
    required this.tier,
    required this.name,
    required this.fare,
    required this.etaMinutes,
    required this.perKm,
  });
}

/// Holds the current booking: pickup, drop, distance, computed fares, tier.
/// Also manages the active-ride lifecycle (create + live tracking).
class RideProvider extends ChangeNotifier {
  final PlacesService _places = PlacesService();
  final RideRepository _rideRepo = RideRepository();

  PlaceModel? _pickup;
  PlaceModel? _drop;
  ServiceType _service = ServiceType.bike;
  RideTier _tier = RideTier.go;
  String _payment = 'Cash';
  double _distanceKm = 0;
  double _surge = 1.0;
  bool _calculating = false;

  // ── Active ride state ─────────────────────────────────────────────────
  RideModel? _activeRide;
  RideStatus _rideStatus = RideStatus.searching;
  DriverModel? _matchedDriver;
  GeoPoint? _driverLocation;
  int? _etaMinutes;
  StreamSubscription<RideUpdate>? _trackSub;

  RideModel? get activeRide => _activeRide;
  RideStatus get rideStatus => _rideStatus;
  DriverModel? get matchedDriver => _matchedDriver;
  GeoPoint? get driverLocation => _driverLocation;
  int? get etaMinutes => _etaMinutes;

  // getters
  PlaceModel? get pickup => _pickup;
  PlaceModel? get drop => _drop;
  ServiceType get service => _service;
  RideTier get tier => _tier;
  String get payment => _payment;
  double get distanceKm => _distanceKm;
  double get surge => _surge;
  bool get calculating => _calculating;
  bool get isSurge => _surge > 1.0;
  bool get hasRoute => _pickup?.location != null && _drop?.location != null;

  PlacesService get placesService => _places;

  // ── Setters ────────────────────────────────────────────────────────────
  void setService(ServiceType s) {
    _service = s;
    notifyListeners();
  }

  void setTier(RideTier t) {
    _tier = t;
    notifyListeners();
  }

  void setPayment(String p) {
    _payment = p;
    notifyListeners();
  }

  Future<void> setPickup(PlaceModel place) async {
    _pickup = await _places.details(place);
    await _recalculate();
  }

  Future<void> setPickupFromLocation(GeoPoint loc) async {
    _pickup = PlaceModel(
      id: 'current',
      name: 'Current Location',
      address: 'Your location',
      location: loc,
      type: 'current',
    );
    await _recalculate();
  }

  Future<void> setDrop(PlaceModel place) async {
    _drop = await _places.details(place);
    await _recalculate();
  }

  /// Recomputes distance + fares whenever pickup/drop changes.
  Future<void> _recalculate() async {
    if (_pickup?.location == null || _drop?.location == null) {
      notifyListeners();
      return;
    }
    _calculating = true;
    notifyListeners();

    // Try real driving distance, fall back to haversine
    final real = await _places.drivingDistanceKm(
      _pickup!.location!,
      _drop!.location!,
    );
    _distanceKm = real ??
        FareCalculator.distanceKm(_pickup!.location!, _drop!.location!);

    // Simple surge simulation: >1.2x during peak-ish random condition
    _surge = _computeSurge();

    _calculating = false;
    notifyListeners();
  }

  double _computeSurge() {
    final hour = DateTime.now().hour;
    // Morning (8–11) and evening (17–21) peak
    if ((hour >= 8 && hour <= 11) || (hour >= 17 && hour <= 21)) {
      return 1.2;
    }
    return 1.0;
  }

  /// All tier quotes for the current service + distance.
  List<FareQuote> get quotes {
    final km = _distanceKm > 0 ? _distanceKm : 3.0; // preview when no route
    return [
      FareQuote(
        tier: RideTier.go,
        name: '${_service.label} Go',
        fare: FareCalculator.fare(
            service: _service, tier: RideTier.go, distanceKm: km, surge: _surge),
        etaMinutes: FareCalculator.etaMinutes(km),
        perKm: 8,
      ),
      FareQuote(
        tier: RideTier.plus,
        name: '${_service.label} Plus',
        fare: FareCalculator.fare(
            service: _service, tier: RideTier.plus, distanceKm: km, surge: _surge),
        etaMinutes: FareCalculator.etaMinutes(km) + 2,
        perKm: 11,
      ),
      FareQuote(
        tier: RideTier.premium,
        name: '${_service.label} Premium',
        fare: FareCalculator.fare(
            service: _service, tier: RideTier.premium, distanceKm: km, surge: _surge),
        etaMinutes: FareCalculator.etaMinutes(km) + 4,
        perKm: 14,
      ),
    ];
  }

  /// The fare for the currently selected tier.
  int get selectedFare {
    final km = _distanceKm > 0 ? _distanceKm : 3.0;
    return FareCalculator.fare(
      service: _service,
      tier: _tier,
      distanceKm: km,
      surge: _surge,
    );
  }

  /// Builds the RideModel to submit when the user taps Book.
  RideModel buildRide(String customerId) {
    return RideModel(
      id: 'r_${DateTime.now().millisecondsSinceEpoch}',
      customerId: customerId,
      pickup: _pickup ??
          const PlaceModel(id: 'current', name: 'Current Location', address: ''),
      drop: _drop ??
          const PlaceModel(id: 'drop', name: 'Destination', address: ''),
      serviceType: _service,
      tier: _tier,
      distanceKm: _distanceKm,
      fare: selectedFare,
      paymentMethod: _payment,
      createdAt: DateTime.now(),
    );
  }

  // ── Ride lifecycle ──────────────────────────────────────────────────────

  /// Books the ride and starts live tracking. Call when user taps "Book".
  Future<void> bookRide(String customerId) async {
    final ride = buildRide(customerId);
    _activeRide = await _rideRepo.createRide(ride);
    _rideStatus = RideStatus.searching;
    _matchedDriver = null;
    _driverLocation = null;
    _etaMinutes = null;
    notifyListeners();

    _trackSub?.cancel();
    _trackSub = _rideRepo.trackRide(_activeRide!).listen((update) {
      _rideStatus = update.status;
      if (update.driver != null) _matchedDriver = update.driver;
      if (update.driverLocation != null) _driverLocation = update.driverLocation;
      if (update.etaMinutes != null) _etaMinutes = update.etaMinutes;
      notifyListeners();
    });
  }

  /// Cancels the active ride.
  Future<void> cancelRide() async {
    if (_activeRide != null) {
      await _rideRepo.cancelRide(_activeRide!.id);
    }
    _trackSub?.cancel();
    _clearActiveRide();
  }

  void _clearActiveRide() {
    _activeRide = null;
    _rideStatus = RideStatus.searching;
    _matchedDriver = null;
    _driverLocation = null;
    _etaMinutes = null;
    notifyListeners();
  }

  void reset() {
    _trackSub?.cancel();
    _pickup = null;
    _drop = null;
    _tier = RideTier.go;
    _distanceKm = 0;
    _surge = 1.0;
    _clearActiveRide();
  }

  @override
  void dispose() {
    _trackSub?.cancel();
    _rideRepo.dispose();
    super.dispose();
  }
}
