import 'package:equatable/equatable.dart';
import '../../../domain/entities/user_profile.dart';

/// States for Profile BLoC
abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ProfileInitial extends ProfileState {}

/// Loading profile
class ProfileLoading extends ProfileState {}

/// Profile loaded successfully
class ProfileLoaded extends ProfileState {
  final UserProfile profile;

  const ProfileLoaded(this.profile);

  @override
  List<Object?> get props => [profile];
}

/// Profile error
class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Role switching in progress
class RoleSwitching extends ProfileState {
  final UserProfile currentProfile;
  final UserRole targetRole;

  const RoleSwitching(this.currentProfile, this.targetRole);

  @override
  List<Object?> get props => [currentProfile, targetRole];
}

/// Role switched successfully
class RoleSwitched extends ProfileState {
  final UserProfile profile;

  const RoleSwitched(this.profile);

  @override
  List<Object?> get props => [profile];
}

/// Profile updating
class ProfileUpdating extends ProfileState {
  final UserProfile currentProfile;

  const ProfileUpdating(this.currentProfile);

  @override
  List<Object?> get props => [currentProfile];
}

/// Profile updated successfully
class ProfileUpdated extends ProfileState {
  final UserProfile profile;

  const ProfileUpdated(this.profile);

  @override
  List<Object?> get props => [profile];
}
