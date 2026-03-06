import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../widgets/islamic_background.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/services/local_storage_service.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String _selected = 'ar';
  // تم إزالة _isLoading و _checkRegistration لكي تظهر هذه الصفحة دائماً كأول صفحة
  // كما طلب المستخدم، مع الحفاظ على البيانات المحفوظة في الذاكرة للمراحل التالية

  final List<_LangItem> _langs = const [
    _LangItem(code: 'ar', title: 'العربية'),
    _LangItem(code: 'en', title: 'English'),
    _LangItem(code: 'fr', title: 'Français'),
    _LangItem(code: 'es', title: 'Español'),
    _LangItem(code: 'tr', title: 'Türkçe'),
    _LangItem(code: 'ur', title: 'اردو'),
    _LangItem(code: 'id', title: 'Bahasa Indonesia'),
    _LangItem(code: 'ms', title: 'Bahasa Melayu'),
  ];

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return IslamicBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              const Spacer(),
              _buildHeader(tt),
              const Spacer(),
              _buildLanguageGrid(),
              const Spacer(flex: 2),
              _buildNextButton(context, tt),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(TextTheme tt) {
    return Column(
      children: [
        Icon(Icons.mosque, size: 72, color: Colors.white.withOpacity(0.9),),
        const SizedBox(height: 20),
        Text('مساعد الصلاة', style: tt.displaySmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold, shadows: [Shadow(color: Colors.black.withOpacity(0.2), blurRadius: 5, offset: const Offset(0, 3))])),
        const SizedBox(height: 12),
        Text('اختر لغتك المفضلة', style: tt.titleLarge?.copyWith(color: Colors.white.withOpacity(0.8))),
      ],
    );
  }

  Widget _buildLanguageGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _langs.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 18,
          crossAxisSpacing: 18,
          childAspectRatio: 2.5,
        ),
        itemBuilder: (context, i) {
          final item = _langs[i];
          final selected = item.code == _selected;

          return _buildLangChip(item, selected);
        },
      ),
    );
  }

  Widget _buildLangChip(_LangItem item, bool selected) {
    return GestureDetector(
      onTap: () => setState(() => _selected = item.code),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected ? const Color(0xFFF5A623) : Colors.white.withOpacity(0.3),
                width: selected ? 2.5 : 1.5,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: selected 
                  ? [const Color(0xFFF5A623).withOpacity(0.3), const Color(0xFFF5A623).withOpacity(0.1)]
                  : [Colors.white.withOpacity(0.15), Colors.white.withOpacity(0.05)],
              )
            ),
            child: Center(
              child: Text(item.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, shadows: [Shadow(color: Colors.black38, blurRadius: 4)] )),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNextButton(BuildContext context, TextTheme tt) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: SizedBox(
        width: double.infinity,
        height: 58,
        child: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFF5A623),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            elevation: 8,
            shadowColor: Colors.black.withOpacity(0.5),
          ),
          onPressed: () {
             // عند الضغط على التالي، ننتقل لصفحة المعلومات الشخصية
             // هناك سنقوم بالتحقق مما إذا كانت المعلومات موجودة مسبقاً للانتقال السريع
             context.push('/profile', extra: _selected);
          },
          child: Text('التالي', style: tt.titleLarge?.copyWith(color: const Color(0xFF0D3B2E), fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}

class _LangItem {
  final String code;
  final String title;
  const _LangItem({required this.code, required this.title});
}
