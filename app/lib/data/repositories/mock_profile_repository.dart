import 'dart:async';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';

class MockProfileRepository implements ProfileRepository {
  // Mock user profile for demo
  final UserProfile _demoProfile = UserProfile(
    userId: 'demo-user-id',
    name: 'Demo User',
    email: 'demo@mantenimientosinai.com',
    phone: '+52 123 456 7890',
    address: 'Ciudad de México',
    companyName: 'Mantenimiento Sinai',
    avatarUrl: null,
    activeRole: UserRole.contractor,
    availableRoles: const [
      UserRole.contractor,
      UserRole.client,
    ],
    isVerified: true,
    createdAt: DateTime.now().subtract(const Duration(days: 30)),
    lastUpdated: DateTime.now(),
  );

  final _profileController = StreamController<UserProfile?>.broadcast();

  @override
  Future<UserProfile?> getProfile(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _demoProfile;
  }

  @override
  Future<void> updateProfile(UserProfile profile) async {
    await Future.delayed(const Duration(milliseconds: 200));
    // In mock mode, we just simulate success
    _profileController.add(profile);
  }

  @override
  Future<UserProfile> switchRole(String userId, UserRole newRole) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final updatedProfile = _demoProfile.withActiveRole(newRole);
    _profileController.add(updatedProfile);
    return updatedProfile;
  }

  @override
  Future<void> addRole(String userId, UserRole role) async {
    await Future.delayed(const Duration(milliseconds: 200));
    // Simulate success
  }

  @override
  Future<void> removeRole(String userId, UserRole role) async {
    await Future.delayed(const Duration(milliseconds: 200));
    // Simulate success
  }

  @override
  Stream<UserProfile?> watchProfile(String userId) {
    // Immediately emit the demo profile
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!_profileController.isClosed) {
        _profileController.add(_demoProfile);
      }
    });
    return _profileController.stream;
  }

  void dispose() {
    _profileController.close();
  }
}
