import '../../domain/entities/project.dart';
import '../../domain/repositories/project_repository.dart';
import '../../domain/entities/workflow_state.dart';

class MockProjectRepository implements ProjectRepository {
  final List<Project> _projects = [
    Project(
      id: 'proj_001',
      name: 'Torre Residencial Sunset',
      description: 'Complejo residencial de 20 pisos en zona premium',
      location: 'Av. Reforma 123, CDMX',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      workflowState: WorkflowState(
        mainStage: WorkflowStage.execution,
        subState: 'inProgress',
        lastUpdated: DateTime.now(),
      ),
    ),
    Project(
      id: 'proj_002',
      name: 'Centro Comercial Plaza Norte',
      description: 'Centro comercial con 150 locales y estacionamiento',
      location: 'Blvd. Norte 456, Monterrey',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      workflowState: WorkflowState(
        mainStage: WorkflowStage.planning,
        subState: 'draft',
        lastUpdated: DateTime.now(),
      ),
    ),
    Project(
      id: 'proj_003',
      name: 'Remodelación Casa Lomas',
      description: 'Acabados de lujo y ampliación de cocina',
      location: 'Lomas de Chapultepec, CDMX',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      workflowState: WorkflowState(
        mainStage: WorkflowStage.quotation,
        subState: 'quoteApproved',
        lastUpdated: DateTime.now(),
      ),
    ),
    Project(
      id: 'proj_004',
      name: 'Oficinas Corporativas Santa Fe',
      description: 'Adecuación de 3 pisos para oficinas',
      location: 'Santa Fe, CDMX',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      workflowState: WorkflowState(
        mainStage: WorkflowStage.completion,
        subState: 'completed',
        lastUpdated: DateTime.now(),
      ),
    ),
  ];

  @override
  Future<List<Project>> getProjects() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    return _projects;
  }

  @override
  Future<Project> createProject(
      String name, String description, String location) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final newProject = Project(
      id: 'proj_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      description: description,
      location: location,
      createdAt: DateTime.now(),
      workflowState: WorkflowState(
        mainStage: WorkflowStage.planning,
        subState: 'draft',
        lastUpdated: DateTime.now(),
      ),
    );
    _projects.insert(0, newProject);
    return newProject;
  }

  @override
  Future<void> updateProject(Project project) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _projects.indexWhere((p) => p.id == project.id);
    if (index != -1) {
      _projects[index] = project;
    } else {
      throw Exception('Project not found');
    }
  }

  @override
  Future<void> deleteProject(String projectId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _projects.removeWhere((p) => p.id == projectId);
  }
}
