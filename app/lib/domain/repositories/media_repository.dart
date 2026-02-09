import 'dart:io';
import '../entities/project_media.dart';
import '../entities/workflow_state.dart';

abstract class MediaRepository {
  /// Get all media for a project
  Stream<List<ProjectMedia>> getProjectMedia(String projectId);

  /// Get media filtered by stage
  Future<List<ProjectMedia>> getMediaByStage(
      String projectId, WorkflowStage stage);

  /// Upload a new media file (Photo or Video)
  /// Returns the created ProjectMedia entity
  Future<ProjectMedia> uploadMedia({
    required String projectId,
    required File file,
    required MediaType type,
    required WorkflowStage stage,
    required String userId,
    String? description,
    String? activityId,
  });

  /// Delete media
  Future<void> deleteMedia(String projectId, String mediaId);

  /// Update media metadata (e.g. description)
  Future<void> updateMedia(ProjectMedia media);
}
