import '../../domain/entities/workflow_state.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/services/workflow_service.dart';

class WorkflowServiceImpl implements WorkflowService {
  @override
  bool canTransition({
    required WorkflowState currentState,
    required WorkflowStage targetStage,
    required String targetSubState,
    required UserRole userRole,
  }) {
    // Check if transition is logically valid (sequential progression)
    if (!_isValidProgression(currentState.mainStage, targetStage)) {
      return false;
    }

    // Check role-based permissions
    if (!_hasRolePermission(
        currentState, targetStage, targetSubState, userRole)) {
      return false;
    }

    // Check for blockers
    if (currentState.blockers.isNotEmpty) {
      return false;
    }

    return true;
  }

  @override
  List<Map<String, dynamic>> getAllowedTransitions({
    required WorkflowState currentState,
    required UserRole userRole,
  }) {
    final transitions = <Map<String, dynamic>>[];

    // Define allowed transitions based on current state
    switch (currentState.mainStage) {
      case WorkflowStage.planning:
        if (currentState.subState == 'draft' && userRole == UserRole.client) {
          transitions.add({
            'stage': WorkflowStage.planning,
            'subState': 'published',
            'label': 'Publicar Proyecto',
          });
        }
        if (currentState.subState == 'published' &&
            userRole == UserRole.client) {
          transitions.add({
            'stage': WorkflowStage.planning,
            'subState': 'quoteRequested',
            'label': 'Solicitar Cotización',
          });
        }
        if (currentState.subState == 'quoteRequested') {
          transitions.add({
            'stage': WorkflowStage.survey,
            'subState': 'visitPaymentPending',
            'label': 'Iniciar Levantamiento',
          });
        }
        break;

      case WorkflowStage.survey:
        if (currentState.subState == 'visitPaymentPending' &&
            userRole == UserRole.client) {
          transitions.add({
            'stage': WorkflowStage.survey,
            'subState': 'visitPaid',
            'label': 'Confirmar Pago de Visita',
          });
        }
        if (currentState.subState == 'visitPaid' &&
            userRole == UserRole.contractor) {
          transitions.add({
            'stage': WorkflowStage.survey,
            'subState': 'visitScheduled',
            'label': 'Programar Visita',
          });
        }
        if (currentState.subState == 'visitScheduled' &&
            userRole == UserRole.contractor) {
          transitions.add({
            'stage': WorkflowStage.survey,
            'subState': 'surveyCompleted',
            'label': 'Completar Levantamiento',
          });
        }
        if (currentState.subState == 'surveyCompleted') {
          transitions.add({
            'stage': WorkflowStage.quotation,
            'subState': 'quoteInReview',
            'label': 'Enviar Cotización',
          });
        }
        break;

      case WorkflowStage.quotation:
        if (currentState.subState == 'quoteInReview' &&
            userRole == UserRole.client) {
          transitions.addAll([
            {
              'stage': WorkflowStage.quotation,
              'subState': 'quoteApproved',
              'label': 'Aprobar Cotización',
            },
            {
              'stage': WorkflowStage.quotation,
              'subState': 'quoteAdjustments',
              'label': 'Solicitar Ajustes',
            },
            {
              'stage': WorkflowStage.quotation,
              'subState': 'quoteRejected',
              'label': 'Rechazar',
            },
          ]);
        }
        if (currentState.subState == 'quoteAdjustments' &&
            userRole == UserRole.contractor) {
          transitions.add({
            'stage': WorkflowStage.quotation,
            'subState': 'quoteInReview',
            'label': 'Reenviar Cotización',
          });
        }
        if (currentState.subState == 'quoteApproved') {
          transitions.add({
            'stage': WorkflowStage.execution,
            'subState': 'contractSigned',
            'label': 'Firmar Contrato',
          });
        }
        break;

      case WorkflowStage.execution:
        if (currentState.subState == 'contractSigned' &&
            userRole == UserRole.contractor) {
          transitions.add({
            'stage': WorkflowStage.execution,
            'subState': 'inProgress',
            'label': 'Iniciar Trabajo',
          });
        }
        if (currentState.subState == 'inProgress') {
          if (userRole == UserRole.contractor) {
            transitions.add({
              'stage': WorkflowStage.execution,
              'subState': 'milestoneReview',
              'label': 'Solicitar Revisión de Hito',
            });
          }
          if (userRole == UserRole.client) {
            transitions.add({
              'stage': WorkflowStage.execution,
              'subState': 'paused',
              'label': 'Pausar Proyecto',
            });
          }
        }
        if (currentState.subState == 'milestoneReview' &&
            userRole == UserRole.client) {
          transitions.addAll([
            {
              'stage': WorkflowStage.execution,
              'subState': 'inProgress',
              'label': 'Aprobar Hito',
            },
          ]);
        }
        if (currentState.subState == 'inProgress' &&
            userRole == UserRole.contractor) {
          transitions.add({
            'stage': WorkflowStage.completion,
            'subState': 'completed',
            'label': 'Marcar como Completado',
          });
        }
        break;

      case WorkflowStage.completion:
        if (currentState.subState == 'completed' &&
            userRole == UserRole.client) {
          transitions.addAll([
            {
              'stage': WorkflowStage.completion,
              'subState': 'archived',
              'label': 'Archivar Proyecto',
            },
            {
              'stage': WorkflowStage.completion,
              'subState': 'disputed',
              'label': 'Abrir Disputa',
            },
          ]);
        }
        break;
    }

    return transitions;
  }

  @override
  bool hasPermissionForAction({
    required WorkflowStage stage,
    required String action,
    required UserRole userRole,
  }) {
    final permissions = {
      'planning': {
        'create': [UserRole.client],
        'publish': [UserRole.client],
        'requestQuote': [UserRole.client],
      },
      'survey': {
        'scheduleVisit': [UserRole.contractor],
        'completesurvey': [UserRole.contractor],
        'payVisit': [UserRole.client],
      },
      'quotation': {
        'submit': [UserRole.contractor],
        'approve': [UserRole.client],
        'reject': [UserRole.client],
        'requestChanges': [UserRole.client],
      },
      'execution': {
        'updateProgress': [UserRole.contractor],
        'completeMilestone': [UserRole.contractor],
        'approveMilestone': [UserRole.client],
        'pause': [UserRole.client, UserRole.contractor],
      },
      'completion': {
        'markComplete': [UserRole.contractor],
        'archive': [UserRole.client],
        'dispute': [UserRole.client],
      },
    };

    final stagePermissions = permissions[stage.name];
    if (stagePermissions == null) return false;

    final allowedRoles = stagePermissions[action];
    if (allowedRoles == null) return false;

    return allowedRoles.contains(userRole);
  }

  @override
  int calculateProgress(WorkflowState state) {
    // Base progress on main stage
    int baseProgress = state.stageIndex * 20; // 0, 20, 40, 60, 80

    // Add progress within stage based on sub-state
    int subProgress = _getSubStateProgress(state.mainStage, state.subState);

    return (baseProgress + subProgress).clamp(0, 100);
  }

  @override
  List<String> getBlockers(WorkflowState state) {
    final blockers = <String>[];

    // Check for payment blockers
    if (state.mainStage == WorkflowStage.survey &&
        state.subState == 'visitPaymentPending') {
      blockers.add('Pago de visita técnica pendiente');
    }

    // Check for approval blockers
    if (state.mainStage == WorkflowStage.quotation &&
        state.subState == 'quoteInReview') {
      blockers.add('Esperando aprobación del cliente');
    }

    if (state.mainStage == WorkflowStage.execution &&
        state.subState == 'milestoneReview') {
      blockers.add('Hito pendiente de revisión');
    }

    return blockers;
  }

  bool _isValidProgression(WorkflowStage from, WorkflowStage to) {
    // Allow same stage transitions
    if (from == to) return true;

    // Allow sequential progression
    if (to.index == from.index + 1) return true;

    // Allow going back to planning from quotation (if rejected)
    if (from == WorkflowStage.quotation && to == WorkflowStage.planning) {
      return true;
    }

    // Allow jumping to completion from execution (cancellation)
    if (from == WorkflowStage.execution && to == WorkflowStage.completion) {
      return true;
    }

    return false;
  }

  bool _hasRolePermission(
    WorkflowState currentState,
    WorkflowStage targetStage,
    String targetSubState,
    UserRole userRole,
  ) {
    // Client-only transitions
    final clientOnlyTransitions = [
      'published',
      'quoteRequested',
      'visitPaid',
      'quoteApproved',
      'quoteRejected',
      'quoteAdjustments',
      'paused',
      'archived',
      'disputed',
    ];

    // Contractor-only transitions
    final contractorOnlyTransitions = [
      'visitScheduled',
      'surveyCompleted',
      'contractSigned',
      'inProgress',
      'milestoneReview',
      'completed',
    ];

    if (clientOnlyTransitions.contains(targetSubState) &&
        userRole != UserRole.client) {
      return false;
    }

    if (contractorOnlyTransitions.contains(targetSubState) &&
        userRole != UserRole.contractor) {
      return false;
    }

    return true;
  }

  int _getSubStateProgress(WorkflowStage stage, String subState) {
    final progressMap = {
      WorkflowStage.planning: {
        'draft': 5,
        'published': 10,
        'quoteRequested': 15,
      },
      WorkflowStage.survey: {
        'visitPaymentPending': 5,
        'visitPaid': 10,
        'visitScheduled': 15,
        'surveyCompleted': 20,
      },
      WorkflowStage.quotation: {
        'quoteInReview': 5,
        'quoteAdjustments': 10,
        'quoteApproved': 20,
        'quoteRejected': 0,
      },
      WorkflowStage.execution: {
        'contractSigned': 5,
        'inProgress': 10,
        'milestoneReview': 15,
        'paused': 10,
      },
      WorkflowStage.completion: {
        'completed': 10,
        'archived': 20,
        'disputed': 0,
      },
    };

    return progressMap[stage]?[subState] ?? 0;
  }
}
