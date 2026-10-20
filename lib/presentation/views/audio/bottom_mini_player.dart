import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/audio/hybrid_audio_player_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../blocs/audio/audio_cubit.dart';
import 'audio_settings_sheet.dart';

class BottomMiniPlayer extends StatelessWidget {
  final bool isKidsTheme;

  const BottomMiniPlayer({super.key, this.isKidsTheme = false});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioCubit, PlaybackProgressState>(
      builder: (context, state) {
        if (state.currentItem == null && !state.isPlaying && !state.isInIntervalDelay) {
          return const SizedBox.shrink();
        }

        final item = state.currentItem;
        final currentAyahNumber = item?.ayahNumber ?? 1;
        final surahName = item?.surahArabicName ?? '';

        final primaryColor = isKidsTheme ? KidsColors.primaryPurple : AdultColors.primaryGreen;
        final accentColor = isKidsTheme ? KidsColors.sunnyOrange : AdultColors.goldAccent;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(isKidsTheme ? 24 : 16),
            border: Border.all(
              color: isKidsTheme ? const Color(0xFFE2D4F0) : AdultColors.borderLight,
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: (isKidsTheme ? KidsColors.primaryPurple : Colors.black).withOpacity(0.08),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(isKidsTheme ? 24 : 16)),
                child: LinearProgressIndicator(
                  value: state.duration.inMilliseconds > 0
                      ? (state.position.inMilliseconds / state.duration.inMilliseconds).clamp(0.0, 1.0)
                      : 0.0,
                  minHeight: 3.5,
                  backgroundColor: Colors.grey.shade100,
                  valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Play/Pause circular button
                        GestureDetector(
                          onTap: () => context.read<AudioCubit>().togglePlayPause(),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: primaryColor,
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.35),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: state.isBuffering
                                ? const Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                    ),
                                  )
                                : Icon(
                                    state.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                    color: Colors.white,
                                    size: 26,
                                  ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Title, Reciter and Ayah
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'سورة $surahName',
                                    style: GoogleFonts.cairo(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: accentColor.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'الآية $currentAyahNumber',
                                      style: GoogleFonts.cairo(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: accentColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                state.reciter.nameArabic,
                                style: GoogleFonts.cairo(
                                  fontSize: 11.5,
                                  color: Colors.grey.shade600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),

                        // Skip previous / next controls
                        IconButton(
                          icon: const Icon(Icons.skip_previous_rounded),
                          color: primaryColor,
                          iconSize: 26,
                          onPressed: () => context.read<AudioCubit>().skipPrevious(),
                        ),
                        IconButton(
                          icon: const Icon(Icons.skip_next_rounded),
                          color: primaryColor,
                          iconSize: 26,
                          onPressed: () => context.read<AudioCubit>().skipNext(),
                        ),

                        // Audio Settings icon
                        IconButton(
                          icon: const Icon(Icons.tune_rounded),
                          color: Colors.grey.shade700,
                          iconSize: 22,
                          onPressed: () => AudioSettingsSheet.show(context),
                        ),
                      ],
                    ),

                    // Repetition Status & Interval Delay Banner
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Ayah loop count: N
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'تكرار الآية: ${state.currentAyahRepeatCount}/${state.targetAyahRepeats}',
                            style: GoogleFonts.cairo(fontSize: 10.5, fontWeight: FontWeight.w600, color: Colors.grey.shade800),
                          ),
                        ),

                        // Portion loop cycle: M
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'دورة الورد: ${state.currentPortionCycle}/${state.targetPortionCycles}',
                            style: GoogleFonts.cairo(fontSize: 10.5, fontWeight: FontWeight.w600, color: Colors.grey.shade800),
                          ),
                        ),

                        // Interval Delay Indicator (T)
                        if (state.isInIntervalDelay)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFF60A5FA), width: 1),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.timer_outlined, size: 12, color: Color(0xFF2563EB)),
                                const SizedBox(width: 4),
                                Text(
                                  'ترديد ذهني: ${state.intervalSecondsRemaining}ث',
                                  style: GoogleFonts.cairo(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF1D4ED8),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Text(
                            'وقفة الترديد: ${state.intervalDelaySeconds}ث',
                            style: GoogleFonts.cairo(fontSize: 10.5, color: Colors.grey.shade500),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
