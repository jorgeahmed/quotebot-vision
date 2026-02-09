import 'package:equatable/equatable.dart';
import 'workflow_state.dart';

class Project extends Equatable {
  final String id;
  final String name;
  final String description;
  final String location;
  final DateTime createdAt;
  final WorkflowState? workflowState;
  final String? ownerId;

  const Project({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.createdAt,
    this.workflowState,
    this.ownerId,
  });

  /// Copy with method
  Project copyWith({
    String? name,
    String? description,
    String? location,
    WorkflowState? workflowState,
    String? ownerId,
  }) {
    return Project(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      location: location ?? this.location,
      createdAt: createdAt,
      workflowState: workflowState ?? this.workflowState,
      ownerId: ownerId ?? this.ownerId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        location,
        createdAt,
        workflowState,
        ownerId,
      ];
}
