import 'package:uuid/uuid.dart';
import '../../domain/entities/payment.dart';
import '../../domain/repositories/payment_repository.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final _uuid = const Uuid();

  // Mock in-memory storage for payments
  final List<Payment> _mockPayments = [];

  @override
  Future<Payment> processPayment({
    required String quotationId,
    required double amount,
    required PaymentMethod method,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Simulate random failure (10% chance)
    // if (DateTime.now().millisecond % 10 == 0) {
    //   throw Exception('Payment declined by bank');
    // }

    final payment = Payment(
      id: _uuid.v4(),
      quotationId: quotationId,
      amount: amount,
      method: method,
      status: PaymentStatus.completed,
      date: DateTime.now(),
    );

    _mockPayments.add(payment);
    return payment;
  }

  @override
  Future<Payment?> getPaymentByQuotation(String quotationId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      return _mockPayments.firstWhere(
        (p) =>
            p.quotationId == quotationId && p.status == PaymentStatus.completed,
      );
    } catch (e) {
      return null;
    }
  }
}
