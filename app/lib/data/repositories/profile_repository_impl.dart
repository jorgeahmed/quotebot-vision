import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../models/user_profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final FirebaseFirestore _firestore;

  ProfileRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _profilesCollection =>
      _firestore.collection('user_profiles');

  @override
  Future<UserProfile?> getProfile(String userId) async {
    try {
      final doc = await _profilesCollection.doc(userId).get();

      if (!doc.exists) {
        return null;
      }

      final data = doc.data() as Map<String, dynamic>;
      return UserProfileModel.fromJson({...data, 'userId': userId});
    } catch (e) {
      debugPrint('Error getting profile: $e');
      return null;
    }
  }

  @override
  Future<void> updateProfile(UserProfile profile) async {
    try {
      final model = UserProfileModel.fromEntity(profile);
      final json = model.toJson();

      // Remove userId from json as it's the document ID
      json.remove('userId');

      await _profilesCollection.doc(profile.userId).set(
            json,
            SetOptions(merge: true),
          );
    } catch (e) {
      debugPrint('Error updating profile: $e');
      rethrow;
    }
  }

  @override
  Future<UserProfile> switchRole(String userId, UserRole newRole) async {
    try {
      final profile = await getProfile(userId);

      if (profile == null) {
        throw Exception('Profile not found');
      }

      final updatedProfile = profile.withActiveRole(newRole);
      await updateProfile(updatedProfile);

      return updatedProfile;
    } catch (e) {
      debugPrint('Error switching role: $e');
      rethrow;
    }
  }

  @override
  Future<void> addRole(String userId, UserRole role) async {
    try {
      final profile = await getProfile(userId);

      if (profile == null) {
        throw Exception('Profile not found');
      }

      if (!profile.hasRole(role)) {
        final updatedRoles = [...profile.availableRoles, role];
        final updatedProfile = profile.copyWith(
          availableRoles: updatedRoles,
          lastUpdated: DateTime.now(),
        );
        await updateProfile(updatedProfile);
      }
    } catch (e) {
      debugPrint('Error adding role: $e');
      rethrow;
    }
  }

  @override
  Future<void> removeRole(String userId, UserRole role) async {
    try {
      final profile = await getProfile(userId);

      if (profile == null) {
        throw Exception('Profile not found');
      }

      if (profile.availableRoles.length <= 1) {
        throw Exception('Cannot remove last role');
      }

      if (profile.activeRole == role) {
        throw Exception('Cannot remove active role');
      }

      final updatedRoles =
          profile.availableRoles.where((r) => r != role).toList();

      final updatedProfile = profile.copyWith(
        availableRoles: updatedRoles,
        lastUpdated: DateTime.now(),
      );

      await updateProfile(updatedProfile);
    } catch (e) {
      debugPrint('Error removing role: $e');
      rethrow;
    }
  }

  @override
  Stream<UserProfile?> watchProfile(String userId) {
    return _profilesCollection.doc(userId).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        return null;
      }

      final data = snapshot.data() as Map<String, dynamic>;
      return UserProfileModel.fromJson({...data, 'userId': userId});
    });
  }
}
