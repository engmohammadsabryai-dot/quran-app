import 'package:equatable/equatable.dart';
import '../../../core/utils/compensation_calculator.dart';
import '../../../domain/models/daily_task.dart';
import '../../../domain/models/memorization_plan.dart';

class PlanState extends Equatable {
  final MemorizationPlan? activePlan;
  final List<DailyTask> tasks;
  final DailyTask? todayTask;
  final List<DailyTask> delayedTasks;
  final AnalyticsSummary analytics;
  final bool isLoading;
  final String? compensationMessage;
  final String? errorMessage;

  const PlanState({
    this.activePlan,
    this.tasks = const [],
    this.todayTask,
    this.delayedTasks = const [],
    this.analytics = const AnalyticsSummary(
      totalTasks: 0,
      completedTasks: 0,
      delayedTasks: 0,
      activeStreakDays: 0,
      completionPercentage: 0,
      totalQuartersMemorized: 0,
      remainingQuarters: 240,
    ),
    this.isLoading = false,
    this.compensationMessage,
    this.errorMessage,
  });

  bool get hasDelayedTasks => delayedTasks.isNotEmpty;

  PlanState copyWith({
    MemorizationPlan? activePlan,
    List<DailyTask>? tasks,
    DailyTask? todayTask,
    List<DailyTask>? delayedTasks,
    AnalyticsSummary? analytics,
    bool? isLoading,
    String? compensationMessage,
    String? errorMessage,
  }) {
    return PlanState(
      activePlan: activePlan ?? this.activePlan,
      tasks: tasks ?? this.tasks,
      todayTask: todayTask ?? this.todayTask,
      delayedTasks: delayedTasks ?? this.delayedTasks,
      analytics: analytics ?? this.analytics,
      isLoading: isLoading ?? this.isLoading,
      compensationMessage: compensationMessage,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        activePlan,
        tasks,
        todayTask,
        delayedTasks,
        analytics,
        isLoading,
        compensationMessage,
        errorMessage,
      ];
}
