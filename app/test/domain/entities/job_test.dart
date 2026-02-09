import 'package:flutter_test/flutter_test.dart';
import 'package:quotebot_vision/domain/entities/job.dart';

void main() {
  group('Job Entity Tests', () {
    test('should create Job with all properties', () {
      // Arrange & Act
      const job = Job(
        id: 'job-123',
        projectId: 'project-456',
        videoUrl: 'https://storage.googleapis.com/video.mp4',
        analysisResult: {
          'detected_materials': ['cemento', 'arena'],
          'confidence': 0.85,
        },
        status: 'completed',
      );

      // Assert
      expect(job.id, 'job-123');
      expect(job.projectId, 'project-456');
      expect(job.videoUrl, 'https://storage.googleapis.com/video.mp4');
      expect(job.analysisResult, isNotNull);
      expect(job.analysisResult!['detected_materials'], ['cemento', 'arena']);
      expect(job.status, 'completed');
    });

    test('should create Job with processing status and null analysis', () {
      // Arrange & Act
      const job = Job(
        id: 'job-789',
        projectId: 'project-101',
        videoUrl: 'https://storage.googleapis.com/video2.mp4',
        status: 'processing',
      );

      // Assert
      expect(job.id, 'job-789');
      expect(job.status, 'processing');
      expect(job.analysisResult, isNull);
    });

    test('should create Job with error status', () {
      // Arrange & Act
      const job = Job(
        id: 'job-error',
        projectId: 'project-error',
        status: 'error',
      );

      // Assert
      expect(job.id, 'job-error');
      expect(job.status, 'error');
      expect(job.videoUrl, isNull);
      expect(job.analysisResult, isNull);
    });

    test('should support equality comparison', () {
      // Arrange
      const job1 = Job(
        id: 'job-123',
        projectId: 'project-456',
        videoUrl: 'https://example.com/video.mp4',
        status: 'completed',
      );

      const job2 = Job(
        id: 'job-123',
        projectId: 'project-456',
        videoUrl: 'https://example.com/video.mp4',
        status: 'completed',
      );

      const job3 = Job(
        id: 'job-999',
        projectId: 'project-456',
        videoUrl: 'https://example.com/video.mp4',
        status: 'completed',
      );

      // Assert
      expect(job1, equals(job2));
      expect(job1, isNot(equals(job3)));
    });

    test('should validate job status values', () {
      // Arrange & Act
      const processingJob = Job(
        id: 'job-1',
        projectId: 'project-1',
        status: 'processing',
      );

      const completedJob = Job(
        id: 'job-2',
        projectId: 'project-1',
        status: 'completed',
      );

      const errorJob = Job(
        id: 'job-3',
        projectId: 'project-1',
        status: 'error',
      );

      // Assert
      expect(processingJob.status, 'processing');
      expect(completedJob.status, 'completed');
      expect(errorJob.status, 'error');
    });
  });
}
