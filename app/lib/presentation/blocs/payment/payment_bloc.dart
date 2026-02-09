import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/payment_repository.dart';
import 'payment_event.dart';
import 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final PaymentRepository _paymentRepository;

  PaymentBloc(this._paymentRepository) : super(PaymentInitial()) {
    on<ProcessPayment>(_onProcessPayment);
    on<CheckPaymentStatus>(_onCheckPaymentStatus);
  }

  Future<void> _onProcessPayment(
    ProcessPayment event,
    Emitter<PaymentState> emit,
  ) async {
    emit(PaymentLoading());
    try {
      final payment = await _paymentRepository.processPayment(
        quotationId: event.quotationId,
        amount: event.amount,
        method: event.method,
      );
      emit(PaymentSuccess(payment));
    } catch (e) {
      emit(PaymentFailure(e.toString()));
    }
  }

  Future<void> _onCheckPaymentStatus(
    CheckPaymentStatus event,
    Emitter<PaymentState> emit,
  ) async {
    emit(PaymentLoading());
    try {
      final payment =
          await _paymentRepository.getPaymentByQuotation(event.quotationId);
      emit(PaymentStatusLoaded(payment));
    } catch (e) {
      emit(PaymentFailure("Failed to check status: $e"));
    }
  }
}
