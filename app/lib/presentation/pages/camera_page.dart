import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import '../../domain/repositories/media_repository.dart';
import '../../domain/entities/project_media.dart';
import '../../domain/entities/workflow_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/job_repository.dart';
import '../../data/repositories/media_repository_impl.dart';

class CameraPage extends StatefulWidget {
  final String projectId;

  const CameraPage({super.key, required this.projectId});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _controller;
  bool _isRecording = false;
  bool _isPhoto = true; // Default to photo
  bool _isUploading = false;
  final MediaRepository _mediaRepository = MediaRepositoryImpl();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        debugPrint('⚠️ No cameras found. Using simulation mode.');
        if (mounted) setState(() {}); // Rebuild to show simulation UI
        return;
      }

      final firstCamera = cameras.first;

      _controller = CameraController(
        firstCamera,
        ResolutionPreset.high,
        enableAudio: true,
      );

      await _controller!.initialize();
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      if (mounted) setState(() {}); // Fallback to simulation on error
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _capture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (_isUploading) return;

    // If recording video, stop it regardless of _isPhoto state to be safe,
    // or strictly follow mode.
    if (!_isPhoto && _isRecording) {
      final file = await _controller!.stopVideoRecording();
      setState(() => _isRecording = false);
      if (mounted) {
        await _handleVideoWithAI(File(file.path));
        // Also save to gallery for record keeping (optional, doing both for now)
        // await _showPreviewAndUpload(File(file.path), MediaType.video);
      }
      return;
    }

    // Start action
    if (_isPhoto) {
      setState(() => _isUploading = true);
      try {
        final image = await _controller!.takePicture();
        if (mounted) {
          await _showPreviewAndUpload(File(image.path), MediaType.photo);
        }
      } catch (e) {
        _handleError(e);
      }
    } else {
      // Start recording
      try {
        await _controller!.startVideoRecording();
        setState(() {
          _isRecording = true;
        });
      } catch (e) {
        _handleError(e);
      }
    }
  }

  void _handleError(dynamic e) {
    debugPrint('Error capturing media: $e');
    if (mounted) {
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _showPreviewAndUpload(File file, MediaType type) async {
    // In a real app, show preview dialog here.
    // Proceeding to upload simulation.

    setState(() => _isUploading = true);

    try {
      await _mediaRepository.uploadMedia(
        projectId: widget.projectId,
        file: file,
        type: type,
        stage: WorkflowStage.planning, // Default, ideally selectable
        userId: 'current-user',
        description: 'Captura desde cámara',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  '${type == MediaType.photo ? "Foto" : "Video"} guardado')),
        );
        Navigator.pop(context, true); // Close camera and refresh
      }
    } catch (e) {
      debugPrint("Upload error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.videocam_off, color: Colors.white54, size: 64),
              const SizedBox(height: 16),
              const Text(
                'Cámara no detectada',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 8),
              const Text(
                'Puedes subir un video existente para analizar.',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                icon: const Icon(Icons.upload_file),
                label: const Text('SUBIR VIDEO DE GALERÍA'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                onPressed: () => _pickVideoFromGallery(),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar',
                    style: TextStyle(color: Colors.white54)),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview
          Center(
            child: CameraPreview(_controller!),
          ),

          // Top Controls
          Positioned(
            top: 40,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Bottom Controls
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Mode Toggle
                if (!_isRecording)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildModeButton(true, "Foto"),
                        _buildModeButton(false, "Video"),
                      ],
                    ),
                  ),

                const SizedBox(height: 20),

                // Capture Button
                GestureDetector(
                  onTap: _capture,
                  child: _isUploading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Container(
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                          ),
                          child: Center(
                            child: Container(
                              height: 60,
                              width: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _isRecording
                                    ? Colors.red
                                    : (_isPhoto ? Colors.white : Colors.red),
                              ),
                              child: _isRecording
                                  ? const Icon(Icons.stop, color: Colors.white)
                                  : null,
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),

          if (_isUploading && !_isRecording)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildModeButton(bool isPhotoMode, String text) {
    final isSelected = _isPhoto == isPhotoMode;
    return GestureDetector(
      onTap: () => setState(() => _isPhoto = isPhotoMode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white24 : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.yellowAccent : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Future<void> _handleVideoWithAI(File videoFile) async {
    setState(() {
      _isUploading = true;
    });

    try {
      final jobRepo = context.read<JobRepository>();

      // 1. Upload Video
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Subiendo video para análisis...')),
      );

      final gcsUrl = await jobRepo.uploadVideo(videoFile.path);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Iniciando Inteligencia Artificial...')),
        );
      }

      await jobRepo.createJob(widget.projectId, gcsUrl);

      if (mounted) {
        Navigator.pop(context, true); // Return success
      }
    } catch (e) {
      debugPrint("AI Analysis Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al iniciar análisis: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _pickVideoFromGallery() async {
    final picker = ImagePicker();
    try {
      final XFile? video = await picker.pickVideo(source: ImageSource.gallery);

      if (video != null) {
        // Proceed with the selected video
        await _handleVideoWithAI(File(video.path));
      }
    } catch (e) {
      debugPrint('Error picking video: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al seleccionar video: $e')),
        );
      }
    }
  }
}
