import 'package:equatable/equatable.dart';
import 'material_item.dart';

class Quotation extends Equatable {
  final String id;
  final String jobId;
  final String projectId;
  final List<MaterialItem> materials;
  final double laborCost;
  final double totalCost;
  final double confidenceScore;
  final String status;
  final DateTime createdAt;
  final double? marketAdjustmentFactor;

  const Quotation({
    required this.id,
    required this.jobId,
    required this.projectId,
    required this.materials,
    required this.laborCost,
    required this.totalCost,
    required this.confidenceScore,
    required this.status,
    required this.createdAt,
    this.marketAdjustmentFactor,
  });

  @override
  List<Object?> get props => [
        id,
        jobId,
        projectId,
        materials,
        laborCost,
        totalCost,
        confidenceScore,
        status,
        createdAt,
        marketAdjustmentFactor,
      ];
}
