import 'package:flutter/material.dart';

class PlanDashboardHeader extends StatelessWidget {
  final PlanAnalyticsResult analytics;
  final Function(CompensationStrategy) onApplyCompensation;

  const PlanDashboardHeader({
    super.key,
    required this.analytics,
    required this.onApplyCompensation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. نسبة الإنجاز وشريط التقدم
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'مؤشر تقدم الختمة السنوية',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Text(
                '${analytics.completionPercentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: analytics.completionPercentage / 100,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                analytics.delayDaysCount > 3 ? Colors.orange : Colors.teal,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 2. بطاقات الإحصائيات السريعة (المنجز، المتبقي، التأخير)
          Row(
            children: [
              _buildStatCard(
                label: 'تم حفظه',
                count: '${analytics.completedTasks}',
                icon: Icons.check_circle_outline,
                color: Colors.teal,
              ),
              const SizedBox(width: 8),
              _buildStatCard(
                label: 'متبقي',
                count: '${analytics.remainingTasks}',
                icon: Icons.hourglass_empty_rounded,
                color: Colors.indigo,
              ),
              const SizedBox(width: 8),
              _buildStatCard(
                label: 'أيام التأخير',
                count: '${analytics.delayDaysCount}',
                icon: Icons.warning_amber_rounded,
                color: analytics.delayDaysCount > 0 ? Colors.redAccent : Colors.grey,
              ),
            ],
          ),

          // 3. صندوق اقتراحات التعويض (يظهر فقط إذا كان هناك تأخير)
          if (analytics.delayDaysCount > 0) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_outline, color: Colors.amber.shade900, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        'اقتراح تعويض الأيام الفائتة (${analytics.delayDaysCount})',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.amber.shade900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    analytics.suggestions.first.description,
                    style: TextStyle(fontSize: 12, color: Colors.brown.shade800, height: 1.4),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton.icon(
                      onPressed: () => onApplyCompensation(analytics.suggestions.first.strategy),
                      icon: const Icon(Icons.auto_fix_high, size: 16),
                      label: Text(analytics.suggestions.first.actionLabel, style: const TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        elevation: 0,
                      ),
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

  Widget _buildStatCard({
    required String label,
    required String count,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 4),
            Text(count, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}