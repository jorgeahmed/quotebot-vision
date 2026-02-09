import '../entities/user_profile.dart';

/// Repository interface for user profile operations
abstract class ProfileRepository {
  /// Get user profile by user ID
  Future<UserProfile?> getProfile(String userId);

  /// Update user profile
  Future<void> updateProfile(UserProfile profile);

  /// Switch active role for a user
  Future<UserProfile> switchRole(String userId, UserRole newRole);

  /// Add a role to user's available roles
  Future<void> addRole(String userId, UserRole role);

  /// Remove a role from user's available roles
  Future<void> removeRole(String userId, UserRole role);

  /// Stream user profile changes
  Stream<UserProfile?> watchProfile(String userId);
}
