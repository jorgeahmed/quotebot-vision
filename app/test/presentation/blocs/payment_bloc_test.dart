import 'package:flutter_test/flutter_test.dart';
import 'package:quotebot_vision/presentation/blocs/payment/payment_bloc.dart';
import 'package:quotebot_vision/presentation/blocs/payment/payment_event.dart';
import 'package:quotebot_vision/presentation/blocs/payment/payment_state.dart';
import 'package:quotebot_vision/domain/repositories/payment_repository.dart';
import 'package:quotebot_vision/domain/entities/payment.dart';

// Manual Mock
class MockPaymentRepository implements PaymentRepository {
  bool shouldFail = false;

  @override
  Future<Payment> processPayment({
    required String quotationId,
    required double amount,
    required PaymentMethod method,
  }) async {
    if (shouldFail) {
      throw Exception('Payment failed');
    }
    return Payment(
      id: 'test-payment-id',
      quotationId: quotationId,
      amount: amount,
      method: method,
      status: PaymentStatus.completed,
      date: DateTime.now(),
    );
  }

  @override
  Future<Payment?> getPaymentByQuotation(String quotationId) async {
    return null;
  }
}

void main() {
  group('PaymentBloc', () {
    late PaymentBloc paymentBloc;
    late MockPaymentRepository mockRepository;

    setUp(() {
      mockRepository = MockPaymentRepository();
      paymentBloc = PaymentBloc(mockRepository);
    });

    tearDown(() {
      paymentBloc.close();
    });

    test('initial state is PaymentInitial', () {
      expect(paymentBloc.state, isA<PaymentInitial>());
    });

    test('emits [PaymentLoading, PaymentSuccess] when ProcessPayment succeeds',
        () async {
      final expectedResponse = [
        isA<PaymentLoading>(),
        isA<PaymentSuccess>(),
      ];

      expectLater(paymentBloc.stream, emitsInOrder(expectedResponse));

      paymentBloc.add(const ProcessPayment(
        quotationId: 'quote-123',
        amount: 100.0,
        method: PaymentMethod.creditCard,
      ));
    });

    test('emits [PaymentLoading, PaymentFailure] when ProcessPayment fails',
        () async {
      mockRepository.shouldFail = true;

      final expectedResponse = [
        isA<PaymentLoading>(),
        isA<PaymentFailure>(),
      ];

      expectLater(paymentBloc.stream, emitsInOrder(expectedResponse));

      paymentBloc.add(const ProcessPayment(
        quotationId: 'quote-123',
        amount: 100.0,
        method: PaymentMethod.creditCard,
      ));
    });
  });
}
