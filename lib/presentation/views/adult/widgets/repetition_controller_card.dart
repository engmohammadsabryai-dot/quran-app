import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/audio/hybrid_audio_player_service.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/datasources/local/quran_text_data.dart';

class RepetitionControllerCard extends StatelessWidget {
  final PlaybackProgressState audioState;
  final int surahNumber;
  final String surahArabicName;
  final int fromAyah;
  final int toAyah;
  final VoidCallback onPlayRange;
  final VoidCallback onTogglePlayPause;
  final VoidCallback onSkipNext;
  final VoidCallback onSkipPrevious;
  final Function(int n) onSetAyahRepeats;
  final Function(int m) onSetPortionCycles;
  final Function(int t) onSetIntervalDelay;
  final Function(ReciterInfo reciter) onReciterChanged;

  const RepetitionControllerCard({
    super.key,
    required this.audioState,
    required this.surahNumber,
    required this.surahArabicName,
    required this.fromAyah,
    required this.toAyah,
    required this.onPlayRange,
    required this.onTogglePlayPause,
    required this.onSkipNext,
    required this.onSkipPrevious,
    required this.onSetAyahRepeats,
    required this.onSetPortionCycles,
    required this.onSetIntervalDelay,
    required this.onReciterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isPlaying = audioState.isPlaying;
    final currentAyah = audioState.currentItem?.ayahNumber ?? fromAyah;
    final currentText = audioState.currentItem?.textArabic.isNotEmpty == true
        ? audioState.currentItem!.textArabic
        : QuranTextData.getAyahText(surahNumber, currentAyah, surahArabicName);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AdultColors.goldAccent.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AdultColors.goldAccent.withOpacity(0.1),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Live Repetition State Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isPlaying ? const Color(0xFF10B981) : Colors.grey,
                      boxShadow: isPlaying
                          ? [
                              BoxShadow(
                                color: const Color(0xFF10B981).withOpacity(0.6),
                                blurRadius: 6,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'الآية $currentAyah ($fromAyah - $toAyah) • تكرار: ${audioState.currentAyahRepeatCount} / ${audioState.targetAyahRepeats} (N)',
                    style: GoogleFonts.cairo(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: AdultColors.primaryGreen,
                    ),
                  ),
                ],
              ),
              if (audioState.isInIntervalDelay)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFF59E0B)),
                  ),
                  child: Text(
                    '⏱️ وقفة: ${audioState.intervalSecondsRemaining}ث',
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFB45309),
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AdultColors.primaryGreen.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'دورة: ${audioState.currentPortionCycle} / ${audioState.targetPortionCycles} (M)',
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AdultColors.primaryGreen,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // 2. Active Ayah Text Preview
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Text(
              currentText,
              textAlign: TextAlign.center,
              style: GoogleFonts.amiri(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AdultColors.primaryGreen,
                height: 1.7,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // 3. Reciter Selection Dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFCBD5E1)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: audioState.reciter.id,
                isExpanded: true,
                icon: const Icon(Icons.mic, color: AdultColors.primaryGreen),
                items: AppConstants.availableReciters.map((r) {
                  return DropdownMenuItem<String>(
                    value: r.id,
                    child: Text(
                      '${r.nameArabic} - ${r.style}',
                      style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (newId) {
                  if (newId != null) {
                    final reciter = AppConstants.availableReciters.firstWhere((r) => r.id == newId);
                    onReciterChanged(reciter);
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 14),

          // 4. Repetition Parameters (N, M, T)
          Row(
            children: [
              // N: Ayah Repeats
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('تكرار الآية (N):', style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.bold, color: AdultColors.textSecondary)),
                    const SizedBox(height: 4),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [1, 3, 5, 10].map((n) {
                          final selected = audioState.targetAyahRepeats == n;
                          return InkWell(
                            onTap: () => onSetAyahRepeats(n),
                            child: Container(
                              margin: const EdgeInsets.only(left: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                              decoration: BoxDecoration(
                                color: selected ? AdultColors.primaryGreen : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '$n',
                                style: GoogleFonts.cairo(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: selected ? Colors.white : AdultColors.textSecondary,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              // M: Range Cycles
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('دورة الورد (M):', style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.bold, color: AdultColors.textSecondary)),
                    const SizedBox(height: 4),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [1, 2, 3, 5].map((m) {
                          final selected = audioState.targetPortionCycles == m;
                          return InkWell(
                            onTap: () => onSetPortionCycles(m),
                            child: Container(
                              margin: const EdgeInsets.only(left: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                              decoration: BoxDecoration(
                                color: selected ? AdultColors.primaryGreen : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '$m',
                                style: GoogleFonts.cairo(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: selected ? Colors.white : AdultColors.textSecondary,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              // T: Interval Delay
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('وقفة (T):', style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.bold, color: AdultColors.textSecondary)),
                    const SizedBox(height: 4),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [0, 2, 3, 5].map((t) {
                          final selected = audioState.intervalDelaySeconds == t;
                          return InkWell(
                            onTap: () => onSetIntervalDelay(t),
                            child: Container(
                              margin: const EdgeInsets.only(left: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                              decoration: BoxDecoration(
                                color: selected ? AdultColors.goldAccent : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${t}ث',
                                style: GoogleFonts.cairo(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: selected ? Colors.white : AdultColors.textSecondary,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 5. Main Audio Playback Action Bar
          Row(
            children: [
              IconButton(
                onPressed: onSkipPrevious,
                icon: const Icon(Icons.skip_previous_rounded, size: 30, color: AdultColors.primaryGreen),
                tooltip: 'الآية السابقة',
              ),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (isPlaying) {
                      onTogglePlayPause();
                    } else {
                      onPlayRange();
                    }
                  },
                  icon: Icon(
                    isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
                    size: 24,
                  ),
                  label: Text(
                    isPlaying ? 'إيقاف مؤقت للاستماع' : 'تشغيل الاستماع والترديد بالنطاق المحدد',
                    style: GoogleFonts.cairo(fontSize: 13.5, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdultColors.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              IconButton(
                onPressed: onSkipNext,
                icon: const Icon(Icons.skip_next_rounded, size: 30, color: AdultColors.primaryGreen),
                tooltip: 'الآية التالية',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
