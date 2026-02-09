import 'package:equatable/equatable.dart';
import '../../../domain/entities/project_media.dart';
import '../../../domain/entities/workflow_state.dart';

abstract class MediaState extends Equatable {
  const MediaState();

  @override
  List<Object?> get props => [];
}

class MediaInitial extends MediaState {}

class MediaLoading extends MediaState {}

class MediaUploading extends MediaState {
  final double progress; // 0.0 to 1.0

  const MediaUploading(this.progress);

  @override
  List<Object?> get props => [progress];
}

class MediaLoaded extends MediaState {
  final List<ProjectMedia> allMedia;
  final List<ProjectMedia> filteredMedia;
  final WorkflowStage? currentStageFilter;

  const MediaLoaded({
    required this.allMedia,
    this.filteredMedia = const [],
    this.currentStageFilter,
  });

  MediaLoaded copyWith({
    List<ProjectMedia>? allMedia,
    List<ProjectMedia>? filteredMedia,
    WorkflowStage? currentStageFilter,
  }) {
    return MediaLoaded(
      allMedia: allMedia ?? this.allMedia,
      filteredMedia: filteredMedia ?? this.filteredMedia,
      currentStageFilter: currentStageFilter ?? this.currentStageFilter,
    );
  }

  @override
  List<Object?> get props => [allMedia, filteredMedia, currentStageFilter];
}

class MediaError extends MediaState {
  final String message;

  const MediaError(this.message);

  @override
  List<Object?> get props => [message];
}

class MediaOperationSuccess extends MediaState {
  final String message;

  const MediaOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
