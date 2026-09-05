/// A simple lat/lng pair — decoupled from google_maps so models stay pure.
class GeoPoint {
  final double latitude;
  final double longitude;

  const GeoPoint({required this.latitude, required this.longitude});

  factory GeoPoint.fromJson(Map<String, dynamic> json) => GeoPoint(
        latitude: (json['lat'] ?? json['latitude'] as num).toDouble(),
        longitude: (json['lng'] ?? json['longitude'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'lat': latitude,
        'lng': longitude,
      };

  @override
  String toString() => '($latitude, $longitude)';
}
