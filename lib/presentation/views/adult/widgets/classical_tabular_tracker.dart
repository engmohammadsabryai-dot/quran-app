import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../domain/models/daily_task.dart';
import '../../../../domain/models/mutashabiha_item.dart';
import 'mutashabiha_badge_and_modal.dart';

class ClassicalTabularTracker extends StatelessWidget {
  final List<DailyTask> tasks;
  final Function(DailyTask) onPlayTask;
  final Function(DailyTask) onToggleComplete;
  final Function(DailyTask) onSelectTask;
  final List<MutashabihaItem> mutashabihatList;

  const ClassicalTabularTracker({
    super.key,
    required this.tasks,
    required this.onPlayTask,
    required this.onToggleComplete,
    required this.onSelectTask,
    required this.mutashabihatList,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE d MMMM', 'ar');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdultColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Table Title Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              color: AdultColors.primaryGreen,
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Row(
              children: [
                const Icon(Icons.table_chart_rounded, color: AdultColors.goldAccent, size: 20),
                const SizedBox(width: 8),
                Text(
                  'جدول متابعة الأوراد اليومية (نظام الجدولة الكلاسيكي)',
                  style: GoogleFonts.cairo(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Text(
                  '${tasks.length} ورد',
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          // Column Headers
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: const Color(0xFFF3F1EC),
            child: Row(
              children: [
                SizedBox(
                  width: 44,
                  child: Text(
                    'اليوم',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(fontSize: 11.5, fontWeight: FontWeight.bold, color: AdultColors.textSecondary),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'المقدار / السورة',
                    style: GoogleFonts.cairo(fontSize: 11.5, fontWeight: FontWeight.bold, color: AdultColors.textSecondary),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'الصلوات',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(fontSize: 11.5, fontWeight: FontWeight.bold, color: AdultColors.textSecondary),
                  ),
                ),
                const SizedBox(
                  width: 90,
                  child: Text(
                    'الإجراءات',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AdultColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),

          // Tasks List (Rows)
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tasks.length,
            separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade200),
            itemBuilder: (context, index) {
              final task = tasks[index];
              final isDelayed = task.isDelayed();
              final isFriday = task.isFridayReview;

              // Check if task range has mutashabihat
              final matchingMutashabiha = mutashabihatList.cast<MutashabihaItem?>().firstWhere(
                    (m) => m?.isInRange(task.surahNumber, task.fromAyah, task.toAyah) ?? false,
                    orElse: () => null,
                  );

              Color rowBg = Colors.white;
              if (task.isCompleted) {
                rowBg = const Color(0xFFF6FBF7);
              } else if (isDelayed) {
                rowBg = const Color(0xFFFFF5F5);
              } else if (isFriday) {
                rowBg = const Color(0xFFFAF5FF);
              }

              return InkWell(
                onTap: () => onSelectTask(task),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  color: rowBg,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          // Day Number Badge
                          SizedBox(
                            width: 44,
                            child: Column(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: isFriday
                                        ? const Color(0xFF7B2CBF).withOpacity(0.12)
                                        : AdultColors.primaryGreen.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '${task.dayNumber}',
                                    style: GoogleFonts.cairo(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: isFriday ? const Color(0xFF7B2CBF) : AdultColors.primaryGreen,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Portion Description & Surah info
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        task.portionTitle,
                                        style: GoogleFonts.cairo(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: task.isCompleted ? AdultColors.completedGreen : AdultColors.textPrimary,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (isFriday) ...[
                                      const SizedBox(width: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF7B2CBF),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          'مراجعة الجمعة',
                                          style: GoogleFonts.cairo(fontSize: 9.5, color: Colors.white, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'سورة ${task.surahArabicName} (الآيات ${task.fromAyah} - ${task.toAyah})',
                                  style: GoogleFonts.amiri(
                                    fontSize: 13,
                                    color: AdultColors.textSecondary,
                                  ),
                                ),
                                Text(
                                  dateFormat.format(task.scheduledDate),
                                  style: GoogleFonts.cairo(
                                    fontSize: 10.5,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                                if (task.compensationNote != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    '⚠️ ${task.compensationNote}',
                                    style: GoogleFonts.cairo(
                                      fontSize: 11,
                                      color: AdultColors.pendingOrange,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          // Prayer Checkoff Summary
                          Expanded(
                            flex: 2,
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildPrayerDot(task.prayer1FajrDone),
                                  _buildPrayerDot(task.prayer2DhuhrDone),
                                  _buildPrayerDot(task.prayer3AsrDone),
                                  _buildPrayerDot(task.prayer4MaghribDone),
                                  _buildPrayerDot(task.prayer5IshaDone),
                                ],
                              ),
                            ),
                          ),

                          // Action Buttons: Play + Complete Checkbox
                          SizedBox(
                            width: 90,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.play_circle_fill_rounded, color: AdultColors.primaryGreen, size: 26),
                                  tooltip: 'استماع وتكرار',
                                  onPressed: () => onPlayTask(task),
                                ),
                                InkWell(
                                  onTap: () => onToggleComplete(task),
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    width: 26,
                                    height: 26,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: task.isCompleted ? AdultColors.completedGreen : Colors.transparent,
                                      border: Border.all(
                                        color: task.isCompleted ? AdultColors.completedGreen : Colors.grey.shade400,
                                        width: 1.8,
                                      ),
                                    ),
                                    child: task.isCompleted
                                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // If there is a Mutashabiha Badge for this task, show it right underneath!
                      if (matchingMutashabiha != null) ...[
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.only(right: 44),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: MutashabihaBadge(
                              item: matchingMutashabiha,
                              onTap: () {
                                MutashabihaComparisonModal.show(context, matchingMutashabiha);
                              },
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerDot(bool isDone) {
    return Container(
      width: 7,
      height: 7,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDone ? AdultColors.completedGreen : Colors.grey.shade300,
      ),
    );
  }
}
