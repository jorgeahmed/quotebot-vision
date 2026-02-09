import 'package:flutter_test/flutter_test.dart';
import 'package:quotebot_vision/data/models/activity_model.dart';
import 'package:quotebot_vision/domain/entities/activity.dart';
import 'package:quotebot_vision/domain/entities/workflow_state.dart';

void main() {
  late DateTime testDate;

  setUp(() {
    testDate = DateTime(2025, 2, 1);
  });

  group('ActivityModel Tests', () {
    test('should convert from JSON correctly', () {
      final json = {
        'id': '123',
        'projectId': 'proj_abc',
        'title': 'Test Item',
        'description': 'A test item',
        'estimatedCost': 500.50,
        'actualCost': 0.0,
        'status': 'inProgress',
        'priority': 'high',
        'stage': 'survey',
        'startDate': testDate.toIso8601String(),
        'blockers': ['Blocker 1'],
      };

      final model = ActivityModel.fromJson(json);

      expect(model.id, '123');
      expect(model.estimatedCost, 500.50);
      expect(model.status, ActivityStatus.inProgress);
      expect(model.priority, ActivityPriority.high);
      expect(model.stage, WorkflowStage.survey);
      expect(model.blockers.length, 1);
      expect(model.startDate, testDate);
    });

    test('should convert to JSON correctly', () {
      final model = ActivityModel(
        id: '123',
        projectId: 'proj_abc',
        title: 'Test Item',
        description: 'Desc',
        stage: WorkflowStage.execution,
        startDate: testDate,
        status: ActivityStatus.completed,
      );

      final json = model.toJson();

      expect(json['id'], '123');
      expect(json['status'], 'completed');
      expect(json['stage'], 'execution');
      expect(json['startDate'], testDate.toIso8601String());
    });

    test('should handle missing optional fields in JSON', () {
      final json = {
        'id': '123',
        'projectId': 'p1',
        'title': 't',
        'description': 'd',
        'stage': 'planning',
        'startDate': testDate.toIso8601String(),
      };

      final model = ActivityModel.fromJson(json);

      expect(model.estimatedCost, 0.0);
      expect(model.status, ActivityStatus.pending);
      expect(model.priority, ActivityPriority.medium);
      expect(model.blockers, isEmpty);
      expect(model.attachments, isEmpty);
    });

    test('should parse unknown enum values to defaults', () {
      final json = {
        'id': '1',
        'projectId': 'p',
        'title': 't',
        'description': 'd',
        'stage': 'INVALID_STAGE',
        'status': 'INVALID_STATUS',
        'startDate': testDate.toIso8601String(),
      };

      final model = ActivityModel.fromJson(json);

      expect(model.stage, WorkflowStage.planning); // Default
      expect(model.status, ActivityStatus.pending); // Default
    });
  });
}
