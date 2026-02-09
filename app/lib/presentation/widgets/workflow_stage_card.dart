import 'package:flutter/material.dart';
import '../../domain/entities/workflow_state.dart';
import '../../domain/entities/user_profile.dart';

class WorkflowStageCard extends StatelessWidget {
  final WorkflowState workflowState;
  final UserRole? userRole;
  final List<Map<String, dynamic>> allowedTransitions;
  final Function(WorkflowStage, String)? onTransition;

  const WorkflowStageCard({
    super.key,
    required this.workflowState,
    this.userRole,
    this.allowedTransitions = const [],
    this.onTransition,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getStageColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getStageIcon(),
                    color: _getStageColor(),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        workflowState.stageName.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        workflowState.subStateName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),

            // Current milestone
            if (workflowState.currentMilestone != null) ...[
              _buildInfoRow(
                icon: Icons.flag,
                label: 'Hito Actual',
                value: workflowState.currentMilestone!,
              ),
              const SizedBox(height: 12),
            ],

            // Blockers
            if (workflowState.isBlocked) ...[
              _buildBlockers(),
              const SizedBox(height: 16),
            ],

            // Available actions
            if (allowedTransitions.isNotEmpty && userRole != null) ...[
              const SizedBox(height: 16),
              const Text(
                'Acciones Disponibles',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              ...allowedTransitions.map(
                (transition) => _buildActionButton(
                  context,
                  transition,
                ),
              ),
            ],

            // Last updated
            const SizedBox(height: 16),
            Text(
              'Última actualización: ${_formatDateTime(workflowState.lastUpdated)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBlockers() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7), // Yellow light
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFF59E0B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning_amber,
                color: Color(0xFFF59E0B),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Bloqueadores (${workflowState.blockers.length})',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFD97706),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...workflowState.blockers.map(
            (blocker) => Padding(
              padding: const EdgeInsets.only(left: 28, top: 4),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF59E0B),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      blocker,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFFD97706),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    Map<String, dynamic> transition,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onTransition != null
              ? () => onTransition!(
                    transition['stage'] as WorkflowStage,
                    transition['subState'] as String,
                  )
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6366F1),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                transition['label'] as String,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStageColor() {
    switch (workflowState.mainStage) {
      case WorkflowStage.planning:
        return const Color(0xFF8B5CF6); // Purple
      case WorkflowStage.survey:
        return const Color(0xFF3B82F6); // Blue
      case WorkflowStage.quotation:
        return const Color(0xFFF59E0B); // Orange
      case WorkflowStage.execution:
        return const Color(0xFF10B981); // Green
      case WorkflowStage.completion:
        return const Color(0xFF6B7280); // Gray
    }
  }

  IconData _getStageIcon() {
    switch (workflowState.mainStage) {
      case WorkflowStage.planning:
        return Icons.lightbulb_outline;
      case WorkflowStage.survey:
        return Icons.camera_alt_outlined;
      case WorkflowStage.quotation:
        return Icons.receipt_long;
      case WorkflowStage.execution:
        return Icons.construction;
      case WorkflowStage.completion:
        return Icons.check_circle_outline;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inDays > 0) {
      return 'Hace ${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'Hace ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'Hace ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'Hace un momento';
    }
  }
}
