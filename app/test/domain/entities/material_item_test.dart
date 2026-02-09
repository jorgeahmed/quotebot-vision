import 'package:flutter_test/flutter_test.dart';
import 'package:quotebot_vision/domain/entities/material_item.dart';

void main() {
  group('MaterialItem Entity Tests', () {
    test('should create MaterialItem with all properties', () {
      // Arrange & Act
      const item = MaterialItem(
        name: 'Cemento Portland',
        quantity: '10',
        unit: 'sacos',
        unitPrice: 150.0,
        totalPrice: 1500.0,
        marketAverage: 155.0,
        wasAdjusted: true,
        adjustmentReason: 'Precio de mercado ajustado',
      );

      // Assert
      expect(item.name, 'Cemento Portland');
      expect(item.quantity, '10');
      expect(item.unit, 'sacos');
      expect(item.unitPrice, 150.0);
      expect(item.totalPrice, 1500.0);
      expect(item.marketAverage, 155.0);
      expect(item.wasAdjusted, true);
      expect(item.adjustmentReason, 'Precio de mercado ajustado');
    });

    test('should create MaterialItem without optional properties', () {
      // Arrange & Act
      const item = MaterialItem(
        name: 'Arena',
        quantity: '5',
        unit: 'm³',
        unitPrice: 200.0,
        totalPrice: 1000.0,
        wasAdjusted: false,
      );

      // Assert
      expect(item.name, 'Arena');
      expect(item.marketAverage, isNull);
      expect(item.adjustmentReason, isNull);
      expect(item.wasAdjusted, false);
    });

    test('should support equality comparison', () {
      // Arrange
      const item1 = MaterialItem(
        name: 'Cemento',
        quantity: '10',
        unit: 'sacos',
        unitPrice: 150.0,
        totalPrice: 1500.0,
        wasAdjusted: false,
      );

      const item2 = MaterialItem(
        name: 'Cemento',
        quantity: '10',
        unit: 'sacos',
        unitPrice: 150.0,
        totalPrice: 1500.0,
        wasAdjusted: false,
      );

      const item3 = MaterialItem(
        name: 'Arena',
        quantity: '5',
        unit: 'm³',
        unitPrice: 200.0,
        totalPrice: 1000.0,
        wasAdjusted: false,
      );

      // Assert
      expect(item1, equals(item2));
      expect(item1, isNot(equals(item3)));
    });

    test('should calculate total price correctly from unit price and quantity',
        () {
      // Arrange
      const unitPrice = 150.0;
      const expectedTotal = 1500.0;

      // Act
      const item = MaterialItem(
        name: 'Test Material',
        quantity: '10',
        unit: 'unidades',
        unitPrice: unitPrice,
        totalPrice: expectedTotal,
        wasAdjusted: false,
      );

      // Assert
      expect(item.totalPrice, expectedTotal);
    });
  });
}
