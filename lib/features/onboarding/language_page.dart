import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LanguagePage extends StatelessWidget {
  const LanguagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/islamic_decoration_7.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: SizedBox(
              width: 520,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('مساعد الصلاة', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('اختر لغتك المفضلة', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 24),

                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: const [
                      _LangChip('العربية', 'ar'),
                      _LangChip('English', 'en'),
                      _LangChip('Français', 'fr'),
                      _LangChip('Español', 'es'),
                      _LangChip('Türkçe', 'tr'),
                      _LangChip('اردو', 'ur'),
                    ],
                  ),

                  const SizedBox(height: 28),
                  FilledButton(
                    onPressed: () => context.go('/profile'),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                      child: Text('التالي'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LangChip extends StatelessWidget {
  final String label;
  final String code;
  const _LangChip(this.label, this.code);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: OutlinedButton(
        onPressed: () {
          // لاحقاً: تغيير اللغة وتخزينها
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Text(label),
        ),
      ),
    );
  }
}
