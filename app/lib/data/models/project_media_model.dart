import '../../domain/entities/project_media.dart';
import '../../domain/entities/workflow_state.dart';

class ProjectMediaModel extends ProjectMedia {
  const ProjectMediaModel({
    required super.id,
    required super.projectId,
    required super.url,
    super.thumbnailUrl,
    required super.type,
    required super.stage,
    super.activityId,
    required super.createdAt,
    required super.createdBy,
    super.description,
    super.location,
  });

  factory ProjectMediaModel.fromJson(Map<String, dynamic> json) {
    return ProjectMediaModel(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      url: json['url'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      type: _typeFromString(json['type'] as String? ?? 'photo'),
      stage: _stageFromString(json['stage'] as String? ?? 'planning'),
      activityId: json['activityId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      createdBy: json['createdBy'] as String,
      description: json['description'] as String?,
      location: (json['location'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(key, (value as num).toDouble()),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'url': url,
      'thumbnailUrl': thumbnailUrl,
      'type': type.name,
      'stage': stage.name,
      'activityId': activityId,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
      'description': description,
      'location': location,
    };
  }

  factory ProjectMediaModel.fromEntity(ProjectMedia media) {
    return ProjectMediaModel(
      id: media.id,
      projectId: media.projectId,
      url: media.url,
      thumbnailUrl: media.thumbnailUrl,
      type: media.type,
      stage: media.stage,
      activityId: media.activityId,
      createdAt: media.createdAt,
      createdBy: media.createdBy,
      description: media.description,
      location: media.location,
    );
  }

  static MediaType _typeFromString(String type) {
    return MediaType.values.firstWhere(
      (e) => e.name == type,
      orElse: () => MediaType.photo,
    );
  }

  static WorkflowStage _stageFromString(String stage) {
    return WorkflowStage.values.firstWhere(
      (e) => e.name == stage,
      orElse: () => WorkflowStage.planning,
    );
  }
}
