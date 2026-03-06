import 'package:flutter/material.dart';

class StartWirdCard extends StatelessWidget {
  final VoidCallback onStart;

  const StartWirdCard({super.key, required this.onStart});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      color: cs.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        onTap: onStart,
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ابدأ وردك الآن',
                      style: tt.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'لقد وصلت إلى الصفحة 1. أكمل وردك مع كتاب الله في صلاتك القادمة.',
                      style: tt.bodyMedium?.copyWith(color: cs.onSurface.withOpacity(0.7)),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: onStart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cs.primary,
                        foregroundColor: cs.onPrimary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('دخول وضع الصلاة'),
                    )
                  ],
                ),
              ),
            ),
            // Placeholder for the image
            Container(
              width: 120,
              height: 140,
              color: cs.primary.withOpacity(0.1),
              child: Icon(Icons.photo_size_select_actual_rounded, size: 40, color: cs.primary.withOpacity(0.5)),
            ),
          ],
        ),
      ),
    );
  }
}
