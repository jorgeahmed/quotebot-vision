import 'package:equatable/equatable.dart';
import 'workflow_state.dart';

enum ActivityStatus {
  pending,
  inProgress,
  review,
  completed,
  blocked,
}

enum ActivityPriority {
  low,
  medium,
  high,
  critical,
}

class Activity extends Equatable {
  final String id;
  final String projectId;
  final String title;
  final String description;
  final double estimatedCost;
  final double actualCost;
  final ActivityStatus status;
  final ActivityPriority priority;
  final WorkflowStage stage;
  final String? assignedTo;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime? completedAt;
  final List<String> attachments;
  final List<String> blockers;

  const Activity({
    required this.id,
    required this.projectId,
    required this.title,
    required this.description,
    this.estimatedCost = 0.0,
    this.actualCost = 0.0,
    this.status = ActivityStatus.pending,
    this.priority = ActivityPriority.medium,
    required this.stage,
    this.assignedTo,
    required this.startDate,
    this.endDate,
    this.completedAt,
    this.attachments = const [],
    this.blockers = const [],
  });

  bool get isCompleted => status == ActivityStatus.completed;
  bool get isBlocked => status == ActivityStatus.blocked || blockers.isNotEmpty;
  bool get isOverBudget => actualCost > estimatedCost;

  /// Copy with method
  Activity copyWith({
    String? title,
    String? description,
    double? estimatedCost,
    double? actualCost,
    ActivityStatus? status,
    ActivityPriority? priority,
    WorkflowStage? stage,
    String? assignedTo,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? completedAt,
    List<String>? attachments,
    List<String>? blockers,
  }) {
    return Activity(
      id: id,
      projectId: projectId,
      title: title ?? this.title,
      description: description ?? this.description,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      actualCost: actualCost ?? this.actualCost,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      stage: stage ?? this.stage,
      assignedTo: assignedTo ?? this.assignedTo,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      completedAt: completedAt ?? this.completedAt,
      attachments: attachments ?? this.attachments,
      blockers: blockers ?? this.blockers,
    );
  }

  @override
  List<Object?> get props => [
        id,
        projectId,
        title,
        description,
        estimatedCost,
        actualCost,
        status,
        priority,
        stage,
        assignedTo,
        startDate,
        endDate,
        completedAt,
        attachments,
        blockers,
      ];
}
