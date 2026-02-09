import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/activity_repository.dart';
import '../../../domain/entities/activity.dart';
import 'activity_event.dart';
import 'activity_state.dart';

class ActivityBloc extends Bloc<ActivityEvent, ActivityState> {
  final ActivityRepository _repository;
  StreamSubscription<List<Activity>>? _activitiesSubscription;

  ActivityBloc({required ActivityRepository repository})
      : _repository = repository,
        super(ActivityInitial()) {
    on<LoadActivities>(_onLoadActivities);
    on<ActivitiesUpdated>(_onActivitiesUpdated);
    on<AddActivity>(_onAddActivity);
    on<UpdateActivity>(_onUpdateActivity);
    on<DeleteActivity>(_onDeleteActivity);
    on<FilterActivitiesByStage>(_onFilterActivitiesByStage);
  }

  Future<void> _onLoadActivities(
    LoadActivities event,
    Emitter<ActivityState> emit,
  ) async {
    emit(ActivityLoading());
    try {
      await _activitiesSubscription?.cancel();
      _activitiesSubscription = _repository
          .getProjectActivities(event.projectId)
          .listen((activities) => add(ActivitiesUpdated(activities)));
    } catch (e) {
      emit(ActivityError(e.toString()));
    }
  }

  void _onActivitiesUpdated(
    ActivitiesUpdated event,
    Emitter<ActivityState> emit,
  ) {
    if (state is ActivityLoaded) {
      final currentState = state as ActivityLoaded;
      final filtered = currentState.currentStageFilter != null
          ? event.activities
              .where((a) => a.stage == currentState.currentStageFilter)
              .toList()
          : event.activities;

      emit(currentState.copyWith(
        allActivities: event.activities,
        filteredActivities: filtered,
      ));
    } else {
      emit(ActivityLoaded(
        allActivities: event.activities,
        filteredActivities: event.activities,
      ));
    }
  }

  Future<void> _onAddActivity(
    AddActivity event,
    Emitter<ActivityState> emit,
  ) async {
    try {
      await _repository.addActivity(event.activity);
      // Not emitting Success state here to avoid breaking the Loaded state flow
      // The stream will update the list automatically
    } catch (e) {
      emit(ActivityError(e.toString()));
    }
  }

  Future<void> _onUpdateActivity(
    UpdateActivity event,
    Emitter<ActivityState> emit,
  ) async {
    try {
      await _repository.updateActivity(event.activity);
    } catch (e) {
      emit(ActivityError(e.toString()));
    }
  }

  Future<void> _onDeleteActivity(
    DeleteActivity event,
    Emitter<ActivityState> emit,
  ) async {
    try {
      await _repository.deleteActivity(event.projectId, event.activityId);
    } catch (e) {
      emit(ActivityError(e.toString()));
    }
  }

  void _onFilterActivitiesByStage(
    FilterActivitiesByStage event,
    Emitter<ActivityState> emit,
  ) {
    if (state is ActivityLoaded) {
      final currentState = state as ActivityLoaded;
      final filtered = event.stage != null
          ? currentState.allActivities
              .where((a) => a.stage == event.stage)
              .toList()
          : currentState.allActivities;

      emit(currentState.copyWith(
        filteredActivities: filtered,
        currentStageFilter: event.stage,
      ));
    }
  }

  @override
  Future<void> close() {
    _activitiesSubscription?.cancel();
    return super.close();
  }
}
