import 'dart:io';
import 'package:flutter/foundation.dart';
// import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import '../../core/constants/api_constants.dart';
import '../../domain/entities/job.dart';
import '../../domain/repositories/job_repository.dart';
import '../models/job_model.dart';

class CloudJobRepository implements JobRepository {
  final String _baseUrl = ApiConstants.baseUrl;
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
    ),
  );

  @override
  Future<String> uploadVideo(String videoPath) async {
    try {
      final file = File(videoPath);
      final fileName = path.basename(videoPath);

      // 1. Get Signed URL
      final response = await _dio.get('$_baseUrl/upload-url', queryParameters: {
        'filename': 'videos/${DateTime.now().millisecondsSinceEpoch}_$fileName',
        'contentType': 'video/mp4',
      });

      if (response.statusCode != 200) {
        throw Exception("Failed to get upload URL: ${response.data}");
      }

      final uploadUrl = response.data['uploadUrl'];
      final gcsUri = response.data['gcsUri'];

      // 2. Upload File to GCS
      // Read file as bytes for cross-platform compatibility
      Uint8List fileBytes;
      int fileLength;

      try {
        fileBytes = await file.readAsBytes();
        fileLength = fileBytes.length;
      } catch (e) {
        // Fallback: If readAsBytes fails, try getting length first
        fileLength = await file.length();
        fileBytes = await file.readAsBytes();
      }

      final uploadResponse = await _dio.put(
        uploadUrl,
        data: Stream.fromIterable([fileBytes]),
        options: Options(
          headers: {
            'Content-Type': 'video/mp4',
            'Content-Length': fileLength.toString(),
          },
        ),
      );

      if (uploadResponse.statusCode != 200) {
        throw Exception(
            "Failed to upload video to Storage: ${uploadResponse.statusCode}");
      }

      return gcsUri;
    } catch (e) {
      debugPrint("Error uploading video: $e");
      throw Exception("Upload failed: $e");
    }
  }

  @override
  Future<Job> createJob(String projectId, String videoUrl) async {
    try {
      // 3. Trigger Analysis
      final response = await _dio.post('$_baseUrl/analyze', data: {
        'projectId': projectId,
        'videoGcsUri': videoUrl,
      });

      if (response.statusCode != 200) {
        throw Exception("Failed to start analysis: ${response.data}");
      }

      final jobId = response.data['jobId'];

      // Return a temporary job object with 'processing' status
      // The real data will come from the stream
      return Job(
        id: jobId,
        projectId: projectId,
        videoUrl: videoUrl,
        status: 'processing',
      );
    } catch (e) {
      debugPrint("Error creating job: $e");
      throw Exception("Analysis trigger failed: $e");
    }
  }

  @override
  Stream<Job> getJobStream(String jobId) async* {
    while (true) {
      try {
        final response = await _dio.get('$_baseUrl/jobs/$jobId');
        if (response.statusCode == 200 && response.data != null) {
          final jobModel = JobModel.fromJson(response.data);
          yield jobModel;

          if (jobModel.status == 'completed' || jobModel.status == 'failed') {
            break; // Stop polling when done
          }
        }
      } catch (e) {
        debugPrint("Polling error: $e");
        // Don't crash stream on temporary network error, just wait and retry
      }

      // Poll at configured interval
      await Future.delayed(ApiConstants.pollingInterval);
    }
  }

  // New method: Generate quotation for a completed job
  Future<String?> generateQuotationForJob(String jobId) async {
    try {
      final response = await _dio.post('$_baseUrl/quotations/generate', data: {
        'jobId': jobId,
      });

      if (response.statusCode == 200 && response.data != null) {
        final quotationId = response.data['quotation']?['id'] as String?;
        debugPrint('✅ Quotation generated: $quotationId');
        return quotationId;
      }
    } catch (e) {
      debugPrint('Error generating quotation: $e');
    }
    return null;
  }
}
