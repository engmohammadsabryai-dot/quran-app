import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Validates complete Uthmanic Quran JSON dataset has 6236 verses', () async {
    final file = File('assets/data/ara-quranuthmanihaf.min.json');
    expect(file.existsSync(), isTrue);

    final raw = await file.readAsString();
    final data = jsonDecode(raw) as Map<String, dynamic>;
    final list = data['quran'] as List;

    expect(list.length, equals(6236));

    // Verify Surah 1:1
    final s1v1 = list.firstWhere((e) => e['chapter'] == 1 && e['verse'] == 1);
    expect((s1v1['text'] as String).isNotEmpty, isTrue);

    // Verify Surah 2:1 (Al-Baqarah Ayah 1 is strictly Alm)
    final s2v1 = list.firstWhere((e) => e['chapter'] == 2 && e['verse'] == 1);
    expect(s2v1['text'], contains('الٓمٓ'));

    // Verify Surah 112:1
    final s112v1 = list.firstWhere((e) => e['chapter'] == 112 && e['verse'] == 1);
    expect((s112v1['text'] as String).isNotEmpty, isTrue);

    // Verify Surah 114:6
    final s114v6 = list.firstWhere((e) => e['chapter'] == 114 && e['verse'] == 6);
    expect((s114v6['text'] as String).isNotEmpty, isTrue);
  });
}
