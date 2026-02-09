import '../entities/quotation.dart';

abstract class QuotationRepository {
  Future<Quotation> generateQuotation(String jobId);
  Future<Quotation> getQuotation(String quotationId);
  Future<List<Quotation>> getProjectQuotations(String projectId);
}
