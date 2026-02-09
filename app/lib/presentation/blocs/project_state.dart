import 'package:equatable/equatable.dart';
import '../../domain/entities/project.dart';
import '../../domain/entities/workflow_state.dart';

abstract class ProjectState extends Equatable {
  const ProjectState();

  @override
  List<Object?> get props => [];
}

class ProjectInitial extends ProjectState {}

class ProjectLoading extends ProjectState {}

class ProjectLoaded extends ProjectState {
  final List<Project> allProjects;
  final List<Project> filteredProjects;
  final String searchQuery;
  final WorkflowStage? currentStageFilter;
  // Stats can be computed on the fly or stored here

  const ProjectLoaded({
    required this.allProjects,
    this.filteredProjects = const [],
    this.searchQuery = '',
    this.currentStageFilter,
  });

  ProjectLoaded copyWith({
    List<Project>? allProjects,
    List<Project>? filteredProjects,
    String? searchQuery,
    WorkflowStage? currentStageFilter,
  }) {
    return ProjectLoaded(
      allProjects: allProjects ?? this.allProjects,
      filteredProjects: filteredProjects ?? this.filteredProjects,
      searchQuery: searchQuery ?? this.searchQuery,
      currentStageFilter: currentStageFilter ?? this.currentStageFilter,
    );
  }

  @override
  List<Object?> get props => [
        allProjects,
        filteredProjects,
        searchQuery,
        currentStageFilter,
      ];
}

class ProjectError extends ProjectState {
  final String message;

  const ProjectError(this.message);

  @override
  List<Object> get props => [message];
}
