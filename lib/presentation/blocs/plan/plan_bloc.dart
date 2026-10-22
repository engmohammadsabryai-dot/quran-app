import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/compensation_calculator.dart';
import '../../../domain/models/daily_task.dart';
import '../../../domain/models/memorization_plan.dart';
import '../../../domain/repositories/i_plan_repository.dart';
import '../../../domain/repositories/i_task_repository.dart';
import 'plan_event.dart';
import 'plan_state.dart';

class PlanBloc extends Bloc<PlanEvent, PlanState> {
  final IPlanRepository _planRepository;
  final ITaskRepository _taskRepository;

  StreamSubscription? _plansSubscription;
  StreamSubscription? _tasksSubscription;
  String? _currentUserId;

  PlanBloc({
    required IPlanRepository planRepository,
    required ITaskRepository taskRepository,
  })  : _planRepository = planRepository,
        _taskRepository = taskRepository,
        super(const PlanState(isLoading: true)) {
    on<LoadPlanForUserEvent>(_onLoadPlanForUser);
    on<CreateNewPlanEvent>(_onCreateNewPlan);
    on<ToggleTaskCompletedEvent>(_onToggleTaskCompleted);
    on<TogglePrayerCheckoffEvent>(_onTogglePrayerCheckoff);
    on<ApplyCompensationStrategyEvent>(_onApplyCompensation);
    on<_TasksUpdatedInternalEvent>(_onTasksUpdatedInternal);
  }

  void _onTasksUpdatedInternal(_TasksUpdatedInternalEvent event, Emitter<PlanState> emit) {
    emit(state.copyWith(
      activePlan: event.plan,
      tasks: event.tasks,
      todayTask: event.todayTask,
      delayedTasks: event.delayedTasks,
      analytics: event.analytics,
      isLoading: false,
    ));
  }

  void _onLoadPlanForUser(LoadPlanForUserEvent event, Emitter<PlanState> emit) {
    if (_currentUserId == event.userId && state.activePlan != null) return;
    _currentUserId = event.userId;

    _plansSubscription?.cancel();
    _tasksSubscription?.cancel();

    _plansSubscription = _planRepository.watchPlansForUser(event.userId).listen((plans) {
      if (plans.isEmpty) {
        add(const _TasksUpdatedInternalEvent(tasks: [], delayedTasks: []));
        return;
      }

      final active = plans.first;
      _watchTasks(active);
    });
  }

  void _watchTasks(MemorizationPlan plan) {
    _tasksSubscription?.cancel();
    _tasksSubscription = _taskRepository.watchTasksForPlan(plan.planId).listen((tasks) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Find today's task or next uncompleted task
      DailyTask? todayT;
      try {
        todayT = tasks.firstWhere(
          (t) {
            final d = t.scheduledDate;
            return d.year == today.year && d.month == today.month && d.day == today.day;
          },
          orElse: () => tasks.firstWhere((t) => !t.isCompleted, orElse: () => tasks.first),
        );
      } catch (_) {
        todayT = tasks.isNotEmpty ? tasks.first : null;
      }

      // Delayed tasks
      final delayed = tasks.where((t) => t.isDelayed(now)).toList();

      // Live Analytics
      final analytics = AnalyticsSummary.calculate(
        allTasks: tasks,
        isCompleted: (t) => (t as DailyTask).isCompleted,
        getScheduledDate: (t) => (t as DailyTask).scheduledDate,
        getQuarterCount: (t) => (t as DailyTask).quarterIndex != null ? 1 : 0,
      );

      add(_TasksUpdatedInternalEvent(
        plan: plan,
        tasks: tasks,
        todayTask: todayT,
        delayedTasks: delayed,
        analytics: analytics,
      ));
    });
  }

  Future<void> _onCreateNewPlan(CreateNewPlanEvent event, Emitter<PlanState> emit) async {
    try {
      await _planRepository.createPlan(event.plan);
    } catch (e) {
      emit(state.copyWith(errorMessage: 'فشل في إنشاء الخطة: $e'));
    }
  }

  Future<void> _onToggleTaskCompleted(ToggleTaskCompletedEvent event, Emitter<PlanState> emit) async {
    final updated = event.task.copyWith(
      isCompleted: !event.task.isCompleted,
      completedAt: !event.task.isCompleted ? DateTime.now() : null,
    );
    await _taskRepository.updateTask(updated);
  }

  Future<void> _onTogglePrayerCheckoff(TogglePrayerCheckoffEvent event, Emitter<PlanState> emit) async {
    await _taskRepository.togglePrayerCheckoff(event.taskId, event.prayerIndex, event.isCompleted);
  }

  Future<void> _onApplyCompensation(ApplyCompensationStrategyEvent event, Emitter<PlanState> emit) async {
    final currentTasks = state.tasks;
    if (currentTasks.isEmpty) return;

    CompensationResult result;

    switch (event.strategy) {
      case CompensationStrategyType.intensiveFridayCatchUp:
        result = SmartCompensationEngine.applyFridayCatchUp<DailyTask>(
          tasks: currentTasks,
          isCompleted: (t) => t.isCompleted,
          getScheduledDate: (t) => t.scheduledDate,
          copyWithNewSchedule: (t, newDate, note) => t.copyWith(
            scheduledDate: newDate,
            compensationNote: note,
          ),
        );
        break;

      case CompensationStrategyType.gradualSplit:
        result = SmartCompensationEngine.applyGradualSplit<DailyTask>(
          tasks: currentTasks,
          isCompleted: (t) => t.isCompleted,
          getScheduledDate: (t) => t.scheduledDate,
          copyWithGradualNote: (t, note) => t.copyWith(compensationNote: note),
        );
        break;

      case CompensationStrategyType.scheduleTimelineShift:
        final days = event.shiftDays ?? 1;
        result = SmartCompensationEngine.applyTimelineShift<DailyTask>(
          tasks: currentTasks,
          isCompleted: (t) => t.isCompleted,
          getScheduledDate: (t) => t.scheduledDate,
          copyWithNewSchedule: (t, newDate) => t.copyWith(scheduledDate: newDate),
          delayedDays: days,
        );
        break;
    }

    if (result.affectedTasksCount > 0) {
      await _taskRepository.updateTasksBatch(result.updatedTasks.cast<DailyTask>());
      emit(state.copyWith(compensationMessage: result.description));
    } else {
      emit(state.copyWith(compensationMessage: result.description));
    }
  }

  @override
  Future<void> close() {
    _plansSubscription?.cancel();
    _tasksSubscription?.cancel();
    return super.close();
  }
}

class _TasksUpdatedInternalEvent extends PlanEvent {
  final MemorizationPlan? plan;
  final List<DailyTask> tasks;
  final DailyTask? todayTask;
  final List<DailyTask> delayedTasks;
  final AnalyticsSummary? analytics;

  const _TasksUpdatedInternalEvent({
    this.plan,
    required this.tasks,
    this.todayTask,
    required this.delayedTasks,
    this.analytics,
  });

  @override
  List<Object?> get props => [plan, tasks, todayTask, delayedTasks, analytics];
}
