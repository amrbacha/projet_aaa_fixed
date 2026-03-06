import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import '../../../core/providers/theme_provider.dart';
import '../../../models/settings_model.dart';
import '../../../widgets/islamic_background.dart';
import '../../../core/theme.dart';

class ThemeCustomizationScreen extends StatefulWidget {
  const ThemeCustomizationScreen({super.key});

  @override
  State<ThemeCustomizationScreen> createState() => _ThemeCustomizationScreenState();
}

class _ThemeCustomizationScreenState extends State<ThemeCustomizationScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ThemeProvider themeProvider, AppSettings settings) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      themeProvider.updateSettings(settings.copyWith(backgroundImage: image.path, isCustomBackground: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final settings = themeProvider.settings;
    final tt = Theme.of(context).textTheme;

    return IslamicBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
          toolbarHeight: 45, // تقليل ارتفاع الـ AppBar
          title: Text('خصص واجهتك النورانية', style: tt.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSection(context, 'نمط العرض', 
                _ThemeModeSelector(isDarkMode: settings.isDarkMode, onSelect: (isDark) {
                  themeProvider.updateSettings(settings.copyWith(isDarkMode: isDark));
                })
              ),
              const SizedBox(height: 12), // تقليل المسافة
              _buildSection(context, 'اختر الخلفية', 
                _BackgroundSelector(
                  settings: settings,
                  onSelectDefault: (path) {
                    themeProvider.updateSettings(settings.copyWith(backgroundImage: path, isCustomBackground: false));
                  },
                  onPickImage: () => _pickImage(themeProvider, settings),
                )
              ),
              const SizedBox(height: 12), // تقليل المسافة
              _buildSection(context, 'اللون الأساسي للأزرار', 
                _ColorSelector(colors: const [
                  Color(0xFF0B6B3A), Color(0xFF154360), Color(0xFF6D214F), Color(0xFF4A235A),
                ], 
                selectedColor: Color(settings.primaryColor), 
                onSelect: (c) => themeProvider.updateSettings(settings.copyWith(primaryColor: c.value)))
              ),
              const SizedBox(height: 12), // تقليل المسافة
              _buildSection(context, 'لون التفاصيل والكتابة',
                 _ColorSelector(colors: const [
                  Color(0xFFF5A623), Color(0xFF1ABC9C), Color(0xFF3498DB), Color(0xFFE74C3C), Color(0xFFF1C40F), Color(0xFF9B59B6),
                ], 
                selectedColor: Color(settings.accentColor), 
                onSelect: (c) => themeProvider.updateSettings(settings.copyWith(accentColor: c.value)))
              ),
              const SizedBox(height: 16), // تقليل المسافة
              _buildPreviewCard(context, settings),
              const SizedBox(height: 20), // تقليل المسافة
              SizedBox(
                height: 52, // تقليل ارتفاع الزر قليلاً
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: Color(settings.accentColor), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  onPressed: () => context.go('/main-menu'),
                  child: Text(
                    'ابدأ رحلتي الآن',
                    style: tt.titleMedium?.copyWith(
                      color: ThemeData.estimateBrightnessForColor(Color(settings.accentColor)) == Brightness.dark ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, Widget child) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0), // تقليل الـ padding الداخلي
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _buildPreviewCard(BuildContext context, AppSettings settings) {
    final previewTheme = settings.isDarkMode 
      ? AppTheme.dark(primaryColor: Color(settings.primaryColor), accentColor: Color(settings.accentColor))
      : AppTheme.light(primaryColor: Color(settings.primaryColor), accentColor: Color(settings.accentColor));

    return Theme(
      data: previewTheme,
      child: Card(
        elevation: 2,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0), // تقليل الـ padding
          child: Column(
            children: [
              Text("معاينة حية", style: previewTheme.textTheme.titleMedium?.copyWith(color: previewTheme.colorScheme.onSurface)),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Icon(Icons.mosque, size: 28, color: previewTheme.colorScheme.primary),
                      Text("نص أساسي", style: previewTheme.textTheme.bodySmall?.copyWith(color: previewTheme.colorScheme.primary)),
                    ],
                  ),
                  Column(
                    children: [
                      Icon(Icons.star, size: 28, color: previewTheme.colorScheme.secondary),
                      Text("نص ثانوي", style: previewTheme.textTheme.bodySmall?.copyWith(color: previewTheme.colorScheme.secondary)),
                    ],
                  ),
                ],
              ),
               const SizedBox(height: 12),
              SizedBox(
                height: 36,
                child: FilledButton(onPressed: (){}, style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16)), child: const Text("زر مثال", style: TextStyle(fontSize: 12)))
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _BackgroundSelector extends StatelessWidget {
  final AppSettings settings;
  final Function(String) onSelectDefault;
  final VoidCallback onPickImage;

  const _BackgroundSelector({required this.settings, required this.onSelectDefault, required this.onPickImage});

  void _showDefaultBackgroundsDialog(BuildContext context) {
    final List<String> defaultImages = [
      'assets/images/backgrounds/bg1.png',
      'assets/images/backgrounds/bg2.png',
      'assets/images/backgrounds/bg3.png',
      'assets/images/backgrounds/bg4.png',
      'assets/images/backgrounds/bg5.png',
    ];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2c3e50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('اختر خلفية مقترحة', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: double.maxFinite,
            child: GridView.builder(
              shrinkWrap: true,
              itemCount: defaultImages.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12),
              itemBuilder: (context, index) {
                final path = defaultImages[index];
                final isSelected = path == settings.backgroundImage && !settings.isCustomBackground;
                return GestureDetector(
                  onTap: () {
                    onSelectDefault(path);
                    Navigator.of(context).pop();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(image: AssetImage(path), fit: BoxFit.cover),
                      border: Border.all(color: isSelected ? const Color(0xfff5a623) : Colors.white.withOpacity(0.5), width: isSelected ? 3.0 : 1.5),
                    ),
                    child: isSelected ? Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: const Color(0xfff5a623).withOpacity(0.4)), child: const Icon(Icons.check_circle, color: Colors.white, size: 36)) : null,
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('إغلاق', style: TextStyle(color: Colors.white)))
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90, // تقليل الارتفاع من 120 إلى 90
      child: Row(
        children: [
          Expanded(
            child: _buildChoiceChip(
              context,
              icon: Icons.photo_library_outlined,
              label: 'خلفيات مقترحة',
              onTap: () => _showDefaultBackgroundsDialog(context),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildChoiceChip(
              context,
              icon: Icons.add_photo_alternate_outlined,
              label: 'من جهازك',
              onTap: onPickImage,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceChip(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white54, width: 1.5),
          color: Colors.black.withOpacity(0.2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 28), // تقليل حجم الأيقونة
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _ColorSelector extends StatelessWidget {
  final List<Color> colors;
  final Color selectedColor;
  final Function(Color) onSelect;

  const _ColorSelector({required this.colors, required this.selectedColor, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40, // تقليل الارتفاع من 48 إلى 40
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: colors.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final color = colors[index];
          final isSelected = color.value == selectedColor.value;
          return GestureDetector(
            onTap: () => onSelect(color),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.8), width: isSelected ? 3 : 1.5),
              ),
              child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 24) : null,
            ),
          );
        },
      ),
    );
  }
}

class _ThemeModeSelector extends StatelessWidget {
  final bool isDarkMode;
  final Function(bool) onSelect;
  const _ThemeModeSelector({required this.isDarkMode, required this.onSelect});

  @override
  Widget build(BuildContext context) {
     return Container(
      height: 44, // تقليل الارتفاع من 52 إلى 44
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withOpacity(0.1),
         border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
      ),
      child: Row(
        children: [
          _themeChip('ليلي', true, isDarkMode, () => onSelect(true)),
          _themeChip('نهاري', false, !isDarkMode, () => onSelect(false)),
        ],
      ),
    );
  }

   Widget _themeChip(String label, bool isDark, bool selected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: selected ? const Color(0xfff5a623) : Colors.transparent,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: selected ? const Color(0xFF0D3B2E) : Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
