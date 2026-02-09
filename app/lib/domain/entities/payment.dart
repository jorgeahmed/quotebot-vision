import 'package:equatable/equatable.dart';

enum PaymentMethod { creditCard, cash, transfer }

enum PaymentStatus { pending, completed, failed }

class Payment extends Equatable {
  final String id;
  final String quotationId;
  final double amount;
  final PaymentMethod method;
  final PaymentStatus status;
  final DateTime date;

  const Payment({
    required this.id,
    required this.quotationId,
    required this.amount,
    required this.method,
    required this.status,
    required this.date,
  });

  @override
  List<Object> get props => [id, quotationId, amount, method, status, date];
}
