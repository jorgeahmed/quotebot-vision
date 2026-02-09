import '../../domain/entities/project.dart';
import 'workflow_state_model.dart';

class ProjectModel extends Project {
  const ProjectModel({
    required super.id,
    required super.name,
    required super.description,
    required super.location,
    required super.createdAt,
    WorkflowStateModel? super.workflowState,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] ?? '',
      name: json['name'] is Map
          ? json['name']['es'] ?? json['name']['en'] ?? ''
          : json['name'] ?? '',
      description: json['description'] is Map
          ? json['description']['es'] ?? json['description']['en'] ?? ''
          : json['description'] ?? '',
      location: json['location'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      workflowState: json['workflow_state'] != null
          ? WorkflowStateModel.fromJson(
              Map<String, dynamic>.from(json['workflow_state']))
          : WorkflowStateModel.initial(), // Default if missing
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': {'es': name, 'en': name}, // Default to both for now
      'description': {'es': description, 'en': description},
      'location': location,
      'created_at': createdAt.toIso8601String(),
      'workflow_state': workflowState != null
          ? WorkflowStateModel.fromEntity(workflowState!).toJson()
          : null,
    };
  }

  factory ProjectModel.fromEntity(Project project) {
    return ProjectModel(
      id: project.id,
      name: project.name,
      description: project.description,
      location: project.location,
      createdAt: project.createdAt,
      workflowState: project.workflowState != null
          ? WorkflowStateModel.fromEntity(project.workflowState!)
          : null,
    );
  }
}
