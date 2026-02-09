import 'package:equatable/equatable.dart';
import '../../../domain/entities/payment.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object> get props => [];
}

class ProcessPayment extends PaymentEvent {
  final String quotationId;
  final double amount;
  final PaymentMethod method;

  const ProcessPayment({
    required this.quotationId,
    required this.amount,
    required this.method,
  });

  @override
  List<Object> get props => [quotationId, amount, method];
}

class CheckPaymentStatus extends PaymentEvent {
  final String quotationId;

  const CheckPaymentStatus(this.quotationId);

  @override
  List<Object> get props => [quotationId];
}
