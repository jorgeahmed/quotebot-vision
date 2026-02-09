import 'package:equatable/equatable.dart';
import 'workflow_state.dart';

enum MediaType {
  photo,
  video,
  document,
}

class ProjectMedia extends Equatable {
  final String id;
  final String projectId;
  final String url;
  final String? thumbnailUrl;
  final MediaType type;
  final WorkflowStage stage;
  final String? activityId;
  final DateTime createdAt;
  final String createdBy; // userId
  final String? description;
  final Map<String, double>? location; // {lat, lng}

  const ProjectMedia({
    required this.id,
    required this.projectId,
    required this.url,
    this.thumbnailUrl,
    required this.type,
    required this.stage,
    this.activityId,
    required this.createdAt,
    required this.createdBy,
    this.description,
    this.location,
  });

  bool get isVideo => type == MediaType.video;
  bool get isPhoto => type == MediaType.photo;

  ProjectMedia copyWith({
    String? url,
    String? thumbnailUrl,
    MediaType? type,
    WorkflowStage? stage,
    String? activityId,
    String? description,
    Map<String, double>? location,
  }) {
    return ProjectMedia(
      id: id,
      projectId: projectId,
      url: url ?? this.url,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      type: type ?? this.type,
      stage: stage ?? this.stage,
      activityId: activityId ?? this.activityId,
      createdAt: createdAt,
      createdBy: createdBy,
      description: description ?? this.description,
      location: location ?? this.location,
    );
  }

  @override
  List<Object?> get props => [
        id,
        projectId,
        url,
        thumbnailUrl,
        type,
        stage,
        activityId,
        createdAt,
        createdBy,
        description,
        location,
      ];
}
