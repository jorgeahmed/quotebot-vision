import '../../domain/entities/quotation.dart';
import 'material_item_model.dart';

class QuotationModel extends Quotation {
  const QuotationModel({
    required super.id,
    required super.jobId,
    required super.projectId,
    required super.materials,
    required super.laborCost,
    required super.totalCost,
    required super.confidenceScore,
    required super.status,
    required super.createdAt,
    super.marketAdjustmentFactor,
  });

  factory QuotationModel.fromJson(Map<String, dynamic> json) {
    final materialsJson = json['materials'] as List? ?? [];
    final materials = materialsJson
        .map((m) => MaterialItemModel.fromJson(m as Map<String, dynamic>))
        .toList();

    return QuotationModel(
      id: json['id'] as String? ?? '',
      jobId: json['jobId'] as String? ?? '',
      projectId: json['projectId'] as String? ?? '',
      materials: materials,
      laborCost: (json['laborCost'] as num?)?.toDouble() ?? 0.0,
      totalCost: (json['totalCost'] as num?)?.toDouble() ?? 0.0,
      confidenceScore: (json['confidenceScore'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'draft',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      marketAdjustmentFactor:
          (json['marketAdjustmentFactor'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'jobId': jobId,
      'projectId': projectId,
      'materials':
          materials.map((m) => (m as MaterialItemModel).toJson()).toList(),
      'laborCost': laborCost,
      'totalCost': totalCost,
      'confidenceScore': confidenceScore,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'marketAdjustmentFactor': marketAdjustmentFactor,
    };
  }
}
