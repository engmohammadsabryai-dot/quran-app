import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/datasources/local/quran_text_data.dart';

class MadaniMushafViewWidget extends StatelessWidget {
  final int pageNumber;
  final int surahNumber;
  final int fromAyah;
  final int toAyah;
  final int? activePlayingAyah;
  final Function(int ayahNumber) onAyahTapped;

  const MadaniMushafViewWidget({
    super.key,
    required this.pageNumber,
    required this.surahNumber,
    required this.fromAyah,
    required this.toAyah,
    this.activePlayingAyah,
    required this.onAyahTapped,
  });

  @override
  Widget build(BuildContext context) {
    final pageInfo = QuranTextData.getPageInfo(pageNumber);
    final surahInfo = AppConstants.getSurah(surahNumber);
    final juzOrdinal = QuranTextData.arabicOrdinalWords[pageInfo.juzNumber] ?? QuranTextData.toArabicDigits(pageInfo.juzNumber);
    final hizbOrdinal = QuranTextData.arabicOrdinalWords[pageInfo.hizbNumber] ?? QuranTextData.toArabicDigits(pageInfo.hizbNumber);

    // Compute which verses to render on this page view
    // If the selected range is within this page, show them, or show the full page verses
    final startAyah = pageInfo.startAyah;
    final endAyah = pageInfo.endAyah.clamp(startAyah, surahInfo.totalAyahs);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFBF7), // Warm authentic Mushaf parchment cream
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AdultColors.goldAccent, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: AdultColors.goldAccent.withOpacity(0.15),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Top Mushaf Ribbon Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AdultColors.primaryGreen,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(17),
                topRight: Radius.circular(17),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'الجُزْءُ $juzOrdinal',
                  style: GoogleFonts.amiri(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  'سُورَةُ ${surahInfo.nameArabic}',
                  style: GoogleFonts.amiri(fontSize: 14.5, fontWeight: FontWeight.bold, color: AdultColors.goldAccent),
                ),
                Text(
                  'الحِزْبُ $hizbOrdinal',
                  style: GoogleFonts.amiri(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
          ),

          // 2. Inner Frame with Ornate Border
          Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AdultColors.goldAccent.withOpacity(0.6), width: 1.5),
            ),
            child: Column(
              children: [
                // Surah Plaque Header
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AdultColors.goldAccent.withOpacity(0.15),
                        AdultColors.goldAccent.withOpacity(0.3),
                        AdultColors.goldAccent.withOpacity(0.15),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AdultColors.goldAccent.withOpacity(0.7)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('۞', style: TextStyle(color: AdultColors.goldAccent, fontSize: 18)),
                      Column(
                        children: [
                          Text(
                            'سُورَةُ ${surahInfo.nameArabic}',
                            style: GoogleFonts.amiri(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: AdultColors.primaryGreen,
                            ),
                          ),
                          Text(
                            '${surahInfo.isMakki ? "مَكِّيَّةٌ" : "مَدَنِيَّةٌ"} • آيَاتُهَا ${QuranTextData.toArabicDigits(surahInfo.totalAyahs)}',
                            style: GoogleFonts.cairo(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: AdultColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const Text('۞', style: TextStyle(color: AdultColors.goldAccent, fontSize: 18)),
                    ],
                  ),
                ),

                // Sacred Basmalah Header (Strictly unnumbered, except Al-Fatihah, hidden for At-Tawbah)
                if (surahNumber != 9) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      children: [
                        Text(
                          'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.amiri(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: AdultColors.primaryGreen,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          surahNumber == 1
                              ? '(آية رقم ١ في سورة الفاتحة)'
                              : '(فصل استفتاح وتبرك • ليست آية معدودة في سورة ${surahInfo.nameArabic})',
                          style: GoogleFonts.cairo(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                            color: AdultColors.textSecondary.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Color(0xFFF1F5F9), thickness: 1, height: 16),
                ],

                // 3. Complete Mushaf Page Verses with Dynamic Live Highlighting
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 4,
                  runSpacing: 8,
                  children: List.generate(endAyah - startAyah + 1, (index) {
                    final ayahNum = startAyah + index;
                    final isHighlighted = activePlayingAyah == ayahNum;
                    final isInRange = ayahNum >= fromAyah && ayahNum <= toAyah;
                    final verseText = QuranTextData.getAyahText(surahNumber, ayahNum, surahInfo.nameArabic);

                    return InkWell(
                      onTap: () => onAyahTapped(ayahNum),
                      borderRadius: BorderRadius.circular(8),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        decoration: BoxDecoration(
                          color: isHighlighted
                              ? AdultColors.goldAccent.withOpacity(0.3)
                              : isInRange
                                  ? AdultColors.primaryGreen.withOpacity(0.06)
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: isHighlighted
                              ? Border.all(color: AdultColors.goldAccent, width: 1.5)
                              : null,
                        ),
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '$verseText ',
                                style: GoogleFonts.amiri(
                                  fontSize: 18,
                                  height: 1.9,
                                  fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
                                  color: isHighlighted
                                      ? AdultColors.primaryGreen
                                      : const Color(0xFF1E293B),
                                ),
                              ),
                              WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 2),
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: isHighlighted
                                        ? AdultColors.goldAccent
                                        : AdultColors.goldAccent.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AdultColors.goldAccent,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    '﴿${QuranTextData.toArabicDigits(ayahNum)}﴾',
                                    style: GoogleFonts.amiri(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: isHighlighted ? Colors.white : AdultColors.primaryGreen,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.justify,
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),

          // 4. Bottom Page Indicator Ribbon
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
                decoration: BoxDecoration(
                  color: AdultColors.primaryGreen.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AdultColors.goldAccent.withOpacity(0.5)),
                ),
                child: Text(
                  '﴿ ${QuranTextData.toArabicDigits(pageNumber)} ﴾',
                  style: GoogleFonts.amiri(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AdultColors.primaryGreen,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
