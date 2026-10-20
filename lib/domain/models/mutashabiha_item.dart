import 'package:equatable/equatable.dart';

class MutashabihaItem extends Equatable {
  final int id;
  final int surah1;
  final String surah1Name;
  final int ayah1;
  final String text1;
  final int surah2;
  final String surah2Name;
  final int ayah2;
  final String text2;
  final String ruleMnemonic; // قاعدة الضبط والربط للحفظ المتقن
  final String differenceHighlight; // Difference visual focus
  final String category; // e.g., 'تقديم وتأخير', 'زيادة ونقصان', 'إبدال حرف'

  const MutashabihaItem({
    required this.id,
    required this.surah1,
    required this.surah1Name,
    required this.ayah1,
    required this.text1,
    required this.surah2,
    required this.surah2Name,
    required this.ayah2,
    required this.text2,
    required this.ruleMnemonic,
    required this.differenceHighlight,
    required this.category,
  });

  bool matchesAyah(int surah, int ayah) {
    return (surah1 == surah && ayah1 == ayah) || (surah2 == surah && ayah2 == ayah);
  }

  bool isInRange(int surah, int fromAyah, int toAyah) {
    return (surah1 == surah && ayah1 >= fromAyah && ayah1 <= toAyah) ||
        (surah2 == surah && ayah2 >= fromAyah && ayah2 <= toAyah);
  }

  @override
  List<Object?> get props => [
        id,
        surah1,
        surah1Name,
        ayah1,
        text1,
        surah2,
        surah2Name,
        ayah2,
        text2,
        ruleMnemonic,
        differenceHighlight,
        category,
      ];
}
