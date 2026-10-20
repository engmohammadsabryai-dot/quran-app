import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../domain/models/parental_reward.dart';

class ParentalRewardCard extends StatelessWidget {
  final ParentalReward reward;
  final int currentQuartersCount;
  final VoidCallback onClaim;

  const ParentalRewardCard({
    super.key,
    required this.reward,
    required this.currentQuartersCount,
    required this.onClaim,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (currentQuartersCount / reward.targetQuarterMilestone).clamp(0.0, 1.0);
    final isMilestoneReached = currentQuartersCount >= reward.targetQuarterMilestone;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: reward.isClaimed
              ? Colors.grey.shade300
              : isMilestoneReached
                  ? KidsColors.sunnyOrange
                  : const Color(0xFFE2D4F0),
          width: isMilestoneReached ? 2 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isMilestoneReached ? KidsColors.sunnyOrange : Colors.black).withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isMilestoneReached ? KidsColors.sunnyOrange.withOpacity(0.15) : Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    reward.isClaimed ? '🎁' : isMilestoneReached ? '🏆' : '🔒',
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reward.title,
                      style: GoogleFonts.cairo(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      reward.description,
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              if (reward.isClaimed)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.green.shade300),
                  ),
                  child: Text(
                    'تم استلام الجائزة 🎉',
                    style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green.shade800),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Milestone Progress Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الهدف: حفظ ${reward.targetQuarterMilestone} أرباع',
                style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w600, color: KidsColors.primaryPurple),
              ),
              Text(
                '$currentQuartersCount / ${reward.targetQuarterMilestone}',
                style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(
                isMilestoneReached ? KidsColors.grassGreen : KidsColors.sunnyOrange,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Action button
          if (isMilestoneReached && !reward.isClaimed) ...[
            ElevatedButton(
              onPressed: onClaim,
              style: ElevatedButton.styleFrom(
                backgroundColor: KidsColors.sunnyOrange,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                'فتح واستلام الجائزة مع الوالدين! 🎉',
                style: GoogleFonts.cairo(fontSize: 13.5, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
