enum CompensationStrategy {
  intensiveWeekend, // تعويض في يوم الجمعة المخصص للمراجعة
  splitOverDays,    // تقسيم الربع المتأخر بمعدل نصف ربع إضافي يومياً
  shiftSchedule,    // إزاحة الجدول الزمني بالكامل للأمام
}

class CompensationSuggestion {
  final CompensationStrategy strategy;
  final String title;
  final String description;
  final String actionLabel;

  CompensationSuggestion({
    required this.strategy,
    required this.title,
    required this.description,
    required this.actionLabel,
  });
}

class PlanAnalyticsResult {
  final int totalTasks;
  final int completedTasks;
  final int missedTasks;
  final int remainingTasks;
  final double completionPercentage;
  final int delayDaysCount;
  final List<ScheduledDayItem> delayedQuarters;
  final List<CompensationSuggestion> suggestions;

  PlanAnalyticsResult({
    required this.totalTasks,
    required this.completedTasks,
    required this.missedTasks,
    required this.remainingTasks,
    required this.completionPercentage,
    required this.delayDaysCount,
    required this.delayedQuarters,
    required this.suggestions,
  });
}

class PlanAnalyticsEngine {
  static PlanAnalyticsResult calculateAnalytics({
    required List<ScheduledDayItem> schedule,
    required DateTime now,
  }) {
    int total = schedule.length;
    int completed = 0;
    int missed = 0;
    List<ScheduledDayItem> delayedItems = [];

    final today = DateTime(now.year, now.month, now.day);

    for (var item in schedule) {
      final itemDate = DateTime(
        item.scheduledDate.year,
        item.scheduledDate.month,
        item.scheduledDate.day,
      );

      if (item.status == TaskStatus.done) {
        completed++;
      } else if (item.status == TaskStatus.notDone) {
        missed++;
        delayedItems.add(item);
      } else if (item.status == TaskStatus.pending && itemDate.isBefore(today)) {
        // فات موعدها ولم تنجز بعد
        missed++;
        delayedItems.add(item);
      }
    }

    int remaining = total - completed;
    double percentage = total > 0 ? (completed / total) * 100 : 0.0;
    int delayDays = delayedItems.length;

    // توليد مقترحات التعويض بناءً على حجم التأخير
    List<CompensationSuggestion> suggestions = [];
    if (delayDays > 0) {
      if (delayDays <= 2) {
        // تأخير خفيف (ربع أو ربعان): التعويض في يوم المراجعة الأسبوعي (الجمعة)
        suggestions.add(CompensationSuggestion(
          strategy: CompensationStrategy.intensiveWeekend,
          title: 'دمج الورد في يوم الجمعة',
          description: 'لديك $delayDays ربع متأخر فقط؛ يمكنك استغلال يوم الجمعة (المخصص لمراجعة الأسبوع) لتعويضها وتثبيتها.',
          actionLabel: 'ترحيل إلى الجمعة القادمة',
        ));
      }

      if (delayDays >= 2 && delayDays <= 6) {
        // تأخير متوسط: تجزئة الربع المتأخر على الأيام القادمة
        suggestions.add(CompensationSuggestion(
          strategy: CompensationStrategy.splitOverDays,
          title: 'خطة التوزيع التدريجي',
          description: 'قسّم الأرباع المتأخرة بمعدل نصف ربع إضافي يومياً مع وردك المعتاد لتعويض التأخير خلال ${(delayDays * 2)} أيام دون إجهاد.',
          actionLabel: 'تفعيل التوزيع التدريجي',
        ));
      }

      // خيار الإزاحة العامة للجدول متاح دائماً لمنع الضغط النفسي
      suggestions.add(CompensationSuggestion(
        strategy: CompensationStrategy.shiftSchedule,
        title: 'إعادة جدولة وضبط التواريخ',
        description: 'إزاحة تواريخ الخطة بمقدار $delayDays أيام للأمام بحيث يصبح المقطع المتأخر هو ورد اليوم دون تراكم.',
        actionLabel: 'إزاحة التواريخ بمقدار $delayDays أيام',
      ));
    }

    return PlanAnalyticsResult(
      totalTasks: total,
      completedTasks: completed,
      missedTasks: missed,
      remainingTasks: remaining,
      completionPercentage: percentage,
      delayDaysCount: delayDays,
      delayedQuarters: delayedItems,
      suggestions: suggestions,
    );
  }
}