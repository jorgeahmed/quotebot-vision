import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/workflow_state.dart';
import '../blocs/project_bloc.dart';

class ProjectFilterBar extends StatelessWidget {
  const ProjectFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProjectBloc, ProjectState>(
      builder: (context, state) {
        final currentFilter =
            state is ProjectLoaded ? state.currentStageFilter : null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Search Bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Buscar proyectos...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (query) {
                context.read<ProjectBloc>().add(SearchProjects(query));
              },
            ),
            const SizedBox(height: 12),

            // Chips Filter
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: Row(
                children: [
                  _buildFilterChip(
                    context: context,
                    label: 'Todos',
                    isSelected: currentFilter == null,
                    onTap: () => context
                        .read<ProjectBloc>()
                        .add(const FilterProjectsByStage(null)),
                  ),
                  ...WorkflowStage.values.map((stage) => Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: _buildFilterChip(
                          context: context,
                          label: stage.name.toUpperCase(),
                          isSelected: currentFilter == stage,
                          color: _getColorForStage(stage),
                          onTap: () => context
                              .read<ProjectBloc>()
                              .add(FilterProjectsByStage(stage)),
                        ),
                      )),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterChip({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    Color? color,
  }) {
    final themeColor = color ?? Colors.black;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? themeColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? themeColor : Colors.grey.shade300,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: themeColor.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2))
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Color _getColorForStage(WorkflowStage stage) {
    switch (stage) {
      case WorkflowStage.planning:
        return Colors.blue;
      case WorkflowStage.survey:
        return Colors.orange;
      case WorkflowStage.quotation:
        return Colors.purple;
      case WorkflowStage.execution:
        return Colors.red;
      case WorkflowStage.completion:
        return Colors.green;
    }
  }
}
