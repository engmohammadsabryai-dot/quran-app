import 'package:flutter_test/flutter_test.dart';
import 'package:quran_memorization_engine/core/constants/app_constants.dart';
import 'package:quran_memorization_engine/data/datasources/local/quran_text_data.dart';

void main() {
  group('Quran Data and Range Selector Tests', () {
    test('Converts Western digits to Arabic-Indic digits accurately', () {
      expect(QuranTextData.toArabicDigits(1), equals('١'));
      expect(QuranTextData.toArabicDigits(25), equals('٢٥'));
      expect(QuranTextData.toArabicDigits(286), equals('٢٨٦'));
      expect(QuranTextData.toArabicDigits(604), equals('٦٠٤'));
    });

    test('Retrieves authentic Madani page info correctly', () {
      final p1 = QuranTextData.getPageInfo(1);
      expect(p1.surahNumber, equals(1));
      expect(p1.startAyah, equals(1));
      expect(p1.endAyah, equals(7));

      final p2 = QuranTextData.getPageInfo(2);
      expect(p2.surahNumber, equals(2));
      expect(p2.startAyah, equals(1));
      expect(p2.endAyah, equals(5));

      final p604 = QuranTextData.getPageInfo(604);
      expect(p604.surahNumber, equals(112));
      expect(p604.juzNumber, equals(30));
    });

    test('Retrieves authentic Uthmanic verse texts without errors', () {
      final fatihah1 = QuranTextData.getAyahText(1, 1);
      expect(fatihah1, contains('بِسْمِ اللَّهِ'));

      final baqarah1 = QuranTextData.getAyahText(2, 1);
      expect(baqarah1, equals('الم'));

      final baqarah2 = QuranTextData.getAyahText(2, 2);
      expect(baqarah2, contains('ذَٰلِكَ الْكِتَابُ لَا رَيْبَ'));

      final ikhlas1 = QuranTextData.getAyahText(112, 1);
      expect(ikhlas1, equals('قُلْ هُوَ اللَّهُ أَحَدٌ'));
    });

    test('All 114 Surahs are properly registered and mapped', () {
      expect(AppConstants.quranSurahs.length, equals(114));
      final alBaqarah = AppConstants.getSurah(2);
      expect(alBaqarah.nameArabic, equals('البقرة'));
      expect(alBaqarah.totalAyahs, equals(286));
      expect(alBaqarah.startPage, equals(2));

      final anNas = AppConstants.getSurah(114);
      expect(anNas.nameArabic, equals('الناس'));
      expect(anNas.totalAyahs, equals(6));
    });

    test('Reciter audio URLs strictly point to individual ayah MP3s for EveryAyah', () {
      for (final reciter in AppConstants.availableReciters) {
        final ayahUrl = reciter.getAyahAudioUrl(2, 1);
        expect(ayahUrl, startsWith('https://everyayah.com/data/'));
        expect(ayahUrl, endsWith('002001.mp3'));
        expect(ayahUrl.contains(reciter.cdnSubfolder), isTrue);
      }
    });
  });
}
