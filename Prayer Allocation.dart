class PrayerDistributionService {
  // توزيع آيات الربع اليومي على صلوات اليوم
  static Map<String, String> splitQuarterIntoPrayers({
    required int totalAyahs,
    required String surahName,
    required int startAyah,
    required int endAyah,
  }) {
    int ayahsCount = endAyah - startAyah + 1;
    int step = (ayahsCount / 5).ceil();

    return {
      'الفجر (سنة وفريضة)': 'سورة $surahName: من آية $startAyah إلى ${startAyah + step - 1}',
      'الظهر (الركعات الأربع)': 'سورة $surahName: من آية ${startAyah + step} إلى ${startAyah + (step * 2) - 1}',
      'العصر (الفريضة والسنة)': 'سورة $surahName: من آية ${startAyah + (step * 2)} إلى ${startAyah + (step * 3) - 1}',
      'المغرب (الفريضة)': 'سورة $surahName: من آية ${startAyah + (step * 3)} إلى ${startAyah + (step * 4) - 1}',
      'العشاء وقيام الليل': 'سورة $surahName: من آية ${startAyah + (step * 4)} إلى $endAyah (مراجعة كاملة للمقطع)',
    };
  }
}