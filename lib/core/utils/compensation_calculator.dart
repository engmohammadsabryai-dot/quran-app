// Smart Compensation & Delay Detection Engine

class AnalyticsSummary {
  final int totalTasks;
  final int completedTasks;
  final int delayedTasks;
  final int activeStreakDays;
  final double completionPercentage;
  final int totalQuartersMemorized;
  final int remainingQuarters;

  const AnalyticsSummary({
    required this.totalTasks,
    required this.completedTasks,
    required this.delayedTasks,
    required this.activeStreakDays,
    required this.completionPercentage,
    required this.totalQuartersMemorized,
    required this.remainingQuarters,
  });

  factory AnalyticsSummary.calculate({
    required List<dynamic> allTasks, // DailyTask objects or map representations
    required bool Function(dynamic) isCompleted,
    required DateTime Function(dynamic) getScheduledDate,
    required int Function(dynamic) getQuarterCount,
  }) {
    if (allTasks.isEmpty) {
      return const AnalyticsSummary(
        totalTasks: 0,
        completedTasks: 0,
        delayedTasks: 0,
        activeStreakDays: 0,
        completionPercentage: 0.0,
        totalQuartersMemorized: 0,
        remainingQuarters: 240,
      );
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    int completed = 0;
    int delayed = 0;
    int quartersMemorized = 0;

    // Sort tasks by date
    final sorted = List.from(allTasks)
      ..sort((a, b) => getScheduledDate(a).compareTo(getScheduledDate(b)));

    for (final task in sorted) {
      final taskDate = getScheduledDate(task);
      final normalizedDate = DateTime(taskDate.year, taskDate.month, taskDate.day);
      final done = isCompleted(task);

      if (done) {
        completed++;
        quartersMemorized += getQuarterCount(task);
      } else if (normalizedDate.isBefore(today)) {
        delayed++;
      }
    }

    // Calculate active streak
    int streak = 0;
    DateTime checkDate = today;

    // Check if today is completed, if not check starting from yesterday
    final todayTasks = sorted.where((t) {
      final d = getScheduledDate(t);
      return d.year == today.year && d.month == today.month && d.day == today.day;
    }).toList();

    bool todayDone = todayTasks.isNotEmpty && todayTasks.every(isCompleted);

    if (todayDone) {
      streak++;
      checkDate = today.subtract(const Duration(days: 1));
    } else {
      checkDate = today.subtract(const Duration(days: 1));
    }

    while (true) {
      final pastDate = checkDate;
      final dayTasks = sorted.where((t) {
        final d = getScheduledDate(t);
        return d.year == pastDate.year && d.month == pastDate.month && d.day == pastDate.day;
      }).toList();

      if (dayTasks.isNotEmpty && dayTasks.every(isCompleted)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    final percentage = (completed / sorted.length) * 100.0;
    final remainingQuarters = (240 - quartersMemorized).clamp(0, 240);

    return AnalyticsSummary(
      totalTasks: sorted.length,
      completedTasks: completed,
      delayedTasks: delayed,
      activeStreakDays: streak,
      completionPercentage: percentage,
      totalQuartersMemorized: quartersMemorized,
      remainingQuarters: remainingQuarters,
    );
  }
}

enum CompensationStrategyType {
  intensiveFridayCatchUp, // Reallocate 1-2 delayed quarters directly into Friday's review slot
  gradualSplit, // Distribute backlogged portions as +0.5 quarter daily over subsequent sessions
  scheduleTimelineShift, // Automatically slide subsequent calendar dates forward by K delayed days
}

class CompensationResult {
  final CompensationStrategyType strategy;
  final String description;
  final int affectedTasksCount;
  final List<dynamic> updatedTasks;

  const CompensationResult({
    required this.strategy,
    required this.description,
    required this.affectedTasksCount,
    required this.updatedTasks,
  });
}

class SmartCompensationEngine {
  /// 1. Intensive Friday Catch-Up Strategy:
  /// Identifies up to [maxQuartersToCatchUp] uncompleted delayed tasks and shifts their scheduled date
  /// to the upcoming Friday review session.
  static CompensationResult applyFridayCatchUp<T>({
    required List<T> tasks,
    required bool Function(T) isCompleted,
    required DateTime Function(T) getScheduledDate,
    required T Function(T, DateTime newDate, String note) copyWithNewSchedule,
    int maxQuartersToCatchUp = 2,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Find next Friday (weekday 5)
    int daysUntilFriday = (DateTime.friday - today.weekday) % 7;
    if (daysUntilFriday <= 0) daysUntilFriday += 7;
    final nextFriday = today.add(Duration(days: daysUntilFriday));

    final delayed = tasks.where((t) {
      final d = getScheduledDate(t);
      return !isCompleted(t) && DateTime(d.year, d.month, d.day).isBefore(today);
    }).take(maxQuartersToCatchUp).toList();

    if (delayed.isEmpty) {
      return CompensationResult(
        strategy: CompensationStrategyType.intensiveFridayCatchUp,
        description: 'لا توجد أوراد متأخرة تحتاج لتعويض يوم الجمعة.',
        affectedTasksCount: 0,
        updatedTasks: tasks,
      );
    }

    final delayedSet = delayed.toSet();
    final updatedList = tasks.map((t) {
      if (delayedSet.contains(t)) {
        return copyWithNewSchedule(
          t,
          nextFriday,
          'تعويض مكثف في جلسة مراجعة الجمعة (${nextFriday.day}/${nextFriday.month})',
        );
      }
      return t;
    }).toList();

    return CompensationResult(
      strategy: CompensationStrategyType.intensiveFridayCatchUp,
      description: 'تم جدولة ${delayed.length} ورد متأخر في جلسة مراجعة يوم الجمعة القادم.',
      affectedTasksCount: delayed.length,
      updatedTasks: updatedList,
    );
  }

  /// 2. Gradual Split Strategy:
  /// Distributes delayed work as +0.5 quarter extra across the next few sessions.
  static CompensationResult applyGradualSplit<T>({
    required List<T> tasks,
    required bool Function(T) isCompleted,
    required DateTime Function(T) getScheduledDate,
    required T Function(T, String note) copyWithGradualNote,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final delayedCount = tasks.where((t) {
      final d = getScheduledDate(t);
      return !isCompleted(t) && DateTime(d.year, d.month, d.day).isBefore(today);
    }).length;

    if (delayedCount == 0) {
      return CompensationResult(
        strategy: CompensationStrategyType.gradualSplit,
        description: 'لا توجد أوراد متأخرة لتوزيعها تدريجياً.',
        affectedTasksCount: 0,
        updatedTasks: tasks,
      );
    }

    // Mark upcoming tasks for gradual split
    final upcoming = tasks.where((t) {
      final d = getScheduledDate(t);
      return !isCompleted(t) && !DateTime(d.year, d.month, d.day).isBefore(today);
    }).take(delayedCount * 2).toList();

    final upcomingSet = upcoming.toSet();
    final updatedList = tasks.map((t) {
      if (upcomingSet.contains(t)) {
        return copyWithGradualNote(
          t,
          '+ 0.5 ربع تعويضي تدريجي',
        );
      }
      return t;
    }).toList();

    return CompensationResult(
      strategy: CompensationStrategyType.gradualSplit,
      description: 'تم توزيع المقدار المتأخر بمعدل نصف ربع إضافي يومياً على الجلسات القادمة منعاً للإرهاق.',
      affectedTasksCount: upcoming.length,
      updatedTasks: updatedList,
    );
  }

  /// 3. Schedule Timeline Shift Strategy:
  /// Slides subsequent calendar dates forward by [delayedDays] days to relieve pressure.
  static CompensationResult applyTimelineShift<T>({
    required List<T> tasks,
    required bool Function(T) isCompleted,
    required DateTime Function(T) getScheduledDate,
    required T Function(T, DateTime newDate) copyWithNewSchedule,
    required int delayedDays,
  }) {
    if (delayedDays <= 0) {
      return CompensationResult(
        strategy: CompensationStrategyType.scheduleTimelineShift,
        description: 'عدد أيام الإزاحة يجب أن يكون يوماً واحداً على الأقل.',
        affectedTasksCount: 0,
        updatedTasks: tasks,
      );
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    int shiftedCount = 0;
    final updatedList = tasks.map((t) {
      if (!isCompleted(t)) {
        final curDate = getScheduledDate(t);
        final newDate = curDate.add(Duration(days: delayedDays));
        shiftedCount++;
        return copyWithNewSchedule(t, newDate);
      }
      return t;
    }).toList();

    return CompensationResult(
      strategy: CompensationStrategyType.scheduleTimelineShift,
      description: 'تمت إزاحة الجدول الزمني للأوراد المتبقية بمقدار $delayedDays يوم للحفاظ على الاستمرارية بدون انقطاع.',
      affectedTasksCount: shiftedCount,
      updatedTasks: updatedList,
    );
  }
}
