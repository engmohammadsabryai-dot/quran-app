import 'package:equatable/equatable.dart';
import '../../../core/utils/compensation_calculator.dart';
import '../../../domain/models/daily_task.dart';
import '../../../domain/models/memorization_plan.dart';

abstract class PlanEvent extends Equatable {
  const PlanEvent();

  @override
  List<Object?> get props => [];
}

class LoadPlanForUserEvent extends PlanEvent {
  final String userId;
  const LoadPlanForUserEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class CreateNewPlanEvent extends PlanEvent {
  final MemorizationPlan plan;
  const CreateNewPlanEvent(this.plan);

  @override
  List<Object?> get props => [plan];
}

class ToggleTaskCompletedEvent extends PlanEvent {
  final DailyTask task;
  const ToggleTaskCompletedEvent(this.task);

  @override
  List<Object?> get props => [task];
}

class TogglePrayerCheckoffEvent extends PlanEvent {
  final String taskId;
  final int prayerIndex;
  final bool isCompleted;

  const TogglePrayerCheckoffEvent({
    required this.taskId,
    required this.prayerIndex,
    required this.isCompleted,
  });

  @override
  List<Object?> get props => [taskId, prayerIndex, isCompleted];
}

class ApplyCompensationStrategyEvent extends PlanEvent {
  final CompensationStrategyType strategy;
  final int? shiftDays; // For scheduleTimelineShift

  const ApplyCompensationStrategyEvent({
    required this.strategy,
    this.shiftDays,
  });

  @override
  List<Object?> get props => [strategy, shiftDays];
}
