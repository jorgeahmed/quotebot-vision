import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/media_repository.dart';
import '../../../domain/entities/project_media.dart';
import 'media_event.dart';
import 'media_state.dart';

class MediaBloc extends Bloc<MediaEvent, MediaState> {
  final MediaRepository _repository;
  StreamSubscription<List<ProjectMedia>>? _mediaSubscription;

  MediaBloc({required MediaRepository repository})
      : _repository = repository,
        super(MediaInitial()) {
    on<LoadProjectMedia>(_onLoadProjectMedia);
    on<MediaUpdated>(_onMediaUpdated);
    on<UploadMediaFile>(_onUploadMediaFile);
    on<DeleteMediaFile>(_onDeleteMediaFile);
    on<FilterMediaByStage>(_onFilterMediaByStage);
  }

  Future<void> _onLoadProjectMedia(
    LoadProjectMedia event,
    Emitter<MediaState> emit,
  ) async {
    emit(MediaLoading());
    try {
      await _mediaSubscription?.cancel();
      _mediaSubscription = _repository
          .getProjectMedia(event.projectId)
          .listen((media) => add(MediaUpdated(media)));
    } catch (e) {
      emit(MediaError(e.toString()));
    }
  }

  void _onMediaUpdated(
    MediaUpdated event,
    Emitter<MediaState> emit,
  ) {
    if (state is MediaLoaded) {
      final currentState = state as MediaLoaded;

      final filtered = currentState.currentStageFilter != null
          ? event.media
              .where((m) => m.stage == currentState.currentStageFilter)
              .toList()
          : event.media;

      emit(currentState.copyWith(
        allMedia: event.media,
        filteredMedia: filtered,
      ));
    } else {
      emit(MediaLoaded(
        allMedia: event.media,
        filteredMedia: event.media,
      ));
    }
  }

  Future<void> _onUploadMediaFile(
    UploadMediaFile event,
    Emitter<MediaState> emit,
  ) async {
    // Preserve current list if possible, but show uploading state
    // We can't easily preserve the loaded state if we switch to MediaUploading unless we change state structure
    // For simplicity, we'll just emit loading/uploading or use a separate status field in state.
    // Here I'll emit MediaUploading, and the Stream will refresh the list upon completion.

    emit(const MediaUploading(0.1)); // Started
    try {
      await _repository.uploadMedia(
        projectId: event.projectId,
        file: event.file,
        type: event.type,
        stage: event.stage,
        userId: event.userId,
        description: event.description,
        activityId: event.activityId,
      );
      emit(const MediaOperationSuccess('Archivo subido correctamente'));
      // The stream will emit MediaUpdated shortly
    } catch (e) {
      emit(MediaError('Error al subir archivo: ${e.toString()}'));
      // Re-trigger load to restore state if needed, or rely on subscription
    }
  }

  Future<void> _onDeleteMediaFile(
    DeleteMediaFile event,
    Emitter<MediaState> emit,
  ) async {
    try {
      await _repository.deleteMedia(event.projectId, event.mediaId);
    } catch (e) {
      emit(MediaError(e.toString()));
    }
  }

  void _onFilterMediaByStage(
    FilterMediaByStage event,
    Emitter<MediaState> emit,
  ) {
    if (state is MediaLoaded) {
      final currentState = state as MediaLoaded;
      final filtered = event.stage != null
          ? currentState.allMedia.where((m) => m.stage == event.stage).toList()
          : currentState.allMedia;

      emit(currentState.copyWith(
        filteredMedia: filtered,
        currentStageFilter: event.stage,
      ));
    }
  }

  @override
  Future<void> close() {
    _mediaSubscription?.cancel();
    return super.close();
  }
}
