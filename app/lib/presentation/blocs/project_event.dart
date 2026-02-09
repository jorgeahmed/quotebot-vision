import 'package:equatable/equatable.dart';
import '../../domain/entities/workflow_state.dart';
import '../../domain/entities/project.dart';

abstract class ProjectEvent extends Equatable {
  const ProjectEvent();

  @override
  List<Object?> get props => [];
}

class LoadProjects extends ProjectEvent {}

class CreateProjectEvent extends ProjectEvent {
  final String name;
  final String description;
  final String location;

  const CreateProjectEvent(this.name, this.description, this.location);

  @override
  List<Object> get props => [name, description, location];
}

class UpdateProject extends ProjectEvent {
  final Project project;

  const UpdateProject(this.project);

  @override
  List<Object> get props => [project];
}

class DeleteProject extends ProjectEvent {
  final String projectId;

  const DeleteProject(this.projectId);

  @override
  List<Object> get props => [projectId];
}

class SearchProjects extends ProjectEvent {
  final String query;

  const SearchProjects(this.query);

  @override
  List<Object> get props => [query];
}

class FilterProjectsByStage extends ProjectEvent {
  final WorkflowStage? stage;

  const FilterProjectsByStage(this.stage);

  @override
  List<Object?> get props => [stage];
}
