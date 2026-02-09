import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/project.dart';
import '../../domain/repositories/project_repository.dart';
import '../models/project_model.dart';
import '../models/workflow_state_model.dart';

class FirestoreProjectRepository implements ProjectRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'projects';

  @override
  Future<List<Project>> getProjects() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('created_at', descending: true)
          .get()
          .timeout(const Duration(seconds: 10));

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return ProjectModel.fromJson(data);
      }).toList();
    } catch (e) {
      debugPrint('🔥 [FIRESTORE REPO ERROR] $e');
      throw Exception('Error fetching projects from Firestore: $e');
    }
  }

  @override
  Future<Project> createProject(
      String name, String description, String location) async {
    try {
      final docRef = _firestore.collection(_collection).doc();
      final now = DateTime.now();

      final newProject = ProjectModel(
        id: docRef.id,
        name: name,
        description: description,
        location: location,
        createdAt: now,
        workflowState: WorkflowStateModel.initial(),
      );

      await docRef.set(newProject.toJson());

      return newProject;
    } catch (e) {
      throw Exception('Error creating project in Firestore: $e');
    }
  }

  @override
  Future<void> updateProject(Project project) async {
    try {
      final projectModel = ProjectModel.fromEntity(project);
      await _firestore
          .collection(_collection)
          .doc(project.id)
          .update(projectModel.toJson());
    } catch (e) {
      throw Exception('Error updating project: $e');
    }
  }

  @override
  Future<void> deleteProject(String projectId) async {
    try {
      await _firestore.collection(_collection).doc(projectId).delete();
    } catch (e) {
      throw Exception('Error deleting project: $e');
    }
  }
}
