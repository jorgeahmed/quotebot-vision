import '../../domain/entities/job.dart';

class JobModel extends Job {
  const JobModel({
    required super.id,
    required super.projectId,
    super.videoUrl,
    super.analysisResult,
    required super.status,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      videoUrl: json['videoUri'] as String?, // Note: backend sends 'videoUri'
      analysisResult: json['analysis'] as Map<String, dynamic>?,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'videoUri': videoUrl,
      'analysis': analysisResult,
      'status': status,
    };
  }
}
