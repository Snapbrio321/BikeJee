enum UserRole { customer, driver }

class UserModel {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? photoUrl;
  final UserRole role;
  final bool isVerified;
  final double rating;
  final int totalRides;
  final double walletBalance;
  final DateTime? createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.photoUrl,
    this.role = UserRole.customer,
    this.isVerified = false,
    this.rating = 0.0,
    this.totalRides = 0,
    this.walletBalance = 0.0,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id']?.toString() ?? '',
        name: json['name'] ?? '',
        phone: json['phone'] ?? '',
        email: json['email'],
        photoUrl: json['photoUrl'],
        role: (json['role'] == 'driver')
            ? UserRole.driver
            : UserRole.customer,
        isVerified: json['isVerified'] ?? false,
        rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
        totalRides: json['totalRides'] ?? 0,
        walletBalance: (json['walletBalance'] as num?)?.toDouble() ?? 0.0,
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'].toString())
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'email': email,
        'photoUrl': photoUrl,
        'role': role.name,
        'isVerified': isVerified,
        'rating': rating,
        'totalRides': totalRides,
        'walletBalance': walletBalance,
        'createdAt': createdAt?.toIso8601String(),
      };

  UserModel copyWith({
    String? name,
    String? email,
    String? photoUrl,
    bool? isVerified,
    double? rating,
    int? totalRides,
    double? walletBalance,
  }) =>
      UserModel(
        id: id,
        name: name ?? this.name,
        phone: phone,
        email: email ?? this.email,
        photoUrl: photoUrl ?? this.photoUrl,
        role: role,
        isVerified: isVerified ?? this.isVerified,
        rating: rating ?? this.rating,
        totalRides: totalRides ?? this.totalRides,
        walletBalance: walletBalance ?? this.walletBalance,
        createdAt: createdAt,
      );
}
