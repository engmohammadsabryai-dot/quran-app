import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/datasources/local/seed_data.dart';
import '../../blocs/audio/audio_cubit.dart';
import '../../blocs/kids/kids_garden_cubit.dart';
import '../../blocs/plan/plan_bloc.dart';
import '../../blocs/plan/plan_event.dart';
import '../../blocs/plan/plan_state.dart';
import '../../blocs/profile/profile_bloc.dart';
import '../../blocs/profile/profile_state.dart';
import '../audio/bottom_mini_player.dart';
import '../profile/profile_switcher_sheet.dart';
import 'widgets/bubble_pop_game.dart';
import 'widgets/parental_reward_card.dart';
import 'widgets/quran_garden_tree.dart';
import 'widgets/virtual_mascot_widget.dart';

class KidsInteractiveHomeView extends StatefulWidget {
  const KidsInteractiveHomeView({super.key});

  @override
  State<KidsInteractiveHomeView> createState() => _KidsInteractiveHomeViewState();
}

class _KidsInteractiveHomeViewState extends State<KidsInteractiveHomeView> {
  final TextEditingController _customNameCtrl = TextEditingController();

  @override
  void dispose() {
    _customNameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KidsColors.softBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🌟', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 6),
            Text(
              'بستان القرآن وحلقات الأبطال',
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: KidsColors.primaryPurple,
              ),
            ),
          ],
        ),
        actions: [
          // Profile Switcher Action
          BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, profState) {
              final active = profState.activeProfile;
              return TextButton.icon(
                onPressed: () => ProfileSwitcherSheet.show(context),
                icon: CircleAvatar(
                  radius: 14,
                  backgroundColor: KidsColors.sunnyOrange,
                  child: Text(active?.gender == 'female' ? '👧' : '👦', style: const TextStyle(fontSize: 14)),
                ),
                label: Row(
                  children: [
                    Text(
                      active?.name ?? 'البطل',
                      style: GoogleFonts.cairo(fontSize: 12.5, fontWeight: FontWeight.bold, color: KidsColors.primaryPurple),
                    ),
                    const Icon(Icons.arrow_drop_down, color: KidsColors.primaryPurple, size: 20),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<KidsGardenCubit, KidsGardenState>(
        builder: (context, gardenState) {
          return BlocBuilder<PlanBloc, PlanState>(
            builder: (context, planState) {
              final activeTask = planState.todayTask ?? planState.tasks.firstOrNull;

              return SafeArea(
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 120),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Interactive Character Chooser & Custom Name Input
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFE2D4F0)),
                              boxShadow: [
                                BoxShadow(
                                  color: KidsColors.primaryPurple.withOpacity(0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'اختر شخصيتك المفضلة أو اكتب اسمك:',
                                  style: GoogleFonts.cairo(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                    color: KidsColors.primaryPurple,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 6,
                                  children: [
                                    _buildHeroChip('سالم', '👦', gardenState.mascotName == 'سالم'),
                                    _buildHeroChip('سارة', '👧', gardenState.mascotName == 'سارة'),
                                    _buildHeroChip('عائشة', '🧕', gardenState.mascotName == 'عائشة'),
                                    _buildHeroChip('مريم', '🌸', gardenState.mascotName == 'مريم'),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _customNameCtrl,
                                        decoration: InputDecoration(
                                          hintText: 'اكتب اسمك يا بطل بنفسك هنا...',
                                          hintStyle: GoogleFonts.cairo(fontSize: 11.5, color: Colors.grey.shade400),
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          isDense: true,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: const BorderSide(color: Color(0xFFDDD6FE)),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: () {
                                        if (_customNameCtrl.text.trim().isNotEmpty) {
                                          context.read<KidsGardenCubit>().setMascotName(_customNameCtrl.text.trim());
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: KidsColors.primaryPurple,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                      ),
                                      child: Text('تأكيد الاسم', style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Virtual Mascot Companion ("سالم" / "سارة" / "عائشة" / "مريم")
                          VirtualMascotWidget(
                            mascotName: gardenState.mascotName,
                            emotion: gardenState.mascotEmotion,
                            speechText: gardenState.mascotSpeechText,
                            onTap: () {
                              context.read<KidsGardenCubit>().waterTree();
                            },
                          ),

                          // The Quran Garden (شجرة القرآن) with 5 Stages
                          QuranGardenTreeWidget(
                            stage: gardenState.gardenStage,
                            waterDrops: gardenState.waterDropsEarned,
                            stars: gardenState.starsCollected,
                            onWaterTree: () {
                              context.read<KidsGardenCubit>().waterTree();
                            },
                          ),

                          // Interactive Bubble Pop Quiz Launcher
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [KidsColors.sunnyOrange, KidsColors.berryPink],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: KidsColors.sunnyOrange.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  context.read<KidsGardenCubit>().startQuiz();
                                  BubblePopQuizDialog.show(context);
                                },
                                borderRadius: BorderRadius.circular(24),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.25),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Text('🫧', style: TextStyle(fontSize: 26)),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'تحدي فرقعة الفقاعات القرآني!',
                                              style: GoogleFonts.cairo(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w900,
                                                color: Colors.white,
                                              ),
                                            ),
                                            Text(
                                              'فرقع الفقاعة واكسب نجوم ذهبية لبستانك',
                                              style: GoogleFonts.cairo(
                                                fontSize: 12,
                                                color: Colors.white.withOpacity(0.9),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 18),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Today's Child Task Card
                          if (activeTask != null) ...[
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: const Color(0xFFE2D4F0), width: 1.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: KidsColors.primaryPurple.withOpacity(0.06),
                                    blurRadius: 10,
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
                                          color: KidsColors.playfulSky,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          'ورد اليوم يا بطل 📖',
                                          style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                        ),
                                      ),
                                      if (activeTask.isCompleted)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: KidsColors.grassGreen.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            'أتممت الحفظ بنجاح! 🌟',
                                            style: GoogleFonts.cairo(fontSize: 11.5, fontWeight: FontWeight.bold, color: KidsColors.grassGreen),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'سورة ${activeTask.surahArabicName}',
                                    style: GoogleFonts.amiri(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: KidsColors.primaryPurple,
                                    ),
                                  ),
                                  Text(
                                    'الآيات الكريمة من ${activeTask.fromAyah} إلى ${activeTask.toAyah}',
                                    style: GoogleFonts.cairo(fontSize: 13, color: Colors.grey.shade600),
                                  ),
                                  const SizedBox(height: 14),

                                  // Play Audio with Minshawi Teacher / Kids
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      final minshawiTeacher = AppConstants.availableReciters.firstWhere(
                                        (r) => r.id == 'minshawi_teacher_kids',
                                        orElse: () => AppConstants.availableReciters.first,
                                      );
                                      context.read<AudioCubit>().setRepetitionSettings(reciter: minshawiTeacher);
                                      context.read<AudioCubit>().playTask(activeTask);
                                    },
                                    icon: const Icon(Icons.record_voice_over_rounded, size: 22),
                                    label: Text(
                                      'استمع وردد مع الشيخ والأطفال',
                                      style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: KidsColors.primaryPurple,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  // Complete Task Button
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      context.read<PlanBloc>().add(ToggleTaskCompletedEvent(activeTask));
                                      context.read<KidsGardenCubit>().onTaskCompletedCheer(activeTask.portionTitle);
                                    },
                                    icon: Icon(
                                      activeTask.isCompleted ? Icons.check_circle_rounded : Icons.star_border_rounded,
                                      color: KidsColors.grassGreen,
                                    ),
                                    label: Text(
                                      activeTask.isCompleted ? 'مكتمل (اضغط للإلغاء)' : 'أنا جاهز وحفظت الورد اليوم! ✓',
                                      style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold, color: KidsColors.grassGreen),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: KidsColors.grassGreen, width: 1.5),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          // Parental Reward Contract Card (Section 2)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            child: Row(
                              children: [
                                const Icon(Icons.card_giftcard_rounded, color: KidsColors.sunnyOrange, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'عقد مكافآت الوالدين (الجوائز الواقعية)',
                                  style: GoogleFonts.cairo(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF1E293B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ParentalRewardCard(
                            reward: AppThemeRewardHelper.sampleKidsReward,
                            currentQuartersCount: planState.analytics.completedTasks,
                            onClaim: () {
                              _showClaimDialog(context);
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
                      child: BottomMiniPlayer(isKidsTheme: true),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showClaimDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('مبارك يا بطل! 🎉', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: KidsColors.primaryPurple)),
        content: Text(
          'لقد حققت الهدف المحدد مع والديك! سيتم الآن تسجيل استلام الجائزة الواقعية.',
          style: GoogleFonts.cairo(fontSize: 13.5),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(backgroundColor: KidsColors.sunnyOrange),
            child: Text('استلمت هديتي شكراً لكم', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroChip(String name, String avatar, bool isSelected) {
    return InkWell(
      onTap: () {
        context.read<KidsGardenCubit>().setMascotName(name);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? KidsColors.primaryPurple : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? KidsColors.primaryPurple : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(avatar, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 5),
            Text(
              name,
              style: GoogleFonts.cairo(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppThemeRewardHelper {
  static final sampleKidsReward = AppSeedData.initialRewards.first;
}

