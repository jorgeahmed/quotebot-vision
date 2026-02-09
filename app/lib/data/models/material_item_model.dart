import '../../domain/entities/material_item.dart';

class MaterialItemModel extends MaterialItem {
  const MaterialItemModel({
    required super.name,
    required super.quantity,
    required super.unit,
    required super.unitPrice,
    required super.totalPrice,
    super.marketAverage,
    required super.wasAdjusted,
    super.adjustmentReason,
  });

  factory MaterialItemModel.fromJson(Map<String, dynamic> json) {
    return MaterialItemModel(
      name: json['name'] as String? ?? '',
      quantity: json['quantity'] as String? ?? '',
      unit: json['unit'] as String? ?? '',
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      marketAverage: (json['marketAverage'] as num?)?.toDouble(),
      wasAdjusted: json['wasAdjusted'] as bool? ?? false,
      adjustmentReason: json['adjustmentReason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
      'marketAverage': marketAverage,
      'wasAdjusted': wasAdjusted,
      'adjustmentReason': adjustmentReason,
    };
  }
}
