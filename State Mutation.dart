void applyScheduleShift({
  required List<ScheduledDayItem> schedule,
  required int delayDays,
}) {
  bool shiftStarted = false;
  final today = DateTime.now();

  for (var item in schedule) {
    // تبدأ الإزاحة من أول عنصر غير مكتمل تجاوز تاريخه
    if (!shiftStarted && item.status != TaskStatus.done && item.scheduledDate.isBefore(today)) {
      shiftStarted = true;
    }

    if (shiftStarted && item.status != TaskStatus.done) {
      item.scheduledDate = item.scheduledDate.add(Duration(days: delayDays));
    }
  }
}