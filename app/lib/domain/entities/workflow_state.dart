import 'package:equatable/equatable.dart';

/// Main workflow stages
enum WorkflowStage {
  planning,
  survey,
  quotation,
  execution,
  completion,
}

/// Sub-states for Planning stage
enum PlanningState {
  draft,
  published,
  quoteRequested,
}

/// Sub-states for Survey stage
enum SurveyState {
  visitPaymentPending,
  visitPaid,
  visitScheduled,
  surveyCompleted,
}

/// Sub-states for Quotation stage
enum QuotationState {
  quoteInReview,
  quoteAdjustments,
  quoteApproved,
  quoteRejected,
}

/// Sub-states for Execution stage
enum ExecutionState {
  contractSigned,
  inProgress,
  milestoneReview,
  paused,
}

/// Sub-states for Completion stage
enum CompletionState {
  completed,
  archived,
  disputed,
}

/// Represents a transition in workflow history
class WorkflowTransitionRecord extends Equatable {
  final String fromState;
  final String toState;
  final DateTime timestamp;
  final String changedBy;
  final String? reason;

  const WorkflowTransitionRecord({
    required this.fromState,
    required this.toState,
    required this.timestamp,
    required this.changedBy,
    this.reason,
  });

  @override
  List<Object?> get props => [fromState, toState, timestamp, changedBy, reason];
}

/// Complete workflow state of a project
class WorkflowState extends Equatable {
  final WorkflowStage mainStage;
  final String subState;
  final int progress; // 0-100
  final List<WorkflowTransitionRecord> history;
  final String? currentMilestone;
  final List<String> blockers;
  final DateTime lastUpdated;

  const WorkflowState({
    required this.mainStage,
    required this.subState,
    this.progress = 0,
    this.history = const [],
    this.currentMilestone,
    this.blockers = const [],
    required this.lastUpdated,
  });

  /// Get user-friendly stage name
  String get stageName {
    switch (mainStage) {
      case WorkflowStage.planning:
        return 'Planeación';
      case WorkflowStage.survey:
        return 'Levantamiento';
      case WorkflowStage.quotation:
        return 'Cotización';
      case WorkflowStage.execution:
        return 'Ejecución';
      case WorkflowStage.completion:
        return 'Finalización';
    }
  }

  /// Get user-friendly sub-state name
  String get subStateName {
    return _formatSubState(subState);
  }

  /// Check if workflow is blocked
  bool get isBlocked => blockers.isNotEmpty;

  /// Check if project is active
  bool get isActive =>
      mainStage != WorkflowStage.completion || subState != 'archived';

  /// Create new state with transition
  WorkflowState transitionTo({
    WorkflowStage? newStage,
    String? newSubState,
    int? newProgress,
    required String changedBy,
    String? reason,
    String? milestone,
    List<String>? newBlockers,
  }) {
    final transition = WorkflowTransitionRecord(
      fromState: '${mainStage.name}:$subState',
      toState: '${(newStage ?? mainStage).name}:${newSubState ?? subState}',
      timestamp: DateTime.now(),
      changedBy: changedBy,
      reason: reason,
    );

    return WorkflowState(
      mainStage: newStage ?? mainStage,
      subState: newSubState ?? subState,
      progress: newProgress ?? progress,
      history: [...history, transition],
      currentMilestone: milestone ?? currentMilestone,
      blockers: newBlockers ?? blockers,
      lastUpdated: DateTime.now(),
    );
  }

  /// Create a copy of state with updated fields
  WorkflowState copyWith({
    WorkflowStage? mainStage,
    String? subState,
    int? progress,
    List<WorkflowTransitionRecord>? history,
    String? currentMilestone,
    List<String>? blockers,
    DateTime? lastUpdated,
  }) {
    return WorkflowState(
      mainStage: mainStage ?? this.mainStage,
      subState: subState ?? this.subState,
      progress: progress ?? this.progress,
      history: history ?? this.history,
      currentMilestone: currentMilestone ?? this.currentMilestone,
      blockers: blockers ?? this.blockers,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// Calculate stage index (0-4)
  int get stageIndex {
    switch (mainStage) {
      case WorkflowStage.planning:
        return 0;
      case WorkflowStage.survey:
        return 1;
      case WorkflowStage.quotation:
        return 2;
      case WorkflowStage.execution:
        return 3;
      case WorkflowStage.completion:
        return 4;
    }
  }

  /// Check if stage is completed
  bool isStageCompleted(WorkflowStage stage) {
    return stageIndex > stage.index;
  }

  /// Check if stage is current
  bool isCurrentStage(WorkflowStage stage) {
    return mainStage == stage;
  }

  String _formatSubState(String state) {
    // Convert camelCase to readable format
    final result = state.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (match) => ' ${match.group(0)}',
    );
    return result[0].toUpperCase() + result.substring(1);
  }

  @override
  List<Object?> get props => [
        mainStage,
        subState,
        progress,
        history,
        currentMilestone,
        blockers,
        lastUpdated,
      ];
}
