import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../l10n/app_localizations.dart'; 
import '../../../core/services/local_storage_service.dart';
import '../../../core/services/settings_service.dart';
import '../../../models/settings_model.dart';
import '../../../widgets/islamic_background.dart';

class ReadingDashboardScreen extends StatefulWidget {
  const ReadingDashboardScreen({super.key});

  @override
  State<ReadingDashboardScreen> createState() => _ReadingDashboardScreenState();
}

class _ReadingDashboardScreenState extends State<ReadingDashboardScreen> {
  DateTime _now = DateTime.now();
  int _lastVerseIndex = 0;
  double _progressPercent = 0.0;
  int _currentDay = 1;
  int _completedKhatmas = 0;
  bool _isLoading = true;
  AppSettings _settings = AppSettings.defaultSettings();
  Timer? _clockTimer;

  @override
  void initState() {
    super.initState();
    _startClock();
    _loadData();
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  void _startClock() {
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final settings = await SettingsService.loadSettings();
    final lastIndex = await LocalStorageService.getReadingProgress();
    final khatmasCount = await LocalStorageService.getCompletedKhatmasCount();
    const totalVerses = 6236;

    setState(() {
      _settings = settings;
      _lastVerseIndex = lastIndex;
      _completedKhatmas = khatmasCount;
      _progressPercent = (lastIndex / totalVerses) * 100;
      final versesPerDay = (totalVerses / _settings.khatmaDuration).ceil();
      _currentDay = (lastIndex / versesPerDay).floor() + 1;
      if (_currentDay > _settings.khatmaDuration) _currentDay = _settings.khatmaDuration;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return IslamicBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text("الختمة بالقراءة", style: GoogleFonts.amiri(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => context.go('/main-menu'),
          ),
        ),
        body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildTimeCard(l10n),
                  const SizedBox(height: 16),
                  _buildProgressCard(l10n),
                  const SizedBox(height: 16),
                  _buildGridSettings(context, l10n),
                  const SizedBox(height: 24),
                  _buildStartReadingButton(context, l10n),
                ],
              ),
            ),
      ),
    );
  }

  Widget _buildTimeCard(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("الوقت الآن", style: const TextStyle(color: Colors.white70, fontSize: 12)),
              Text(DateFormat('HH:mm:ss').format(_now),
                  style: GoogleFonts.notoSans(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            ],
          ),
          const Icon(Icons.auto_stories_outlined, color: Color(0xFFF5A623), size: 35),
        ],
      ),
    );
  }

  Widget _buildProgressCard(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("تقدم الختمة بالقراءة", style: GoogleFonts.amiri(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              Text('${_progressPercent.toStringAsFixed(1)}%', 
                  style: GoogleFonts.notoSans(color: const Color(0xFFF5A623), fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: _progressPercent / 100,
              backgroundColor: Colors.white.withOpacity(0.1),
              color: const Color(0xFFF5A623),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 8),
          Text('اليوم: ${_currentDay}',
              style: GoogleFonts.amiri(color: Colors.white70, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildGridSettings(BuildContext context, AppLocalizations l10n) {
    return Row(
      children: [
        // تعديل: المربع الأوسط يظهر الآن عدد الختمات المكتملة
        Expanded(child: _buildGridItem(title: "عدد الختمات", content: '${_completedKhatmas}', icon: Icons.workspace_premium)),
        const SizedBox(width: 12),
        Expanded(child: _buildGridItem(title: "أذكار الصباح", content: 'ابدأ', icon: Icons.wb_sunny_outlined, onTap: () => context.push('/adhkar'))),
        const SizedBox(width: 12),
        Expanded(child: _buildGridItem(title: "الإعدادات", icon: Icons.settings, onTap: () => context.push('/reading-settings').then((_) => _loadData()))),
      ],
    );
  }

  Widget _buildGridItem({required String title, String? content, IconData? icon, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 110,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12), 
          borderRadius: BorderRadius.circular(20), 
          border: Border.all(color: Colors.white.withOpacity(0.2))
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) Icon(icon, color: Colors.white70, size: 28),
            if (content != null) ...[
              const SizedBox(height: 4),
              Text(content, style: GoogleFonts.amiri(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
            const Spacer(),
            Text(title, textAlign: TextAlign.center, style: GoogleFonts.amiri(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildStartReadingButton(BuildContext context, AppLocalizations l10n) {
    return InkWell(
      onTap: () => context.push('/reading-player'),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFFF5A623), Color(0xFFD48106)]),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: const Color(0xFFF5A623).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            const Icon(Icons.auto_stories, color: Colors.white, size: 48),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("ابدأ القراءة الآن", style: GoogleFonts.amiri(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  Text("أتمم وردك اليومي من كتاب الله بخشوع وتدبر", style: GoogleFonts.amiri(color: Colors.white.withOpacity(0.85), fontSize: 14)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }
}
