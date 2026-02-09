import 'package:flutter_test/flutter_test.dart';
import 'package:quotebot_vision/data/models/user_profile_model.dart';
import 'package:quotebot_vision/domain/entities/user_profile.dart';

void main() {
  group('UserProfileModel Tests', () {
    test('should create UserProfileModel from JSON', () {
      // Arrange
      final json = {
        'userId': 'user-123',
        'name': 'Juan Pérez',
        'email': 'juan@example.com',
        'phone': '+52 123 456 7890',
        'avatarUrl': 'https://example.com/avatar.jpg',
        'availableRoles': ['client', 'contractor'],
        'activeRole': 'client',
        'isVerified': true,
        'createdAt': '2025-01-01T00:00:00.000Z',
        'lastUpdated': '2025-01-15T00:00:00.000Z',
      };

      // Act
      final model = UserProfileModel.fromJson(json);

      // Assert
      expect(model.userId, 'user-123');
      expect(model.name, 'Juan Pérez');
      expect(model.email, 'juan@example.com');
      expect(model.availableRoles.length, 2);
      expect(model.availableRoles, contains(UserRole.client));
      expect(model.availableRoles, contains(UserRole.contractor));
      expect(model.activeRole, UserRole.client);
      expect(model.isVerified, true);
    });

    test('should handle missing optional fields in JSON', () {
      // Arrange
      final json = {
        'userId': 'user-456',
        'name': 'María García',
        'email': 'maria@example.com',
        'availableRoles': ['client'],
        'activeRole': 'client',
        'createdAt': '2025-01-01T00:00:00.000Z',
      };

      // Act
      final model = UserProfileModel.fromJson(json);

      // Assert
      expect(model.userId, 'user-456');
      expect(model.phone, isNull);
      expect(model.avatarUrl, isNull);
      expect(model.isVerified, false);
      expect(model.lastUpdated, isNull);
    });

    test('should convert UserProfileModel to JSON', () {
      // Arrange
      final model = UserProfileModel(
        userId: 'user-789',
        name: 'Carlos López',
        email: 'carlos@example.com',
        phone: '+52 555 123 4567',
        availableRoles: const [UserRole.client, UserRole.contractor],
        activeRole: UserRole.contractor,
        isVerified: true,
        createdAt: DateTime(2025, 1, 1),
        lastUpdated: DateTime(2025, 1, 15),
      );

      // Act
      final json = model.toJson();

      // Assert
      expect(json['userId'], 'user-789');
      expect(json['name'], 'Carlos López');
      expect(json['email'], 'carlos@example.com');
      expect(json['availableRoles'], ['client', 'contractor']);
      expect(json['activeRole'], 'contractor');
      expect(json['isVerified'], true);
    });

    test('should handle role string conversion correctly', () {
      // Arrange
      final json = {
        'userId': 'user-test',
        'name': 'Test User',
        'email': 'test@example.com',
        'availableRoles': ['client', 'contractor', 'invalid'],
        'activeRole': 'contractor',
        'createdAt': '2025-01-01T00:00:00.000Z',
      };

      // Act
      final model = UserProfileModel.fromJson(json);

      // Assert
      expect(model.availableRoles.length, 3);
      expect(model.activeRole, UserRole.contractor);
    });

    test('should serialize and deserialize correctly (round trip)', () {
      // Arrange
      final original = UserProfileModel(
        userId: 'round-trip-test',
        name: 'Round Trip User',
        email: 'roundtrip@example.com',
        phone: '+52 111 222 3333',
        avatarUrl: 'https://example.com/roundtrip.jpg',
        availableRoles: const [UserRole.client, UserRole.contractor],
        activeRole: UserRole.client,
        isVerified: true,
        createdAt: DateTime(2025, 1, 1),
        lastUpdated: DateTime(2025, 1, 15),
      );

      // Act
      final json = original.toJson();
      final reconstructed = UserProfileModel.fromJson(json);

      // Assert
      expect(reconstructed.userId, original.userId);
      expect(reconstructed.name, original.name);
      expect(reconstructed.email, original.email);
      expect(reconstructed.activeRole, original.activeRole);
      expect(reconstructed.availableRoles, original.availableRoles);
    });

    test('should create model from entity', () {
      // Arrange
      final entity = UserProfile(
        userId: 'entity-test',
        name: 'Entity User',
        email: 'entity@example.com',
        availableRoles: const [UserRole.client],
        activeRole: UserRole.client,
        createdAt: DateTime.now(),
      );

      // Act
      final model = UserProfileModel.fromEntity(entity);

      // Assert
      expect(model.userId, entity.userId);
      expect(model.name, entity.name);
      expect(model.email, entity.email);
      expect(model.activeRole, entity.activeRole);
    });
  });
}
