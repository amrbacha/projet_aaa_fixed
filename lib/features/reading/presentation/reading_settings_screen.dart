import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projet_aaa/core/providers/audio_provider.dart';
import 'package:projet_aaa/core/providers/theme_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/services/settings_service.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../models/settings_model.dart';
import '../../../widgets/islamic_background.dart';

class ReadingSettingsScreen extends StatefulWidget {
  const ReadingSettingsScreen({super.key});

  @override
  State<ReadingSettingsScreen> createState() => _ReadingSettingsScreenState();
}

class _ReadingSettingsScreenState extends State<ReadingSettingsScreen> {
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
        const SnackBar(content: Text('تم حفظ إعدادات الختمة بنجاح')),
      );
      context.pop(true);
    }
  }

  Future<void> _resetKhatma() async {
    bool confirm = await _showConfirmDialog('تصفير الختمة', 'هل أنت متأكد من تصفير تقدم الختمة والبدء من جديد؟');
    if (confirm) {
      await LocalStorageService.saveQuranProgress(0);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تصفير الختمة بنجاح')));
      }
    }
  }

  Future<bool> _showConfirmDialog(String title, String content) async {
    return await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0D3B2E),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: Text(content, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('إلغاء', style: TextStyle(color: Colors.white))),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('تأكيد', style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    ) ?? false;
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

    final tt = Theme.of(context).textTheme;

    return IslamicBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
          centerTitle: true,
          title: Text('إعدادات ختمة القراءة', 
            style: GoogleFonts.amiri(fontSize: 24, fontWeight: FontWeight.bold)
          ),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            children: [
              _buildSettingsCard(
                tt,
                title: 'التخصيص والختمة',
                children: [
                  _buildThemeToggle(tt),
                  const Divider(color: Colors.white10),
                  _buildKhatmaDurationSlider(tt),
                  const Divider(color: Colors.white10),
                  _buildDropdownSetting('القارئ المساعد', _settings.qari, 
                    {
                      'mishary': 'مشاري العفاسي',
                      'sudais': 'عبد الرحمن السديس',
                      'ghamdi': 'سعد الغامدي',
                      'basit': 'عبد الباسط عبد الصمد',
                      'husary': 'محمود خليل الحصري',
                      'minshawi': 'محمد صديق المنشاوي',
                      'muaiqly': 'ماهر المعيقلي',
                      'tablawi': 'محمد محمود الطبلاوي',
                      'shuraim': 'سعود الشريم',
                    }, 
                    (v) => setState(() => _settings = _settings.copyWith(qari: v!))),
                ],
              ),
              const SizedBox(height: 20),

              _buildSettingsCard(
                tt,
                title: 'إدارة البيانات والتقدم',
                children: [
                  _buildResetButton('تصفير تقدم الختمة والقراءة', Icons.restart_alt, _resetKhatma),
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
                    elevation: 4,
                  ),
                  onPressed: _saveSettings,
                  child: Text('حفظ الإعدادات والبدء', 
                    style: GoogleFonts.amiri(fontSize: 20, fontWeight: FontWeight.bold)
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsCard(TextTheme tt, {required String title, required List<Widget> children}) {
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

  Widget _buildThemeToggle(TextTheme tt) {
    return _buildToggleSetting('الوضع الليلي', _settings.isDarkMode, 
      (value) => setState(() => _settings = _settings.copyWith(isDarkMode: value)));
  }

  Widget _buildKhatmaDurationSlider(TextTheme tt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, top: 10),
          child: Text('مدة ختم القرآن: ${_settings.khatmaDuration} يوم', 
            style: GoogleFonts.amiri(color: Colors.white, fontSize: 16)),
        ),
        Slider(
          value: _settings.khatmaDuration.toDouble(),
          min: 7, max: 365, divisions: 50,
          activeColor: const Color(0xFF1ABC9C),
          onChanged: (v) => setState(() => _settings = _settings.copyWith(khatmaDuration: v.round())),
        ),
      ],
    );
  }

  Widget _buildResetButton(String label, IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFF5A623), size: 24),
            const SizedBox(width: 15),
            Text(label, style: GoogleFonts.amiri(color: Colors.white, fontSize: 16)),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 14),
          ],
        ),
      ),
    );
  }
}
