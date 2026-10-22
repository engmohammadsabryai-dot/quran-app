import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/audio/hybrid_audio_player_service.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/datasources/local/quran_text_data.dart';
import '../../../blocs/audio/audio_cubit.dart';

class QuranRangeSelectorWidget extends StatefulWidget {
  final int selectedSurah;
  final int selectedPage;
  final int fromAyah;
  final int toAyah;
  final String memorizationSystem; // 'page' or 'rub'
  final Function({
    required int surahNumber,
    required String surahArabicName,
    required int fromAyah,
    required int toAyah,
    required int pageNumber,
    required String system,
  }) onRangeChanged;

  const QuranRangeSelectorWidget({
    super.key,
    required this.selectedSurah,
    required this.selectedPage,
    required this.fromAyah,
    required this.toAyah,
    this.memorizationSystem = 'page',
    required this.onRangeChanged,
  });

  @override
  State<QuranRangeSelectorWidget> createState() => _QuranRangeSelectorWidgetState();
}

class _QuranRangeSelectorWidgetState extends State<QuranRangeSelectorWidget> {
  late String _currentSystem; // 'page' or 'rub'
  late String _currentRiwayah; // 'hafs', 'warsh', 'qaloon', 'hamzah', 'kisai', 'soosi'
  late ReciterInfo _selectedReciter;
  late int _surahNumber;
  late int _pageNumber;
  late int _rubQuarter; // 1 to 240
  late int _fromAyah;
  late int _toAyah;

  @override
  void initState() {
    super.initState();
    _currentSystem = widget.memorizationSystem;
    _surahNumber = widget.selectedSurah;
    _pageNumber = widget.selectedPage;
    _rubQuarter = 1;
    _fromAyah = widget.fromAyah;
    _toAyah = widget.toAyah;

    // Initialize Riwayah & Reciter from AudioCubit or defaults
    final audioCubit = context.read<AudioCubit>();
    _selectedReciter = audioCubit.state.reciter;
    _currentRiwayah = _selectedReciter.riwayahId;
  }

  @override
  void didUpdateWidget(covariant QuranRangeSelectorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedSurah != widget.selectedSurah ||
        oldWidget.selectedPage != widget.selectedPage ||
        oldWidget.fromAyah != widget.fromAyah ||
        oldWidget.toAyah != widget.toAyah ||
        oldWidget.memorizationSystem != widget.memorizationSystem) {
      _currentSystem = widget.memorizationSystem;
      _surahNumber = widget.selectedSurah;
      _pageNumber = widget.selectedPage;
      _fromAyah = widget.fromAyah;
      _toAyah = widget.toAyah;
    }
  }

  SurahInfo get _currentSurahInfo => AppConstants.getSurah(_surahNumber);

  List<ReciterInfo> get _filteredReciters {
    final list = AppConstants.availableReciters.where((r) => r.riwayahId == _currentRiwayah).toList();
    return list.isNotEmpty ? list : AppConstants.availableReciters;
  }

  void _onRiwayahChanged(String riwayahId) {
    setState(() {
      _currentRiwayah = riwayahId;
      final matching = AppConstants.availableReciters.where((r) => r.riwayahId == riwayahId).toList();
      if (matching.isNotEmpty) {
        _selectedReciter = matching.first;
      }
    });
  }

  void _onSurahSelected(int surahNum) {
    setState(() {
      _surahNumber = surahNum;
      final info = AppConstants.getSurah(surahNum);
      _pageNumber = info.startPage;
      final pageInfo = QuranTextData.getPageInfo(_pageNumber);
      _fromAyah = 1;
      _toAyah = pageInfo.endAyah.clamp(1, info.totalAyahs);
    });
    _applyChanges();
  }

  void _onPageChanged(int delta) {
    final newPage = (_pageNumber + delta).clamp(1, 604);
    if (newPage == _pageNumber) return;

    setState(() {
      _pageNumber = newPage;
      final pageInfo = QuranTextData.getPageInfo(newPage);
      _surahNumber = pageInfo.surahNumber;
      final info = AppConstants.getSurah(_surahNumber);
      _fromAyah = pageInfo.startAyah.clamp(1, info.totalAyahs);
      _toAyah = pageInfo.endAyah.clamp(_fromAyah, info.totalAyahs);
    });
    _applyChanges();
  }

  void _onRubChanged(int delta) {
    final newRub = (_rubQuarter + delta).clamp(1, 240);
    if (newRub == _rubQuarter) return;

    setState(() {
      _rubQuarter = newRub;
      // Approximate page for rub (240 quarters across 604 pages -> ~2.5 pages per quarter)
      _pageNumber = (((newRub - 1) * 604) ~/ 240 + 1).clamp(1, 604);
      final pageInfo = QuranTextData.getPageInfo(_pageNumber);
      _surahNumber = pageInfo.surahNumber;
      final info = AppConstants.getSurah(_surahNumber);
      _fromAyah = pageInfo.startAyah.clamp(1, info.totalAyahs);
      _toAyah = pageInfo.endAyah.clamp(_fromAyah, info.totalAyahs);
    });
    _applyChanges();
  }

  void _applyPreset(String preset) {
    final info = _currentSurahInfo;
    setState(() {
      if (preset == 'page') {
        final pageInfo = QuranTextData.getPageInfo(_pageNumber);
        _fromAyah = pageInfo.startAyah.clamp(1, info.totalAyahs);
        _toAyah = pageInfo.endAyah.clamp(_fromAyah, info.totalAyahs);
      } else if (preset == 'single') {
        _toAyah = _fromAyah;
      } else if (preset == 'three') {
        _toAyah = (_fromAyah + 2).clamp(1, info.totalAyahs);
      } else if (preset == 'ten') {
        _toAyah = (_fromAyah + 9).clamp(1, info.totalAyahs);
      }
    });
    _applyChanges();
  }

  // 1. زر تطبيق: تطبيق التغييرات فورياً ولحظياً في المشغل والمصحف
  void _applyChanges({bool showFeedbackToast = false}) {
    // 1. Update Repetition Settings & Reciter in AudioCubit
    final audioCubit = context.read<AudioCubit>();
    audioCubit.setRepetitionSettings(reciter: _selectedReciter);

    // 2. Notify Parent view to update Madani Mushaf page and texts
    widget.onRangeChanged(
      surahNumber: _surahNumber,
      surahArabicName: _currentSurahInfo.nameArabic,
      fromAyah: _fromAyah,
      toAyah: _toAyah,
      pageNumber: _pageNumber,
      system: _currentSystem,
    );

    // 3. If audio is already playing, seamlessly update the stream with the new reciter and range
    if (audioCubit.state.isPlaying) {
      audioCubit.playAyahRange(
        surahNumber: _surahNumber,
        surahArabicName: _currentSurahInfo.nameArabic,
        fromAyah: _fromAyah,
        toAyah: _toAyah,
        startAyah: _fromAyah,
        autoPlay: true,
      );
    }

    if (showFeedbackToast && mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✅ تم تطبيق الإعدادات وتفعيل تلاوة: ${_selectedReciter.nameArabic} - سورة ${_currentSurahInfo.nameArabic} (${QuranTextData.toArabicDigits(_fromAyah)} إلى ${QuranTextData.toArabicDigits(_toAyah)})',
            style: GoogleFonts.cairo(fontSize: 12.5, fontWeight: FontWeight.bold),
          ),
          backgroundColor: AdultColors.primaryGreen,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  // 2. زر تشغيل: تطبيق التغييرات وبدء التلاوة فوراً
  void _playSelection() {
    final audioCubit = context.read<AudioCubit>();
    audioCubit.setRepetitionSettings(reciter: _selectedReciter);

    widget.onRangeChanged(
      surahNumber: _surahNumber,
      surahArabicName: _currentSurahInfo.nameArabic,
      fromAyah: _fromAyah,
      toAyah: _toAyah,
      pageNumber: _pageNumber,
      system: _currentSystem,
    );

    audioCubit.playAyahRange(
      surahNumber: _surahNumber,
      surahArabicName: _currentSurahInfo.nameArabic,
      fromAyah: _fromAyah,
      toAyah: _toAyah,
      startAyah: _fromAyah,
      autoPlay: true,
    );
  }

  // 3. زر إيقاف مؤقت
  void _pausePlayback() {
    context.read<AudioCubit>().pause();
  }

  // 4. زر إيقاف: إيقاف كامل وإعادة الموضع إلى بداية النطاق
  void _stopPlayback() {
    context.read<AudioCubit>().stop();
  }

  @override
  Widget build(BuildContext context) {
    final surah = _currentSurahInfo;

    return BlocBuilder<AudioCubit, PlaybackProgressState>(
      builder: (context, audioState) {
        final isPlaying = audioState.isPlaying;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AdultColors.goldAccent.withOpacity(0.4), width: 1.4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header: Title and Active Range Indicator Pill
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text('🎛️', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Text(
                        'خيارات الحفظ والمشغل التفاعلي',
                        style: GoogleFonts.cairo(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AdultColors.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AdultColors.primaryGreen.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AdultColors.primaryGreen.withOpacity(0.25)),
                    ),
                    child: Text(
                      'سورة ${surah.nameArabic} • (${QuranTextData.toArabicDigits(_fromAyah)} - ${QuranTextData.toArabicDigits(_toAyah)})',
                      style: GoogleFonts.amiri(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AdultColors.primaryGreen,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // 1. اختيار الطريقة: طريقة صفحات المصحف المدني vs طريقة الأرباع
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() => _currentSystem = 'page');
                          _applyPreset('page');
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _currentSystem == 'page' ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: _currentSystem == 'page'
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.06),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('📖', style: TextStyle(fontSize: 14)),
                              const SizedBox(width: 6),
                              Text(
                                'طريقة صفحات المصحف (604)',
                                style: GoogleFonts.cairo(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: _currentSystem == 'page' ? AdultColors.primaryGreen : AdultColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() => _currentSystem = 'rub');
                          _applyChanges();
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _currentSystem == 'rub' ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: _currentSystem == 'rub'
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.06),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('📜', style: TextStyle(fontSize: 14)),
                              const SizedBox(width: 6),
                              Text(
                                'طريقة الأرباع (240 ربعاً)',
                                style: GoogleFonts.cairo(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: _currentSystem == 'rub' ? AdultColors.primaryGreen : AdultColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // 2. اختيار الرواية و 3. اختيار الشيخ القارئ
              Row(
                children: [
                  // اختيار الرواية
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '٢. اختيار الرواية:',
                          style: GoogleFonts.cairo(fontSize: 11.5, fontWeight: FontWeight.bold, color: AdultColors.textSecondary),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                            borderRadius: BorderRadius.circular(10),
                            color: const Color(0xFFF8FAFC),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _currentRiwayah,
                              isExpanded: true,
                              icon: const Icon(Icons.arrow_drop_down, color: AdultColors.primaryGreen),
                              items: AppConstants.availableRiwayat.map((r) {
                                return DropdownMenuItem<String>(
                                  value: r.id,
                                  child: Text(
                                    r.nameArabic,
                                    style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) _onRiwayahChanged(val);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),

                  // اختيار الشيخ القارئ
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '٣. اختيار الشيخ القارئ:',
                          style: GoogleFonts.cairo(fontSize: 11.5, fontWeight: FontWeight.bold, color: AdultColors.textSecondary),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                            borderRadius: BorderRadius.circular(10),
                            color: const Color(0xFFF8FAFC),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _filteredReciters.any((r) => r.id == _selectedReciter.id)
                                  ? _selectedReciter.id
                                  : _filteredReciters.first.id,
                              isExpanded: true,
                              icon: const Icon(Icons.arrow_drop_down, color: AdultColors.primaryGreen),
                              items: _filteredReciters.map((r) {
                                return DropdownMenuItem<String>(
                                  value: r.id,
                                  child: Text(
                                    r.nameArabic,
                                    style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold, color: AdultColors.primaryGreen),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  final rec = AppConstants.availableReciters.firstWhere((r) => r.id == val);
                                  setState(() => _selectedReciter = rec);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 4. اختيار السورة و 5. اختيار الصفحة / الربع
              Row(
                children: [
                  // 4. اختيار السورة
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '٤. اختيار السورة:',
                          style: GoogleFonts.cairo(fontSize: 11.5, fontWeight: FontWeight.bold, color: AdultColors.textSecondary),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                            borderRadius: BorderRadius.circular(10),
                            color: const Color(0xFFF8FAFC),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: _surahNumber,
                              isExpanded: true,
                              icon: const Icon(Icons.arrow_drop_down, color: AdultColors.primaryGreen),
                              items: AppConstants.quranSurahs.map((s) {
                                return DropdownMenuItem<int>(
                                  value: s.number,
                                  child: Text(
                                    '${QuranTextData.toArabicDigits(s.number)}. سورة ${s.nameArabic} (${QuranTextData.toArabicDigits(s.totalAyahs)} آية)',
                                    style: GoogleFonts.cairo(fontSize: 12.5, fontWeight: FontWeight.w600),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) _onSurahSelected(val);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),

                  // 5. اختيار الصفحة أو الربع
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentSystem == 'page' ? '٥. اختيار الصفحة:' : '٥. اختيار الربع:',
                          style: GoogleFonts.cairo(fontSize: 11.5, fontWeight: FontWeight.bold, color: AdultColors.textSecondary),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: 48,
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                            borderRadius: BorderRadius.circular(10),
                            color: const Color(0xFFF8FAFC),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.chevron_right, size: 20),
                                onPressed: () => _currentSystem == 'page' ? _onPageChanged(-1) : _onRubChanged(-1),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 32),
                              ),
                              Text(
                                _currentSystem == 'page'
                                    ? 'ص ${QuranTextData.toArabicDigits(_pageNumber)}'
                                    : 'ربع ${QuranTextData.toArabicDigits(_rubQuarter)}',
                                style: GoogleFonts.amiri(fontSize: 14, fontWeight: FontWeight.bold, color: AdultColors.primaryGreen),
                              ),
                              IconButton(
                                icon: const Icon(Icons.chevron_left, size: 20),
                                onPressed: () => _currentSystem == 'page' ? _onPageChanged(1) : _onRubChanged(1),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 32),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 6. تحديد نطاق الآيات المراد تلاوتها وترديدها
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '٦. تحديد نطاق الآيات المراد تلاوتها وترديدها:',
                    style: GoogleFonts.cairo(fontSize: 11.5, fontWeight: FontWeight.bold, color: AdultColors.textSecondary),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      // من آية
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                            borderRadius: BorderRadius.circular(10),
                            color: const Color(0xFFF8FAFC),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('من آية:', style: GoogleFonts.cairo(fontSize: 11, color: AdultColors.textSecondary)),
                              Row(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      if (_fromAyah > 1) {
                                        setState(() => _fromAyah--);
                                        _applyChanges();
                                      }
                                    },
                                    child: const Icon(Icons.remove_circle_outline, size: 20, color: AdultColors.primaryGreen),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: Text(
                                      QuranTextData.toArabicDigits(_fromAyah),
                                      style: GoogleFonts.amiri(fontSize: 16, fontWeight: FontWeight.bold, color: AdultColors.primaryGreen),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      if (_fromAyah < _toAyah) {
                                        setState(() => _fromAyah++);
                                        _applyChanges();
                                      }
                                    },
                                    child: const Icon(Icons.add_circle_outline, size: 20, color: AdultColors.primaryGreen),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(Icons.arrow_back_rounded, color: AdultColors.goldAccent, size: 20),
                      ),
                      // إلى آية
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                            borderRadius: BorderRadius.circular(10),
                            color: const Color(0xFFF8FAFC),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('إلى آية:', style: GoogleFonts.cairo(fontSize: 11, color: AdultColors.textSecondary)),
                              Row(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      if (_toAyah > _fromAyah) {
                                        setState(() => _toAyah--);
                                        _applyChanges();
                                      }
                                    },
                                    child: const Icon(Icons.remove_circle_outline, size: 20, color: AdultColors.primaryGreen),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: Text(
                                      QuranTextData.toArabicDigits(_toAyah),
                                      style: GoogleFonts.amiri(fontSize: 16, fontWeight: FontWeight.bold, color: AdultColors.primaryGreen),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      if (_toAyah < surah.totalAyahs) {
                                        setState(() => _toAyah++);
                                        _applyChanges();
                                      }
                                    },
                                    child: const Icon(Icons.add_circle_outline, size: 20, color: AdultColors.primaryGreen),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // خيارات النطاق السريعة
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _buildPresetChip('كامل الصفحة', () => _applyPreset('page')),
                  _buildPresetChip('الآية الحالية فقط', () => _applyPreset('single')),
                  _buildPresetChip('٣ آيات', () => _applyPreset('three')),
                  _buildPresetChip('١٠ آيات', () => _applyPreset('ten')),
                ],
              ),
              const SizedBox(height: 16),

              // 7. أزرار التحكم الصوتي الأربعة: زر تطبيق | زر تشغيل | زر إيقاف مؤقت | زر إيقاف
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    // زر تطبيق (Apply)
                    Expanded(
                      flex: 3,
                      child: ElevatedButton.icon(
                        onPressed: () => _applyChanges(showFeedbackToast: true),
                        icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                        label: Text(
                          'تطبيق',
                          style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AdultColors.goldAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),

                    // زر تشغيل (Play)
                    Expanded(
                      flex: 3,
                      child: ElevatedButton.icon(
                        onPressed: _playSelection,
                        icon: const Icon(Icons.play_arrow_rounded, size: 20),
                        label: Text(
                          'تشغيل',
                          style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AdultColors.primaryGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),

                    // زر إيقاف مؤقت (Pause)
                    Expanded(
                      flex: 2,
                      child: OutlinedButton.icon(
                        onPressed: isPlaying ? _pausePlayback : null,
                        icon: const Icon(Icons.pause_rounded, size: 18),
                        label: Text(
                          'مؤقت',
                          style: GoogleFonts.cairo(fontSize: 11.5, fontWeight: FontWeight.bold),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFD97706),
                          side: const BorderSide(color: Color(0xFFD97706)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),

                    // زر إيقاف (Stop)
                    Expanded(
                      flex: 2,
                      child: OutlinedButton.icon(
                        onPressed: _stopPlayback,
                        icon: const Icon(Icons.stop_rounded, size: 18),
                        label: Text(
                          'إيقاف',
                          style: GoogleFonts.cairo(fontSize: 11.5, fontWeight: FontWeight.bold),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFDC2626),
                          side: const BorderSide(color: Color(0xFFDC2626)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
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

  Widget _buildPresetChip(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AdultColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
