import '../entities/workflow_state.dart';
import '../entities/user_profile.dart';

/// Service interface for workflow transitions and validations
abstract class WorkflowService {
  /// Check if transition from one state to another is valid
  bool canTransition({
    required WorkflowState currentState,
    required WorkflowStage targetStage,
    required String targetSubState,
    required UserRole userRole,
  });

  /// Get allowed next states for current state and user role
  List<Map<String, dynamic>> getAllowedTransitions({
    required WorkflowState currentState,
    required UserRole userRole,
  });

  /// Validate if user has permission for an action
  bool hasPermissionForAction({
    required WorkflowStage stage,
    required String action,
    required UserRole userRole,
  });

  /// Get progress percentage based on current state
  int calculateProgress(WorkflowState state);

  /// Get blockers preventing workflow progression
  List<String> getBlockers(WorkflowState state);
}
