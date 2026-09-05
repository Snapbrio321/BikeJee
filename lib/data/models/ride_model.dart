import 'lat_lng.dart';
import 'place_model.dart';

enum RideStatus {
  searching,   // finding a driver
  accepted,    // driver assigned
  arriving,    // driver on the way to pickup
  arrived,     // driver at pickup
  onTrip,      // trip in progress
  completed,   // finished
  cancelled,   // cancelled by user or driver
}

enum ServiceType { bike, auto, cab, parcel }

enum RideTier { go, plus, premium }

extension RideStatusX on RideStatus {
  String get label {
    switch (this) {
      case RideStatus.searching: return 'Finding driver';
      case RideStatus.accepted:  return 'Driver assigned';
      case RideStatus.arriving:  return 'Driver arriving';
      case RideStatus.arrived:   return 'Driver at pickup';
      case RideStatus.onTrip:    return 'On trip';
      case RideStatus.completed: return 'Completed';
      case RideStatus.cancelled: return 'Cancelled';
    }
  }
}

extension ServiceTypeX on ServiceType {
  String get label {
    switch (this) {
      case ServiceType.bike:   return 'Bike';
      case ServiceType.auto:   return 'Auto';
      case ServiceType.cab:    return 'Cab';
      case ServiceType.parcel: return 'Parcel';
    }
  }

  static ServiceType fromString(String s) {
    switch (s.toLowerCase()) {
      case 'auto':   return ServiceType.auto;
      case 'cab':    return ServiceType.cab;
      case 'parcel': return ServiceType.parcel;
      default:       return ServiceType.bike;
    }
  }
}

class RideModel {
  final String id;
  final String customerId;
  final String? driverId;
  final PlaceModel pickup;
  final PlaceModel drop;
  final ServiceType serviceType;
  final RideTier tier;
  final double distanceKm;
  final int fare;
  final RideStatus status;
  final String paymentMethod;
  final GeoPoint? driverLocation; // live position for tracking
  final int? etaMinutes;
  final DateTime? createdAt;
  final DateTime? completedAt;
  final double? rating;

  const RideModel({
    required this.id,
    required this.customerId,
    this.driverId,
    required this.pickup,
    required this.drop,
    required this.serviceType,
    this.tier = RideTier.go,
    required this.distanceKm,
    required this.fare,
    this.status = RideStatus.searching,
    this.paymentMethod = 'Cash',
    this.driverLocation,
    this.etaMinutes,
    this.createdAt,
    this.completedAt,
    this.rating,
  });

  factory RideModel.fromJson(Map<String, dynamic> json) => RideModel(
        id: json['id']?.toString() ?? '',
        customerId: json['customerId']?.toString() ?? '',
        driverId: json['driverId']?.toString(),
        pickup: PlaceModel.fromJson(json['pickup'] ?? {}),
        drop: PlaceModel.fromJson(json['drop'] ?? {}),
        serviceType:
            ServiceTypeX.fromString(json['serviceType'] ?? 'bike'),
        tier: RideTier.values.firstWhere(
          (t) => t.name == json['tier'],
          orElse: () => RideTier.go,
        ),
        distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0.0,
        fare: json['fare'] ?? 0,
        status: RideStatus.values.firstWhere(
          (s) => s.name == json['status'],
          orElse: () => RideStatus.searching,
        ),
        paymentMethod: json['paymentMethod'] ?? 'Cash',
        driverLocation: json['driverLocation'] != null
            ? GeoPoint.fromJson(json['driverLocation'])
            : null,
        etaMinutes: json['etaMinutes'],
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'].toString())
            : null,
        completedAt: json['completedAt'] != null
            ? DateTime.tryParse(json['completedAt'].toString())
            : null,
        rating: (json['rating'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'customerId': customerId,
        'driverId': driverId,
        'pickup': pickup.toJson(),
        'drop': drop.toJson(),
        'serviceType': serviceType.name,
        'tier': tier.name,
        'distanceKm': distanceKm,
        'fare': fare,
        'status': status.name,
        'paymentMethod': paymentMethod,
        'driverLocation': driverLocation?.toJson(),
        'etaMinutes': etaMinutes,
        'createdAt': createdAt?.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
        'rating': rating,
      };

  RideModel copyWith({
    String? driverId,
    RideStatus? status,
    GeoPoint? driverLocation,
    int? etaMinutes,
    DateTime? completedAt,
    double? rating,
  }) =>
      RideModel(
        id: id,
        customerId: customerId,
        driverId: driverId ?? this.driverId,
        pickup: pickup,
        drop: drop,
        serviceType: serviceType,
        tier: tier,
        distanceKm: distanceKm,
        fare: fare,
        status: status ?? this.status,
        paymentMethod: paymentMethod,
        driverLocation: driverLocation ?? this.driverLocation,
        etaMinutes: etaMinutes ?? this.etaMinutes,
        createdAt: createdAt,
        completedAt: completedAt ?? this.completedAt,
        rating: rating ?? this.rating,
      );
}

class DriverModel {
  final String id;
  final String name;
  final String phone;
  final String vehicleName;
  final String vehicleNumber;
  final double rating;
  final GeoPoint location;
  final String? photoUrl;

  const DriverModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.vehicleName,
    required this.vehicleNumber,
    required this.rating,
    required this.location,
    this.photoUrl,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) => DriverModel(
        id: json['id']?.toString() ?? '',
        name: json['name'] ?? '',
        phone: json['phone'] ?? '',
        vehicleName: json['vehicleName'] ?? '',
        vehicleNumber: json['vehicleNumber'] ?? '',
        rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
        location: GeoPoint.fromJson(json['location'] ?? {'lat': 0, 'lng': 0}),
        photoUrl: json['photoUrl'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'vehicleName': vehicleName,
        'vehicleNumber': vehicleNumber,
        'rating': rating,
        'location': location.toJson(),
        'photoUrl': photoUrl,
      };
}
