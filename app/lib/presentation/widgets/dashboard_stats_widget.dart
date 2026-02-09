import 'package:flutter/material.dart';
import '../../domain/entities/project.dart';
import '../../domain/entities/workflow_state.dart';

class DashboardStatsWidget extends StatelessWidget {
  final List<Project> projects;

  const DashboardStatsWidget({super.key, required this.projects});

  @override
  Widget build(BuildContext context) {
    // Calculate stats
    final total = projects.length;
    final active = projects
        .where((p) =>
            p.workflowState != null &&
            p.workflowState!.mainStage != WorkflowStage.completion)
        .length;
    final completed = projects
        .where((p) => p.workflowState?.mainStage == WorkflowStage.completion)
        .length;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(context, 'Total', total.toString(),
                Colors.blueAccent, Icons.folder_copy),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(context, 'Activos', active.toString(),
                Colors.orangeAccent, Icons.construction),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(context, 'Finalizados', completed.toString(),
                Colors.green, Icons.check_circle),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value,
      Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 20),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
