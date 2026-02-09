import 'package:equatable/equatable.dart';
import '../../../domain/entities/activity.dart';
import '../../../domain/entities/workflow_state.dart';

abstract class ActivityState extends Equatable {
  const ActivityState();

  @override
  List<Object?> get props => [];
}

class ActivityInitial extends ActivityState {}

class ActivityLoading extends ActivityState {}

class ActivityLoaded extends ActivityState {
  final List<Activity> allActivities;
  final List<Activity> filteredActivities;
  final WorkflowStage? currentStageFilter;

  const ActivityLoaded({
    required this.allActivities,
    this.filteredActivities = const [],
    this.currentStageFilter,
  });

  ActivityLoaded copyWith({
    List<Activity>? allActivities,
    List<Activity>? filteredActivities,
    WorkflowStage? currentStageFilter,
  }) {
    return ActivityLoaded(
      allActivities: allActivities ?? this.allActivities,
      filteredActivities: filteredActivities ?? this.filteredActivities,
      currentStageFilter: currentStageFilter ?? this.currentStageFilter,
    );
  }

  @override
  List<Object?> get props =>
      [allActivities, filteredActivities, currentStageFilter];
}

class ActivityError extends ActivityState {
  final String message;

  const ActivityError(this.message);

  @override
  List<Object?> get props => [message];
}

class ActivityOperationSuccess extends ActivityState {
  final String message;

  const ActivityOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
