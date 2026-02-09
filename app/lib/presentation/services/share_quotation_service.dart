import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/quotation.dart';

class ShareQuotationService {
  // Generar texto formateado de cotización para compartir
  static String generateShareText(Quotation quotation) {
    final buffer = StringBuffer();

    buffer.writeln('📋 COTIZACIÓN QUOTEBOT');
    buffer.writeln('=' * 40);
    buffer.writeln();
    buffer.writeln('🏗️ Proyecto: ${quotation.projectId}');
    buffer.writeln('📅 Fecha: ${_formatDate(quotation.createdAt)}');
    buffer.writeln();
    buffer.writeln(
        '💰 PRECIO TOTAL: \$${quotation.totalCost.toStringAsFixed(2)}');
    buffer
        .writeln('   Confianza: ${(quotation.confidenceScore * 100).toInt()}%');
    buffer.writeln();
    buffer.writeln('📦 MATERIALES:');
    buffer.writeln('-' * 40);

    for (final material in quotation.materials) {
      buffer.writeln('• ${material.name}');
      buffer.writeln(
          '  ${material.quantity} ${material.unit} × \$${material.unitPrice.toStringAsFixed(2)} = \$${material.totalPrice.toStringAsFixed(2)}');
      if (material.wasAdjusted && material.adjustmentReason != null) {
        buffer.writeln('  ⚡ ${material.adjustmentReason}');
      }
      buffer.writeln();
    }

    buffer.writeln('-' * 40);
    buffer.writeln(
        '👷 Mano de obra: \$${quotation.laborCost.toStringAsFixed(2)}');
    buffer.writeln();
    buffer.writeln('Generado con QuoteBot 🤖');
    buffer.writeln('Sistema de cotización inteligente con IA');

    return buffer.toString();
  }

  // Copiar al clipboard
  static Future<void> copyToClipboard(
      BuildContext context, Quotation quotation) async {
    final text = generateShareText(quotation);
    await Clipboard.setData(ClipboardData(text: text));

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Cotización copiada al portapapeles'),
            ],
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // Generar resumen corto para compartir
  static String generateSummary(Quotation quotation) {
    return '💰 Cotización: \$${quotation.totalCost.toStringAsFixed(2)} | '
        '${quotation.materials.length} materiales | '
        'Confianza: ${(quotation.confidenceScore * 100).toInt()}%';
  }

  static String _formatDate(DateTime date) {
    final months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
