import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/user_profile.dart';
import '../../../domain/repositories/profile_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _profileRepository;
  StreamSubscription<UserProfile?>? _profileSubscription;

  ProfileBloc({required ProfileRepository profileRepository})
      : _profileRepository = profileRepository,
        super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<SwitchRole>(_onSwitchRole);
    on<UpdateProfile>(_onUpdateProfile);
    on<AddRole>(_onAddRole);
    on<RemoveRole>(_onRemoveRole);
    on<SubscribeToProfile>(_onSubscribeToProfile);
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());

    try {
      final profile = await _profileRepository.getProfile(event.userId);

      if (profile != null) {
        emit(ProfileLoaded(profile));
      } else {
        emit(const ProfileError('Profile not found'));
      }
    } catch (e) {
      emit(ProfileError('Failed to load profile: $e'));
    }
  }

  Future<void> _onSwitchRole(
    SwitchRole event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is! ProfileLoaded) {
      emit(const ProfileError('No profile loaded'));
      return;
    }

    final currentProfile = (state as ProfileLoaded).profile;

    if (!currentProfile.canSwitchTo(event.newRole)) {
      emit(const ProfileError('Cannot switch to this role'));
      return;
    }

    emit(RoleSwitching(currentProfile, event.newRole));

    try {
      final updatedProfile = await _profileRepository.switchRole(
        currentProfile.userId,
        event.newRole,
      );

      emit(RoleSwitched(updatedProfile));
      // Transition back to ProfileLoaded after a short delay
      await Future.delayed(const Duration(milliseconds: 500));
      emit(ProfileLoaded(updatedProfile));
    } catch (e) {
      emit(ProfileError('Failed to switch role: $e'));
      emit(ProfileLoaded(currentProfile)); // Revert to previous state
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfile event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is! ProfileLoaded) {
      emit(const ProfileError('No profile loaded'));
      return;
    }

    final currentProfile = (state as ProfileLoaded).profile;
    emit(ProfileUpdating(currentProfile));

    try {
      final updatedProfile = currentProfile.copyWith(
        name: event.name,
        email: event.email,
        phone: event.phone,
        address: event.address,
        companyName: event.companyName,
        avatarUrl: event.avatarUrl,
        lastUpdated: DateTime.now(),
      );

      await _profileRepository.updateProfile(updatedProfile);

      emit(ProfileUpdated(updatedProfile));
      // Transition back to ProfileLoaded
      await Future.delayed(const Duration(milliseconds: 500));
      emit(ProfileLoaded(updatedProfile));
    } catch (e) {
      emit(ProfileError('Failed to update profile: $e'));
      emit(ProfileLoaded(currentProfile)); // Revert to previous state
    }
  }

  Future<void> _onAddRole(
    AddRole event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is! ProfileLoaded) {
      emit(const ProfileError('No profile loaded'));
      return;
    }

    final currentProfile = (state as ProfileLoaded).profile;

    try {
      await _profileRepository.addRole(currentProfile.userId, event.role);

      // Reload profile to get updated data
      add(LoadProfile(currentProfile.userId));
    } catch (e) {
      emit(ProfileError('Failed to add role: $e'));
      emit(ProfileLoaded(currentProfile));
    }
  }

  Future<void> _onRemoveRole(
    RemoveRole event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is! ProfileLoaded) {
      emit(const ProfileError('No profile loaded'));
      return;
    }

    final currentProfile = (state as ProfileLoaded).profile;

    try {
      await _profileRepository.removeRole(currentProfile.userId, event.role);

      // Reload profile to get updated data
      add(LoadProfile(currentProfile.userId));
    } catch (e) {
      emit(ProfileError('Failed to remove role: $e'));
      emit(ProfileLoaded(currentProfile));
    }
  }

  Future<void> _onSubscribeToProfile(
    SubscribeToProfile event,
    Emitter<ProfileState> emit,
  ) async {
    // Cancel existing subscription
    await _profileSubscription?.cancel();

    emit(ProfileLoading());

    _profileSubscription = _profileRepository.watchProfile(event.userId).listen(
      (profile) {
        if (profile != null) {
          emit(ProfileLoaded(profile));
        } else {
          emit(const ProfileError('Profile not found'));
        }
      },
      onError: (error) {
        emit(ProfileError('Profile stream error: $error'));
      },
    );
  }

  @override
  Future<void> close() {
    _profileSubscription?.cancel();
    return super.close();
  }
}
