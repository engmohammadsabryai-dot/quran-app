// Pure algorithmic distribution engine dividing a day's Quranic portion
// across the 5 daily prayers with specific Rak'ah allocations

enum PrayerType {
  fajr,
  dhuhr,
  asr,
  maghrib,
  ishaAndQiyam,
}

extension PrayerTypeExtension on PrayerType {
  String get arabicName {
    switch (this) {
      case PrayerType.fajr:
        return 'الفجر';
      case PrayerType.dhuhr:
        return 'الظهر';
      case PrayerType.asr:
        return 'العصر';
      case PrayerType.maghrib:
        return 'المغرب';
      case PrayerType.ishaAndQiyam:
        return 'العشاء وقيام الليل';
    }
  }

  String get rakahAllocation {
    switch (this) {
      case PrayerType.fajr:
        return 'ركعتا الفجر (سنة + فرض)';
      case PrayerType.dhuhr:
        return '٤ ركعات (الفرض والسنة البعدية)';
      case PrayerType.asr:
        return '٤ ركعات الفرض';
      case PrayerType.maghrib:
        return '٣ ركعات الفرض';
      case PrayerType.ishaAndQiyam:
        return 'تثبيت ومراجعة كامل النص في الشفع والوتر والتهجد';
    }
  }

  String get iconAsset {
    switch (this) {
      case PrayerType.fajr:
        return 'assets/icons/fajr.png';
      case PrayerType.dhuhr:
        return 'assets/icons/dhuhr.png';
      case PrayerType.asr:
        return 'assets/icons/asr.png';
      case PrayerType.maghrib:
        return 'assets/icons/maghrib.png';
      case PrayerType.ishaAndQiyam:
        return 'assets/icons/isha.png';
    }
  }
}

class PrayerChunk {
  final PrayerType prayerType;
  final String portionDescription;
  final int startAyah;
  final int endAyah;
  final int surahNumber;
  final String surahArabicName;
  final bool isCompleted;

  const PrayerChunk({
    required this.prayerType,
    required this.portionDescription,
    required this.startAyah,
    required this.endAyah,
    required this.surahNumber,
    required this.surahArabicName,
    this.isCompleted = false,
  });

  PrayerChunk copyWith({bool? isCompleted}) {
    return PrayerChunk(
      prayerType: prayerType,
      portionDescription: portionDescription,
      startAyah: startAyah,
      endAyah: endAyah,
      surahNumber: surahNumber,
      surahArabicName: surahArabicName,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class PrayerSplitterEngine {
  /// Divides [totalAyahs] of [surahNumber] starting at [fromAyah] and ending at [toAyah]
  /// into 5 balanced chunks across the 5 daily prayers.
  /// Isha & Qiyam also includes consolidation review of the entire portion.
  static List<PrayerChunk> splitPortionIntoFivePrayers({
    required int surahNumber,
    required String surahArabicName,
    required int fromAyah,
    required int toAyah,
    List<bool>? completedStatus,
  }) {
    final count = (toAyah - fromAyah) + 1;
    if (count <= 0) return [];

    // If less than 5 ayahs, give 1 ayah per available prayer, and full review in Isha
    if (count < 5) {
      final List<PrayerChunk> chunks = [];
      for (int i = 0; i < 5; i++) {
        final prayer = PrayerType.values[i];
        final ayahNum = (fromAyah + (i % count));
        final isDone = completedStatus != null && i < completedStatus.length ? completedStatus[i] : false;

        chunks.add(
          PrayerChunk(
            prayerType: prayer,
            portionDescription: prayer == PrayerType.ishaAndQiyam
                ? 'تثبيت المقدار كاملاً (الآيات $fromAyah - $toAyah)'
                : 'الآية رقم $ayahNum',
            startAyah: prayer == PrayerType.ishaAndQiyam ? fromAyah : ayahNum,
            endAyah: prayer == PrayerType.ishaAndQiyam ? toAyah : ayahNum,
            surahNumber: surahNumber,
            surahArabicName: surahArabicName,
            isCompleted: isDone,
          ),
        );
      }
      return chunks;
    }

    // Algorithmic equal distribution across the first 4 prayers,
    // with 5th prayer (Isha & Qiyam) acting as full consolidation + final portion.
    final baseChunkSize = count ~/ 4;
    final remainder = count % 4;

    final List<PrayerChunk> chunks = [];
    int currentStart = fromAyah;

    for (int i = 0; i < 4; i++) {
      final prayer = PrayerType.values[i];
      final currentSize = baseChunkSize + (i < remainder ? 1 : 0);
      final currentEnd = (currentStart + currentSize - 1).clamp(fromAyah, toAyah);

      final isDone = completedStatus != null && i < completedStatus.length ? completedStatus[i] : false;

      chunks.add(
        PrayerChunk(
          prayerType: prayer,
          portionDescription: 'الآيات ($currentStart - $currentEnd) في ${prayer.rakahAllocation}',
          startAyah: currentStart,
          endAyah: currentEnd,
          surahNumber: surahNumber,
          surahArabicName: surahArabicName,
          isCompleted: isDone,
        ),
      );

      currentStart = currentEnd + 1;
    }

    // 5th: Isha & Qiyam (Consolidation of full portion)
    final isIshaDone = completedStatus != null && completedStatus.length >= 5 ? completedStatus[4] : false;
    chunks.add(
      PrayerChunk(
        prayerType: PrayerType.ishaAndQiyam,
        portionDescription: 'تثبيت كامل الورد اليومي (الآيات $fromAyah - $toAyah) في ركعات الشفع والوتر والقيام',
        startAyah: fromAyah,
        endAyah: toAyah,
        surahNumber: surahNumber,
        surahArabicName: surahArabicName,
        isCompleted: isIshaDone,
      ),
    );

    return chunks;
  }
}
