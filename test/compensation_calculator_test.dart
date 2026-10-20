import 'package:flutter_test/flutter_test.dart';
import 'package:quran_memorization_engine/core/utils/compensation_calculator.dart';
import 'package:quran_memorization_engine/domain/models/daily_task.dart';

void main() {
  group('SmartCompensationEngine Tests', () {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final twoDaysAgo = today.subtract(const Duration(days: 2));

    final sampleTasks = [
      DailyTask(
        taskId: 't-1',
        planId: 'p-1',
        userId: 'u-1',
        dayNumber: 1,
        scheduledDate: twoDaysAgo,
        surahNumber: 2,
        surahArabicName: 'البقرة',
        fromAyah: 1,
        toAyah: 25,
        quarterIndex: 1,
        portionTitle: 'الربع ١',
        isCompleted: true,
      ),
      DailyTask(
        taskId: 't-2',
        planId: 'p-1',
        userId: 'u-1',
        dayNumber: 2,
        scheduledDate: yesterday,
        surahNumber: 2,
        surahArabicName: 'البقرة',
        fromAyah: 26,
        toAyah: 43,
        quarterIndex: 2,
        portionTitle: 'الربع ٢',
        isCompleted: false, // Delayed!
      ),
      DailyTask(
        taskId: 't-3',
        planId: 'p-1',
        userId: 'u-1',
        dayNumber: 3,
        scheduledDate: today,
        surahNumber: 2,
        surahArabicName: 'البقرة',
        fromAyah: 44,
        toAyah: 59,
        quarterIndex: 3,
        portionTitle: 'الربع ٣',
        isCompleted: false,
      ),
    ];

    test('Detects delayed tasks and computes analytics accurately', () {
      final analytics = AnalyticsSummary.calculate(
        allTasks: sampleTasks,
        isCompleted: (t) => (t as DailyTask).isCompleted,
        getScheduledDate: (t) => (t as DailyTask).scheduledDate,
        getQuarterCount: (t) => 1,
      );

      expect(analytics.totalTasks, equals(3));
      expect(analytics.completedTasks, equals(1));
      expect(analytics.delayedTasks, equals(1)); // t-2 was yesterday and uncompleted
      expect(analytics.totalQuartersMemorized, equals(1));
    });

    test('Applies Friday Catch-Up Strategy for delayed tasks', () {
      final result = SmartCompensationEngine.applyFridayCatchUp<DailyTask>(
        tasks: sampleTasks,
        isCompleted: (t) => t.isCompleted,
        getScheduledDate: (t) => t.scheduledDate,
        copyWithNewSchedule: (t, newDate, note) => t.copyWith(
          scheduledDate: newDate,
          compensationNote: note,
        ),
      );

      expect(result.strategy, equals(CompensationStrategyType.intensiveFridayCatchUp));
      expect(result.affectedTasksCount, equals(1));

      final updatedT2 = (result.updatedTasks as List<DailyTask>).firstWhere((t) => t.taskId == 't-2');
      expect(updatedT2.scheduledDate.weekday, equals(DateTime.friday));
      expect(updatedT2.compensationNote, contains('تعويض مكثف في جلسة مراجعة الجمعة'));
    });

    test('Applies Schedule Timeline Shift Strategy by K days', () {
      final result = SmartCompensationEngine.applyTimelineShift<DailyTask>(
        tasks: sampleTasks,
        isCompleted: (t) => t.isCompleted,
        getScheduledDate: (t) => t.scheduledDate,
        copyWithNewSchedule: (t, newDate) => t.copyWith(scheduledDate: newDate),
        delayedDays: 3,
      );

      expect(result.strategy, equals(CompensationStrategyType.scheduleTimelineShift));
      expect(result.affectedTasksCount, equals(2)); // t-2 and t-3 were uncompleted

      final updatedT3 = (result.updatedTasks as List<DailyTask>).firstWhere((t) => t.taskId == 't-3');
      final expectedDate = today.add(const Duration(days: 3));
      expect(updatedT3.scheduledDate.year, equals(expectedDate.year));
      expect(updatedT3.scheduledDate.month, equals(expectedDate.month));
      expect(updatedT3.scheduledDate.day, equals(expectedDate.day));
    });
  });
}
