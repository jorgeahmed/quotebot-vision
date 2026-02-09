import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/project_repository.dart';
import '../../domain/entities/project.dart';
import 'project_event.dart';
import 'project_state.dart';

export 'project_event.dart';
export 'project_state.dart';

class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  final ProjectRepository _repository;

  ProjectBloc(this._repository) : super(ProjectInitial()) {
    // print('📦 [PROJECT BLOC] Constructor called');
    on<LoadProjects>(_onLoadProjects);
    on<CreateProjectEvent>(_onCreateProject);
    on<SearchProjects>(_onSearchProjects);
    on<UpdateProject>(_onUpdateProject);
    on<DeleteProject>(_onDeleteProject);
    on<FilterProjectsByStage>(_onFilterProjectsByStage);
  }

  // ... existing handlers ...

  Future<void> _onUpdateProject(
    UpdateProject event,
    Emitter<ProjectState> emit,
  ) async {
    try {
      await _repository.updateProject(event.project);
      add(LoadProjects());
    } catch (e) {
      // ignore: avoid_print
      // print('Error updating project: $e\n$stackTrace');
      emit(ProjectError("Failed to update project: $e"));
    }
  }

  Future<void> _onDeleteProject(
    DeleteProject event,
    Emitter<ProjectState> emit,
  ) async {
    try {
      await _repository.deleteProject(event.projectId);
      add(LoadProjects());
    } catch (e) {
      emit(ProjectError("Failed to delete project: $e"));
    }
  }

  // ... existing _applyFilters method ...

  Future<void> _onLoadProjects(
    LoadProjects event,
    Emitter<ProjectState> emit,
  ) async {
    // print('📦 [PROJECT BLOC] _onLoadProjects started');
    emit(ProjectLoading());
    try {
      final projects = await _repository.getProjects();
      emit(ProjectLoaded(
        allProjects: projects,
        filteredProjects: projects,
      ));
      // print(
      //     '📦 [PROJECT BLOC] _onLoadProjects success: ${projects.length} projects');
    } catch (e) {
      emit(ProjectError("Failed to load projects: $e"));
    }
  }

  Future<void> _onCreateProject(
    CreateProjectEvent event,
    Emitter<ProjectState> emit,
  ) async {
    try {
      await _repository.createProject(
        event.name,
        event.description,
        event.location,
      );
      add(LoadProjects());
    } catch (e) {
      emit(ProjectError("Failed to create project: $e"));
    }
  }

  void _onSearchProjects(
    SearchProjects event,
    Emitter<ProjectState> emit,
  ) {
    if (state is ProjectLoaded) {
      final currentState = state as ProjectLoaded;
      final query = event.query.toLowerCase();

      final filtered = _applyFilters(
        currentState.allProjects,
        query,
        currentState.currentStageFilter,
      );

      emit(currentState.copyWith(
        searchQuery: event.query,
        filteredProjects: filtered,
      ));
    }
  }

  void _onFilterProjectsByStage(
    FilterProjectsByStage event,
    Emitter<ProjectState> emit,
  ) {
    if (state is ProjectLoaded) {
      final currentState = state as ProjectLoaded;

      final filtered = _applyFilters(
        currentState.allProjects,
        currentState.searchQuery,
        event.stage,
      );

      emit(currentState.copyWith(
        currentStageFilter: event.stage,
        filteredProjects: filtered,
      ));
    }
  }

  List<Project> _applyFilters(
    List<Project> projects,
    String searchQuery,
    filterStage,
  ) {
    return projects.where((project) {
      final matchesQuery = project.name
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
          project.location.toLowerCase().contains(searchQuery.toLowerCase());

      final matchesStage = filterStage == null ||
          project.workflowState?.mainStage == filterStage;

      return matchesQuery && matchesStage;
    }).toList();
  }
}
