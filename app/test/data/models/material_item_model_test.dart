import 'package:flutter_test/flutter_test.dart';
import 'package:quotebot_vision/data/models/material_item_model.dart';

void main() {
  group('MaterialItemModel Tests', () {
    test('should create MaterialItemModel from JSON', () {
      // Arrange
      final json = {
        'name': 'Cemento Portland',
        'quantity': '10',
        'unit': 'sacos',
        'unitPrice': 150.0,
        'totalPrice': 1500.0,
        'marketAverage': 155.0,
        'wasAdjusted': true,
        'adjustmentReason': 'Ajuste de mercado',
      };

      // Act
      final model = MaterialItemModel.fromJson(json);

      // Assert
      expect(model.name, 'Cemento Portland');
      expect(model.quantity, '10');
      expect(model.unit, 'sacos');
      expect(model.unitPrice, 150.0);
      expect(model.totalPrice, 1500.0);
      expect(model.marketAverage, 155.0);
      expect(model.wasAdjusted, true);
      expect(model.adjustmentReason, 'Ajuste de mercado');
    });

    test('should handle missing optional fields in JSON', () {
      // Arrange
      final json = {
        'name': 'Arena',
        'quantity': '5',
        'unit': 'm³',
        'unitPrice': 200.0,
        'totalPrice': 1000.0,
        'wasAdjusted': false,
      };

      // Act
      final model = MaterialItemModel.fromJson(json);

      // Assert
      expect(model.name, 'Arena');
      expect(model.marketAverage, isNull);
      expect(model.adjustmentReason, isNull);
      expect(model.wasAdjusted, false);
    });

    test('should handle null or missing fields with defaults', () {
      // Arrange
      final json = <String, dynamic>{};

      // Act
      final model = MaterialItemModel.fromJson(json);

      // Assert
      expect(model.name, '');
      expect(model.quantity, '');
      expect(model.unit, '');
      expect(model.unitPrice, 0.0);
      expect(model.totalPrice, 0.0);
      expect(model.wasAdjusted, false);
    });

    test('should convert model to JSON', () {
      // Arrange
      const model = MaterialItemModel(
        name: 'Cemento',
        quantity: '10',
        unit: 'sacos',
        unitPrice: 150.0,
        totalPrice: 1500.0,
        marketAverage: 155.0,
        wasAdjusted: true,
        adjustmentReason: 'Ajuste',
      );

      // Act
      final json = model.toJson();

      // Assert
      expect(json['name'], 'Cemento');
      expect(json['quantity'], '10');
      expect(json['unit'], 'sacos');
      expect(json['unitPrice'], 150.0);
      expect(json['totalPrice'], 1500.0);
      expect(json['marketAverage'], 155.0);
      expect(json['wasAdjusted'], true);
      expect(json['adjustmentReason'], 'Ajuste');
    });

    test('should handle number types in JSON (int to double conversion)', () {
      // Arrange
      final json = {
        'name': 'Material',
        'quantity': '1',
        'unit': 'unidad',
        'unitPrice': 100, // int instead of double
        'totalPrice': 100, // int instead of double
        'marketAverage': 105, // int instead of double
        'wasAdjusted': false,
      };

      // Act
      final model = MaterialItemModel.fromJson(json);

      // Assert
      expect(model.unitPrice, 100.0);
      expect(model.totalPrice, 100.0);
      expect(model.marketAverage, 105.0);
    });

    test('should serialize and deserialize correctly (round trip)', () {
      // Arrange
      const original = MaterialItemModel(
        name: 'Grava',
        quantity: '15',
        unit: 'm³',
        unitPrice: 250.0,
        totalPrice: 3750.0,
        marketAverage: 260.0,
        wasAdjusted: true,
        adjustmentReason: 'Precio mayorista',
      );

      // Act
      final json = original.toJson();
      final reconstructed = MaterialItemModel.fromJson(json);

      // Assert
      expect(reconstructed, equals(original));
    });
  });
}
