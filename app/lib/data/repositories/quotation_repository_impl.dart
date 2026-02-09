import 'package:flutter/foundation.dart';
import '../../domain/entities/quotation.dart';
import '../../domain/repositories/quotation_repository.dart';
import '../models/quotation_model.dart';
import '../services/api_client.dart';

class QuotationRepositoryImpl implements QuotationRepository {
  final ApiClient _apiClient;

  QuotationRepositoryImpl({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  @override
  Future<Quotation> generateQuotation(String jobId) async {
    try {
      final response = await _apiClient.post(
        '/quotations/generate',
        data: {'jobId': jobId},
      );

      if (response.statusCode == 200 && response.data != null) {
        final quotationData =
            response.data['quotation'] as Map<String, dynamic>;
        return QuotationModel.fromJson(quotationData);
      } else {
        throw Exception('Failed to generate quotation: ${response.data}');
      }
    } catch (e) {
      debugPrint('Error generating quotation: $e');
      rethrow;
    }
  }

  @override
  Future<Quotation> getQuotation(String quotationId) async {
    try {
      final response = await _apiClient.get('/quotations/$quotationId');

      if (response.statusCode == 200 && response.data != null) {
        return QuotationModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to get quotation: ${response.data}');
      }
    } catch (e) {
      debugPrint('Error getting quotation: $e');
      rethrow;
    }
  }

  @override
  Future<List<Quotation>> getProjectQuotations(String projectId) async {
    try {
      final response = await _apiClient.get('/quotations/project/$projectId');

      if (response.statusCode == 200 && response.data != null) {
        final quotationsData = response.data['quotations'] as List? ?? [];
        return quotationsData
            .map((q) => QuotationModel.fromJson(q as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to get project quotations: ${response.data}');
      }
    } catch (e) {
      debugPrint('Error getting project quotations: $e');
      return []; // Return empty list on error for better UX
    }
  }
}
