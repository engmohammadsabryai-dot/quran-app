import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/compensation_calculator.dart';

class AnalyticsDashboardHeader extends StatelessWidget {
  final AnalyticsSummary analytics;
  final VoidCallback onOpenCompensation;

  const AnalyticsDashboardHeader({
    super.key,
    required this.analytics,
    required this.onOpenCompensation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AdultColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Row 1: Percentage Progress & Quarters Overview
          Row(
            children: [
              // Circular progress
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 76,
                    height: 76,
                    child: CircularProgressIndicator(
                      value: analytics.totalTasks > 0 ? (analytics.completedTasks / analytics.totalTasks) : 0,
                      strokeWidth: 7,
                      backgroundColor: Colors.grey.shade100,
                      valueColor: const AlwaysStoppedAnimation<Color>(AdultColors.primaryGreen),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${analytics.completionPercentage.toStringAsFixed(1)}%',
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AdultColors.primaryGreen,
                        ),
                      ),
                      Text(
                        'مُنجَز',
                        style: GoogleFonts.cairo(
                          fontSize: 10,
                          color: AdultColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 16),

              // Title and Quarters Count
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مؤشرات الإنجاز والمسار القرآني',
                      style: GoogleFonts.cairo(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AdultColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'أتممت ${analytics.totalQuartersMemorized} من ٢٤٠ ربعاً (${analytics.remainingQuarters} متبقٍ)',
                      style: GoogleFonts.cairo(
                        fontSize: 12.5,
                        color: AdultColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Mini progress bar for 240 quarters
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: (analytics.totalQuartersMemorized / 240).clamp(0.0, 1.0),
                        minHeight: 6,
                        backgroundColor: Colors.grey.shade100,
                        valueColor: const AlwaysStoppedAnimation<Color>(AdultColors.goldAccent),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          Divider(height: 1, color: Colors.grey.shade100),
          const SizedBox(height: 14),

          // Row 2: 4 Analytic Metric Cards
          Row(
            children: [
              _buildMetricCard(
                title: 'إجمالي الأوراد',
                value: '${analytics.totalTasks}',
                icon: Icons.assignment_outlined,
                color: AdultColors.primaryGreen,
              ),
              const SizedBox(width: 8),
              _buildMetricCard(
                title: 'الأوراد المكتملة',
                value: '${analytics.completedTasks}',
                icon: Icons.check_circle_outline,
                color: AdultColors.completedGreen,
              ),
              const SizedBox(width: 8),
              _buildMetricCard(
                title: 'الأيام المتأخرة',
                value: '${analytics.delayedTasks}',
                icon: Icons.warning_amber_rounded,
                color: analytics.delayedTasks > 0 ? AdultColors.missedRed : Colors.grey,
              ),
              const SizedBox(width: 8),
              _buildMetricCard(
                title: 'التتابع النشط',
                value: '${analytics.activeStreakDays} يوم',
                icon: Icons.local_fire_department_rounded,
                color: AdultColors.pendingOrange,
              ),
            ],
          ),

          // Delay Warning and Compensation action if delayed tasks exist
          if (analytics.delayedTasks > 0) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFDBA74)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: AdultColors.pendingOrange, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'يوجد ${analytics.delayedTasks} أوراد متأخرة عن الجدول',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF9A3412),
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: onOpenCompensation,
                    icon: const Icon(Icons.auto_fix_high_rounded, size: 16, color: AdultColors.pendingOrange),
                    label: Text(
                      'تعويض ذكي',
                      style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold, color: AdultColors.pendingOrange),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.cairo(
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 10,
                color: AdultColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
