import '../entities/activity.dart';
import '../entities/workflow_state.dart';

abstract class ActivityRepository {
  /// Get all activities for a project
  Stream<List<Activity>> getProjectActivities(String projectId);

  /// Get activities for a specific stage of a project
  Future<List<Activity>> getActivitiesByStage(
      String projectId, WorkflowStage stage);

  /// Add a new activity
  Future<void> addActivity(Activity activity);

  /// Update an existing activity
  Future<void> updateActivity(Activity activity);

  /// Delete an activity
  Future<void> deleteActivity(String projectId, String activityId);

  /// Update activity status
  Future<void> updateActivityStatus(
      String projectId, String activityId, ActivityStatus status);
}
