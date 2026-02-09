import '../../domain/entities/workflow_state.dart';

class WorkflowStateModel extends WorkflowState {
  const WorkflowStateModel({
    required super.mainStage,
    required super.subState,
    super.progress,
    super.history,
    super.currentMilestone,
    super.blockers,
    required super.lastUpdated,
  });

  factory WorkflowStateModel.fromJson(Map<String, dynamic> json) {
    return WorkflowStateModel(
      mainStage: _stageFromString(json['mainStage'] as String? ?? 'planning'),
      subState: json['subState'] as String? ?? 'draft',
      progress: json['progress'] as int? ?? 0,
      history: (json['history'] as List? ?? [])
          .map((h) => _transitionFromJson(h as Map<String, dynamic>))
          .toList(),
      currentMilestone: json['currentMilestone'] as String?,
      blockers:
          (json['blockers'] as List? ?? []).map((b) => b as String).toList(),
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mainStage': mainStage.name,
      'subState': subState,
      'progress': progress,
      'history': history.map(_transitionToJson).toList(),
      'currentMilestone': currentMilestone,
      'blockers': blockers,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  static WorkflowStage _stageFromString(String stage) {
    switch (stage.toLowerCase()) {
      case 'planning':
        return WorkflowStage.planning;
      case 'survey':
        return WorkflowStage.survey;
      case 'quotation':
        return WorkflowStage.quotation;
      case 'execution':
        return WorkflowStage.execution;
      case 'completion':
        return WorkflowStage.completion;
      default:
        return WorkflowStage.planning;
    }
  }

  static WorkflowTransitionRecord _transitionFromJson(
      Map<String, dynamic> json) {
    return WorkflowTransitionRecord(
      fromState: json['fromState'] as String,
      toState: json['toState'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      changedBy: json['changedBy'] as String,
      reason: json['reason'] as String?,
    );
  }

  static Map<String, dynamic> _transitionToJson(
      WorkflowTransitionRecord transition) {
    return {
      'fromState': transition.fromState,
      'toState': transition.toState,
      'timestamp': transition.timestamp.toIso8601String(),
      'changedBy': transition.changedBy,
      'reason': transition.reason,
    };
  }

  factory WorkflowStateModel.fromEntity(WorkflowState state) {
    return WorkflowStateModel(
      mainStage: state.mainStage,
      subState: state.subState,
      progress: state.progress,
      history: state.history,
      currentMilestone: state.currentMilestone,
      blockers: state.blockers,
      lastUpdated: state.lastUpdated,
    );
  }

  /// Create initial workflow state for new project
  factory WorkflowStateModel.initial() {
    return WorkflowStateModel(
      mainStage: WorkflowStage.planning,
      subState: 'draft',
      progress: 0,
      history: const [],
      currentMilestone: null,
      blockers: const [],
      lastUpdated: DateTime.now(),
    );
  }
}
