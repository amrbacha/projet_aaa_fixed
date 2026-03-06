import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projet_aaa/core/providers/audio_provider.dart';
import 'package:projet_aaa/core/providers/theme_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/services/settings_service.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../core/services/prayer_times_service.dart';
import '../../../models/settings_model.dart';
import '../../../widgets/islamic_background.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late AppSettings _settings;
  bool _isLoading = true;
  bool _isUpdatingLocation = false;

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

    await PrayerTimesService.refreshAndScheduleAllPrayers();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ الإعدادات وتحديث التنبيهات')),
      );
      context.pop(true);
    }
  }

  Future<void> _updateLocationManually() async {
    setState(() => _isUpdatingLocation = true);
    try {
      await PrayerTimesService.refreshAndScheduleAllPrayers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تحديث الموقع وأوقات الصلاة بنجاح')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل تحديث الموقع، يرجى التأكد من الصلاحيات')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdatingLocation = false);
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

  Future<void> _resetDailyPrayers() async {
    bool confirm = await _showConfirmDialog('تصفير صلوات اليوم', 'هل أنت متأكد من مسح صلوات اليوم وإعادتها؟');
    if (confirm) {
       await _clearTodayPrayers();
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تصفير صلوات اليوم بنجاح')));
       }
    }
  }

  Future<void> _clearTodayPrayers() async {
     final prefs = await SharedPreferences.getInstance();
     final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
     await prefs.remove('completed_prayers_$today');
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
          title: Text('الإعدادات الشاملة', 
            style: GoogleFonts.amiri(fontSize: 24, fontWeight: FontWeight.bold)
          ),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            children: [
              _buildCameraSection(tt),
              const SizedBox(height: 20),
              _buildLocationSection(tt),
              const SizedBox(height: 20),

              _buildSettingsCard(
                tt,
                title: 'إعدادات الصلاة والتنبيهات',
                children: [
                  _buildToggleSetting('تنبيهات الأذان', _settings.athanNotifications, 
                    (v) => setState(() => _settings = _settings.copyWith(athanNotifications: v))),
                  const Divider(color: Colors.white10),
                  _buildDropdownSetting('صوت الأذان المفضل', _settings.adhanVoice, 
                    {'makkah': 'أذان مكة', 'madina': 'أذان المدينة', 'quds': 'أذان القدس'}, 
                    (v) => setState(() => _settings = _settings.copyWith(adhanVoice: v!))),
                  const Divider(color: Colors.white10),
                  _buildToggleSetting('تنبيه قبل الصلاة', _settings.prePrayerReminder, 
                    (v) => setState(() => _settings = _settings.copyWith(prePrayerReminder: v))),
                  if (_settings.prePrayerReminder)
                    _buildReminderMinutesSlider(tt),
                  const Divider(color: Colors.white10),
                  _buildDropdownSetting('طريقة حساب المواقيت', _settings.calculationMethod.toString(), 
                    {'5': 'الهيئة المصرية', '4': 'أم القرى', '3': 'رابطة العالم الإسلامي', '2': 'الجمعية الإسلامية لأمريكا'}, 
                    (v) => setState(() => _settings = _settings.copyWith(calculationMethod: int.parse(v!)))),
                ],
              ),
              const SizedBox(height: 20),

              _buildSettingsCard(
                tt,
                title: 'التخصيص والختمة',
                children: [
                  _buildThemeToggle(tt),
                  const Divider(color: Colors.white10),
                  _buildKhatmaDurationSlider(tt),
                  const Divider(color: Colors.white10),
                  _buildDropdownSetting('القارئ المفضل', _settings.qari, 
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
                  _buildResetButton('تصفير تقدم الختمة', Icons.restart_alt, _resetKhatma),
                  const Divider(color: Colors.white10),
                  _buildResetButton('تصفير صلوات اليوم', Icons.history, _resetDailyPrayers),
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
                  child: Text('حفظ جميع التغييرات', 
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

  Widget _buildLocationSection(TextTheme tt) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(_containerBorderOpacity)),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: Color(0xFFF5A623), size: 30),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('الموقع الجغرافي', style: GoogleFonts.amiri(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Text('لتحديد مواقيت الصلاة بدقة', style: GoogleFonts.amiri(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
          if (_isUpdatingLocation)
            const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
          else
            TextButton(
              onPressed: _updateLocationManually,
              child: Text('تحديث الآن', style: GoogleFonts.amiri(color: const Color(0xFF1ABC9C), fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }

  Widget _buildReminderMinutesSlider(TextTheme tt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          child: Text('التنبيه قبل بـ ${_settings.prePrayerReminderMinutes} دقيقة', 
            style: GoogleFonts.amiri(color: Colors.white70, fontSize: 14)),
        ),
        Slider(
          value: _settings.prePrayerReminderMinutes.toDouble(),
          min: 5, max: 30, divisions: 5,
          activeColor: const Color(0xFFF5A623),
          onChanged: (v) => setState(() => _settings = _settings.copyWith(prePrayerReminderMinutes: v.round())),
        ),
      ],
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
    // صمام أمان: إذا كانت القيمة المختارة غير موجودة في القائمة، نختار القيمة الأولى تلقائياً لمنع الخطأ الأحمر
    String effectiveValue = items.containsKey(value) ? value : items.keys.first;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: GoogleFonts.amiri(color: Colors.white, fontSize: 16)),
          DropdownButton<String>(
            value: effectiveValue,
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

  Widget _buildCameraSection(TextTheme tt) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(_containerBorderOpacity))
      ),
      child: Column(
        children: [
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('تحليل وضعية الجسم (AI)', style: GoogleFonts.amiri(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(width: 12),
              const Icon(Icons.psychology, color: Colors.white, size: 24),
            ]),
            const SizedBox(height: 15),
            Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('متابعة وتصحيح الوضعية', style: GoogleFonts.amiri(color: Colors.white, fontSize: 16)),
              Switch(
                value: _settings.isCameraOn,
                onChanged: (val) => setState(() => _settings = _settings.copyWith(isCameraOn: val)),
                activeColor: const Color(0xFF1ABC9C),
              ),
            ],
          )
        ],
      ),
    );
  }
}
