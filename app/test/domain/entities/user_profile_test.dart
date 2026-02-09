import 'package:flutter_test/flutter_test.dart';
import 'package:quotebot_vision/domain/entities/user_profile.dart';

void main() {
  group('UserProfile Entity Tests', () {
    late DateTime testDate;

    setUp(() {
      testDate = DateTime(2025, 1, 1);
    });

    test('should create UserProfile with all properties', () {
      // Arrange & Act
      final profile = UserProfile(
        userId: 'user-123',
        name: 'Juan Pérez',
        email: 'juan@example.com',
        phone: '+52 123 456 7890',
        avatarUrl: 'https://example.com/avatar.jpg',
        availableRoles: const [UserRole.client, UserRole.contractor],
        activeRole: UserRole.client,
        isVerified: true,
        createdAt: testDate,
        lastUpdated: DateTime(2025, 1, 15),
      );

      // Assert
      expect(profile.userId, 'user-123');
      expect(profile.name, 'Juan Pérez');
      expect(profile.email, 'juan@example.com');
      expect(profile.phone, '+52 123 456 7890');
      expect(profile.availableRoles.length, 2);
      expect(profile.activeRole, UserRole.client);
      expect(profile.isVerified, true);
    });

    test('should check if user has specific role', () {
      // Arrange
      final profile = UserProfile(
        userId: 'user-123',
        name: 'Juan Pérez',
        email: 'juan@example.com',
        availableRoles: const [UserRole.client, UserRole.contractor],
        activeRole: UserRole.client,
        createdAt: testDate,
      );

      // Act & Assert
      expect(profile.hasRole(UserRole.client), true);
      expect(profile.hasRole(UserRole.contractor), true);
    });

    test('should check if user can switch to role', () {
      // Arrange
      final profile = UserProfile(
        userId: 'user-123',
        name: 'Juan Pérez',
        email: 'juan@example.com',
        availableRoles: const [UserRole.client, UserRole.contractor],
        activeRole: UserRole.client,
        createdAt: testDate,
      );

      // Act & Assert
      expect(profile.canSwitchTo(UserRole.contractor), true);
      expect(profile.canSwitchTo(UserRole.client), false); // Already active
    });

    test('should switch active role', () {
      // Arrange
      final profile = UserProfile(
        userId: 'user-123',
        name: 'Juan Pérez',
        email: 'juan@example.com',
        availableRoles: const [UserRole.client, UserRole.contractor],
        activeRole: UserRole.client,
        createdAt: testDate,
      );

      // Act
      final updatedProfile = profile.withActiveRole(UserRole.contractor);

      // Assert
      expect(updatedProfile.activeRole, UserRole.contractor);
      expect(updatedProfile.userId, profile.userId); // Other fields unchanged
      expect(updatedProfile.lastUpdated, isNotNull);
    });

    test('should throw error when switching to unavailable role', () {
      // Arrange
      final profile = UserProfile(
        userId: 'user-123',
        name: 'Juan Pérez',
        email: 'juan@example.com',
        availableRoles: const [UserRole.client], // Only client role
        activeRole: UserRole.client,
        createdAt: testDate,
      );

      // Act & Assert
      expect(
        () => profile.withActiveRole(UserRole.contractor),
        throwsArgumentError,
      );
    });

    test('should create copy with updated fields', () {
      // Arrange
      final profile = UserProfile(
        userId: 'user-123',
        name: 'Juan Pérez',
        email: 'juan@example.com',
        availableRoles: const [UserRole.client],
        activeRole: UserRole.client,
        createdAt: testDate,
      );

      // Act
      final updated = profile.copyWith(
        name: 'Juan Carlos Pérez',
        phone: '+52 999 888 7777',
        isVerified: true,
      );

      // Assert
      expect(updated.name, 'Juan Carlos Pérez');
      expect(updated.phone, '+52 999 888 7777');
      expect(updated.isVerified, true);
      expect(updated.userId, profile.userId); // Unchanged
      expect(updated.email, profile.email); // Unchanged
    });

    test('should support equality comparison', () {
      // Arrange
      final profile1 = UserProfile(
        userId: 'user-123',
        name: 'Juan Pérez',
        email: 'juan@example.com',
        availableRoles: const [UserRole.client],
        activeRole: UserRole.client,
        createdAt: testDate,
      );

      final profile2 = UserProfile(
        userId: 'user-123',
        name: 'Juan Pérez',
        email: 'juan@example.com',
        availableRoles: const [UserRole.client],
        activeRole: UserRole.client,
        createdAt: testDate,
      );

      final profile3 = UserProfile(
        userId: 'user-456', // Different ID
        name: 'Juan Pérez',
        email: 'juan@example.com',
        availableRoles: const [UserRole.client],
        activeRole: UserRole.client,
        createdAt: testDate,
      );

      // Assert
      expect(profile1, equals(profile2));
      expect(profile1, isNot(equals(profile3)));
    });
  });
}
