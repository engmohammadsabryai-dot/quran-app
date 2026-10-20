import 'package:equatable/equatable.dart';

enum MemorizationSystemType {
  quarterSystem, // 240 Quarters across 30 juz, 280-day cycle (Sat-Thu + Fri review)
  pageSystem, // 604 pages (Madani Mushaf)
  ayahRangeSystem, // Configurable daily limits (3, 5, 10) with waqf awareness
}

extension MemorizationSystemTypeExtension on MemorizationSystemType {
  String get rawValue {
    switch (this) {
      case MemorizationSystemType.quarterSystem:
        return 'QUARTER_SYSTEM';
      case MemorizationSystemType.pageSystem:
        return 'PAGE_SYSTEM';
      case MemorizationSystemType.ayahRangeSystem:
        return 'AYAH_RANGE_SYSTEM';
    }
  }

  String get arabicTitle {
    switch (this) {
      case MemorizationSystemType.quarterSystem:
        return 'نظام الأرباع (٢٤٠ ربع - ٢٨٠ يوم)';
      case MemorizationSystemType.pageSystem:
        return 'نظام الصفحات (٦٠٤ صفحة)';
      case MemorizationSystemType.ayahRangeSystem:
        return 'نظام الآيات والوقف الهادف';
    }
  }

  static MemorizationSystemType fromString(String val) {
    if (val == 'PAGE_SYSTEM') return MemorizationSystemType.pageSystem;
    if (val == 'AYAH_RANGE_SYSTEM') return MemorizationSystemType.ayahRangeSystem;
    return MemorizationSystemType.quarterSystem;
  }
}

class MemorizationPlan extends Equatable {
  final String planId;
  final String userId;
  final MemorizationSystemType systemType;
  final String name;
  final DateTime startDate;
  final DateTime targetEndDate;
  final int totalTasks;
  final int currentStreak;
  final bool isCompleted;

  const MemorizationPlan({
    required this.planId,
    required this.userId,
    required this.systemType,
    required this.name,
    required this.startDate,
    required this.targetEndDate,
    required this.totalTasks,
    this.currentStreak = 0,
    this.isCompleted = false,
  });

  MemorizationPlan copyWith({
    String? planId,
    String? userId,
    MemorizationSystemType? systemType,
    String? name,
    DateTime? startDate,
    DateTime? targetEndDate,
    int? totalTasks,
    int? currentStreak,
    bool? isCompleted,
  }) {
    return MemorizationPlan(
      planId: planId ?? this.planId,
      userId: userId ?? this.userId,
      systemType: systemType ?? this.systemType,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      targetEndDate: targetEndDate ?? this.targetEndDate,
      totalTasks: totalTasks ?? this.totalTasks,
      currentStreak: currentStreak ?? this.currentStreak,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  List<Object?> get props => [
        planId,
        userId,
        systemType,
        name,
        startDate,
        targetEndDate,
        totalTasks,
        currentStreak,
        isCompleted,
      ];
}
