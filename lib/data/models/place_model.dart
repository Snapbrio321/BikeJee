import 'lat_lng.dart';

/// A searchable/selectable place (pickup, drop, saved place, suggestion)
class PlaceModel {
  final String id;
  final String name;
  final String address;
  final GeoPoint? location;
  final String? type; // 'home' | 'work' | 'recent' | 'search'

  const PlaceModel({
    required this.id,
    required this.name,
    required this.address,
    this.location,
    this.type,
  });

  factory PlaceModel.fromJson(Map<String, dynamic> json) => PlaceModel(
        id: json['id']?.toString() ?? json['place_id']?.toString() ?? '',
        name: json['name'] ??
            json['structured_formatting']?['main_text'] ??
            '',
        address: json['address'] ??
            json['description'] ??
            json['formatted_address'] ??
            '',
        location: json['location'] != null
            ? GeoPoint.fromJson(json['location'])
            : null,
        type: json['type'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'address': address,
        'location': location?.toJson(),
        'type': type,
      };
}
