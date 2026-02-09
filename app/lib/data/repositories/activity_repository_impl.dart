import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/activity.dart';
import '../../domain/entities/workflow_state.dart';
import '../../domain/repositories/activity_repository.dart';
import '../models/activity_model.dart';

class ActivityRepositoryImpl implements ActivityRepository {
  final FirebaseFirestore _firestore;

  ActivityRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<Activity>> getProjectActivities(String projectId) {
    return _firestore
        .collection('projects')
        .doc(projectId)
        .collection('activities')
        .orderBy('startDate')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ActivityModel.fromJson(doc.data()))
          .toList();
    });
  }

  @override
  Future<List<Activity>> getActivitiesByStage(
      String projectId, WorkflowStage stage) async {
    final snapshot = await _firestore
        .collection('projects')
        .doc(projectId)
        .collection('activities')
        .where('stage', isEqualTo: stage.name)
        .get();

    return snapshot.docs
        .map((doc) => ActivityModel.fromJson(doc.data()))
        .toList();
  }

  @override
  Future<void> addActivity(Activity activity) async {
    final model = ActivityModel.fromEntity(activity);
    await _firestore
        .collection('projects')
        .doc(activity.projectId)
        .collection('activities')
        .doc(activity.id)
        .set(model.toJson());
  }

  @override
  Future<void> updateActivity(Activity activity) async {
    final model = ActivityModel.fromEntity(activity);
    await _firestore
        .collection('projects')
        .doc(activity.projectId)
        .collection('activities')
        .doc(activity.id)
        .update(model.toJson());
  }

  @override
  Future<void> deleteActivity(String projectId, String activityId) async {
    await _firestore
        .collection('projects')
        .doc(projectId)
        .collection('activities')
        .doc(activityId)
        .delete();
  }

  @override
  Future<void> updateActivityStatus(
      String projectId, String activityId, ActivityStatus status) async {
    await _firestore
        .collection('projects')
        .doc(projectId)
        .collection('activities')
        .doc(activityId)
        .update({'status': status.name});
  }
}
