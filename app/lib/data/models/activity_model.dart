import '../../domain/entities/activity.dart';
import '../../domain/entities/workflow_state.dart';

class ActivityModel extends Activity {
  const ActivityModel({
    required super.id,
    required super.projectId,
    required super.title,
    required super.description,
    super.estimatedCost,
    super.actualCost,
    super.status,
    super.priority,
    required super.stage,
    super.assignedTo,
    required super.startDate,
    super.endDate,
    super.completedAt,
    super.attachments,
    super.blockers,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      estimatedCost: (json['estimatedCost'] as num?)?.toDouble() ?? 0.0,
      actualCost: (json['actualCost'] as num?)?.toDouble() ?? 0.0,
      status: _statusFromString(json['status'] as String? ?? 'pending'),
      priority: _priorityFromString(json['priority'] as String? ?? 'medium'),
      stage: _stageFromString(json['stage'] as String? ?? 'planning'),
      assignedTo: json['assignedTo'] as String?,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      attachments:
          (json['attachments'] as List? ?? []).map((e) => e as String).toList(),
      blockers:
          (json['blockers'] as List? ?? []).map((e) => e as String).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'title': title,
      'description': description,
      'estimatedCost': estimatedCost,
      'actualCost': actualCost,
      'status': status.name,
      'priority': priority.name,
      'stage': stage.name,
      'assignedTo': assignedTo,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'attachments': attachments,
      'blockers': blockers,
    };
  }

  factory ActivityModel.fromEntity(Activity activity) {
    return ActivityModel(
      id: activity.id,
      projectId: activity.projectId,
      title: activity.title,
      description: activity.description,
      estimatedCost: activity.estimatedCost,
      actualCost: activity.actualCost,
      status: activity.status,
      priority: activity.priority,
      stage: activity.stage,
      assignedTo: activity.assignedTo,
      startDate: activity.startDate,
      endDate: activity.endDate,
      completedAt: activity.completedAt,
      attachments: activity.attachments,
      blockers: activity.blockers,
    );
  }

  static ActivityStatus _statusFromString(String status) {
    return ActivityStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => ActivityStatus.pending,
    );
  }

  static ActivityPriority _priorityFromString(String priority) {
    return ActivityPriority.values.firstWhere(
      (e) => e.name == priority,
      orElse: () => ActivityPriority.medium,
    );
  }

  static WorkflowStage _stageFromString(String stage) {
    return WorkflowStage.values.firstWhere(
      (e) => e.name == stage,
      orElse: () => WorkflowStage.planning,
    );
  }
}
