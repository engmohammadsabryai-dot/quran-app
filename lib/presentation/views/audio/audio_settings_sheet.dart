import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../blocs/audio/audio_cubit.dart';

class AudioSettingsSheet extends StatefulWidget {
  const AudioSettingsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const AudioSettingsSheet(),
    );
  }

  @override
  State<AudioSettingsSheet> createState() => _AudioSettingsSheetState();
}

class _AudioSettingsSheetState extends State<AudioSettingsSheet> {
  late int _ayahRepeats;
  late int _portionCycles;
  late int _intervalDelay;
  late String _selectedRiwayahId;
  late ReciterInfo _selectedReciter;
  bool _autoDownload = true;

  @override
  void initState() {
    super.initState();
    final audioState = context.read<AudioCubit>().state;
    _ayahRepeats = audioState.targetAyahRepeats;
    _portionCycles = audioState.targetPortionCycles;
    _intervalDelay = audioState.intervalDelaySeconds;
    _selectedReciter = audioState.reciter;
    _selectedRiwayahId = audioState.reciter.riwayahId;
  }

  @override
  Widget build(BuildContext context) {
    final availableForRiwayah = AppConstants.getRecitersForRiwayah(_selectedRiwayahId);

    // Guard if selected reciter doesn't belong to current riwayah
    if (!availableForRiwayah.any((r) => r.id == _selectedReciter.id)) {
      _selectedReciter = availableForRiwayah.first;
    }

    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                const Icon(Icons.tune_rounded, color: AdultColors.primaryGreen, size: 24),
                const SizedBox(width: 10),
                Text(
                  'اختيار القراءة ورواية التلاوة والشيوخ',
                  style: GoogleFonts.cairo(
                    fontSize: 16.5,
                    fontWeight: FontWeight.bold,
                    color: AdultColors.primaryGreen,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 1. Qira'ah / Riwayah Selection (قالون، ورش، حفص، حمزة، الكسائي، السوسي)
            Row(
              children: [
                const Icon(Icons.menu_book_rounded, color: AdultColors.goldAccent, size: 18),
                const SizedBox(width: 6),
                Text(
                  'اختر الرواية / القراءة القرآنية:',
                  style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold, color: AdultColors.textPrimary),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AdultColors.goldAccent.withOpacity(0.06),
                border: Border.all(color: AdultColors.goldAccent, width: 1.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedRiwayahId,
                  items: AppConstants.availableRiwayat.map((rw) {
                    return DropdownMenuItem(
                      value: rw.id,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'رواية ${rw.nameArabic}',
                            style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold, color: AdultColors.primaryGreen),
                          ),
                          Text(
                            'عن ${rw.qariAsl} • ${rw.description}',
                            style: GoogleFonts.cairo(fontSize: 11, color: Colors.grey.shade600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (newRiwayah) {
                    if (newRiwayah != null) {
                      setState(() {
                        _selectedRiwayahId = newRiwayah;
                        final matchingReciters = AppConstants.getRecitersForRiwayah(newRiwayah);
                        _selectedReciter = matchingReciters.first;
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 2. Reciter Selection (Filtered dynamically based on Riwayah)
            Row(
              children: [
                const Icon(Icons.person_pin_rounded, color: AdultColors.primaryGreen, size: 18),
                const SizedBox(width: 6),
                Text(
                  'الشيخ القارئ برواية (${AppConstants.getRiwayah(_selectedRiwayahId).nameArabic}):',
                  style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold, color: AdultColors.textPrimary),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<ReciterInfo>(
                  isExpanded: true,
                  value: _selectedReciter,
                  items: availableForRiwayah.map((r) {
                    return DropdownMenuItem(
                      value: r,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(r.nameArabic, style: GoogleFonts.cairo(fontSize: 13.5, fontWeight: FontWeight.bold)),
                          Text(r.style, style: GoogleFonts.cairo(fontSize: 11, color: Colors.grey.shade600)),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (r) {
                    if (r != null) setState(() => _selectedReciter = r);
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 3. Per-Ayah Repeat Slider (N)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'تكرار كل آية منفردة (N):',
                  style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: AdultColors.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$_ayahRepeats مرات',
                    style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold, color: AdultColors.primaryGreen),
                  ),
                ),
              ],
            ),
            Slider(
              value: _ayahRepeats.toDouble(),
              min: 1,
              max: 30,
              divisions: 29,
              activeColor: AdultColors.primaryGreen,
              onChanged: (v) => setState(() => _ayahRepeats = v.round()),
            ),
            const SizedBox(height: 12),

            // 4. Full-Range Repeat Slider (M)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'تكرار كامل المقدار / الورد (M):',
                  style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: AdultColors.goldAccent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$_portionCycles مرات',
                    style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold, color: AdultColors.goldAccent),
                  ),
                ),
              ],
            ),
            Slider(
              value: _portionCycles.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              activeColor: AdultColors.goldAccent,
              onChanged: (v) => setState(() => _portionCycles = v.round()),
            ),
            const SizedBox(height: 12),

            // 5. Interval Silent Delay Slider (T)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'وقفة صامتة للترديد الذهني والصوتي (T):',
                  style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$_intervalDelay ثوانٍ',
                    style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF2563EB)),
                  ),
                ),
              ],
            ),
            Slider(
              value: _intervalDelay.toDouble(),
              min: 0,
              max: 15,
              divisions: 15,
              activeColor: const Color(0xFF3B82F6),
              onChanged: (v) => setState(() => _intervalDelay = v.round()),
            ),
            const SizedBox(height: 12),

            // 6. Auto-Download Toggle
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('التحميل التلقائي للاستماع دون إنترنت', style: GoogleFonts.cairo(fontSize: 13.5, fontWeight: FontWeight.w600)),
              subtitle: Text('حفظ الآيات تلقائياً في ذاكرة الجهاز عند الاستماع لأول مرة', style: GoogleFonts.cairo(fontSize: 11.5, color: Colors.grey.shade600)),
              value: _autoDownload,
              activeColor: AdultColors.primaryGreen,
              onChanged: (v) => setState(() => _autoDownload = v),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                context.read<AudioCubit>().setRepetitionSettings(
                  ayahRepeats: _ayahRepeats,
                  portionCycles: _portionCycles,
                  intervalDelay: _intervalDelay,
                  reciter: _selectedReciter,
                  autoDownload: _autoDownload,
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AdultColors.primaryGreen,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                'حفظ وتطبيق القراءة والشيخ والتكرار',
                style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
