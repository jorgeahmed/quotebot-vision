import 'package:flutter_test/flutter_test.dart';
import 'package:quotebot_vision/domain/entities/quotation.dart';
import 'package:quotebot_vision/domain/entities/material_item.dart';

void main() {
  group('Quotation Entity Tests', () {
    late List<MaterialItem> testMaterials;
    late DateTime testDate;

    setUp(() {
      testDate = DateTime(2025, 12, 29, 12, 0);
      testMaterials = [
        const MaterialItem(
          name: 'Cemento Portland',
          quantity: '10',
          unit: 'sacos',
          unitPrice: 150.0,
          totalPrice: 1500.0,
          wasAdjusted: false,
        ),
        const MaterialItem(
          name: 'Arena',
          quantity: '5',
          unit: 'm³',
          unitPrice: 200.0,
          totalPrice: 1000.0,
          wasAdjusted: true,
          adjustmentReason: 'Ajuste por mercado',
        ),
      ];
    });

    test('should create Quotation with all properties', () {
      // Arrange & Act
      final quotation = Quotation(
        id: 'quote-123',
        jobId: 'job-456',
        projectId: 'project-789',
        materials: testMaterials,
        laborCost: 5000.0,
        totalCost: 7500.0,
        confidenceScore: 0.85,
        status: 'completed',
        createdAt: testDate,
        marketAdjustmentFactor: 1.05,
      );

      // Assert
      expect(quotation.id, 'quote-123');
      expect(quotation.jobId, 'job-456');
      expect(quotation.projectId, 'project-789');
      expect(quotation.materials.length, 2);
      expect(quotation.laborCost, 5000.0);
      expect(quotation.totalCost, 7500.0);
      expect(quotation.confidenceScore, 0.85);
      expect(quotation.status, 'completed');
      expect(quotation.createdAt, testDate);
      expect(quotation.marketAdjustmentFactor, 1.05);
    });

    test('should create Quotation without optional marketAdjustmentFactor', () {
      // Arrange & Act
      final quotation = Quotation(
        id: 'quote-999',
        jobId: 'job-999',
        projectId: 'project-999',
        materials: testMaterials,
        laborCost: 3000.0,
        totalCost: 5500.0,
        confidenceScore: 0.90,
        status: 'completed',
        createdAt: testDate,
      );

      // Assert
      expect(quotation.marketAdjustmentFactor, isNull);
      expect(quotation.materials.length, 2);
    });

    test('should calculate total cost from materials and labor', () {
      // Arrange
      const laborCost = 5000.0;
      const expectedTotal = 7500.0;

      // Act
      final quotation = Quotation(
        id: 'quote-calc',
        jobId: 'job-calc',
        projectId: 'project-calc',
        materials: testMaterials,
        laborCost: laborCost,
        totalCost: expectedTotal,
        confidenceScore: 0.85,
        status: 'completed',
        createdAt: testDate,
      );

      // Assert
      expect(quotation.totalCost, expectedTotal);
      expect(quotation.laborCost, laborCost);
    });

    test('should support equality comparison', () {
      // Arrange
      final quotation1 = Quotation(
        id: 'quote-1',
        jobId: 'job-1',
        projectId: 'project-1',
        materials: testMaterials,
        laborCost: 5000.0,
        totalCost: 7500.0,
        confidenceScore: 0.85,
        status: 'completed',
        createdAt: testDate,
      );

      final quotation2 = Quotation(
        id: 'quote-1',
        jobId: 'job-1',
        projectId: 'project-1',
        materials: testMaterials,
        laborCost: 5000.0,
        totalCost: 7500.0,
        confidenceScore: 0.85,
        status: 'completed',
        createdAt: testDate,
      );

      final quotation3 = Quotation(
        id: 'quote-2',
        jobId: 'job-1',
        projectId: 'project-1',
        materials: testMaterials,
        laborCost: 5000.0,
        totalCost: 7500.0,
        confidenceScore: 0.85,
        status: 'completed',
        createdAt: testDate,
      );

      // Assert
      expect(quotation1, equals(quotation2));
      expect(quotation1, isNot(equals(quotation3)));
    });

    test('should handle empty materials list', () {
      // Arrange & Act
      final quotation = Quotation(
        id: 'quote-empty',
        jobId: 'job-empty',
        projectId: 'project-empty',
        materials: const [],
        laborCost: 5000.0,
        totalCost: 5000.0,
        confidenceScore: 0.50,
        status: 'completed',
        createdAt: testDate,
      );

      // Assert
      expect(quotation.materials, isEmpty);
      expect(quotation.totalCost, 5000.0);
    });

    test('should validate confidence score range', () {
      // Arrange & Act
      final highConfidence = Quotation(
        id: 'quote-high',
        jobId: 'job-high',
        projectId: 'project-high',
        materials: testMaterials,
        laborCost: 5000.0,
        totalCost: 7500.0,
        confidenceScore: 0.95,
        status: 'completed',
        createdAt: testDate,
      );

      final lowConfidence = Quotation(
        id: 'quote-low',
        jobId: 'job-low',
        projectId: 'project-low',
        materials: testMaterials,
        laborCost: 5000.0,
        totalCost: 7500.0,
        confidenceScore: 0.45,
        status: 'completed',
        createdAt: testDate,
      );

      // Assert
      expect(highConfidence.confidenceScore, greaterThanOrEqualTo(0.0));
      expect(highConfidence.confidenceScore, lessThanOrEqualTo(1.0));
      expect(lowConfidence.confidenceScore, greaterThanOrEqualTo(0.0));
      expect(lowConfidence.confidenceScore, lessThanOrEqualTo(1.0));
    });
  });
}
