class QuranQuarter {
  final int id;              // من 1 إلى 240
  final int surahNumber;
  final String surahName;
  final int startAyah;
  final int endAyah;
  final String openingText;  // مطلع الربع (مثل: إِنَّ اللَّهَ لَا يَسْتَحْيِي...)
  final int juz;
  final int page;

  const QuranQuarter({
    required this.id,
    required this.surahNumber,
    required this.surahName,
    required this.startAyah,
    required this.endAyah,
    required this.openingText,
    required this.juz,
    required this.page,
  });
}