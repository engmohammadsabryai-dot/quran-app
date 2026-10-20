import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../blocs/kids/kids_garden_cubit.dart';

class VirtualMascotWidget extends StatefulWidget {
  final String mascotName;
  final MascotEmotion emotion;
  final String speechText;
  final VoidCallback onTap;

  const VirtualMascotWidget({
    super.key,
    required this.mascotName,
    required this.emotion,
    required this.speechText,
    required this.onTap,
  });

  @override
  State<VirtualMascotWidget> createState() => _VirtualMascotWidgetState();
}

class _VirtualMascotWidgetState extends State<VirtualMascotWidget> with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: 0, end: -8).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: KidsColors.primaryPurple.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: KidsColors.primaryPurple.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Animated Bouncing Mascot Avatar
          AnimatedBuilder(
            animation: _bounceAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _bounceAnimation.value),
                child: child,
              );
            },
            child: GestureDetector(
              onTap: widget.onTap,
              child: Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      KidsColors.sunnyOrange,
                      KidsColors.berryPink,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: KidsColors.sunnyOrange.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    _getMascotEmoji(widget.emotion, widget.mascotName),
                    style: const TextStyle(fontSize: 38),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Speech Bubble
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F3FF),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(6),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                border: Border.all(color: const Color(0xFFE9D8FD), width: 1.2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        (widget.mascotName == 'عائشة' || widget.mascotName == 'مريم' || widget.mascotName == 'سارة')
                            ? 'صديقتكِ ${widget.mascotName}:'
                            : 'صديقك ${widget.mascotName}:',
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: KidsColors.primaryPurple,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.volume_up_rounded, size: 18, color: KidsColors.primaryPurple),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.speechText,
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      height: 1.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF322A5E),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getMascotEmoji(MascotEmotion emotion, String name) {
    switch (emotion) {
      case MascotEmotion.happy:
        if (name == 'عائشة') return '🧕';
        if (name == 'مريم') return '🌸';
        if (name == 'سارة') return '👧';
        if (name == 'سالم') return '👦';
        return '🌟';
      case MascotEmotion.excited:
        return '🤩';
      case MascotEmotion.proud:
        return '😎';
      case MascotEmotion.thinking:
        return '🤔';
      case MascotEmotion.celebrating:
        return '🥳';
    }
  }
}
