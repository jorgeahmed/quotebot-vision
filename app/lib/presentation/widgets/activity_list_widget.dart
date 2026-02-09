import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/activity.dart';
import '../../domain/entities/workflow_state.dart';
import '../blocs/activity/activity_bloc.dart';
import '../blocs/activity/activity_event.dart';
import '../blocs/activity/activity_state.dart';
import 'activity_card.dart';
import 'create_activity_dialog.dart';

class ActivityListWidget extends StatelessWidget {
  final String projectId;
  final bool canEdit;

  const ActivityListWidget({
    super.key,
    required this.projectId,
    this.canEdit = true,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ActivityBloc, ActivityState>(
      builder: (context, state) {
        if (state is ActivityLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ActivityError) {
          return Center(child: Text('Error: ${state.message}'));
        } else if (state is ActivityLoaded) {
          final grouped = _groupActivities(state.filteredActivities);

          if (state.filteredActivities.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.assignment_outlined,
                      size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No hay actividades registradas'),
                  if (canEdit) ...[
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Crear Actividad'),
                      onPressed: () => _showCreateDialog(context),
                    ),
                  ],
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 80),
            itemCount: grouped.length,
            itemBuilder: (context, index) {
              final stage = grouped.keys.elementAt(index);
              final activities = grouped[stage]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(stage, activities),
                  const SizedBox(height: 12),
                  ...activities.map(
                    (activity) => ActivityCard(
                      activity: activity,
                      isReadOnly: !canEdit,
                      onEdit: canEdit
                          ? () => _showCreateDialog(context, activity: activity)
                          : null,
                      onTap: () {
                        // TODO: Show details
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Map<WorkflowStage, List<Activity>> _groupActivities(
      List<Activity> activities) {
    final Map<WorkflowStage, List<Activity>> grouped = {};
    for (var activity in activities) {
      if (!grouped.containsKey(activity.stage)) {
        grouped[activity.stage] = [];
      }
      grouped[activity.stage]!.add(activity);
    }
    // Sort stages by enum index
    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) => a.index.compareTo(b.index));

    return Map.fromEntries(
        sortedKeys.map((key) => MapEntry(key, grouped[key]!)));
  }

  Widget _buildSectionHeader(WorkflowStage stage, List<Activity> activities) {
    final totalCost =
        activities.fold(0.0, (sum, item) => sum + item.estimatedCost);
    final completedCount = activities.where((a) => a.isCompleted).length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              stage.name.toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$completedCount/${activities.length}',
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        Text(
          'Total: \$${totalCost.toStringAsFixed(0)}',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Future<void> _showCreateDialog(BuildContext context,
      {Activity? activity}) async {
    final result = await showDialog<Activity>(
      context: context,
      builder: (_) => CreateActivityDialog(
        projectId: projectId,
        activityToEdit: activity,
      ),
    );

    if (result != null && context.mounted) {
      if (activity == null) {
        context.read<ActivityBloc>().add(AddActivity(result));
      } else {
        context.read<ActivityBloc>().add(UpdateActivity(result));
      }
    }
  }
}
