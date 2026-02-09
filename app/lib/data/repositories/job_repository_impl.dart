import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import '../../domain/entities/job.dart';
import '../../domain/repositories/job_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class JobRepositoryImpl implements JobRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  JobRepositoryImpl({FirebaseFirestore? firestore, FirebaseStorage? storage})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  @override
  Future<String> uploadVideo(String videoPath) async {
    final file = File(videoPath);
    final fileName = 'videos/${DateTime.now().millisecondsSinceEpoch}_${file.uri.pathSegments.last}';
    final ref = _storage.ref().child(fileName);
    
    // UploadTask task = ref.putFile(file); // Standard upload
    // await task;
    // For Hackathon demo speed, we might simulate if offline, but here is real code:
    try {
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception("Upload failed: $e");
    }
  }

  @override
  Future<Job> createJob(String projectId, String videoUrl) async {
    final jobId = 'job_${DateTime.now().millisecondsSinceEpoch}';
    final jobRef = _firestore.collection('jobs').doc(jobId);

    final jobData = {
      'id': jobId,
      'projectId': projectId,
      'videoUrl': videoUrl,
      'status': 'processing', // Initial status for Cloud Run trigger
      'createdAt': FieldValue.serverTimestamp(),
      'analysisResult': null,
    };

    await jobRef.set(jobData);

    return Job(
      id: jobId,
      projectId: projectId,
      videoUrl: videoUrl,
      status: 'processing',
      analysisResult: null,
    );
  }

  @override
  Stream<Job> getJobStream(String jobId) {
    return _firestore.collection('jobs').doc(jobId).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        throw Exception("Job not found");
      }
      final data = snapshot.data()!;
      return Job(
        id: data['id'],
        projectId: data['projectId'],
        videoUrl: data['videoUrl'],
        status: data['status'] ?? 'unknown',
        analysisResult: data['analysis'] ?? data['analysisResult'], // Handle potential naming diffs
      );
    });
  }
}
