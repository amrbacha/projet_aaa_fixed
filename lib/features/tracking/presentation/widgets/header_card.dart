import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HeaderCard extends StatelessWidget {
  final DateTime now;
  final String nextPrayer;
  final String nextPrayerTime;

  const HeaderCard({
    super.key,
    required this.now,
    required this.nextPrayer,
    required this.nextPrayerTime,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final formattedTime = DateFormat('HH:mm:ss').format(now);
    final formattedDate = DateFormat('EEEE, d MMMM yyyy', 'ar').format(now);

    return Card(
      elevation: 0,
      color: cs.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('الوقت الحالي', style: tt.labelMedium?.copyWith(color: cs.onPrimary.withOpacity(0.8))),
                  const SizedBox(height: 4),
                  Text(
                    formattedTime,
                    style: tt.headlineLarge?.copyWith(color: cs.onPrimary, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formattedDate,
                    style: tt.bodySmall?.copyWith(color: cs.onPrimary.withOpacity(0.8)),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('الصلاة القادمة', style: tt.labelMedium?.copyWith(color: cs.onPrimary.withOpacity(0.8))),
                const SizedBox(height: 4),
                Text(
                  nextPrayer,
                  style: tt.titleLarge?.copyWith(color: cs.onPrimary, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  nextPrayerTime,
                  style: tt.titleMedium?.copyWith(color: cs.onPrimary, fontWeight: FontWeight.w600),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
