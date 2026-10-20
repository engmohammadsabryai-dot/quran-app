import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/models/daily_task.dart';
import '../../blocs/audio/audio_cubit.dart';
import '../../blocs/mutashabihat/mutashabihat_cubit.dart';
import '../../blocs/plan/plan_bloc.dart';
import '../../blocs/plan/plan_event.dart';
import '../../blocs/plan/plan_state.dart';
import '../../blocs/profile/profile_bloc.dart';
import '../../blocs/profile/profile_state.dart';
import '../audio/bottom_mini_player.dart';
import '../profile/profile_switcher_sheet.dart';
import 'widgets/analytics_dashboard_header.dart';
import 'widgets/classical_tabular_tracker.dart';
import 'widgets/delay_compensation_dialog.dart';
import 'widgets/mutashabiha_badge_and_modal.dart';
import 'widgets/prayer_splitter_widget.dart';

class AdultClassicalHomeView extends StatefulWidget {
  const AdultClassicalHomeView({super.key});

  @override
  State<AdultClassicalHomeView> createState() => _AdultClassicalHomeViewState();
}

class _AdultClassicalHomeViewState extends State<AdultClassicalHomeView> {
  DailyTask? _selectedTaskOverride;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'مصحف الحفظ والورد القرآني',
          style: GoogleFonts.amiri(fontSize: 22, fontWeight: FontWeight.bold, color: AdultColors.primaryGreen),
        ),
        actions: [
          // Profile Switcher Action
          BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, profState) {
              final active = profState.activeProfile;
              return TextButton.icon(
                onPressed: () => ProfileSwitcherSheet.show(context),
                icon: const CircleAvatar(
                  radius: 14,
                  backgroundColor: AdultColors.primaryGreen,
                  child: Text('👳', style: TextStyle(fontSize: 14)),
                ),
                label: Row(
                  children: [
                    Text(
                      active?.name ?? 'الحساب',
                      style: GoogleFonts.cairo(fontSize: 12.5, fontWeight: FontWeight.bold, color: AdultColors.primaryGreen),
                    ),
                    const Icon(Icons.arrow_drop_down, color: AdultColors.primaryGreen, size: 20),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocConsumer<PlanBloc, PlanState>(
        listener: (context, state) {
          if (state.compensationMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.compensationMessage!, style: GoogleFonts.cairo()),
                backgroundColor: AdultColors.primaryGreen,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, planState) {
          if (planState.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AdultColors.primaryGreen),
            );
          }

          final activeTask = _selectedTaskOverride ?? planState.todayTask ?? planState.tasks.firstOrNull;
          final mutashabihatList = context.watch<MutashabihatCubit>().state.items;

          return SafeArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Plan Name Badge
                      if (planState.activePlan != null)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AdultColors.primaryGreen.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AdultColors.primaryGreen.withOpacity(0.2)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.bookmark_outline_rounded, color: AdultColors.primaryGreen, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  planState.activePlan!.name,
                                  style: GoogleFonts.cairo(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                    color: AdultColors.primaryGreen,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AdultColors.goldAccent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'تتابع: ${planState.analytics.activeStreakDays} يوم',
                                  style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Analytics Dashboard Header
                      AnalyticsDashboardHeader(
                        analytics: planState.analytics,
                        onOpenCompensation: () {
                          DelayCompensationDialog.show(
                            context,
                            delayedCount: planState.delayedTasks.length,
                            onApply: (strategy, shiftDays) {
                              context.read<PlanBloc>().add(
                                    ApplyCompensationStrategyEvent(
                                      strategy: strategy,
                                      shiftDays: shiftDays,
                                    ),
                                  );
                            },
                          );
                        },
                      ),

                      // Today's Active Portion Spotlight Card
                      if (activeTask != null) ...[
                        _buildTodayPortionSpotlight(context, activeTask, mutashabihatList),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: PrayerSplitterWidget(
                            task: activeTask,
                            onTogglePrayer: (prayerIndex, isCompleted) {
                              context.read<PlanBloc>().add(
                                    TogglePrayerCheckoffEvent(
                                      taskId: activeTask.taskId,
                                      prayerIndex: prayerIndex,
                                      isCompleted: isCompleted,
                                    ),
                                  );
                            },
                          ),
                        ),
                      ],

                      const SizedBox(height: 14),

                      // Classical Tabular Tracker
                      ClassicalTabularTracker(
                        tasks: planState.tasks,
                        mutashabihatList: mutashabihatList,
                        onSelectTask: (task) {
                          setState(() => _selectedTaskOverride = task);
                        },
                        onPlayTask: (task) {
                          context.read<AudioCubit>().playTask(task);
                        },
                        onToggleComplete: (task) {
                          context.read<PlanBloc>().add(ToggleTaskCompletedEvent(task));
                        },
                      ),
                    ],
                  ),
                ),

                // Floating Bottom Mini Player
                const Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: BottomMiniPlayer(isKidsTheme: false),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTodayPortionSpotlight(BuildContext context, DailyTask task, List<dynamic> mutashabihatList) {
    final matchingMutashabiha = mutashabihatList.cast<dynamic>().firstWhere(
          (m) => m.isInRange(task.surahNumber, task.fromAyah, task.toAyah),
          orElse: () => null,
        );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AdultColors.goldAccent.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AdultColors.goldAccent.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AdultColors.primaryGreen,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'الورد المختار لليوم • اليوم ${task.dayNumber}',
                  style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              if (task.isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AdultColors.completedGreen.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'تم الإنجاز بنجاح ✓',
                    style: GoogleFonts.cairo(fontSize: 11.5, fontWeight: FontWeight.bold, color: AdultColors.completedGreen),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Portion Name
          Text(
            task.portionTitle,
            style: GoogleFonts.cairo(
              fontSize: 16.5,
              fontWeight: FontWeight.bold,
              color: AdultColors.primaryGreen,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'سورة ${task.surahArabicName} • من الآية ${task.fromAyah} إلى الآية ${task.toAyah}',
            style: GoogleFonts.amiri(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AdultColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),

          // Mutashabihat Badge if present
          if (matchingMutashabiha != null) ...[
            Align(
              alignment: Alignment.centerRight,
              child: MutashabihaBadge(
                item: matchingMutashabiha,
                onTap: () {
                  MutashabihaComparisonModal.show(context, matchingMutashabiha);
                },
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Play Audio Button
          ElevatedButton.icon(
            onPressed: () {
              context.read<AudioCubit>().playTask(task);
            },
            icon: const Icon(Icons.play_circle_fill_rounded, size: 22),
            label: Text(
              'تشغيل التكرار والاستماع المتقن',
              style: GoogleFonts.cairo(fontSize: 14.5, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AdultColors.primaryGreen,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ],
      ),
    );
  }
}
