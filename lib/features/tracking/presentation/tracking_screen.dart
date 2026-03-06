import 'dart:async';
import 'dart:ui' as ui;
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart'; // إضافة الاستيراد الناقص
import '../../../core/providers/theme_provider.dart';
import 'package:flutter_compass/flutter_compass.dart';

import '../../../core/services/prayer_times_service.dart';
import '../../../core/services/settings_service.dart';
import '../../../core/services/wird_service.dart';
import '../../../core/services/quran_service.dart';
import '../../../core/services/local_storage_service.dart';

import '../../../models/quran_progress.dart';
import '../../../models/settings_model.dart';
import '../../../widgets/islamic_background.dart';
import '../../../core/models/quran_data.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  DateTime _now = DateTime.now();
  
  int _lastVerseIndex = 0;
  double _progressPercent = 0.0;
  int _currentDay = 1;
  List<String> _completedPrayers = [];

  Map<String, String> _prayerTimes = {};
  bool _isLoading = true;

  AppSettings _settings = AppSettings.defaultSettings();

  bool _isPrayerTimesLoading = true;
  String? _prayerTimesError;

  Timer? _clockTimer;

  final Map<String, String> _prayerNameTranslations = const {
    'Fajr': 'الفجر', 'Dhuhr': 'الظهر', 'Asr': 'العصر', 'Maghrib': 'المغرب', 'Isha': 'العشاء', 'Sunrise': 'الشروق',
  };

  static const Map<String, String> _fallbackPrayerTimes = {
    'Fajr': '05:34', 'Dhuhr': '12:35', 'Asr': '15:52', 'Maghrib': '18:19', 'Isha': '19:49',
  };

  final WirdService _wirdService = WirdService();
  List<Ayah> _currentWird = [];
  bool _wirdLoadingFailed = false;

  double? _qiblaDirection;

  @override
  void initState() {
    super.initState();
    _startClock();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAllData();
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  void _startClock() {
    _clockTimer?.cancel();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _now = DateTime.now());
    });
  }

  Future<void> _loadAllData() async {
    if (mounted) setState(() => _isLoading = true);
    try {
      final settings = await Provider.of<ThemeProvider>(context, listen: false).settings;
      final lastIndex = await LocalStorageService.getQuranProgress();
      final completed = await LocalStorageService.getCompletedPrayers();
      const totalVerses = 6236;
      
      if (mounted) {
        setState(() {
          _settings = settings;
          _lastVerseIndex = lastIndex;
          _completedPrayers = completed;
          _progressPercent = (lastIndex / totalVerses) * 100;
          final versesPerDay = (totalVerses / _settings.khatmaDuration).ceil();
          _currentDay = (lastIndex / versesPerDay).floor() + 1;
          if (_currentDay > _settings.khatmaDuration) _currentDay = _settings.khatmaDuration;
        });
      }
      
      await _fetchPrayerTimes();
      await _loadWird();
      _calculateQiblaDirection();
      
    } catch (e) {
      debugPrint("Load All Data Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadWird() async {
    try {
      const totalVerses = 6236; 
      final versesPerDay = (totalVerses / _settings.khatmaDuration).ceil();
      final versesPerWird = (versesPerDay / 5).ceil();
      final wird = await _wirdService.getNextWird(versesPerWird);
      if (mounted) {
        setState(() {
          _currentWird = wird;
          _wirdLoadingFailed = wird.isEmpty;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _wirdLoadingFailed = true);
    }
  }

  Future<void> _fetchPrayerTimes() async {
    if (mounted) setState(() => _isPrayerTimesLoading = true);
    try {
      await PrayerTimesService.refreshAndScheduleAllPrayers();
      
      final position = await PrayerTimesService.getCurrentLocation();
      if (position == null) throw Exception("Location Permission Denied");

      final times = await PrayerTimesService.fetchPrayerTimes(
        latitude: position.latitude, 
        longitude: position.longitude
      );

      if (mounted) {
        setState(() {
          _prayerTimes = times ?? Map<String, String>.from(_fallbackPrayerTimes);
          _isPrayerTimesLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Prayer Times Error: $e");
      if (mounted) {
        setState(() {
          _prayerTimes = Map<String, String>.from(_fallbackPrayerTimes);
          _isPrayerTimesLoading = false;
        });
      }
    }
  }

  void _calculateQiblaDirection() async {
    final position = await PrayerTimesService.getCurrentLocation();
    if (position != null) {
      final qibla = PrayerTimesService.calculateQiblaDirection(position.latitude, position.longitude);
      setState(() => _qiblaDirection = qibla);
    }
  }

  String? get _nextUncompletedPrayer {
    final prayersOrder = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    for (String p in prayersOrder) {
      if (!_completedPrayers.contains(p)) return p;
    }
    return null;
  }

  String get _nextPrayerByTime {
    if (_prayerTimes.isEmpty) return 'Fajr';
    final nowInMinutes = _now.hour * 60 + _now.minute;
    final entries = _prayerTimes.entries.where((e) => e.key != 'Sunrise').toList();
    entries.sort((a, b) => _timeToMinutes(a.value).compareTo(_timeToMinutes(b.value)));

    for (final p in entries) {
      if (_timeToMinutes(p.value) > nowInMinutes) {
        return p.key;
      }
    }
    return entries.first.key; 
  }

  int _timeToMinutes(String timeStr) {
    final parts = timeStr.split(':');
    return (int.tryParse(parts[0]) ?? 0) * 60 + (int.tryParse(parts[1]) ?? 0);
  }

  String get _timeRemainingToNextPrayer {
    if (_prayerTimes.isEmpty) return '00:00:00';
    final nowInMinutes = _now.hour * 60 + _now.minute;
    final entries = _prayerTimes.entries.where((e) => e.key != 'Sunrise').toList();
    entries.sort((a, b) => _timeToMinutes(a.value).compareTo(_timeToMinutes(b.value)));
    
    String? nextTimeStr;
    for (final p in entries) {
      if (_timeToMinutes(p.value) > nowInMinutes) {
        nextTimeStr = p.value;
        break;
      }
    }
    nextTimeStr ??= entries.first.value;

    final parts = nextTimeStr.split(':');
    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts[1]) ?? 0;
    DateTime prayerTime = DateTime(_now.year, _now.month, _now.day, h, m);
    if (prayerTime.isBefore(_now)) prayerTime = prayerTime.add(const Duration(days: 1));
    final diff = prayerTime.difference(_now);
    return '${diff.inHours.toString().padLeft(2, '0')}:${(diff.inMinutes % 60).toString().padLeft(2, '0')}:${(diff.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  static const double _containerOpacity = 0.12;
  static const double _containerBorderOpacity = 0.25;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: IslamicBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: Text('مساعد الصلاة', 
              style: GoogleFonts.amiri(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20), 
              onPressed: () => context.go('/main-menu')
            ),
          ),
          body: _isLoading ? const Center(child: CircularProgressIndicator(color: Colors.white)) : _buildBody(context, tt, cs),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, TextTheme tt, ColorScheme cs) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildCompactHeaderCard(tt),
          const SizedBox(height: 16),
          _buildStandaloneQiblaCard(tt),
          const SizedBox(height: 16),
          _buildStandaloneProgressCard(tt),
          const SizedBox(height: 16),
          _buildTripleGrid(context, tt),
          const SizedBox(height: 20),
          _buildPrayerTimesCard(tt, cs),
          const SizedBox(height: 20),
          _buildStartWirdCard(tt, cs),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildCompactHeaderCard(TextTheme tt) {
    final nextByTime = _nextPrayerByTime;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(_containerBorderOpacity)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('الوقت الحالي', style: tt.labelSmall?.copyWith(color: Colors.white70)),
              Text(DateFormat('HH:mm:ss').format(_now),
                  style: GoogleFonts.notoSans(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('الصلاة القادمة', style: tt.labelSmall?.copyWith(color: Colors.white70)),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: const Color(0xFFF5A623).withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                    child: Text(_timeRemainingToNextPrayer, 
                        style: GoogleFonts.notoSans(color: const Color(0xFFF5A623), fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 10),
                  Text(_prayerNameTranslations[nextByTime] ?? nextByTime, 
                      style: GoogleFonts.amiri(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStandaloneQiblaCard(TextTheme tt) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(_containerOpacity),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(_containerBorderOpacity)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.explore_outlined, color: Color(0xFFF5A623), size: 28),
              const SizedBox(width: 12),
              Text('اتجاه القبلة', style: GoogleFonts.amiri(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          _buildQiblaWidget(),
        ],
      ),
    );
  }

  Widget _buildStandaloneProgressCard(TextTheme tt) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('تقدم الختمة', style: GoogleFonts.amiri(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
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
          Text('اليوم الحالي في الرحلة: ${_toArabicDigits(_currentDay)}', 
              style: GoogleFonts.amiri(color: Colors.white70, fontSize: 14)),
        ],
      ),
    );
  }

  String _toArabicDigits(int number) {
    const map = {'0':'٠','1':'١','2':'٢','3':'٣','4':'٤','5':'٥','6':'٦','7':'٧','8':'٨','9':'٩'};
    return number.toString().split('').map((c) => map[c] ?? c).join();
  }

  Widget _buildQiblaWidget() {
    if (_qiblaDirection == null) return const SizedBox(width: 30, height: 30, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2));
    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.heading == null) return const Icon(Icons.location_searching, color: Colors.white, size: 30);
        final qiblaAngle = _qiblaDirection! - snapshot.data!.heading!;
        return Transform.rotate(angle: (qiblaAngle * (math.pi / 180) * -1), child: const Icon(Icons.navigation, color: Colors.white, size: 40));
      },
    );
  }

  Widget _buildTripleGrid(BuildContext context, TextTheme tt) {
    return Row(
      children: [
        Expanded(child: _buildGridItem(tt, title: 'مدة الختمة', content: '${_toArabicDigits(_settings.khatmaDuration)} يوم', icon: Icons.calendar_month)),
        const SizedBox(width: 12),
        Expanded(child: _buildGridItem(tt, title: 'ختمات سابقة', content: '٠', icon: Icons.history_edu)),
        const SizedBox(width: 12),
        Expanded(child: _buildGridItem(tt, title: 'الإعدادات', icon: Icons.settings, onTap: () => context.push('/settings').then((_) => _loadAllData()))),
      ],
    );
  }

  Widget _buildGridItem(TextTheme tt, {required String title, String? content, IconData? icon, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 110,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(_containerOpacity), 
          borderRadius: BorderRadius.circular(20), 
          border: Border.all(color: Colors.white.withOpacity(_containerBorderOpacity))
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

  Widget _buildPrayerTimesCard(TextTheme tt, ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(_containerOpacity), 
        borderRadius: BorderRadius.circular(24), 
        border: Border.all(color: Colors.white.withOpacity(_containerBorderOpacity))
      ),
      child: Column(
        children: [
          Text('مواقيت الصلاة', style: GoogleFonts.amiri(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (_isPrayerTimesLoading) const Center(child: CircularProgressIndicator(color: Colors.white)) else _buildPrayerTimesWrap(tt, cs),
        ],
      ),
    );
  }

  Widget _buildPrayerTimesWrap(TextTheme tt, ColorScheme cs) {
    final entries = _prayerTimes.entries.where((e) => e.key != 'Sunrise').toList();
    entries.sort((a, b) => _timeToMinutes(a.value).compareTo(_timeToMinutes(b.value)));

    return Wrap(
      spacing: 12, runSpacing: 12, alignment: WrapAlignment.center,
      children: entries.map((entry) {
        final isCompleted = _completedPrayers.contains(entry.key);
        
        return InkWell(
          onTap: isCompleted ? null : () {
            context.push('/prayer', extra: {'prayerName': entry.key, 'wird': _currentWird}).then((_) => _loadAllData());
          },
          child: Container(
            width: 95, padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: isCompleted ? const Color(0xFF1E8449).withOpacity(0.8) : Colors.black.withOpacity(0.2), 
              borderRadius: BorderRadius.circular(16), 
              border: Border.all(color: isCompleted ? Colors.transparent : Colors.white.withOpacity(0.15))
            ),
            child: Column(
              children: [
                Text(_prayerNameTranslations[entry.key] ?? entry.key, 
                    style: GoogleFonts.amiri(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(isCompleted ? 'تمت' : entry.value, 
                    style: GoogleFonts.notoSans(color: isCompleted ? Colors.white70 : Colors.white, fontSize: 14)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStartWirdCard(TextTheme tt, ColorScheme cs) {
    final nextPrayer = _nextUncompletedPrayer;
    final bool allCompleted = nextPrayer == null;

    return InkWell(
      onTap: (allCompleted || _currentWird.isEmpty) ? null : () {
        context.push('/prayer', extra: {'prayerName': nextPrayer, 'wird': _currentWird}).then((_) => _loadAllData());
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(color: (allCompleted ? Colors.black.withOpacity(0.24) : const Color(0xFF1ABC9C)).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))
          ],
          gradient: LinearGradient(
            colors: allCompleted 
              ? [Colors.white.withOpacity(0.2), Colors.white.withOpacity(0.1)] 
              : [const Color(0xFF1ABC9C), const Color(0xFF16A085)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24)
        ),
        child: Row(
          children: [
            Icon(allCompleted ? Icons.check_circle_rounded : Icons.menu_book_rounded, color: Colors.white, size: 48),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(allCompleted ? 'أتممت صلوات اليوم' : 'ابدأ صلاة ${(_prayerNameTranslations[nextPrayer] ?? nextPrayer!)}', 
                      style: GoogleFonts.amiri(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(allCompleted ? 'تقبل الله طاعاتكم وغفر لنا ولكم' : (_currentWird.isEmpty ? 'جاري تحضير وردك...' : 'وردك القرآني جاهز. اضغط للبدء.'), 
                      style: GoogleFonts.amiri(color: Colors.white.withOpacity(0.85), fontSize: 14)),
                ],
              ),
            ),
            if (!allCompleted) const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }
}
