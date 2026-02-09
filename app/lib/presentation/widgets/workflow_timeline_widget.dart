import 'package:flutter/material.dart';
import '../../domain/entities/workflow_state.dart';

class WorkflowTimelineWidget extends StatelessWidget {
  final WorkflowState workflowState;
  final bool showLabels;

  const WorkflowTimelineWidget({
    super.key,
    required this.workflowState,
    this.showLabels = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress bar
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: workflowState.progress / 100,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getProgressColor(workflowState.progress),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${workflowState.progress}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _getProgressColor(workflowState.progress),
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Stage indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStageIndicator(
                context,
                stage: WorkflowStage.planning,
                icon: Icons.lightbulb_outline,
                label: 'Planeación',
              ),
              _buildConnector(
                  workflowState.isStageCompleted(WorkflowStage.planning)),
              _buildStageIndicator(
                context,
                stage: WorkflowStage.survey,
                icon: Icons.camera_alt_outlined,
                label: 'Levantamiento',
              ),
              _buildConnector(
                  workflowState.isStageCompleted(WorkflowStage.survey)),
              _buildStageIndicator(
                context,
                stage: WorkflowStage.quotation,
                icon: Icons.receipt_long,
                label: 'Cotización',
              ),
              _buildConnector(
                  workflowState.isStageCompleted(WorkflowStage.quotation)),
              _buildStageIndicator(
                context,
                stage: WorkflowStage.execution,
                icon: Icons.construction,
                label: 'Ejecución',
              ),
              _buildConnector(
                  workflowState.isStageCompleted(WorkflowStage.execution)),
              _buildStageIndicator(
                context,
                stage: WorkflowStage.completion,
                icon: Icons.check_circle_outline,
                label: 'Finalización',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStageIndicator(
    BuildContext context, {
    required WorkflowStage stage,
    required IconData icon,
    required String label,
  }) {
    final isCompleted = workflowState.isStageCompleted(stage);
    final isCurrent = workflowState.isCurrentStage(stage);

    Color backgroundColor;
    Color iconColor;
    Color textColor;

    if (isCompleted) {
      backgroundColor = const Color(0xFF10B981); // Green
      iconColor = Colors.white;
      textColor = const Color(0xFF10B981);
    } else if (isCurrent) {
      backgroundColor = const Color(0xFF6366F1); // Indigo
      iconColor = Colors.white;
      textColor = const Color(0xFF6366F1);
    } else {
      backgroundColor = Colors.grey.shade200;
      iconColor = Colors.grey.shade600;
      textColor = Colors.grey.shade600;
    }

    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
            boxShadow: isCurrent
                ? [
                    BoxShadow(
                      color: backgroundColor.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Icon(
            isCompleted ? Icons.check : icon,
            color: iconColor,
            size: 24,
          ),
        ),
        if (showLabels) ...[
          const SizedBox(height: 8),
          SizedBox(
            width: 70,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                color: textColor,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildConnector(bool isCompleted) {
    return Expanded(
      child: Container(
        height: 2,
        margin: EdgeInsets.only(bottom: showLabels ? 48 : 0),
        color: isCompleted ? const Color(0xFF10B981) : Colors.grey.shade300,
      ),
    );
  }

  Color _getProgressColor(int progress) {
    if (progress < 33) {
      return const Color(0xFFF59E0B); // Orange
    } else if (progress < 66) {
      return const Color(0xFF6366F1); // Indigo
    } else {
      return const Color(0xFF10B981); // Green
    }
  }
}
