import 'package:equatable/equatable.dart';

/// Enum representing the possible roles a user can have
enum UserRole {
  client,
  contractor,
}

/// Entity representing a user profile with dual role support
class UserProfile extends Equatable {
  final String userId;
  final String name;
  final String email;
  final String? phone;
  final String? address; // NEW: Added address
  final String? companyName; // NEW: Added companyName
  final String? avatarUrl;
  final List<UserRole> availableRoles;
  final UserRole activeRole;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime? lastUpdated;

  const UserProfile({
    required this.userId,
    required this.name,
    required this.email,
    this.phone,
    this.address,
    this.companyName,
    this.avatarUrl,
    required this.availableRoles,
    required this.activeRole,
    this.isVerified = false,
    required this.createdAt,
    this.lastUpdated,
  });

  /// Check if user has a specific role available
  bool hasRole(UserRole role) => availableRoles.contains(role);

  /// Check if user can switch to a specific role
  bool canSwitchTo(UserRole role) =>
      availableRoles.contains(role) && role != activeRole;

  /// Create a copy with updated active role
  UserProfile withActiveRole(UserRole newRole) {
    if (!hasRole(newRole)) {
      throw ArgumentError('User does not have role: $newRole');
    }

    return UserProfile(
      userId: userId,
      name: name,
      email: email,
      phone: phone,
      address: address,
      companyName: companyName,
      avatarUrl: avatarUrl,
      availableRoles: availableRoles,
      activeRole: newRole,
      isVerified: isVerified,
      createdAt: createdAt,
      lastUpdated: DateTime.now(),
    );
  }

  /// Copy with method for updating profile data
  UserProfile copyWith({
    String? name,
    String? email,
    String? phone,
    String? address,
    String? companyName,
    String? avatarUrl,
    List<UserRole>? availableRoles,
    UserRole? activeRole,
    bool? isVerified,
    DateTime? lastUpdated,
  }) {
    return UserProfile(
      userId: userId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      companyName: companyName ?? this.companyName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      availableRoles: availableRoles ?? this.availableRoles,
      activeRole: activeRole ?? this.activeRole,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        name,
        email,
        phone,
        address,
        companyName,
        avatarUrl,
        availableRoles,
        activeRole,
        isVerified,
        createdAt,
        lastUpdated,
      ];
}
