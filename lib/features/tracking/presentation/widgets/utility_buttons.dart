import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class UtilityButtons extends StatelessWidget {
  const UtilityButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildUtilButton(
            context,
            icon: Icons.check_circle_outline,
            label: 'ختمات مكتملة',
            value: '0',
            onTap: () {},
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildUtilButton(
            context,
            icon: Icons.edit_note,
            label: 'تعديل الإعدادات',
            onTap: () {
              context.push('/settings');
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUtilButton(BuildContext context, {required IconData icon, required String label, String? value, required VoidCallback onTap,}) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 150, // Giving it a fixed height to match the other card
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: cs.surface,
          border: Border.all(color: cs.outlineVariant.withOpacity(0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (value != null)
              Text(value, style: tt.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: cs.primary)),
            if (value == null)
              Icon(icon, color: cs.primary, size: 36),

            Text(label, style: tt.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
