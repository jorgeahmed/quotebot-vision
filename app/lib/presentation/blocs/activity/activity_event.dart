import 'package:equatable/equatable.dart';
import '../../../domain/entities/activity.dart';
import '../../../domain/entities/workflow_state.dart';

abstract class ActivityEvent extends Equatable {
  const ActivityEvent();

  @override
  List<Object?> get props => [];
}

class LoadActivities extends ActivityEvent {
  final String projectId;

  const LoadActivities(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

class AddActivity extends ActivityEvent {
  final Activity activity;

  const AddActivity(this.activity);

  @override
  List<Object?> get props => [activity];
}

class UpdateActivity extends ActivityEvent {
  final Activity activity;

  const UpdateActivity(this.activity);

  @override
  List<Object?> get props => [activity];
}

class DeleteActivity extends ActivityEvent {
  final String projectId;
  final String activityId;

  const DeleteActivity(this.projectId, this.activityId);

  @override
  List<Object?> get props => [projectId, activityId];
}

class FilterActivitiesByStage extends ActivityEvent {
  final WorkflowStage? stage;

  const FilterActivitiesByStage(this.stage);

  @override
  List<Object?> get props => [stage];
}

class ActivitiesUpdated extends ActivityEvent {
  final List<Activity> activities;

  const ActivitiesUpdated(this.activities);

  @override
  List<Object?> get props => [activities];
}
