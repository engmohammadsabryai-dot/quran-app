import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/prayer_splitter.dart';
import '../../../../domain/models/daily_task.dart';

class PrayerSplitterWidget extends StatelessWidget {
  final DailyTask task;
  final void Function(int prayerIndex, bool isCompleted) onTogglePrayer;

  const PrayerSplitterWidget({
    super.key,
    required this.task,
    required this.onTogglePrayer,
  });

  @override
  Widget build(BuildContext context) {
    final chunks = PrayerSplitterEngine.splitPortionIntoFivePrayers(
      surahNumber: task.surahNumber,
      surahArabicName: task.surahArabicName,
      fromAyah: task.fromAyah,
      toAyah: task.toAyah,
      completedStatus: [
        task.prayer1FajrDone,
        task.prayer2DhuhrDone,
        task.prayer3AsrDone,
        task.prayer4MaghribDone,
        task.prayer5IshaDone,
      ],
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdultColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AdultColors.primaryGreen.withOpacity(0.06),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              border: Border(bottom: BorderSide(color: AdultColors.borderLight)),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time_filled_rounded, color: AdultColors.primaryGreen, size: 20),
                const SizedBox(width: 8),
                Text(
                  'مصحف الصلوات الخمس - توزيع الورد على الركعات',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AdultColors.primaryGreen,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: task.areAllPrayersCompleted ? AdultColors.completedGreen : AdultColors.goldAccent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${task.prayerCompletionCount}/5 صلوات',
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 5 Prayer Rows
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: chunks.length,
            separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade100),
            itemBuilder: (context, index) {
              final chunk = chunks[index];
              final prayerNumber = index + 1;

              return InkWell(
                onTap: () {
                  onTogglePrayer(prayerNumber, !chunk.isCompleted);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      // Checkbox
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: chunk.isCompleted ? AdultColors.completedGreen : Colors.transparent,
                          border: Border.all(
                            color: chunk.isCompleted ? AdultColors.completedGreen : Colors.grey.shade400,
                            width: 2,
                          ),
                        ),
                        child: chunk.isCompleted
                            ? const Icon(Icons.check, size: 16, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: 12),

                      // Prayer Name Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: chunk.prayerType == PrayerType.ishaAndQiyam
                              ? const Color(0xFF312E81).withOpacity(0.1)
                              : AdultColors.primaryGreen.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          chunk.prayerType.arabicName,
                          style: GoogleFonts.cairo(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: chunk.prayerType == PrayerType.ishaAndQiyam
                                ? const Color(0xFF312E81)
                                : AdultColors.primaryGreen,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Portion allocation & rak'ah note
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              chunk.portionDescription,
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                fontWeight: chunk.isCompleted ? FontWeight.normal : FontWeight.w600,
                                decoration: chunk.isCompleted ? TextDecoration.lineThrough : null,
                                color: chunk.isCompleted ? Colors.grey.shade500 : AdultColors.textPrimary,
                              ),
                            ),
                            Text(
                              chunk.prayerType.rakahAllocation,
                              style: GoogleFonts.cairo(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
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
}
