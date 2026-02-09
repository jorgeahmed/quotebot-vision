import '../../domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.userId,
    required super.name,
    required super.email,
    super.phone,
    super.address,
    super.companyName,
    super.avatarUrl,
    required super.availableRoles,
    required super.activeRole,
    super.isVerified,
    required super.createdAt,
    super.lastUpdated,
  });

  /// Create UserProfileModel from JSON
  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      userId: json['userId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      companyName: json['companyName'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      availableRoles: (json['availableRoles'] as List? ?? [])
          .map((role) => _roleFromString(role as String))
          .toList(),
      activeRole: _roleFromString(json['activeRole'] as String? ?? 'client'),
      isVerified: json['isVerified'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : null,
    );
  }

  /// Convert UserProfileModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'companyName': companyName,
      'avatarUrl': avatarUrl,
      'availableRoles': availableRoles.map(_roleToString).toList(),
      'activeRole': _roleToString(activeRole),
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  /// Convert string to UserRole enum
  static UserRole _roleFromString(String role) {
    switch (role.toLowerCase()) {
      case 'client':
        return UserRole.client;
      case 'contractor':
        return UserRole.contractor;
      default:
        return UserRole.client;
    }
  }

  /// Convert UserRole enum to string
  static String _roleToString(UserRole role) {
    switch (role) {
      case UserRole.client:
        return 'client';
      case UserRole.contractor:
        return 'contractor';
    }
  }

  /// Create model from entity
  factory UserProfileModel.fromEntity(UserProfile profile) {
    return UserProfileModel(
      userId: profile.userId,
      name: profile.name,
      email: profile.email,
      phone: profile.phone,
      address: profile.address,
      companyName: profile.companyName,
      avatarUrl: profile.avatarUrl,
      availableRoles: profile.availableRoles,
      activeRole: profile.activeRole,
      isVerified: profile.isVerified,
      createdAt: profile.createdAt,
      lastUpdated: profile.lastUpdated,
    );
  }
}
