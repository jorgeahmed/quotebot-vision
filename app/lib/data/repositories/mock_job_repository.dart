import 'dart:async';
import '../../domain/entities/job.dart';
import '../../domain/repositories/job_repository.dart';

class MockJobRepository implements JobRepository {
  final Map<String, List<Job>> _projectJobs = {
    'proj_001': [
      const Job(
          id: 'job_1',
          projectId: 'proj_001',
          videoUrl: 'mock_url_1',
          status: 'completed',
          analysisResult: {
            'measurements': 'Room 4x5m',
            'materials': [
              {'name': 'Grey Paint', 'quantity': '40m2', 'unit': 'm2'},
              {'name': 'Baseboard', 'quantity': '18m', 'unit': 'm'}
            ],
            'difficulty': 3,
            'summary': 'Standard room painting job.'
          }),
    ]
  };

  @override
  Future<String> uploadVideo(String videoPath) async {
    await Future.delayed(const Duration(seconds: 2));
    return "gs://mock-video-bucket/${videoPath.split('/').last}";
  }

  @override
  Future<Job> createJob(String projectId, String videoUrl) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final newJob = Job(
      id: 'job_${DateTime.now().millisecondsSinceEpoch}',
      projectId: projectId,
      videoUrl: videoUrl,
      status: 'processing',
    );

    if (!_projectJobs.containsKey(projectId)) {
      _projectJobs[projectId] = [];
    }
    _projectJobs[projectId]!.add(newJob);

    // Simulate async processing completion after 5 seconds
    _simulateProcessing(newJob);

    return newJob;
  }

  void _simulateProcessing(Job job) async {
    // Simulate realistic AI processing time (3-8 seconds)
    await Future.delayed(const Duration(seconds: 5));

    final index =
        _projectJobs[job.projectId]!.indexWhere((j) => j.id == job.id);
    if (index != -1) {
      // Generate varied realistic analysis results
      final analysisResults = [
        {
          'measurements': 'Espacio detectado: 4.2m x 5.1m, altura 2.8m',
          'materials': [
            {'name': 'Cemento Portland', 'quantity': '15', 'unit': 'bultos'},
            {'name': 'Arena de río', 'quantity': '3', 'unit': 'm³'},
            {'name': 'Varilla 3/8"', 'quantity': '25', 'unit': 'piezas'},
          ],
          'difficulty': 6,
          'summary':
              'Gemini Vision detectó: Losa de concreto. Área estimada: 21.4m². Requiere cimbra y acabado.'
        },
        {
          'measurements': 'Muro identificado: 8m largo x 2.5m alto',
          'materials': [
            {'name': 'Block de concreto', 'quantity': '250', 'unit': 'piezas'},
            {'name': 'Cemento', 'quantity': '8', 'unit': 'bultos'},
            {'name': 'Arena cernida', 'quantity': '2', 'unit': 'm³'},
          ],
          'difficulty': 4,
          'summary':
              'IA detectó: Construcción de muro divisorio. Superficie: 20m². Acabado rústico.'
        },
        {
          'measurements': 'Habitación: 5.5m x 6.2m, altura 3.0m',
          'materials': [
            {'name': 'Pintura vinílica', 'quantity': '4', 'unit': 'cubetas'},
            {'name': 'Sellador acrílico', 'quantity': '2', 'unit': 'cubetas'},
            {'name': 'Brochas', 'quantity': '6', 'unit': 'piezas'},
          ],
          'difficulty': 3,
          'summary':
              'Análisis automático: Trabajo de pintura interior. Área total: 34m². Paredes en buen estado.'
        },
        {
          'measurements': 'Instalación eléctrica: 15m lineales',
          'materials': [
            {'name': 'Cable THW Cal. 12', 'quantity': '100', 'unit': 'metros'},
            {'name': 'Tubo conduit PVC', 'quantity': '15', 'unit': 'piezas'},
            {'name': 'Contactos', 'quantity': '12', 'unit': 'piezas'},
          ],
          'difficulty': 5,
          'summary':
              'Gemini identificó: Instalación eléctrica residencial. 8 puntos de luz, 12 contactos.'
        },
      ];

      final randomResult = analysisResults[
          DateTime.now().millisecondsSinceEpoch % analysisResults.length];

      _projectJobs[job.projectId]![index] = Job(
        id: job.id,
        projectId: job.projectId,
        videoUrl: job.videoUrl,
        status: 'completed',
        analysisResult: randomResult,
      );
    }
  }

  @override
  Stream<Job> getJobStream(String jobId) async* {
    while (true) {
      await Future.delayed(const Duration(seconds: 1));
      // In a real mock, we'd look up the job state.
      // For simplicity, we just return the job if found in our local cache
      // iterating through all projects is inefficient but fine for mock
      for (var jobs in _projectJobs.values) {
        final job = jobs.firstWhere((j) => j.id == jobId,
            orElse: () =>
                const Job(id: 'null', projectId: '', status: 'error'));
        if (job.id != 'null') {
          yield job;
        }
      }
    }
  }

  // Helper for UI to list jobs (not in base interface but useful for Details Page)
  Future<List<Job>> getJobsForProject(String projectId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _projectJobs[projectId] ?? [];
  }
}
