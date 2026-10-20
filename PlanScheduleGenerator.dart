enum TaskType { memorize, weeklyReview }
enum TaskStatus { pending, done, notDone }

class ScheduledDayItem {
  final int dayNumber;          // م (1 إلى 280)
  final String dayName;         // السبت، الأحد ... الجمعة
  final DateTime scheduledDate; // التاريخ التقويمي
  final TaskType type;
  final QuranQuarter? quarter;  // ممتلئ إذا كان حفظاً جديداً
  final List<QuranQuarter> reviewQuarters; // قائمة أرباع الأسبوع في يوم الجمعة
  TaskStatus status;

  ScheduledDayItem({
    required this.dayNumber,
    required this.dayName,
    required this.scheduledDate,
    required this.type,
    this.quarter,
    this.reviewQuarters = const [],
    this.status = TaskStatus.pending,
  });
}

class PlanScheduleGenerator {
  static const List<String> weekDayNames = [
    'السبت',
    'الأحد',
    'الإثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
  ];

  static List<ScheduledDayItem> generateQuarterPlan({
    required List<QuranQuarter> allQuarters,
    required DateTime startDate, // يفضل أن يكون يوم سبت
  }) {
    List<ScheduledDayItem> schedule = [];
    int quarterIndex = 0;
    int currentDayCount = 1;
    DateTime currentDate = startDate;

    while (quarterIndex < allQuarters.length) {
      List<QuranQuarter> currentWeekQuarters = [];

      // توليد 6 أيام حفظ (السبت إلى الخميس)
      for (int i = 0; i < 6; i++) {
        if (quarterIndex >= allQuarters.length) break;

        final q = allQuarters[quarterIndex];
        currentWeekQuarters.add(q);

        schedule.add(ScheduledDayItem(
          dayNumber: currentDayCount,
          dayName: weekDayNames[i],
          scheduledDate: currentDate,
          type: TaskType.memorize,
          quarter: q,
          status: TaskStatus.pending,
        ));

        currentDayCount++;
        currentDate = currentDate.add(const Duration(days: 1));
        quarterIndex++;
      }

      // توليد يوم الجمعة (مراجعة حصاد الأسبوع)
      schedule.add(ScheduledDayItem(
        dayNumber: currentDayCount,
        dayName: weekDayNames[6], // الجمعة
        scheduledDate: currentDate,
        type: TaskType.weeklyReview,
        reviewQuarters: List.from(currentWeekQuarters),
        status: TaskStatus.pending,
      ));

      currentDayCount++;
      currentDate = currentDate.add(const Duration(days: 1));
    }

    return schedule;
  }
}