import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/project_media.dart';
import '../../domain/entities/workflow_state.dart';
import '../../domain/repositories/media_repository.dart';
import '../models/project_media_model.dart';

class MediaRepositoryImpl implements MediaRepository {
  final FirebaseFirestore _firestore;

  MediaRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<ProjectMedia>> getProjectMedia(String projectId) {
    return _firestore
        .collection('projects')
        .doc(projectId)
        .collection('media')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ProjectMediaModel.fromJson(doc.data()))
          .toList();
    });
  }

  @override
  Future<List<ProjectMedia>> getMediaByStage(
      String projectId, WorkflowStage stage) async {
    final snapshot = await _firestore
        .collection('projects')
        .doc(projectId)
        .collection('media')
        .where('stage', isEqualTo: stage.name)
        .get();

    return snapshot.docs
        .map((doc) => ProjectMediaModel.fromJson(doc.data()))
        .toList();
  }

  @override
  Future<ProjectMedia> uploadMedia({
    required String projectId,
    required File file,
    required MediaType type,
    required WorkflowStage stage,
    required String userId,
    String? description,
    String? activityId,
  }) async {
    // Note: In a real app, we would upload to Firebase Storage here.
    // using simulated upload for now.

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1500));

    final mediaId = const Uuid().v4();
    // fileName not used in simulation

    // Mock URL - In production this comes from Storage
    // Using a placeholder service for images if type is photo
    final mockUrl = type == MediaType.photo
        ? 'https://picsum.photos/seed/$mediaId/800/600'
        : 'https://www.w3schools.com/html/mov_bbb.mp4'; // Mock video

    final media = ProjectMedia(
      id: mediaId,
      projectId: projectId,
      url: mockUrl,
      type: type,
      stage: stage,
      activityId: activityId,
      createdAt: DateTime.now(),
      createdBy: userId,
      description: description,
    );

    final model = ProjectMediaModel.fromEntity(media);

    await _firestore
        .collection('projects')
        .doc(projectId)
        .collection('media')
        .doc(mediaId)
        .set(model.toJson());

    return media;
  }

  @override
  Future<void> deleteMedia(String projectId, String mediaId) async {
    await _firestore
        .collection('projects')
        .doc(projectId)
        .collection('media')
        .doc(mediaId)
        .delete();
  }

  @override
  Future<void> updateMedia(ProjectMedia media) async {
    final model = ProjectMediaModel.fromEntity(media);
    await _firestore
        .collection('projects')
        .doc(media.projectId)
        .collection('media')
        .doc(media.id)
        .update(model.toJson());
  }
}
