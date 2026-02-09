import 'package:equatable/equatable.dart';

class MaterialItem extends Equatable {
  final String name;
  final String quantity;
  final String unit;
  final double unitPrice;
  final double totalPrice;
  final double? marketAverage;
  final bool wasAdjusted;
  final String? adjustmentReason;

  const MaterialItem({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
    required this.totalPrice,
    this.marketAverage,
    required this.wasAdjusted,
    this.adjustmentReason,
  });

  @override
  List<Object?> get props => [
        name,
        quantity,
        unit,
        unitPrice,
        totalPrice,
        marketAverage,
        wasAdjusted,
        adjustmentReason,
      ];
}
