import 'package:equatable/equatable.dart';

class DailyTask extends Equatable {
  final String taskId;
  final String planId;
  final String userId;
  final int dayNumber;
  final DateTime scheduledDate;
  final int surahNumber;
  final String surahArabicName;
  final int fromAyah;
  final int toAyah;
  final int? quarterIndex; // 1 to 240
  final int? pageNumber; // 1 to 604
  final String portionTitle;
  final bool isCompleted;
  final DateTime? completedAt;
  final bool isFridayReview;
  final String? compensationNote;

  // 5-Prayer check-off indicators
  final bool prayer1FajrDone;
  final bool prayer2DhuhrDone;
  final bool prayer3AsrDone;
  final bool prayer4MaghribDone;
  final bool prayer5IshaDone;

  const DailyTask({
    required this.taskId,
    required this.planId,
    required this.userId,
    required this.dayNumber,
    required this.scheduledDate,
    required this.surahNumber,
    required this.surahArabicName,
    required this.fromAyah,
    required this.toAyah,
    this.quarterIndex,
    this.pageNumber,
    required this.portionTitle,
    this.isCompleted = false,
    this.completedAt,
    this.isFridayReview = false,
    this.compensationNote,
    this.prayer1FajrDone = false,
    this.prayer2DhuhrDone = false,
    this.prayer3AsrDone = false,
    this.prayer4MaghribDone = false,
    this.prayer5IshaDone = false,
  });

  /// Delay Detection: Dynamically flags uncompleted tasks whose scheduled dates precede DateTime.now()
  bool isDelayed([DateTime? now]) {
    if (isCompleted) return false;
    final current = now ?? DateTime.now();
    final today = DateTime(current.year, current.month, current.day);
    final taskDay = DateTime(scheduledDate.year, scheduledDate.month, scheduledDate.day);
    return taskDay.isBefore(today);
  }

  int get prayerCompletionCount {
    int c = 0;
    if (prayer1FajrDone) c++;
    if (prayer2DhuhrDone) c++;
    if (prayer3AsrDone) c++;
    if (prayer4MaghribDone) c++;
    if (prayer5IshaDone) c++;
    return c;
  }

  bool get areAllPrayersCompleted => prayerCompletionCount == 5;

  DailyTask copyWith({
    String? taskId,
    String? planId,
    String? userId,
    int? dayNumber,
    DateTime? scheduledDate,
    int? surahNumber,
    String? surahArabicName,
    int? fromAyah,
    int? toAyah,
    int? quarterIndex,
    int? pageNumber,
    String? portionTitle,
    bool? isCompleted,
    DateTime? completedAt,
    bool? isFridayReview,
    String? compensationNote,
    bool? prayer1FajrDone,
    bool? prayer2DhuhrDone,
    bool? prayer3AsrDone,
    bool? prayer4MaghribDone,
    bool? prayer5IshaDone,
  }) {
    return DailyTask(
      taskId: taskId ?? this.taskId,
      planId: planId ?? this.planId,
      userId: userId ?? this.userId,
      dayNumber: dayNumber ?? this.dayNumber,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      surahNumber: surahNumber ?? this.surahNumber,
      surahArabicName: surahArabicName ?? this.surahArabicName,
      fromAyah: fromAyah ?? this.fromAyah,
      toAyah: toAyah ?? this.toAyah,
      quarterIndex: quarterIndex ?? this.quarterIndex,
      pageNumber: pageNumber ?? this.pageNumber,
      portionTitle: portionTitle ?? this.portionTitle,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      isFridayReview: isFridayReview ?? this.isFridayReview,
      compensationNote: compensationNote ?? this.compensationNote,
      prayer1FajrDone: prayer1FajrDone ?? this.prayer1FajrDone,
      prayer2DhuhrDone: prayer2DhuhrDone ?? this.prayer2DhuhrDone,
      prayer3AsrDone: prayer3AsrDone ?? this.prayer3AsrDone,
      prayer4MaghribDone: prayer4MaghribDone ?? this.prayer4MaghribDone,
      prayer5IshaDone: prayer5IshaDone ?? this.prayer5IshaDone,
    );
  }

  @override
  List<Object?> get props => [
        taskId,
        planId,
        userId,
        dayNumber,
        scheduledDate,
        surahNumber,
        surahArabicName,
        fromAyah,
        toAyah,
        quarterIndex,
        pageNumber,
        portionTitle,
        isCompleted,
        completedAt,
        isFridayReview,
        compensationNote,
        prayer1FajrDone,
        prayer2DhuhrDone,
        prayer3AsrDone,
        prayer4MaghribDone,
        prayer5IshaDone,
      ];
}
