import 'package:flutter_test/flutter_test.dart';
import 'package:quotebot_vision/domain/entities/workflow_state.dart';

void main() {
  late DateTime testDate;

  setUp(() {
    testDate = DateTime(2025, 1, 1);
  });

  group('WorkflowState Entity Tests', () {
    test('should create WorkflowState with all properties', () {
      // Arrange & Act
      final state = WorkflowState(
        mainStage: WorkflowStage.planning,
        subState: 'draft',
        progress: 10,
        history: const [],
        currentMilestone: null,
        blockers: const [],
        lastUpdated: testDate,
      );

      // Assert
      expect(state.mainStage, WorkflowStage.planning);
      expect(state.subState, 'draft');
      expect(state.progress, 10);
      expect(state.history, isEmpty);
      expect(state.blockers, isEmpty);
    });

    test('should get correct stage name in Spanish', () {
      // Arrange
      final states = [
        WorkflowState(
          mainStage: WorkflowStage.planning,
          subState: 'draft',
          lastUpdated: testDate,
        ),
        WorkflowState(
          mainStage: WorkflowStage.survey,
          subState: 'visitPaid',
          lastUpdated: testDate,
        ),
        WorkflowState(
          mainStage: WorkflowStage.quotation,
          subState: 'quoteInReview',
          lastUpdated: testDate,
        ),
        WorkflowState(
          mainStage: WorkflowStage.execution,
          subState: 'inProgress',
          lastUpdated: testDate,
        ),
        WorkflowState(
          mainStage: WorkflowStage.completion,
          subState: 'completed',
          lastUpdated: testDate,
        ),
      ];

      // Assert
      expect(states[0].stageName, 'Planeación');
      expect(states[1].stageName, 'Levantamiento');
      expect(states[2].stageName, 'Cotización');
      expect(states[3].stageName, 'Ejecución');
      expect(states[4].stageName, 'Finalización');
    });

    test('should check if workflow is blocked', () {
      // Arrange
      final blockedState = WorkflowState(
        mainStage: WorkflowStage.survey,
        subState: 'visitPaymentPending',
        blockers: const ['Payment pending'],
        lastUpdated: testDate,
      );

      final unblockedState = WorkflowState(
        mainStage: WorkflowStage.planning,
        subState: 'draft',
        blockers: const [],
        lastUpdated: testDate,
      );

      // Assert
      expect(blockedState.isBlocked, true);
      expect(unblockedState.isBlocked, false);
    });

    test('should check if project is active', () {
      // Arrange
      final activeState = WorkflowState(
        mainStage: WorkflowStage.execution,
        subState: 'inProgress',
        lastUpdated: testDate,
      );

      final archivedState = WorkflowState(
        mainStage: WorkflowStage.completion,
        subState: 'archived',
        lastUpdated: testDate,
      );

      // Assert
      expect(activeState.isActive, true);
      expect(archivedState.isActive, false);
    });

    test('should transition to new state with history', () {
      // Arrange
      final initialState = WorkflowState(
        mainStage: WorkflowStage.planning,
        subState: 'draft',
        progress: 5,
        lastUpdated: testDate,
      );

      // Act
      final newState = initialState.transitionTo(
        newSubState: 'published',
        newProgress: 10,
        changedBy: 'user-123',
        reason: 'Project ready for review',
      );

      // Assert
      expect(newState.subState, 'published');
      expect(newState.progress, 10);
      expect(newState.history.length, 1);
      expect(newState.history.first.fromState, 'planning:draft');
      expect(newState.history.first.toState, 'planning:published');
      expect(newState.history.first.changedBy, 'user-123');
    });

    test('should calculate stage index correctly', () {
      // Arrange & Assert
      expect(
        WorkflowState(
          mainStage: WorkflowStage.planning,
          subState: 'draft',
          lastUpdated: testDate,
        ).stageIndex,
        0,
      );
      expect(
        WorkflowState(
          mainStage: WorkflowStage.survey,
          subState: 'visitPaid',
          lastUpdated: testDate,
        ).stageIndex,
        1,
      );
      expect(
        WorkflowState(
          mainStage: WorkflowStage.quotation,
          subState: 'quoteInReview',
          lastUpdated: testDate,
        ).stageIndex,
        2,
      );
      expect(
        WorkflowState(
          mainStage: WorkflowStage.execution,
          subState: 'inProgress',
          lastUpdated: testDate,
        ).stageIndex,
        3,
      );
      expect(
        WorkflowState(
          mainStage: WorkflowStage.completion,
          subState: 'completed',
          lastUpdated: testDate,
        ).stageIndex,
        4,
      );
    });

    test('should check if stage is completed', () {
      // Arrange
      final state = WorkflowState(
        mainStage: WorkflowStage.execution,
        subState: 'inProgress',
        lastUpdated: testDate,
      );

      // Assert
      expect(state.isStageCompleted(WorkflowStage.planning), true);
      expect(state.isStageCompleted(WorkflowStage.survey), true);
      expect(state.isStageCompleted(WorkflowStage.quotation), true);
      expect(state.isStageCompleted(WorkflowStage.execution), false);
      expect(state.isStageCompleted(WorkflowStage.completion), false);
    });

    test('should check if stage is current', () {
      // Arrange
      final state = WorkflowState(
        mainStage: WorkflowStage.quotation,
        subState: 'quoteInReview',
        lastUpdated: testDate,
      );

      // Assert
      expect(state.isCurrentStage(WorkflowStage.planning), false);
      expect(state.isCurrentStage(WorkflowStage.survey), false);
      expect(state.isCurrentStage(WorkflowStage.quotation), true);
      expect(state.isCurrentStage(WorkflowStage.execution), false);
      expect(state.isCurrentStage(WorkflowStage.completion), false);
    });

    test('should support equality comparison', () {
      // Arrange
      final state1 = WorkflowState(
        mainStage: WorkflowStage.planning,
        subState: 'draft',
        progress: 5,
        lastUpdated: testDate,
      );

      final state2 = WorkflowState(
        mainStage: WorkflowStage.planning,
        subState: 'draft',
        progress: 5,
        lastUpdated: testDate,
      );

      final state3 = WorkflowState(
        mainStage: WorkflowStage.planning,
        subState: 'published', // Different sub-state
        progress: 5,
        lastUpdated: testDate,
      );

      // Assert
      expect(state1, equals(state2));
      expect(state1, isNot(equals(state3)));
    });
  });
}
