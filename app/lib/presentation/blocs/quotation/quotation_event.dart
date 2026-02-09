import 'package:equatable/equatable.dart';

abstract class QuotationEvent extends Equatable {
  const QuotationEvent();

  @override
  List<Object?> get props => [];
}

class GenerateQuotation extends QuotationEvent {
  final String jobId;

  const GenerateQuotation(this.jobId);

  @override
  List<Object?> get props => [jobId];
}

class LoadQuotation extends QuotationEvent {
  final String quotationId;

  const LoadQuotation(this.quotationId);

  @override
  List<Object?> get props => [quotationId];
}

class LoadProjectQuotations extends QuotationEvent {
  final String projectId;

  const LoadProjectQuotations(this.projectId);

  @override
  List<Object?> get props => [projectId];
}
