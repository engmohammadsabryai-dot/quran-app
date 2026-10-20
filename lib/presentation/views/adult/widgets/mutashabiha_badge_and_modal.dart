import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../domain/models/mutashabiha_item.dart';

class MutashabihaBadge extends StatelessWidget {
  final MutashabihaItem item;
  final VoidCallback onTap;

  const MutashabihaBadge({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AdultColors.goldAccent.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AdultColors.goldAccent, width: 1.2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.compare_arrows_rounded, size: 16, color: AdultColors.goldAccent),
            const SizedBox(width: 5),
            Text(
              'متشابه مع ${item.surah2Name} (${item.ayah2})',
              style: GoogleFonts.cairo(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AdultColors.primaryGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MutashabihaComparisonModal extends StatelessWidget {
  final MutashabihaItem item;

  const MutashabihaComparisonModal({super.key, required this.item});

  static Future<void> show(BuildContext context, MutashabihaItem item) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => MutashabihaComparisonModal(item: item),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
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

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AdultColors.goldAccent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.auto_stories_rounded, color: AdultColors.goldAccent, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'محرك المتشابهات اللفظية والضبط',
                        style: GoogleFonts.cairo(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AdultColors.primaryGreen,
                        ),
                      ),
                      Text(
                        'تصنيف: ${item.category}',
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Dual-Card Comparison Section
            // Card 1: Current Ayah
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF7FAF7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AdultColors.primaryGreen.withOpacity(0.3), width: 1.2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AdultColors.primaryGreen,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'الموضع الأول: سورة ${item.surah1Name}',
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Text(
                        'الآية رقم ${item.ayah1}',
                        style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w600, color: AdultColors.primaryGreen),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item.text1,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.amiri(
                      fontSize: 19,
                      height: 2.0,
                      fontWeight: FontWeight.bold,
                      color: AdultColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
            Center(
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AdultColors.goldAccent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: AdultColors.goldAccent.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 2)),
                  ],
                ),
                child: const Icon(Icons.swap_vert_rounded, color: Colors.white, size: 20),
              ),
            ),
            const SizedBox(height: 12),

            // Card 2: Corresponding Mutashabiha Ayah
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFDF5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AdultColors.goldAccent.withOpacity(0.4), width: 1.2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AdultColors.goldAccent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'الموضع الثاني: سورة ${item.surah2Name}',
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Text(
                        'الآية رقم ${item.ayah2}',
                        style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w600, color: AdultColors.goldAccent),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item.text2,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.amiri(
                      fontSize: 19,
                      height: 2.0,
                      fontWeight: FontWeight.bold,
                      color: AdultColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Visual Difference Highlight Box
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.remove_red_eye_rounded, color: Color(0xFF2563EB), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'موطن الفرق اللفظي الدقيق:',
                          style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1E40AF)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.differenceHighlight,
                          style: GoogleFonts.cairo(fontSize: 13, height: 1.6, color: const Color(0xFF1E3A8A)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Grammatical / Mnemonic Anchor (قاعدة الضبط والربط)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AdultColors.goldAccent, width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.lightbulb_rounded, color: AdultColors.goldAccent, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        'قاعدة الضبط والربط للحفظ المتقن:',
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AdultColors.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.ruleMnemonic,
                    style: GoogleFonts.cairo(
                      fontSize: 13.5,
                      height: 1.7,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF78350F),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AdultColors.primaryGreen,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                'فهمت الفرق وسأثبته في ورِدي',
                style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
