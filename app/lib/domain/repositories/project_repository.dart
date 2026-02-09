import '../entities/project.dart';

abstract class ProjectRepository {
  Future<List<Project>> getProjects();
  Future<Project> createProject(
      String name, String description, String location);
  Future<void> updateProject(Project project);
  Future<void> deleteProject(String projectId);
}
