import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/islamic_background.dart';
import '../../../core/providers/theme_provider.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String _selectedCode = 'ar';

  final List<Map<String, String>> languages = const [
    {'code': 'en', 'name': 'English'},
    {'code': 'ar', 'name': 'العربية'},
    {'code': 'es', 'name': 'Español'},
    {'code': 'fr', 'name': 'Français'},
    {'code': 'ur', 'name': 'اردو'},
    {'code': 'tr', 'name': 'Türkçe'},
    {'code': 'ms', 'name': 'Bahasa Melayu'},
    {'code': 'id', 'name': 'Bahasa Indonesia'},
  ];

  @override
  Widget build(BuildContext context) {
    return IslamicBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 30),
              // Logo/Icon
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.mosque, size: 60, color: Colors.white),
              ),
              const SizedBox(height: 15),
              // Title
              Text(
                "أنيس طريق الهداية",
                style: GoogleFonts.amiri(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    const Shadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 4))
                  ],
                ),
              ),
              Text(
                "اختر لغتك المفضلة",
                style: GoogleFonts.amiri(
                  color: Colors.white70,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 30),
              // Grid of Languages
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 2.2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                    ),
                    itemCount: languages.length,
                    itemBuilder: (context, index) {
                      final lang = languages[index];
                      final isSelected = _selectedCode == lang['code'];
                      return _buildLanguageCard(lang, isSelected);
                    },
                  ),
                ),
              ),
              // Next Button
              _buildNextButton(context),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageCard(Map<String, String> lang, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _selectedCode = lang['code']!),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFF5A623).withOpacity(0.3) : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: isSelected ? const Color(0xFFF5A623) : Colors.white.withOpacity(0.2),
                width: isSelected ? 2 : 1,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              lang['name']!,
              textAlign: TextAlign.center,
              style: GoogleFonts.amiri(
                color: Colors.white,
                fontSize: 18,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNextButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton(
        onPressed: () async {
          final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
          await themeProvider.setLocale(_selectedCode);
          if (mounted) {
            context.push('/profile', extra: _selectedCode);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF5A623),
          foregroundColor: Colors.black,
          minimumSize: const Size(double.infinity, 60),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 5,
        ),
        child: Text(
          "التالي",
          style: GoogleFonts.amiri(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
