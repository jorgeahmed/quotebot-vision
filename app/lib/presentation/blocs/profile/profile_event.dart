import 'package:equatable/equatable.dart';
import '../../../domain/entities/user_profile.dart';

/// Events for Profile BLoC
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Load user profile
class LoadProfile extends ProfileEvent {
  final String userId;

  const LoadProfile(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Switch active role
class SwitchRole extends ProfileEvent {
  final UserRole newRole;

  const SwitchRole(this.newRole);

  @override
  List<Object?> get props => [newRole];
}

/// Update profile data
class UpdateProfile extends ProfileEvent {
  final String? name;
  final String? email;
  final String? phone;
  final String? address; // New
  final String? companyName; // New
  final String? avatarUrl;

  const UpdateProfile({
    this.name,
    this.email,
    this.phone,
    this.address,
    this.companyName,
    this.avatarUrl,
  });

  @override
  List<Object?> get props =>
      [name, email, phone, address, companyName, avatarUrl];
}

/// Add role to profile
class AddRole extends ProfileEvent {
  final UserRole role;

  const AddRole(this.role);

  @override
  List<Object?> get props => [role];
}

/// Remove role from profile
class RemoveRole extends ProfileEvent {
  final UserRole role;

  const RemoveRole(this.role);

  @override
  List<Object?> get props => [role];
}

/// Subscribe to profile updates
class SubscribeToProfile extends ProfileEvent {
  final String userId;

  const SubscribeToProfile(this.userId);

  @override
  List<Object?> get props => [userId];
}
