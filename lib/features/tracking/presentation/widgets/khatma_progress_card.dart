import 'package:flutter/material.dart';
import '../../../../models/quran_progress.dart';

class KhatmaProgressCard extends StatelessWidget {
  final QuranProgress progress;

  const KhatmaProgressCard({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      color: cs.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('تقدم الختمة', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const Spacer(),
                Text(
                  '${(progress.progressPercentage * 100).toStringAsFixed(1)}%',
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: cs.primary),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('إجمالي الختمة: ${progress.totalPages} صفحة', style: tt.bodySmall?.copyWith(color: cs.onSurface.withOpacity(0.7))),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress.progressPercentage,
              minHeight: 8,
              borderRadius: BorderRadius.circular(8),
              backgroundColor: cs.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'صفحة ${progress.pagesReadToday} / ${progress.targetPagesPerDay}',
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 6),
                Text('لليوم', style: tt.bodySmall),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'تبقى ${progress.targetPagesPerDay - progress.pagesReadToday} صفحات من ورد اليوم',
              style: tt.bodySmall?.copyWith(color: cs.onSurface.withOpacity(0.7)),
            ),
          ],
        ),
      ),
    );
  }
}
