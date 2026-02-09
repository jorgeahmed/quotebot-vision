import 'dart:io';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/project_media.dart';
import '../../../domain/entities/workflow_state.dart';

abstract class MediaEvent extends Equatable {
  const MediaEvent();

  @override
  List<Object?> get props => [];
}

class LoadProjectMedia extends MediaEvent {
  final String projectId;

  const LoadProjectMedia(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

class UploadMediaFile extends MediaEvent {
  final String projectId;
  final File file;
  final MediaType type;
  final WorkflowStage stage;
  final String userId;
  final String? description;
  final String? activityId;

  const UploadMediaFile({
    required this.projectId,
    required this.file,
    required this.type,
    required this.stage,
    required this.userId,
    this.description,
    this.activityId,
  });

  @override
  List<Object?> get props =>
      [projectId, file, type, stage, userId, description, activityId];
}

class DeleteMediaFile extends MediaEvent {
  final String projectId;
  final String mediaId;

  const DeleteMediaFile(this.projectId, this.mediaId);

  @override
  List<Object?> get props => [projectId, mediaId];
}

class FilterMediaByStage extends MediaEvent {
  final WorkflowStage? stage;

  const FilterMediaByStage(this.stage);

  @override
  List<Object?> get props => [stage];
}

class MediaUpdated extends MediaEvent {
  final List<ProjectMedia> media;

  const MediaUpdated(this.media);

  @override
  List<Object?> get props => [media];
}
