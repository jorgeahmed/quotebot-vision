import 'dart:math';
import 'package:uuid/uuid.dart';
import '../../domain/entities/quotation.dart';
import '../../domain/entities/material_item.dart';
import '../../domain/repositories/quotation_repository.dart';

class MockQuotationRepository implements QuotationRepository {
  final _uuid = const Uuid();
  final _random = Random();

  MockQuotationRepository();

  // In-memory storage for persistent check within session
  final Map<String, Quotation> _quotations = {};
  final Map<String, List<Quotation>> _projectQuotations = {};

  @override
  Future<Quotation> generateQuotation(String jobId) async {
    // Simulate processing delay
    await Future.delayed(const Duration(seconds: 2));

    // Generate random materials based on catalog
    final materials = _generateRandomMaterials();

    // Calculate costs
    double totalMaterialCost = 0;
    for (var m in materials) {
      totalMaterialCost += m.totalPrice;
    }

    // Labor is roughly 40-60% of material cost for simulation
    final laborCost = totalMaterialCost * (0.4 + _random.nextDouble() * 0.2);
    final totalCost = totalMaterialCost + laborCost;

    final quotation = Quotation(
      id: _uuid.v4(),
      jobId: jobId,
      projectId: 'temp-project-id', // Usually passed or inferred
      materials: materials,
      laborCost: double.parse(laborCost.toStringAsFixed(2)),
      totalCost: double.parse(totalCost.toStringAsFixed(2)),
      confidenceScore: 0.85 + _random.nextDouble() * 0.14, // 0.85 - 0.99
      status: 'pending',
      createdAt: DateTime.now(),
    );

    _quotations[quotation.id] = quotation;

    // Note: In a real flow, generateQuotation might update the Job in DB,
    // and we retrieve it. Here we just return it.
    return quotation;
  }

  @override
  Future<Quotation> getQuotation(String quotationId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (_quotations.containsKey(quotationId)) {
      return _quotations[quotationId]!;
    }
    throw Exception('Quotation not found');
  }

  @override
  Future<List<Quotation>> getProjectQuotations(String projectId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Use cached if available, otherwise generate some mock data for the project
    if (!_projectQuotations.containsKey(projectId)) {
      _projectQuotations[projectId] = [
        _createMockQuotation(projectId, 'Simulación Inicial 1'),
        _createMockQuotation(projectId, 'Simulación Inicial 2'),
      ];
    }

    return _projectQuotations[projectId]!;
  }

  // --- Helper Methods ---

  List<MaterialItem> _generateRandomMaterials() {
    // Create realistic construction material lists for different scenarios
    final scenarios = [
      _getConcreteSlabMaterials(),
      _getWallConstructionMaterials(),
      _getPaintingMaterials(),
      _getElectricalMaterials(),
    ];

    return scenarios[_random.nextInt(scenarios.length)];
  }

  List<MaterialItem> _getConcreteSlabMaterials() {
    return [
      MaterialItem(
        name: 'Cemento Portland Gris 50kg',
        quantity: '15',
        unit: 'bulto',
        unitPrice: 185.00,
        totalPrice: 2775.00,
        wasAdjusted: false,
        marketAverage: 185.00,
      ),
      MaterialItem(
        name: 'Arena de Río m³',
        quantity: '3',
        unit: 'm³',
        unitPrice: 450.00,
        totalPrice: 1350.00,
        wasAdjusted: false,
        marketAverage: 450.00,
      ),
      MaterialItem(
        name: 'Grava 3/4" m³',
        quantity: '2',
        unit: 'm³',
        unitPrice: 520.00,
        totalPrice: 1040.00,
        wasAdjusted: false,
        marketAverage: 520.00,
      ),
      MaterialItem(
        name: 'Varilla 3/8" 12m',
        quantity: '25',
        unit: 'pieza',
        unitPrice: 95.00,
        totalPrice: 2375.00,
        wasAdjusted: false,
        marketAverage: 95.00,
      ),
      MaterialItem(
        name: 'Alambre Recocido kg',
        quantity: '5',
        unit: 'kg',
        unitPrice: 28.00,
        totalPrice: 140.00,
        wasAdjusted: false,
        marketAverage: 28.00,
      ),
    ];
  }

  List<MaterialItem> _getWallConstructionMaterials() {
    return [
      MaterialItem(
        name: 'Block de Concreto 15x20x40cm',
        quantity: '250',
        unit: 'pieza',
        unitPrice: 12.50,
        totalPrice: 3125.00,
        wasAdjusted: false,
        marketAverage: 12.50,
      ),
      MaterialItem(
        name: 'Cemento Portland Gris 50kg',
        quantity: '8',
        unit: 'bulto',
        unitPrice: 185.00,
        totalPrice: 1480.00,
        wasAdjusted: false,
        marketAverage: 185.00,
      ),
      MaterialItem(
        name: 'Arena Cernida m³',
        quantity: '2',
        unit: 'm³',
        unitPrice: 380.00,
        totalPrice: 760.00,
        wasAdjusted: false,
        marketAverage: 380.00,
      ),
      MaterialItem(
        name: 'Cal Hidratada 20kg',
        quantity: '6',
        unit: 'bulto',
        unitPrice: 85.00,
        totalPrice: 510.00,
        wasAdjusted: false,
        marketAverage: 85.00,
      ),
    ];
  }

  List<MaterialItem> _getPaintingMaterials() {
    return [
      MaterialItem(
        name: 'Pintura Vinílica Blanca 19L',
        quantity: '4',
        unit: 'cubeta',
        unitPrice: 425.00,
        totalPrice: 1700.00,
        wasAdjusted: false,
        marketAverage: 425.00,
      ),
      MaterialItem(
        name: 'Pintura Esmalte Gris 4L',
        quantity: '2',
        unit: 'cubeta',
        unitPrice: 380.00,
        totalPrice: 760.00,
        wasAdjusted: false,
        marketAverage: 380.00,
      ),
      MaterialItem(
        name: 'Sellador Acrílico 19L',
        quantity: '2',
        unit: 'cubeta',
        unitPrice: 320.00,
        totalPrice: 640.00,
        wasAdjusted: false,
        marketAverage: 320.00,
      ),
      MaterialItem(
        name: 'Lija para Madera #120',
        quantity: '20',
        unit: 'pliego',
        unitPrice: 8.50,
        totalPrice: 170.00,
        wasAdjusted: false,
        marketAverage: 8.50,
      ),
      MaterialItem(
        name: 'Brocha 4 pulgadas',
        quantity: '6',
        unit: 'pieza',
        unitPrice: 45.00,
        totalPrice: 270.00,
        wasAdjusted: false,
        marketAverage: 45.00,
      ),
    ];
  }

  List<MaterialItem> _getElectricalMaterials() {
    return [
      MaterialItem(
        name: 'Cable THW Calibre 12 AWG',
        quantity: '100',
        unit: 'metro',
        unitPrice: 12.50,
        totalPrice: 1250.00,
        wasAdjusted: false,
        marketAverage: 12.50,
      ),
      MaterialItem(
        name: 'Tubo Conduit PVC 1/2"',
        quantity: '15',
        unit: 'pieza',
        unitPrice: 35.00,
        totalPrice: 525.00,
        wasAdjusted: false,
        marketAverage: 35.00,
      ),
      MaterialItem(
        name: 'Apagador Sencillo',
        quantity: '8',
        unit: 'pieza',
        unitPrice: 28.00,
        totalPrice: 224.00,
        wasAdjusted: false,
        marketAverage: 28.00,
      ),
      MaterialItem(
        name: 'Contacto Doble Polarizado',
        quantity: '12',
        unit: 'pieza',
        unitPrice: 32.00,
        totalPrice: 384.00,
        wasAdjusted: false,
        marketAverage: 32.00,
      ),
      MaterialItem(
        name: 'Caja Chalupa Cuadrada',
        quantity: '20',
        unit: 'pieza',
        unitPrice: 8.50,
        totalPrice: 170.00,
        wasAdjusted: false,
        marketAverage: 8.50,
      ),
    ];
  }

  Quotation _createMockQuotation(String projectId, String jobIdSuffix) {
    final materials = _generateRandomMaterials();
    double materialTotal =
        materials.fold(0, (sum, item) => sum + item.totalPrice);
    double labor = materialTotal * 0.55; // 55% labor cost

    return Quotation(
      id: _uuid.v4(),
      jobId: 'job_$jobIdSuffix',
      projectId: projectId,
      materials: materials,
      laborCost: double.parse(labor.toStringAsFixed(2)),
      totalCost: double.parse((materialTotal + labor).toStringAsFixed(2)),
      confidenceScore: 0.88 + (_random.nextDouble() * 0.10), // 0.88-0.98
      status: 'completed',
      createdAt: DateTime.now().subtract(Duration(days: _random.nextInt(5))),
    );
  }
}
