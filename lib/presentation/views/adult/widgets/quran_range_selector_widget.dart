import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/datasources/local/quran_text_data.dart';

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
  late String _currentSystem;
  late int _surahNumber;
  late int _pageNumber;
  late int _fromAyah;
  late int _toAyah;

  @override
  void initState() {
    super.initState();
    _currentSystem = widget.memorizationSystem;
    _surahNumber = widget.selectedSurah;
    _pageNumber = widget.selectedPage;
    _fromAyah = widget.fromAyah;
    _toAyah = widget.toAyah;
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

  void _notifyChange() {
    widget.onRangeChanged(
      surahNumber: _surahNumber,
      surahArabicName: _currentSurahInfo.nameArabic,
      fromAyah: _fromAyah,
      toAyah: _toAyah,
      pageNumber: _pageNumber,
      system: _currentSystem,
    );
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
    _notifyChange();
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
    _notifyChange();
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
    _notifyChange();
  }

  @override
  Widget build(BuildContext context) {
    final surah = _currentSurahInfo;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AdultColors.goldAccent.withOpacity(0.4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
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
                    'تحديد السورة ونطاق الحفظ',
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
                  border: Border.all(color: AdultColors.primaryGreen.withOpacity(0.2)),
                ),
                child: Text(
                  'سورة ${surah.nameArabic} • الآيات ($_fromAyah - $_toAyah)',
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

          // 1. Memorization System Mode Switcher (الصفحات vs الأرباع)
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
                            'طريقة الصفحات (مصحف المدينة)',
                            style: GoogleFonts.cairo(
                              fontSize: 12,
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
                      _notifyChange();
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
                              fontSize: 12,
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
          const SizedBox(height: 14),

          // 2. Surah & Page Row
          Row(
            children: [
              // Surah Dropdown
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'اختر السورة:',
                      style: GoogleFonts.cairo(fontSize: 11.5, fontWeight: FontWeight.bold, color: AdultColors.textSecondary),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                        borderRadius: BorderRadius.circular(10),
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

              // Page Stepper
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'صفحة المصحف:',
                      style: GoogleFonts.cairo(fontSize: 11.5, fontWeight: FontWeight.bold, color: AdultColors.textSecondary),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_right, size: 20),
                            onPressed: () => _onPageChanged(-1),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 32),
                          ),
                          Text(
                            'ص ${QuranTextData.toArabicDigits(_pageNumber)}',
                            style: GoogleFonts.amiri(fontSize: 14, fontWeight: FontWeight.bold, color: AdultColors.primaryGreen),
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_left, size: 20),
                            onPressed: () => _onPageChanged(1),
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
          const SizedBox(height: 14),

          // 3. Ayah Range (من آية إلى آية)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'نطاق الآيات المراد تلاوتها وترديدها:',
                style: GoogleFonts.cairo(fontSize: 11.5, fontWeight: FontWeight.bold, color: AdultColors.textSecondary),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  // From Ayah Box
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                        borderRadius: BorderRadius.circular(10),
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
                                    _notifyChange();
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
                                    _notifyChange();
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
                  // To Ayah Box
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                        borderRadius: BorderRadius.circular(10),
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
                                    _notifyChange();
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
                                    _notifyChange();
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
          const SizedBox(height: 12),

          // 4. Quick Presets Chips
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
        ],
      ),
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
