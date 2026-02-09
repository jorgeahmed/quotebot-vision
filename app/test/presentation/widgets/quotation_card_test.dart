import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quotebot_vision/domain/entities/quotation.dart';
import 'package:quotebot_vision/domain/entities/material_item.dart';
import 'package:quotebot_vision/presentation/widgets/quotation_card.dart';

void main() {
  group('QuotationCard Widget Tests', () {
    late Quotation testQuotation;
    late bool wasTapped;

    setUp(() {
      wasTapped = false;
      testQuotation = Quotation(
        id: 'quote-123456',
        jobId: 'job-789',
        projectId: 'project-101',
        materials: const [
          MaterialItem(
            name: 'Cemento',
            quantity: '10',
            unit: 'sacos',
            unitPrice: 150.0,
            totalPrice: 1500.0,
            wasAdjusted: false,
          ),
          MaterialItem(
            name: 'Arena',
            quantity: '5',
            unit: 'm³',
            unitPrice: 200.0,
            totalPrice: 1000.0,
            wasAdjusted: false,
          ),
        ],
        laborCost: 5000.0,
        totalCost: 7500.0,
        confidenceScore: 0.85,
        status: 'completed',
        createdAt: DateTime(2025, 12, 29),
      );
    });

    testWidgets('should render quotation card with correct data',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuotationCard(
              quotation: testQuotation,
              onTap: () => wasTapped = true,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Cotización #123456'), findsOneWidget);
      expect(find.text('29/12/2025'), findsOneWidget);
      expect(find.text('\$7500.00'), findsOneWidget);
      expect(find.text('2 materiales'), findsOneWidget);
      expect(find.text('Mano de obra: \$5000.00'), findsOneWidget);
      expect(find.text('85%'), findsOneWidget);
    });

    testWidgets('should respond to tap', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuotationCard(
              quotation: testQuotation,
              onTap: () => wasTapped = true,
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(QuotationCard));
      await tester.pump();

      // Assert
      expect(wasTapped, isTrue);
    });

    testWidgets('should display correct confidence color for high confidence',
        (WidgetTester tester) async {
      // Arrange
      final highConfidenceQuotation = Quotation(
        id: 'quote-high',
        jobId: 'job-1',
        projectId: 'project-1',
        materials: const [],
        laborCost: 1000.0,
        totalCost: 1000.0,
        confidenceScore: 0.95,
        status: 'completed',
        createdAt: DateTime.now(),
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuotationCard(
              quotation: highConfidenceQuotation,
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('95%'), findsOneWidget);
    });

    testWidgets('should display correct confidence color for medium confidence',
        (WidgetTester tester) async {
      // Arrange
      final mediumConfidenceQuotation = Quotation(
        id: 'quote-medium',
        jobId: 'job-2',
        projectId: 'project-2',
        materials: const [],
        laborCost: 1000.0,
        totalCost: 1000.0,
        confidenceScore: 0.60,
        status: 'completed',
        createdAt: DateTime.now(),
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuotationCard(
              quotation: mediumConfidenceQuotation,
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('60%'), findsOneWidget);
    });

    testWidgets('should display correct confidence color for low confidence',
        (WidgetTester tester) async {
      // Arrange
      final lowConfidenceQuotation = Quotation(
        id: 'quote-low',
        jobId: 'job-3',
        projectId: 'project-3',
        materials: const [],
        laborCost: 1000.0,
        totalCost: 1000.0,
        confidenceScore: 0.45,
        status: 'completed',
        createdAt: DateTime.now(),
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuotationCard(
              quotation: lowConfidenceQuotation,
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('45%'), findsOneWidget);
    });

    testWidgets('should handle empty materials list',
        (WidgetTester tester) async {
      // Arrange
      final emptyMaterialsQuotation = Quotation(
        id: 'quote-empty',
        jobId: 'job-4',
        projectId: 'project-4',
        materials: const [],
        laborCost: 2000.0,
        totalCost: 2000.0,
        confidenceScore: 0.70,
        status: 'completed',
        createdAt: DateTime.now(),
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuotationCard(
              quotation: emptyMaterialsQuotation,
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('0 materiales'), findsOneWidget);
    });

    testWidgets('should truncate long quotation IDs correctly',
        (WidgetTester tester) async {
      // Arrange
      final longIdQuotation = Quotation(
        id: 'very-long-quotation-id-12345',
        jobId: 'job-5',
        projectId: 'project-5',
        materials: const [],
        laborCost: 1000.0,
        totalCost: 1000.0,
        confidenceScore: 0.80,
        status: 'completed',
        createdAt: DateTime.now(),
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuotationCard(
              quotation: longIdQuotation,
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert - Should show last 6 characters
      expect(find.text('Cotización #-12345'), findsOneWidget);
    });
  });
}
