import 'package:flutter/material.dart';

class PrayerTimesCard extends StatelessWidget {
  final Map<String, String> prayerTimes;
  final String nextPrayer; // English Name
  final Map<String, String> prayerNameTranslations;

  const PrayerTimesCard({
    super.key,
    required this.prayerTimes,
    required this.nextPrayer,
    required this.prayerNameTranslations,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: cs.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'مواقيت الصلاة والختمة',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildPrayerTimes(context),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerTimes(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final displayablePrayers = prayerTimes.entries.where((e) => e.key != 'Sunrise');

    return SizedBox(
      height: 70,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: displayablePrayers.map((entry) {
          final isNext = entry.key == nextPrayer;
          final arabicName = prayerNameTranslations[entry.key] ?? entry.key;
          return Container(
            width: 80,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: isNext ? cs.primary : cs.surfaceVariant.withOpacity(0.3),
              border: isNext ? null : Border.all(color: cs.outlineVariant, width: 1),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  arabicName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isNext ? cs.onPrimary : cs.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  entry.value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isNext ? cs.onPrimary : cs.onSurface,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
