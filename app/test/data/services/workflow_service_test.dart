import 'package:flutter_test/flutter_test.dart';
import 'package:quotebot_vision/domain/entities/workflow_state.dart';
import 'package:quotebot_vision/domain/entities/user_profile.dart';
import 'package:quotebot_vision/data/services/workflow_service_impl.dart';

void main() {
  late WorkflowServiceImpl workflowService;
  late DateTime testDate;

  setUp(() {
    workflowService = WorkflowServiceImpl();
    testDate = DateTime(2025, 1, 1);
  });

  group('WorkflowService Tests', () {
    test('should allow valid transition for client', () {
      // Arrange
      final currentState = WorkflowState(
        mainStage: WorkflowStage.planning,
        subState: 'draft',
        lastUpdated: testDate,
      );

      // Act
      final canTransition = workflowService.canTransition(
        currentState: currentState,
        targetStage: WorkflowStage.planning,
        targetSubState: 'published',
        userRole: UserRole.client,
      );

      // Assert
      expect(canTransition, true);
    });

    test('should block transition if user lacks permission', () {
      // Arrange
      final currentState = WorkflowState(
        mainStage: WorkflowStage.survey,
        subState: 'visitPaid',
        lastUpdated: testDate,
      );

      // Act - Client trying to schedule visit (contractor-only action)
      final canTransition = workflowService.canTransition(
        currentState: currentState,
        targetStage: WorkflowStage.survey,
        targetSubState: 'visitScheduled',
        userRole: UserRole.client,
      );

      // Assert
      expect(canTransition, false);
    });

    test('should block transition if workflow is blocked', () {
      // Arrange
      final currentState = WorkflowState(
        mainStage: WorkflowStage.survey,
        subState: 'visitPaymentPending',
        blockers: const ['Payment pending'],
        lastUpdated: testDate,
      );

      // Act
      final canTransition = workflowService.canTransition(
        currentState: currentState,
        targetStage: WorkflowStage.survey,
        targetSubState: 'visitPaid',
        userRole: UserRole.client,
      );

      // Assert
      expect(canTransition, false);
    });

    test('should get allowed transitions for client in planning', () {
      // Arrange
      final currentState = WorkflowState(
        mainStage: WorkflowStage.planning,
        subState: 'published',
        lastUpdated: testDate,
      );

      // Act
      final transitions = workflowService.getAllowedTransitions(
        currentState: currentState,
        userRole: UserRole.client,
      );

      // Assert
      expect(transitions.isNotEmpty, true);
      expect(
        transitions.any((t) => t['label'] == 'Solicitar Cotización'),
        true,
      );
    });

    test('should get different transitions for contractor vs client', () {
      // Arrange
      final currentState = WorkflowState(
        mainStage: WorkflowStage.survey,
        subState: 'visitPaid',
        lastUpdated: testDate,
      );

      // Act
      final clientTransitions = workflowService.getAllowedTransitions(
        currentState: currentState,
        userRole: UserRole.client,
      );

      final contractorTransitions = workflowService.getAllowedTransitions(
        currentState: currentState,
        userRole: UserRole.contractor,
      );

      // Assert
      expect(clientTransitions.length, 0); // Client can't schedule visit
      expect(contractorTransitions.length, 1); // Contractor can schedule
    });

    test('should check permissions by role and stage', () {
      // Assert - Planning stage
      expect(
        workflowService.hasPermissionForAction(
          stage: WorkflowStage.planning,
          action: 'create',
          userRole: UserRole.client,
        ),
        true,
      );

      expect(
        workflowService.hasPermissionForAction(
          stage: WorkflowStage.planning,
          action: 'create',
          userRole: UserRole.contractor,
        ),
        false,
      );

      // Assert - Survey stage
      expect(
        workflowService.hasPermissionForAction(
          stage: WorkflowStage.survey,
          action: 'scheduleVisit',
          userRole: UserRole.contractor,
        ),
        true,
      );

      expect(
        workflowService.hasPermissionForAction(
          stage: WorkflowStage.survey,
          action: 'scheduleVisit',
          userRole: UserRole.client,
        ),
        false,
      );
    });

    test('should calculate progress correctly', () {
      // Test different stages
      final planningState = WorkflowState(
        mainStage: WorkflowStage.planning,
        subState: 'published',
        lastUpdated: testDate,
      );

      final surveyState = WorkflowState(
        mainStage: WorkflowStage.survey,
        subState: 'surveyCompleted',
        lastUpdated: testDate,
      );

      final executionState = WorkflowState(
        mainStage: WorkflowStage.execution,
        subState: 'inProgress',
        lastUpdated: testDate,
      );

      // Assert
      expect(workflowService.calculateProgress(planningState), greaterThan(0));
      expect(
        workflowService.calculateProgress(surveyState),
        greaterThan(workflowService.calculateProgress(planningState)),
      );
      expect(
        workflowService.calculateProgress(executionState),
        greaterThan(workflowService.calculateProgress(surveyState)),
      );
    });

    test('should identify blockers correctly', () {
      // Arrange - State with payment pending
      final paymentPendingState = WorkflowState(
        mainStage: WorkflowStage.survey,
        subState: 'visitPaymentPending',
        lastUpdated: testDate,
      );

      // Arrange - State with quote in review
      final quoteReviewState = WorkflowState(
        mainStage: WorkflowStage.quotation,
        subState: 'quoteInReview',
        lastUpdated: testDate,
      );

      // Arrange - State without blockers
      final activeState = WorkflowState(
        mainStage: WorkflowStage.execution,
        subState: 'inProgress',
        lastUpdated: testDate,
      );

      // Assert
      expect(workflowService.getBlockers(paymentPendingState).isNotEmpty, true);
      expect(workflowService.getBlockers(quoteReviewState).isNotEmpty, true);
      expect(workflowService.getBlockers(activeState).isEmpty, true);
    });
  });
}
