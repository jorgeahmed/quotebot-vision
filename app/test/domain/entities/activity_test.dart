import 'package:flutter_test/flutter_test.dart';
import 'package:quotebot_vision/domain/entities/activity.dart';
import 'package:quotebot_vision/domain/entities/workflow_state.dart';

void main() {
  late DateTime testDate;

  setUp(() {
    testDate = DateTime(2025, 2, 1);
  });

  group('Activity Entity Tests', () {
    test('should create Activity with correct values', () {
      final activity = Activity(
        id: '1',
        projectId: 'proj_1',
        title: 'Test Activity',
        description: 'Description',
        estimatedCost: 100.0,
        stage: WorkflowStage.planning,
        startDate: testDate,
      );

      expect(activity.id, '1');
      expect(activity.estimatedCost, 100.0);
      expect(activity.status, ActivityStatus.pending);
      expect(activity.priority, ActivityPriority.medium);
    });

    test('should identify completed activity', () {
      final activity = Activity(
        id: '1',
        projectId: 'p1',
        title: 't',
        description: 'd',
        stage: WorkflowStage.execution,
        startDate: testDate,
        status: ActivityStatus.completed,
      );

      expect(activity.isCompleted, true);
    });

    test('should identify blocked activity', () {
      final activity = Activity(
        id: '1',
        projectId: 'p1',
        title: 't',
        description: 'd',
        stage: WorkflowStage.execution,
        startDate: testDate,
        status: ActivityStatus.blocked,
      );

      final activityWithBlockers = activity.copyWith(
        status: ActivityStatus.pending,
        blockers: ['Some blocker'],
      );

      expect(activity.isBlocked, true);
      expect(activityWithBlockers.isBlocked, true);
    });

    test('should detect over budget cost', () {
      final underBudgetActivity = Activity(
        id: '1',
        projectId: 'p1',
        title: 't',
        description: 'd',
        stage: WorkflowStage.planning,
        startDate: testDate,
        estimatedCost: 100.0,
        actualCost: 50.0,
      );

      final overBudgetActivity = underBudgetActivity.copyWith(
        actualCost: 150.0,
      );

      expect(underBudgetActivity.isOverBudget, false);
      expect(overBudgetActivity.isOverBudget, true);
    });

    test('should copyWith values correctly', () {
      final activity = Activity(
        id: '1',
        projectId: 'p1',
        title: 'Old Title',
        description: 'Old Desc',
        stage: WorkflowStage.planning,
        startDate: testDate,
      );

      final updated = activity.copyWith(
        title: 'New Title',
        description: 'New Desc',
        status: ActivityStatus.inProgress,
      );

      expect(updated.id, activity.id); // Should remain same
      expect(updated.title, 'New Title');
      expect(updated.description, 'New Desc');
      expect(updated.status, ActivityStatus.inProgress);
    });
  });
}
