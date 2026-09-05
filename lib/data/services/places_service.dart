import 'package:dio/dio.dart';
import '../../core/config/app_config.dart';
import '../models/lat_lng.dart';
import '../models/place_model.dart';

/// Place search (autocomplete), place details (→ coordinates), and distance.
/// Uses Google Places + Distance Matrix when a key is set, else mock data.
class PlacesService {
  final Dio _dio = Dio();

  static const _placesBase =
      'https://maps.googleapis.com/maps/api/place';
  static const _distanceBase =
      'https://maps.googleapis.com/maps/api/distancematrix/json';

  // ── Mock catalogue used when no Maps key is configured ──────────────────
  static const List<PlaceModel> _mockPlaces = [
    PlaceModel(id: 'home', name: 'Home', address: 'Koramangala, Bangalore',
        type: 'home',
        location: GeoPoint(latitude: 12.9352, longitude: 77.6245)),
    PlaceModel(id: 'work', name: 'Work', address: 'Electronic City, Bangalore',
        type: 'work',
        location: GeoPoint(latitude: 12.8452, longitude: 77.6602)),
    PlaceModel(id: 'p1', name: 'Kempegowda Airport', address: 'Devanahalli',
        location: GeoPoint(latitude: 13.1986, longitude: 77.7066)),
    PlaceModel(id: 'p2', name: 'Whitefield', address: 'Whitefield Main Rd',
        location: GeoPoint(latitude: 12.9698, longitude: 77.7500)),
    PlaceModel(id: 'p3', name: 'Indiranagar', address: '100 Feet Road',
        location: GeoPoint(latitude: 12.9719, longitude: 77.6412)),
    PlaceModel(id: 'p4', name: 'HSR Layout', address: 'Sector 2',
        location: GeoPoint(latitude: 12.9116, longitude: 77.6446)),
    PlaceModel(id: 'p5', name: 'MG Road', address: 'MG Road, Bangalore',
        location: GeoPoint(latitude: 12.9756, longitude: 77.6068)),
    PlaceModel(id: 'p6', name: 'JP Nagar', address: '7th Phase',
        location: GeoPoint(latitude: 12.9077, longitude: 77.5851)),
    PlaceModel(id: 'p7', name: 'Forum Mall', address: 'Koramangala',
        location: GeoPoint(latitude: 12.9345, longitude: 77.6109)),
    PlaceModel(id: 'p8', name: 'Manyata Tech Park', address: 'Nagawara',
        location: GeoPoint(latitude: 13.0468, longitude: 77.6205)),
  ];

  /// Autocomplete search. Returns matching places.
  Future<List<PlaceModel>> search(String query, {GeoPoint? near}) async {
    if (!AppConfig.hasMapsKey) {
      await Future.delayed(const Duration(milliseconds: 150));
      if (query.trim().isEmpty) return _mockPlaces.take(6).toList();
      final q = query.toLowerCase();
      return _mockPlaces
          .where((p) =>
              p.name.toLowerCase().contains(q) ||
              p.address.toLowerCase().contains(q))
          .toList();
    }

    try {
      final res = await _dio.get('$_placesBase/autocomplete/json', queryParameters: {
        'input': query,
        'key': AppConfig.googleMapsKey,
        'components': 'country:in',
        if (near != null) 'location': '${near.latitude},${near.longitude}',
        if (near != null) 'radius': 50000,
      });
      final preds = (res.data['predictions'] as List?) ?? [];
      return preds.map((p) => PlaceModel(
            id: p['place_id'],
            name: p['structured_formatting']?['main_text'] ?? p['description'],
            address: p['structured_formatting']?['secondary_text'] ??
                p['description'],
            type: 'search',
          )).toList();
    } catch (_) {
      return [];
    }
  }

  /// Resolves a place's coordinates (needed after autocomplete selection).
  Future<PlaceModel> details(PlaceModel place) async {
    if (place.location != null) return place; // mock places already have coords
    if (!AppConfig.hasMapsKey) return place;

    try {
      final res = await _dio.get('$_placesBase/details/json', queryParameters: {
        'place_id': place.id,
        'key': AppConfig.googleMapsKey,
        'fields': 'geometry',
      });
      final loc = res.data['result']?['geometry']?['location'];
      if (loc != null) {
        return PlaceModel(
          id: place.id,
          name: place.name,
          address: place.address,
          type: place.type,
          location: GeoPoint(
            latitude: (loc['lat'] as num).toDouble(),
            longitude: (loc['lng'] as num).toDouble(),
          ),
        );
      }
    } catch (_) {}
    return place;
  }

  /// Real driving distance (km) between two points via Distance Matrix API.
  /// Returns null on failure so caller can fall back to haversine.
  Future<double?> drivingDistanceKm(GeoPoint origin, GeoPoint dest) async {
    if (!AppConfig.hasMapsKey) return null;
    try {
      final res = await _dio.get(_distanceBase, queryParameters: {
        'origins': '${origin.latitude},${origin.longitude}',
        'destinations': '${dest.latitude},${dest.longitude}',
        'key': AppConfig.googleMapsKey,
        'mode': 'driving',
      });
      final meters = res.data['rows']?[0]?['elements']?[0]?['distance']?['value'];
      if (meters != null) return (meters as num) / 1000.0;
    } catch (_) {}
    return null;
  }

  List<PlaceModel> get savedPlaces =>
      _mockPlaces.where((p) => p.type == 'home' || p.type == 'work').toList();
  List<PlaceModel> get recentPlaces => _mockPlaces.take(4).toList();
}
