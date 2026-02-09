import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/activity.dart';

class ActivityCard extends StatelessWidget {
  final Activity activity;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final bool isReadOnly;

  const ActivityCard({
    super.key,
    required this.activity,
    this.onTap,
    this.onEdit,
    this.isReadOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = activity.isCompleted;
    final isBlocked = activity.isBlocked;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isBlocked
              ? Colors.red.withOpacity(0.3)
              : Colors.grey.withOpacity(0.2),
        ),
      ),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Status Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getStatusColor(activity.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getStatusIcon(activity.status),
                      color: _getStatusColor(activity.status),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Title and Stage
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            decoration:
                                isCompleted ? TextDecoration.lineThrough : null,
                            color: isCompleted ? Colors.grey : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                activity.stage.name.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            if (activity.priority == ActivityPriority.high ||
                                activity.priority ==
                                    ActivityPriority.critical) ...[
                              const SizedBox(width: 8),
                              Icon(
                                Icons.priority_high,
                                size: 14,
                                color: activity.priority ==
                                        ActivityPriority.critical
                                    ? Colors.red
                                    : Colors.orange,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Cost
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        NumberFormat.currency(symbol: '\$')
                            .format(activity.estimatedCost),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      if (!isReadOnly)
                        IconButton(
                          icon: const Icon(Icons.edit, size: 18),
                          color: Colors.grey[400],
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: onEdit,
                        ),
                    ],
                  ),
                ],
              ),
              if (isBlocked && activity.blockers.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.block, size: 14, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          activity.blockers.first,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(ActivityStatus status) {
    switch (status) {
      case ActivityStatus.pending:
        return Colors.grey;
      case ActivityStatus.inProgress:
        return Colors.blue;
      case ActivityStatus.review:
        return Colors.purple;
      case ActivityStatus.completed:
        return Colors.green;
      case ActivityStatus.blocked:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(ActivityStatus status) {
    switch (status) {
      case ActivityStatus.pending:
        return Icons.radio_button_unchecked;
      case ActivityStatus.inProgress:
        return Icons.play_circle_outline;
      case ActivityStatus.review:
        return Icons.rate_review_outlined;
      case ActivityStatus.completed:
        return Icons.check_circle_outline;
      case ActivityStatus.blocked:
        return Icons.block;
    }
  }
}
