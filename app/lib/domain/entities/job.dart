import 'package:equatable/equatable.dart';

class Job extends Equatable {
  final String id;
  final String projectId;
  final String? videoUrl;
  final Map<String, dynamic>? analysisResult;
  final String status; // processing, completed, error

  const Job({
    required this.id,
    required this.projectId,
    this.videoUrl,
    this.analysisResult,
    required this.status,
  });

  @override
  List<Object?> get props => [id, projectId, videoUrl, analysisResult, status];
}
