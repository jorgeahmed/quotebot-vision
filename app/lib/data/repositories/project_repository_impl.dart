import '../../domain/entities/project.dart';
import '../../domain/repositories/project_repository.dart';
import '../models/project_model.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  final FirebaseFirestore _firestore;
  final _uuid = const Uuid();

  ProjectRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<Project>> getProjects() async {
    try {
      final snapshot = await _firestore
          .collection('projects')
          .orderBy('created_at', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ProjectModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      // Return empty list or throw specific error handling
      debugPrint("Error fetching projects: $e");
      return [];
    }
  }

  @override
  Future<Project> createProject(
      String name, String description, String location) async {
    final id = _uuid.v4();
    final now = DateTime.now();

    final model = ProjectModel(
      id: id,
      name: name,
      description: description,
      location: location,
      createdAt: now,
    );

    await _firestore.collection('projects').doc(id).set(model.toJson());
    return model;
  }

  @override
  Future<void> updateProject(Project project) async {
    try {
      final model = ProjectModel.fromEntity(project);
      // ignore: avoid_print
      // debugPrint('Updating project ${project.id} with data: ${model.toJson()}');
      await _firestore
          .collection('projects')
          .doc(project.id)
          .update(model.toJson());
    } catch (e) {
      // ignore: avoid_print
      debugPrint('Repository Error updating project: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteProject(String projectId) async {
    await _firestore.collection('projects').doc(projectId).delete();
  }
}
