import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/compensation_calculator.dart';

class DelayCompensationDialog extends StatefulWidget {
  final int delayedCount;
  final Function(CompensationStrategyType strategy, int? shiftDays) onApply;

  const DelayCompensationDialog({
    super.key,
    required this.delayedCount,
    required this.onApply,
  });

  static Future<void> show(
    BuildContext context, {
    required int delayedCount,
    required Function(CompensationStrategyType strategy, int? shiftDays) onApply,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => DelayCompensationDialog(
        delayedCount: delayedCount,
        onApply: onApply,
      ),
    );
  }

  @override
  State<DelayCompensationDialog> createState() => _DelayCompensationDialogState();
}

class _DelayCompensationDialogState extends State<DelayCompensationDialog> {
  CompensationStrategyType _selectedStrategy = CompensationStrategyType.intensiveFridayCatchUp;
  int _shiftDays = 2;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AdultColors.pendingOrange.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.healing_rounded, color: AdultColors.pendingOrange, size: 24),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'خطة التعويض الذكي للأوراد المتأخرة',
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AdultColors.primaryGreen,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Text(
                'لديك ${widget.delayedCount} ورد غير منجز من الأيام السابقة. لا تقلق، الاستمرارية هي الأساس! اختر استراتيجية التعويض الأنسب لك:',
                style: GoogleFonts.cairo(fontSize: 13, color: Colors.brown.shade800, height: 1.5),
              ),
            ),
            const SizedBox(height: 16),

            // Option 1: Intensive Friday Catch-Up
            _buildStrategyCard(
              type: CompensationStrategyType.intensiveFridayCatchUp,
              title: '١. التعويض المكثف في مراجعة الجمعة',
              description: 'إعادة جدولة الأوراد المتأخرة مباشرة في جلسة يوم الجمعة المخصصة للمراجعة دون تغيير تواريخ باقي الأسبوع.',
              icon: Icons.calendar_today_rounded,
            ),
            const SizedBox(height: 10),

            // Option 2: Gradual Split
            _buildStrategyCard(
              type: CompensationStrategyType.gradualSplit,
              title: '٢. التقسيم التدريجي الميسر (+0.5 ربع)',
              description: 'توزيع المقدار المتأخر كزيادة طفيفة (نصف ربع إضافي) مع الأوراد القادمة منعاً للإجهاد الذهني.',
              icon: Icons.pie_chart_rounded,
            ),
            const SizedBox(height: 10),

            // Option 3: Schedule Timeline Shift
            _buildStrategyCard(
              type: CompensationStrategyType.scheduleTimelineShift,
              title: '٣. إزاحة الجدول الزمني للأمام',
              description: 'ترحيل مواعيد الأوراد القادمة بمقدار عدد أيام التأخير تلقائياً للحفاظ على نفس وتيرة الحفظ الهادئة.',
              icon: Icons.forward_rounded,
            ),

            if (_selectedStrategy == CompensationStrategyType.scheduleTimelineShift) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('عدد أيام الإزاحة:', style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold)),
                  DropdownButton<int>(
                    value: _shiftDays,
                    items: [1, 2, 3, 5, 7].map((d) => DropdownMenuItem(value: d, child: Text('$d أيام'))).toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _shiftDays = v);
                    },
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('إلغاء', style: GoogleFonts.cairo(color: Colors.grey.shade600)),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onApply(
              _selectedStrategy,
              _selectedStrategy == CompensationStrategyType.scheduleTimelineShift ? _shiftDays : null,
            );
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AdultColors.primaryGreen,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text('تطبيق استراتيجية التعويض', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildStrategyCard({
    required CompensationStrategyType type,
    required String title,
    required String description,
    required IconData icon,
  }) {
    final isSelected = _selectedStrategy == type;

    return InkWell(
      onTap: () {
        setState(() => _selectedStrategy = type);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AdultColors.primaryGreen.withOpacity(0.08) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AdultColors.primaryGreen : Colors.grey.shade300,
            width: isSelected ? 1.8 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Radio<CompensationStrategyType>(
              value: type,
              groupValue: _selectedStrategy,
              activeColor: AdultColors.primaryGreen,
              onChanged: (val) {
                if (val != null) setState(() => _selectedStrategy = val);
              },
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.cairo(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AdultColors.primaryGreen : AdultColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
