import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';

class QuranGardenTreeWidget extends StatefulWidget {
  final int stage; // 1 to 5
  final int waterDrops;
  final int stars;
  final VoidCallback onWaterTree;

  const QuranGardenTreeWidget({
    super.key,
    required this.stage,
    required this.waterDrops,
    required this.stars,
    required this.onWaterTree,
  });

  @override
  State<QuranGardenTreeWidget> createState() => _QuranGardenTreeWidgetState();
}

class _QuranGardenTreeWidgetState extends State<QuranGardenTreeWidget> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  bool _isWatering = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.98, end: 1.02).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _triggerWatering() {
    setState(() => _isWatering = true);
    widget.onWaterTree();
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _isWatering = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFE8F5E9),
            Colors.white,
            const Color(0xFFF1F8E9),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFC8E6C9), width: 2),
        boxShadow: [
          BoxShadow(
            color: KidsColors.grassGreen.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with stage title & stats badges
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Stars badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: KidsColors.starGold.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: KidsColors.starGold, width: 1.5),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star_rounded, color: KidsColors.starGold, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.stars} نجمة',
                      style: GoogleFonts.cairo(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFB45309),
                      ),
                    ),
                  ],
                ),
              ),

              // Water drops badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: KidsColors.playfulSky.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: KidsColors.playfulSky, width: 1.5),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.water_drop_rounded, color: KidsColors.playfulSky, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.waterDrops} قطرة',
                      style: GoogleFonts.cairo(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0369A1),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Stage Title
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6),
              ],
            ),
            child: Text(
              _getStageName(widget.stage),
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: KidsColors.primaryPurple,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Custom Painted / Animated Quran Garden Tree
          ScaleTransition(
            scale: _scaleAnimation,
            child: SizedBox(
              height: 190,
              width: double.infinity,
              child: CustomPaint(
                painter: QuranGardenTreePainter(
                  stage: widget.stage,
                  isWatering: _isWatering,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Water Tree Action Button
          ElevatedButton.icon(
            onPressed: _triggerWatering,
            icon: const Icon(Icons.water_drop_rounded, size: 22, color: Colors.white),
            label: Text(
              'اسقِ شجرة القرآن بورد اليوم 💧',
              style: GoogleFonts.cairo(fontSize: 14.5, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: KidsColors.playfulSky,
              foregroundColor: Colors.white,
              elevation: 4,
              shadowColor: KidsColors.playfulSky.withOpacity(0.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  String _getStageName(int stage) {
    switch (stage) {
      case 1:
        return 'المرحلة ١: البذرة الطيبة في التربة المباركة 🌱';
      case 2:
        return 'المرحلة ٢: البرعم الأخضر اليافع 🌿';
      case 3:
        return 'المرحلة ٣: الغرسة النامية المتأصلة 🪴';
      case 4:
        return 'المرحلة ٤: الشجرة المزهرة العاطرة 🌸';
      case 5:
      default:
        return 'المرحلة ٥: شجرة القرآن الذهبية المثمرة 🌳✨';
    }
  }
}

class QuranGardenTreePainter extends CustomPainter {
  final int stage;
  final bool isWatering;

  QuranGardenTreePainter({required this.stage, required this.isWatering});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final bottomY = size.height - 15;

    // 1. Draw Mound / Soil Base
    final soilPaint = Paint()
      ..color = const Color(0xFF8D6E63)
      ..style = PaintingStyle.fill;

    final grassPaint = Paint()
      ..color = const Color(0xFF66BB6A)
      ..style = PaintingStyle.fill;

    // Soil hill
    final soilPath = Path()
      ..moveTo(cx - 90, bottomY + 10)
      ..quadraticBezierTo(cx, bottomY - 18, cx + 90, bottomY + 10)
      ..close();
    canvas.drawPath(soilPath, soilPaint);

    // Grass patch
    final grassPath = Path()
      ..moveTo(cx - 75, bottomY + 8)
      ..quadraticBezierTo(cx, bottomY - 14, cx + 75, bottomY + 8)
      ..close();
    canvas.drawPath(grassPath, grassPaint);

    // 2. Stage 1: Seed
    if (stage == 1) {
      final seedPaint = Paint()..color = const Color(0xFF5D4037);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(cx, bottomY - 20), width: 22, height: 28),
        seedPaint,
      );
      // Small green leaf sprout
      final sproutPaint = Paint()..color = const Color(0xFF4CAF50);
      canvas.drawCircle(Offset(cx + 4, bottomY - 34), 6, sproutPaint);
    }

    // 3. Stage 2: Sprout
    if (stage == 2) {
      final stemPaint = Paint()
        ..color = const Color(0xFF4CAF50)
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      canvas.drawLine(Offset(cx, bottomY - 15), Offset(cx, bottomY - 55), stemPaint);

      final leafPaint = Paint()..color = const Color(0xFF66BB6A);
      canvas.drawOval(Rect.fromCenter(center: Offset(cx - 16, bottomY - 50), width: 26, height: 14), leafPaint);
      canvas.drawOval(Rect.fromCenter(center: Offset(cx + 16, bottomY - 55), width: 26, height: 14), leafPaint);
    }

    // 4. Stage 3: Young Sapling
    if (stage == 3) {
      final trunkPaint = Paint()
        ..color = const Color(0xFF795548)
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      canvas.drawLine(Offset(cx, bottomY - 15), Offset(cx, bottomY - 80), trunkPaint);

      // Leaves crown
      final leavesPaint = Paint()..color = const Color(0xFF43A047);
      canvas.drawCircle(Offset(cx, bottomY - 95), 38, leavesPaint);
      canvas.drawCircle(Offset(cx - 25, bottomY - 85), 26, leavesPaint);
      canvas.drawCircle(Offset(cx + 25, bottomY - 85), 26, leavesPaint);
    }

    // 5. Stage 4: Blooming Tree
    if (stage == 4) {
      final trunkPaint = Paint()
        ..color = const Color(0xFF5D4037)
        ..strokeWidth = 16
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      canvas.drawLine(Offset(cx, bottomY - 15), Offset(cx, bottomY - 90), trunkPaint);

      // Canopy
      final canopyPaint = Paint()..color = const Color(0xFF2E7D32);
      canvas.drawCircle(Offset(cx, bottomY - 110), 55, canopyPaint);
      canvas.drawCircle(Offset(cx - 36, bottomY - 100), 38, canopyPaint);
      canvas.drawCircle(Offset(cx + 36, bottomY - 100), 38, canopyPaint);

      // Pink Blossom Flowers
      final flowerPaint = Paint()..color = const Color(0xFFFF80AB);
      final flowerCenter = Paint()..color = const Color(0xFFFFEB3B);

      final flowerOffsets = [
        Offset(cx - 20, bottomY - 125),
        Offset(cx + 25, bottomY - 120),
        Offset(cx - 30, bottomY - 95),
        Offset(cx + 15, bottomY - 90),
        Offset(cx, bottomY - 145),
      ];

      for (final fo in flowerOffsets) {
        canvas.drawCircle(fo, 8, flowerPaint);
        canvas.drawCircle(fo, 3.5, flowerCenter);
      }
    }

    // 6. Stage 5: Golden Fruitful Quran Tree
    if (stage >= 5) {
      // Golden aura behind canopy
      final auraPaint = Paint()
        ..color = const Color(0xFFFFD54F).withOpacity(0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
      canvas.drawCircle(Offset(cx, bottomY - 115), 75, auraPaint);

      // Strong Tree Trunk
      final trunkPaint = Paint()
        ..color = const Color(0xFF4E342E)
        ..strokeWidth = 22
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(cx, bottomY - 15), Offset(cx, bottomY - 90), trunkPaint);

      // Lush Deep Emerald Foliage
      final canopyPaint = Paint()..color = const Color(0xFF1B5E20);
      canvas.drawCircle(Offset(cx, bottomY - 115), 65, canopyPaint);
      canvas.drawCircle(Offset(cx - 45, bottomY - 105), 45, canopyPaint);
      canvas.drawCircle(Offset(cx + 45, bottomY - 105), 45, canopyPaint);
      canvas.drawCircle(Offset(cx, bottomY - 145), 42, canopyPaint);

      // Golden Fruits (Glowing Apples / Quran Pomegranates)
      final fruitPaint = Paint()..color = const Color(0xFFFFC107);
      final fruitGlow = Paint()
        ..color = const Color(0xFFFFE082)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

      final fruitOffsets = [
        Offset(cx - 25, bottomY - 130),
        Offset(cx + 30, bottomY - 125),
        Offset(cx - 38, bottomY - 95),
        Offset(cx + 38, bottomY - 95),
        Offset(cx, bottomY - 150),
        Offset(cx - 10, bottomY - 105),
        Offset(cx + 12, bottomY - 110),
      ];

      for (final p in fruitOffsets) {
        canvas.drawCircle(p, 10, fruitGlow);
        canvas.drawCircle(p, 9, fruitPaint);
        // Small leaf on fruit
        final fruitLeaf = Paint()..color = const Color(0xFF66BB6A);
        canvas.drawOval(Rect.fromCenter(center: Offset(p.dx, p.dy - 10), width: 6, height: 4), fruitLeaf);
      }
    }

    // 7. Watering Animation Drops
    if (isWatering) {
      final dropPaint = Paint()..color = const Color(0xFF00B4D8);
      final rand = Random();
      for (int i = 0; i < 7; i++) {
        final dx = cx - 40 + (rand.nextDouble() * 80);
        final dy = 25 + (rand.nextDouble() * 50);
        canvas.drawCircle(Offset(dx, dy), 5, dropPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant QuranGardenTreePainter oldDelegate) {
    return oldDelegate.stage != stage || oldDelegate.isWatering != isWatering;
  }
}
