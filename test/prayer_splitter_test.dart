import 'package:flutter_test/flutter_test.dart';
import 'package:quran_memorization_engine/core/utils/prayer_splitter.dart';

void main() {
  group('PrayerSplitterEngine Tests', () {
    test('Splits 25 ayahs evenly into 5 balanced chunks across daily prayers', () {
      final chunks = PrayerSplitterEngine.splitPortionIntoFivePrayers(
        surahNumber: 2,
        surahArabicName: 'البقرة',
        fromAyah: 1,
        toAyah: 25,
      );

      expect(chunks.length, equals(5));
      expect(chunks[0].prayerType, equals(PrayerType.fajr));
      expect(chunks[1].prayerType, equals(PrayerType.dhuhr));
      expect(chunks[2].prayerType, equals(PrayerType.asr));
      expect(chunks[3].prayerType, equals(PrayerType.maghrib));
      expect(chunks[4].prayerType, equals(PrayerType.ishaAndQiyam));

      // 5th chunk (Isha & Qiyam) must consolidate full portion
      expect(chunks[4].startAyah, equals(1));
      expect(chunks[4].endAyah, equals(25));
    });

    test('Preserves completion check-off status across prayer chunks', () {
      final chunks = PrayerSplitterEngine.splitPortionIntoFivePrayers(
        surahNumber: 2,
        surahArabicName: 'البقرة',
        fromAyah: 1,
        toAyah: 20,
        completedStatus: [true, true, false, false, false],
      );

      expect(chunks[0].isCompleted, isTrue);
      expect(chunks[1].isCompleted, isTrue);
      expect(chunks[2].isCompleted, isFalse);
      expect(chunks[3].isCompleted, isFalse);
      expect(chunks[4].isCompleted, isFalse);
    });
  });
}
