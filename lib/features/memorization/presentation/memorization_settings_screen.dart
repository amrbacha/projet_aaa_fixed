import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projet_aaa_fixed/core/providers/audio_provider.dart';
import 'package:projet_aaa_fixed/core/providers/theme_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/services/settings_service.dart';
import '../../../models/settings_model.dart';
import '../../../widgets/islamic_background.dart';

class MemorizationSettingsScreen extends StatefulWidget {
  const MemorizationSettingsScreen({super.key});

  @override
  State<MemorizationSettingsScreen> createState() => _MemorizationSettingsScreenState();
}

class _MemorizationSettingsScreenState extends State<MemorizationSettingsScreen> {
  late AppSettings _settings;
  bool _isLoading = true;

  static const double _containerOpacity = 0.12;
  static const double _containerBorderOpacity = 0.25;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await SettingsService.loadSettings();
    if (mounted) {
      setState(() {
        _settings = settings;
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSettings() async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final audioProvider = Provider.of<AudioProvider>(context, listen: false);
    await themeProvider.updateSettings(_settings);
    audioProvider.setQari(_settings.qari);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ إعدادات الحفظ بنجاح')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return IslamicBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: const Center(child: CircularProgressIndicator(color: Colors.white)),
        ),
      );
    }

    return IslamicBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
          centerTitle: true,
          title: Text('إعدادات الحفظ والمراجعة', 
            style: GoogleFonts.amiri(fontSize: 24, fontWeight: FontWeight.bold)
          ),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            children: [
              _buildSettingsCard(
                title: 'تخصيص المعلم والمقرئ',
                children: [
                  _buildThemeToggle(),
                  const Divider(color: Colors.white10),
                  _buildDropdownSetting('القارئ المعلم', _settings.qari, 
                    {
                      'mishary': 'مشاري العفاسي',
                      'sudais': 'عبد الرحمن السديس',
                      'ghamdi': 'سعد الغامدي',
                      'basit': 'عبد الباسط عبد الصمد',
                      'husary': 'محمود خليل الحصري',
                      'minshawi': 'محمد صديق المنشاوي',
                    }, 
                    (v) => setState(() => _settings = _settings.copyWith(qari: v!))),
                ],
              ),
              const SizedBox(height: 20),

              _buildSettingsCard(
                title: 'إدارة أهداف الحفظ',
                children: [
                  _buildGoalSlider(),
                  const Divider(color: Colors.white10),
                  _buildToggleSetting('تنبيهات المراجعة اليومية', true, (v) {}),
                ],
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 58,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1ABC9C),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: _saveSettings,
                  child: Text('حفظ الإعدادات والعودة', 
                    style: GoogleFonts.amiri(fontSize: 20, fontWeight: FontWeight.bold)
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsCard({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(_containerOpacity),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(_containerBorderOpacity)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.amiri(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 15),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDropdownSetting(String title, String value, Map<String, String> items, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: GoogleFonts.amiri(color: Colors.white, fontSize: 16)),
          DropdownButton<String>(
            value: value,
            items: items.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
            onChanged: onChanged,
            dropdownColor: const Color(0xFF0D3B2E),
            style: GoogleFonts.amiri(color: const Color(0xFF1ABC9C), fontWeight: FontWeight.bold),
            underline: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleSetting(String title, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: GoogleFonts.amiri(color: Colors.white, fontSize: 16)),
          Switch(value: value, onChanged: onChanged, activeColor: const Color(0xFF1ABC9C)),
        ],
      ),
    );
  }

  Widget _buildThemeToggle() {
    return _buildToggleSetting('الوضع الليلي', _settings.isDarkMode, 
      (value) => setState(() => _settings = _settings.copyWith(isDarkMode: value)));
  }

  Widget _buildGoalSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, top: 10),
          child: Text('هدف الحفظ اليومي: ٥ آيات', 
            style: GoogleFonts.amiri(color: Colors.white, fontSize: 16)),
        ),
        Slider(
          value: 5,
          min: 1, max: 20, divisions: 19,
          activeColor: const Color(0xFF1ABC9C),
          onChanged: (v) {},
        ),
      ],
    );
  }
}
