import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/project_media.dart';
import '../../domain/entities/workflow_state.dart';
import '../blocs/media/media_bloc.dart';
import '../blocs/media/media_state.dart';
import '../blocs/media/media_event.dart';

class ProjectGalleryWidget extends StatelessWidget {
  final String projectId;
  final bool canDelete;

  const ProjectGalleryWidget({
    super.key,
    required this.projectId,
    this.canDelete = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MediaBloc, MediaState>(
      builder: (context, state) {
        if (state is MediaLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is MediaError) {
          return Center(child: Text('Error: ${state.message}'));
        } else if (state is MediaLoaded) {
          if (state.allMedia.isEmpty) {
            return _buildEmptyState();
          }

          // Use filtered media if available
          final mediaList = state.filteredMedia;

          return Column(
            children: [
              _buildFilterChips(context, state.currentStageFilter),
              Expanded(
                child: mediaList.isEmpty
                    ? const Center(child: Text('No hay archivos en esta etapa'))
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: mediaList.length,
                        itemBuilder: (context, index) {
                          final media = mediaList[index];
                          return _buildMediaItem(context, media);
                        },
                      ),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildFilterChips(BuildContext context, WorkflowStage? currentFilter) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          FilterChip(
            label: const Text('Todos'),
            selected: currentFilter == null,
            onSelected: (selected) {
              if (selected) {
                context.read<MediaBloc>().add(const FilterMediaByStage(null));
              }
            },
          ),
          const SizedBox(width: 8),
          ...WorkflowStage.values.map((stage) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(stage.name.toUpperCase()),
                selected: currentFilter == stage,
                onSelected: (selected) {
                  context.read<MediaBloc>().add(FilterMediaByStage(
                        selected ? stage : null,
                      ));
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMediaItem(BuildContext context, ProjectMedia media) {
    return GestureDetector(
      onTap: () {
        // TODO: Show full screen viewer
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ver ${media.type.name} - ${media.url}')),
        );
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Image / Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              media.type == MediaType.photo
                  ? media.url
                  : 'https://via.placeholder.com/150?text=VIDEO', // Fallback for video thumb
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                );
              },
            ),
          ),

          // Video Indicator
          if (media.isVideo)
            const Center(
              child: Icon(
                Icons.play_circle_fill,
                color: Colors.white,
                size: 32,
              ),
            ),

          // Date Label
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: Text(
                DateFormat('dd/MM').format(media.createdAt),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.perm_media_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No hay fotos ni videos',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }
}
