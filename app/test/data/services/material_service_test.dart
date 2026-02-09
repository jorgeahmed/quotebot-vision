import 'package:flutter_test/flutter_test.dart';
import 'package:quotebot_vision/data/services/material_service.dart';
import 'package:quotebot_vision/domain/entities/material_catalog.dart';

void main() {
  group('MaterialService', () {
    late MaterialService service;

    setUp(() {
      service = MaterialService();
    });

    test('normalizeMaterialName cleans strings correctly', () {
      expect(service.normalizeMaterialName('Cemento'), 'cemento');
      expect(service.normalizeMaterialName('Pintura Látex'), 'pintura-latex');
      expect(service.normalizeMaterialName('  Espacio  '), 'espacio');
    });

    test('findMaterial returns exact match', () {
      final result = service.findMaterial('cemento');
      expect(result, isNotNull);
      expect(result!.materialName, 'Cemento');
      expect(result.category, MaterialCategory.masonry);
    });

    test('findMaterial returns partial match', () {
      // Searching for "necesito bulto de cemento" should find "cemento"
      final result = service.findMaterial('necesito bulto de cemento');
      expect(result, isNotNull);
      expect(result!.normalizedName, 'cemento');
    });

    test('findMaterial returns partial match (catalog name in search)', () {
      // Searching for "cemento gris"
      final result = service.findMaterial('cemento gris');
      expect(result, isNotNull);
      expect(result!.normalizedName, 'cemento');
    });

    test('findMaterial returns null for unknown material', () {
      final result = service.findMaterial('astrophysics textbook');
      expect(result, isNull);
    });
  });
}
