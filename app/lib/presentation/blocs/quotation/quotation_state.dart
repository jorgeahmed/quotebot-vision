import 'package:equatable/equatable.dart';
import '../../../domain/entities/quotation.dart';

abstract class QuotationState extends Equatable {
  const QuotationState();

  @override
  List<Object?> get props => [];
}

class QuotationInitial extends QuotationState {}

class QuotationLoading extends QuotationState {}

class QuotationLoaded extends QuotationState {
  final Quotation quotation;

  const QuotationLoaded(this.quotation);

  @override
  List<Object?> get props => [quotation];
}

class QuotationsLoaded extends QuotationState {
  final List<Quotation> quotations;

  const QuotationsLoaded(this.quotations);

  @override
  List<Object?> get props => [quotations];
}

class QuotationError extends QuotationState {
  final String message;

  const QuotationError(this.message);

  @override
  List<Object?> get props => [message];
}
