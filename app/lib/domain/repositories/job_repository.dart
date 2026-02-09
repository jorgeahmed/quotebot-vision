import '../entities/job.dart';

abstract class JobRepository {
  Future<String> uploadVideo(String videoPath);
  Future<Job> createJob(String projectId, String videoUrl);
  Stream<Job> getJobStream(String jobId);
}
