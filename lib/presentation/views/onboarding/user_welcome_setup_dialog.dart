import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/models/user_profile.dart';
import '../../blocs/profile/profile_bloc.dart';
import '../../blocs/profile/profile_event.dart';

class UserWelcomeSetupDialog extends StatefulWidget {
  final UserProfile? existingProfile;
  final VoidCallback onComplete;

  const UserWelcomeSetupDialog({
    super.key,
    this.existingProfile,
    required this.onComplete,
  });

  static Future<void> show(BuildContext context, {UserProfile? existingProfile, required VoidCallback onComplete}) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: UserWelcomeSetupDialog(
          existingProfile: existingProfile,
          onComplete: onComplete,
        ),
      ),
    );
  }

  @override
  State<UserWelcomeSetupDialog> createState() => _UserWelcomeSetupDialogState();
}

class _UserWelcomeSetupDialogState extends State<UserWelcomeSetupDialog> with SingleTickerProviderStateMixin {
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  final _formKey = GlobalKey<FormState>();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlayingIntro = false;
  int _currentAge = 25;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    final p = widget.existingProfile;
    _nameController = TextEditingController(text: p?.name ?? '');
    _currentAge = p?.age ?? 25;
    _ageController = TextEditingController(text: p != null ? '${p.age}' : '25');

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _initAndPlayIntroAudio();
  }

  Future<void> _initAndPlayIntroAudio() async {
    try {
      await _audioPlayer.setAsset('assets/audio/husary_15_9.mp3');
      await _audioPlayer.play();
      if (mounted) {
        setState(() => _isPlayingIntro = true);
      }
      _audioPlayer.playerStateStream.listen((state) {
        if (!mounted) return;
        setState(() {
          _isPlayingIntro = state.playing && state.processingState != ProcessingState.completed;
        });
      });
    } catch (e) {
      debugPrint('Intro recitation playback notice: $e');
    }
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    _pulseController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _toggleAudio() async {
    if (_audioPlayer.playing) {
      await _audioPlayer.pause();
    } else {
      if (_audioPlayer.processingState == ProcessingState.completed) {
        await _audioPlayer.seek(Duration.zero);
      }
      await _audioPlayer.play();
    }
  }

  void _submitProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final age = int.tryParse(_ageController.text.trim()) ?? _currentAge;

    await _audioPlayer.stop();

    if (!mounted) return;

    final profile = UserProfile(
      userId: widget.existingProfile?.userId ?? const Uuid().v4(),
      name: name,
      age: age,
      gender: 'male',
      avatarId: age < 15 ? 'kid_boy' : 'adult_classic',
      isActive: true,
      createdAt: widget.existingProfile?.createdAt ?? DateTime.now(),
    );

    context.read<ProfileBloc>().add(CreateProfileEvent(profile));
    context.read<ProfileBloc>().add(SwitchProfileEvent(profile.userId));

    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final isChild = _currentAge < 15;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AdultColors.goldAccent, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 25,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Decorative Header with Quranic Verse (سورة الحجر: 9)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AdultColors.primaryGreen.withOpacity(0.08),
                          AdultColors.goldAccent.withOpacity(0.12),
                        ],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AdultColors.goldAccent.withOpacity(0.35)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                          style: GoogleFonts.amiri(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AdultColors.primaryGreen,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '﴿ إِنَّا نَحْنُ نَزَّلْنَا الذِّكْرَ وَإِنَّا لَهُ لَحَافِظُونَ ﴾',
                          style: GoogleFonts.amiri(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: AdultColors.goldAccent,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '[سورة الحجر: 9]',
                          style: GoogleFonts.cairo(
                            fontSize: 11,
                            color: AdultColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Audio Playing Indicator & Controller for Sheikh Mahmoud Khalil Al-Husary
                        InkWell(
                          onTap: _toggleAudio,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AdultColors.primaryGreen,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: AdultColors.primaryGreen.withOpacity(0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _isPlayingIntro ? Icons.volume_up_rounded : Icons.play_arrow_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _isPlayingIntro
                                      ? 'تلاوة الآية: الشيخ محمود خليل الحصري (جارٍ الاستماع)'
                                      : 'استمع لتلاوة الآية بصوت الشيخ محمود خليل الحصري',
                                  style: GoogleFonts.cairo(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 2. Title & Guidance
                  Text(
                    'مرحباً بك في مصحف الحفظ والورد',
                    style: GoogleFonts.cairo(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AdultColors.primaryGreen,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'فضلاً أدخل اسمك وسنك لنخصص لك واجهة الحفظ المناسبة',
                    style: GoogleFonts.cairo(
                      fontSize: 12.5,
                      color: AdultColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // 3. User Name Field
                  Text(
                    'اسم المستخدم:',
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AdultColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _nameController,
                    textAlign: TextAlign.right,
                    style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      hintText: 'اكتب اسمك الكريم (مثال: عبد الله)',
                      hintStyle: GoogleFonts.cairo(fontSize: 12.5, color: Colors.grey.shade400),
                      prefixIcon: const Icon(Icons.person_rounded, color: AdultColors.primaryGreen),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AdultColors.primaryGreen, width: 2),
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'يرجى كتابة اسم المستخدم';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // 4. Age Field
                  Text(
                    'السن (بالسنوات):',
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AdultColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.right,
                    style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      hintText: 'مثال: 12 أو 24',
                      hintStyle: GoogleFonts.cairo(fontSize: 12.5, color: Colors.grey.shade400),
                      prefixIcon: const Icon(Icons.cake_rounded, color: AdultColors.primaryGreen),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AdultColors.primaryGreen, width: 2),
                      ),
                    ),
                    onChanged: (val) {
                      final parsed = int.tryParse(val);
                      if (parsed != null && parsed != _currentAge) {
                        setState(() => _currentAge = parsed);
                      }
                    },
                    validator: (val) {
                      final parsed = int.tryParse(val ?? '');
                      if (parsed == null || parsed <= 0 || parsed > 120) {
                        return 'يرجى إدخال سن صحيح بين 1 و 120';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // 5. Dynamic Routing Badge Preview (Child vs Adult Mode)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isChild ? const Color(0xFFFFF7ED) : const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isChild ? const Color(0xFFF97316) : AdultColors.primaryGreen,
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(isChild ? '👦' : '📖', style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isChild ? 'الواجهة التالية: واجهة الأطفال (أقل من 15 سنة)' : 'الواجهة التالية: واجهة الكبار (15 سنة فأكثر)',
                                style: GoogleFonts.cairo(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: isChild ? const Color(0xFFC2410C) : AdultColors.primaryGreen,
                                ),
                              ),
                              Text(
                                isChild
                                    ? 'تشمل: حديقة القرآن التفاعلية، شجرة الورد، قطرات الماء والنجوم، ومسابقات التثبيت.'
                                    : 'تشمل: المصحف المدني الكامل، طريقة الأرباع والصفحات، المتشابهات، وجدولة الصلوات الخمس.',
                                style: GoogleFonts.cairo(
                                  fontSize: 11,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 6. Action Button: Enter & Proceed
                  ElevatedButton(
                    onPressed: _submitProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AdultColors.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 3,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'دخول ومتابعة إلى خيارات الحفظ',
                          style: GoogleFonts.cairo(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, size: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
