import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/quotation_repository.dart';
import 'quotation_event.dart';
import 'quotation_state.dart';

class QuotationBloc extends Bloc<QuotationEvent, QuotationState> {
  final QuotationRepository repository;

  QuotationBloc(this.repository) : super(QuotationInitial()) {
    on<GenerateQuotation>(_onGenerateQuotation);
    on<LoadQuotation>(_onLoadQuotation);
    on<LoadProjectQuotations>(_onLoadProjectQuotations);
  }

  Future<void> _onGenerateQuotation(
    GenerateQuotation event,
    Emitter<QuotationState> emit,
  ) async {
    emit(QuotationLoading());
    try {
      final quotation = await repository.generateQuotation(event.jobId);
      emit(QuotationLoaded(quotation));
    } catch (e) {
      emit(QuotationError('Failed to generate quotation: ${e.toString()}'));
    }
  }

  Future<void> _onLoadQuotation(
    LoadQuotation event,
    Emitter<QuotationState> emit,
  ) async {
    emit(QuotationLoading());
    try {
      final quotation = await repository.getQuotation(event.quotationId);
      emit(QuotationLoaded(quotation));
    } catch (e) {
      emit(QuotationError('Failed to load quotation: ${e.toString()}'));
    }
  }

  Future<void> _onLoadProjectQuotations(
    LoadProjectQuotations event,
    Emitter<QuotationState> emit,
  ) async {
    emit(QuotationLoading());
    try {
      final quotations = await repository.getProjectQuotations(event.projectId);
      emit(QuotationsLoaded(quotations));
    } catch (e) {
      emit(
          QuotationError('Failed to load project quotations: ${e.toString()}'));
    }
  }
}
