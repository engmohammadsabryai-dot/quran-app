import 'package:flutter/material.dart';

class MutashabihaItem {
  final String sourceSurah;
  final int sourceAyah;
  final String sourceText;
  final String targetSurah;
  final int targetAyah;
  final String targetText;
  final String differenceNote;

  const MutashabihaItem({
    required this.sourceSurah,
    required this.sourceAyah,
    required this.sourceText,
    required this.targetSurah,
    required this.targetAyah,
    required this.targetText,
    required this.differenceNote,
  });
}

class MutashabihaAlertWidget extends StatelessWidget {
  final MutashabihaItem item;

  const MutashabihaAlertWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF8EE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2C98F)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: const [
              Icon(Icons.compare_arrows_rounded, color: Color(0xFF8C6615), size: 20),
              SizedBox(width: 8),
              Text(
                'تنبيه متشابهة لفظية',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF8C6615)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // الموضع الحالي
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('سورة ${item.sourceSurah} (آية ${item.sourceAyah}):', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.teal)),
                Text(item.sourceText, style: const TextStyle(fontFamily: 'UthmanicHafs', fontSize: 14)),
              ],
            ),
          ),
          const SizedBox(height: 6),
          // الموضع المتشابه معه
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('تتشابه مع: سورة ${item.targetSurah} (آية ${item.targetAyah}):', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.blueGrey)),
                Text(item.targetText, style: const TextStyle(fontFamily: 'UthmanicHafs', fontSize: 14)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // ضابط الحفظ وقاعدة التمييز
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(color: const Color(0xFFEAE3D2), borderRadius: BorderRadius.circular(6)),
            child: Text(
              '💡 قاعدة الضبط: ${item.differenceNote}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF533F10)),
            ),
          ),
        ],
      ),
    );
  }
}