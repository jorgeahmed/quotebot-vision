import '../entities/payment.dart';

abstract class PaymentRepository {
  Future<Payment> processPayment({
    required String quotationId,
    required double amount,
    required PaymentMethod method,
  });

  Future<Payment?> getPaymentByQuotation(String quotationId);
}
