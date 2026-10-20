import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/models/user_profile.dart';
import '../../blocs/profile/profile_bloc.dart';
import '../../blocs/profile/profile_event.dart';
import '../../blocs/profile/profile_state.dart';

class ProfileSwitcherSheet extends StatelessWidget {
  const ProfileSwitcherSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const ProfileSwitcherSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        return Container(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.people_alt_rounded, color: AdultColors.primaryGreen, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'إدارة الحسابات والتبديل الفوري',
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AdultColors.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'التبديل الفوري بين الأنماط (وضع الكبار الكلاسيكي vs وضع الأطفال وبستان القرآن) دون إعادة تسجيل الدخول.',
                style: GoogleFonts.cairo(fontSize: 12.5, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),

              // Profiles List
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.profiles.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final profile = state.profiles[index];
                  final isActive = profile.isActive;
                  final isChild = profile.isChild;

                  return InkWell(
                    onTap: () {
                      context.read<ProfileBloc>().add(SwitchProfileEvent(profile.userId));
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isActive
                            ? (isChild ? const Color(0xFFF3E8FF) : AdultColors.primaryGreen.withOpacity(0.08))
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isActive
                              ? (isChild ? KidsColors.primaryPurple : AdultColors.primaryGreen)
                              : Colors.grey.shade300,
                          width: isActive ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Avatar Icon
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: isChild ? KidsColors.sunnyOrange : AdultColors.primaryGreen,
                            child: Text(
                              isChild ? (profile.gender == 'female' ? '👧' : '👦') : '👳',
                              style: const TextStyle(fontSize: 22),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Name and Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      profile.name,
                                      style: GoogleFonts.cairo(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.bold,
                                        color: AdultColors.textPrimary,
                                      ),
                                    ),
                                    if (isActive) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: isChild ? KidsColors.primaryPurple : AdultColors.primaryGreen,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          'الحالي',
                                          style: GoogleFonts.cairo(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isChild
                                      ? 'العمر: ${profile.age} سنة • وضع الأطفال وبستان القرآن 🌸'
                                      : 'العمر: ${profile.age} سنة • النمط الكلاسيكي المتقدم 📜',
                                  style: GoogleFonts.cairo(
                                    fontSize: 11.5,
                                    color: isChild ? KidsColors.primaryPurple : AdultColors.textSecondary,
                                    fontWeight: isChild ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          if (isActive)
                            Icon(
                              Icons.check_circle_rounded,
                              color: isChild ? KidsColors.primaryPurple : AdultColors.primaryGreen,
                              size: 24,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 18),

              // Add Profile Button
              OutlinedButton.icon(
                onPressed: () {
                  _showAddProfileDialog(context);
                },
                icon: const Icon(Icons.person_add_alt_1_rounded),
                label: Text(
                  'إضافة ملف شخصي جديد (طفل أو بالغ)',
                  style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  foregroundColor: AdultColors.primaryGreen,
                  side: const BorderSide(color: AdultColors.primaryGreen, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddProfileDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    int age = 10;
    String gender = 'male';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) {
          final isKid = age < 15;

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(
              'إنشاء ملف شخصي جديد',
              style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold, color: AdultColors.primaryGreen),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: 'الاسم الكريم',
                      hintText: 'اكتب الاسم هنا أو اختر من الشخصيات أدناه',
                      labelStyle: GoogleFonts.cairo(fontSize: 13),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      ActionChip(
                        avatar: const Text('👦', style: TextStyle(fontSize: 12)),
                        label: Text('سالم', style: GoogleFonts.cairo(fontSize: 11)),
                        onPressed: () {
                          nameCtrl.text = 'سالم';
                          setDlgState(() => gender = 'male');
                        },
                      ),
                      ActionChip(
                        avatar: const Text('👧', style: TextStyle(fontSize: 12)),
                        label: Text('سارة', style: GoogleFonts.cairo(fontSize: 11)),
                        onPressed: () {
                          nameCtrl.text = 'سارة';
                          setDlgState(() => gender = 'female');
                        },
                      ),
                      ActionChip(
                        avatar: const Text('🧕', style: TextStyle(fontSize: 12)),
                        label: Text('عائشة', style: GoogleFonts.cairo(fontSize: 11)),
                        onPressed: () {
                          nameCtrl.text = 'عائشة';
                          setDlgState(() => gender = 'female');
                        },
                      ),
                      ActionChip(
                        avatar: const Text('🌸', style: TextStyle(fontSize: 12)),
                        label: Text('مريم', style: GoogleFonts.cairo(fontSize: 11)),
                        onPressed: () {
                          nameCtrl.text = 'مريم';
                          setDlgState(() => gender = 'female');
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('العمر (بالسنوات):', style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold)),
                      DropdownButton<int>(
                        value: age,
                        items: List.generate(70, (i) => i + 5).map((a) {
                          return DropdownMenuItem(value: a, child: Text('$a سنة'));
                        }).toList(),
                        onChanged: (v) {
                          if (v != null) setDlgState(() => age = v);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isKid ? const Color(0xFFF3E8FF) : const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      isKid
                          ? '🌟 نظراً لأن العمر أقل من ١٥ سنة، سيتم تفعيل وضع الأطفال التفاعلي (KidsFunTheme) مع شجرة القرآن والمسابقات تلقائياً!'
                          : '📜 سيتم تفعيل الوضع الكلاسيكي للكبار مع الجداول والتحليلات البيانية المتقدمة.',
                      style: GoogleFonts.cairo(fontSize: 11.5, color: isKid ? KidsColors.primaryPurple : AdultColors.primaryGreen),
                    ),
                  ),
                  const SizedBox(height: 14),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ChoiceChip(
                        label: Text('ذكر', style: GoogleFonts.cairo(fontSize: 12)),
                        selected: gender == 'male',
                        onSelected: (s) => setDlgState(() => gender = 'male'),
                      ),
                      ChoiceChip(
                        label: Text('أنثى', style: GoogleFonts.cairo(fontSize: 12)),
                        selected: gender == 'female',
                        onSelected: (s) => setDlgState(() => gender = 'female'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('إلغاء', style: GoogleFonts.cairo(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: () {
                  if (nameCtrl.text.trim().isEmpty) return;

                  final newProfile = UserProfile(
                    userId: 'usr-${const Uuid().v4().substring(0, 8)}',
                    name: nameCtrl.text.trim(),
                    age: age,
                    gender: gender,
                    avatarId: isKid ? 'kid_generic' : 'adult_generic',
                    isActive: true,
                    createdAt: DateTime.now(),
                  );

                  context.read<ProfileBloc>().add(CreateProfileEvent(newProfile));
                  Navigator.pop(ctx);
                  Navigator.pop(context); // Close switcher sheet
                },
                style: ElevatedButton.styleFrom(backgroundColor: AdultColors.primaryGreen),
                child: Text('حفظ وتشغيل', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }
}
