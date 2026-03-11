import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/services/prayer_times_service.dart';
import '../../../core/services/wird_service.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../core/services/assistant_service.dart';
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
  int _completedKhatmas = 0;
  Map<String, String> _prayerTimes = {};
  List<String> _completedPrayers = [];
  bool _isLoading = true;
  AppSettings _settings = AppSettings.defaultSettings();
  Timer? _clockTimer;
  final WirdService _wirdService = WirdService();
  List<Ayah> _currentWird = [];
  final AssistantService _anis = AssistantService();
  bool _hasMotivated = false;

  @override
  void initState() {
    super.initState();
    _startClock();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAllData());
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

  Future<void> _loadAllData() async {
    if (mounted) setState(() => _isLoading = true);
    try {
      final settings = Provider.of<ThemeProvider>(context, listen: false).settings;
      final lastIndex = await LocalStorageService.getPrayerProgress();
      final completed = await LocalStorageService.getCompletedPrayers();
      final khatmasCount = await LocalStorageService.getCompletedKhatmasCount();
      const totalVerses = 6236;
      
      setState(() {
        _settings = settings;
        _lastVerseIndex = lastIndex;
        _completedPrayers = completed;
        _completedKhatmas = khatmasCount;
        _progressPercent = (lastIndex / totalVerses) * 100;
        final versesPerDay = (totalVerses / _settings.khatmaDuration).ceil();
        _currentDay = (lastIndex / versesPerDay).floor() + 1;
        if (_currentDay > _settings.khatmaDuration) _currentDay = _settings.khatmaDuration;
      });
      
      await _fetchPrayerTimes();
      await _loadWird();
      
      if (!_hasMotivated) {
        _hasMotivated = true;
        _showInitialMotivation();
      }
    } catch (e) {
      debugPrint("Load Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showInitialMotivation() async {
    final userData = await LocalStorageService.getUserData();
    final name = userData['fullName'] ?? "";
    _anis.giveSmartAdvice(userName: name, progress: _progressPercent);
  }

  Future<void> _loadWird() async {
    const totalVerses = 6236; 
    final versesPerDay = (totalVerses / _settings.khatmaDuration).ceil();
    final wird = await _wirdService.getNextWird((versesPerDay / 5).ceil());
    if (mounted) setState(() => _currentWird = wird);
  }

  Future<void> _fetchPrayerTimes() async {
    final position = await PrayerTimesService.getCurrentLocation();
    if (position == null) return;
    final times = await PrayerTimesService.fetchPrayerTimes(latitude: position.latitude, longitude: position.longitude);
    if (mounted) setState(() => _prayerTimes = times ?? {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return IslamicBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.black26,
          elevation: 0,
          centerTitle: true,
          title: Text("الختمة بالصلاة", style: GoogleFonts.amiri(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white), onPressed: () => context.go('/main-menu')),
          actions: const [],
        ),
        body: _isLoading ? const Center(child: CircularProgressIndicator(color: Color(0xFFF5A623))) : _buildBody(l10n),
      ),
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          _buildPrayerCountdownCard(l10n),
          const SizedBox(height: 20),
          _buildKhatmaProgressCard(l10n),
          const SizedBox(height: 20),
          _buildQuickStatsGrid(l10n),
          const SizedBox(height: 20),
          _buildPrayerTimesPanel(l10n),
          const SizedBox(height: 20),
          _buildActionCard(l10n),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildPrayerCountdownCard(AppLocalizations l10n) {
    final nextPrayer = _getNextPrayerKey();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(25), border: Border.all(color: Colors.white10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("الصلاة القادمة", style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14)),
              const SizedBox(height: 5),
              Text(_getPrayerTranslation(l10n, nextPrayer), style: GoogleFonts.amiri(color: const Color(0xFFF5A623), fontSize: 28, fontWeight: FontWeight.bold)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(DateFormat('HH:mm:ss').format(_now), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w300)),
              const SizedBox(height: 5),
              Text("متبقي: ${_getTimeRemaining(nextPrayer)}", style: const TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKhatmaProgressCard(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(25), border: Border.all(color: Colors.white10)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("${_progressPercent.toStringAsFixed(1)}%", style: const TextStyle(color: Color(0xFFF5A623), fontSize: 20, fontWeight: FontWeight.bold)),
              Text("تقدم الختمة", style: GoogleFonts.amiri(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 15),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(value: _progressPercent / 100, backgroundColor: Colors.white10, color: const Color(0xFFF5A623), minHeight: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatsGrid(AppLocalizations l10n) {
    return Row(
      children: [
        _buildStatItem("مدة الختمة", "${_settings.khatmaDuration} يوم", Icons.calendar_today),
        const SizedBox(width: 15),
        // تعديل: وضع إحصائية الختمات مكان زر "ابدأ"
        _buildStatItem("إجمالي الختمات", "${_completedKhatmas}", Icons.workspace_premium),
        const SizedBox(width: 15),
        // تعديل: تغيير "ضبط" إلى "الاعدادات" (كنص كبير)
        _buildStatItem("الاعدادات", "ضبط", Icons.settings, onTap: () => context.push('/settings').then((_) => _loadAllData())),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, {VoidCallback? onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white10)),
          child: Column(
            children: [
              Icon(icon, color: Colors.white70, size: 24),
              const SizedBox(height: 8),
              Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              Text(label, textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrayerTimesPanel(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.white10)),
      child: Column(
        children: [
          Text("مواقيت الصلاة", style: GoogleFonts.amiri(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _prayerTimes.isEmpty 
              ? const CircularProgressIndicator(color: Color(0xFFF5A623))
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 1.5, crossAxisSpacing: 10, mainAxisSpacing: 10),
                  itemCount: _prayerTimes.length,
                  itemBuilder: (context, index) {
                    final key = _prayerTimes.keys.elementAt(index);
                    final isCompleted = _completedPrayers.contains(key);
                    final isNext = !isCompleted && key.toLowerCase() == _getNextPrayerKey().toLowerCase();
                    
                    return InkWell(
                      onTap: isCompleted ? null : () => _startPrayerFlow(key, l10n),
                      borderRadius: BorderRadius.circular(15),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isCompleted 
                              ? Colors.green.withOpacity(0.3)
                              : (isNext ? const Color(0xFFF5A623).withOpacity(0.2) : Colors.white.withOpacity(0.05)),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: isCompleted ? Colors.green : (isNext ? const Color(0xFFF5A623) : Colors.transparent)),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center, 
                          children: [
                            Text(_getPrayerTranslation(l10n, key), 
                              style: TextStyle(
                                color: isCompleted ? Colors.greenAccent : (isNext ? const Color(0xFFF5A623) : Colors.white70), 
                                fontSize: 14, 
                                fontWeight: FontWeight.bold)),
                            Text(_prayerTimes[key]!, style: TextStyle(color: isCompleted ? Colors.white60 : Colors.white, fontSize: 12)),
                            if (isCompleted) const Icon(Icons.check_circle, color: Colors.greenAccent, size: 14),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  void _startPrayerFlow(String prayerKey, AppLocalizations l10n) {
    context.push('/prayer', extra: {'prayerName': _getPrayerTranslation(l10n, prayerKey), 'wird': _currentWird}).then((_) => _loadAllData());
  }

  Widget _buildActionCard(AppLocalizations l10n) {
    final nextPrayer = _getNextPrayerKey();
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF00796B), Color(0xFF004D40)]), borderRadius: BorderRadius.circular(25)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _startPrayerFlow(nextPrayer, l10n),
          borderRadius: BorderRadius.circular(25),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
            child: Row(
              children: [
                const Icon(Icons.play_circle_fill, color: Colors.white, size: 40),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("ابدأ الصلاة الآن", style: GoogleFonts.amiri(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      Text("أهلاً بك في رحاب الطاعة، اختر وجهتك اليوم لنرتقي سوياً في درجات الإيمان", style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getNextPrayerKey() {
    final hour = _now.hour;
    if (hour >= 5 && hour < 12) return "Dhuhr";
    if (hour >= 12 && hour < 15) return "Asr";
    if (hour >= 15 && hour < 18) return "Maghrib";
    if (hour >= 18 && hour < 20) return "Isha";
    return "Fajr";
  }

  String _getTimeRemaining(String prayer) {
    if (_prayerTimes[prayer] == null) return "00:00:00";
    final parts = _prayerTimes[prayer]!.split(':');
    final pTime = DateTime(_now.year, _now.month, _now.day, int.parse(parts[0]), int.parse(parts[1]));
    final diff = pTime.isAfter(_now) ? pTime.difference(_now) : const Duration(hours: 0);
    return "${diff.inHours.toString().padLeft(2, '0')}:${(diff.inMinutes % 60).toString().padLeft(2, '0')}:${(diff.inSeconds % 60).toString().padLeft(2, '0')}";
  }

  String _getPrayerTranslation(AppLocalizations l10n, String key) {
    switch (key.toLowerCase()) {
      case 'fajr': return l10n.fajr;
      case 'dhuhr': return l10n.dhuhr;
      case 'asr': return l10n.asr;
      case 'maghrib': return l10n.maghrib;
      case 'isha': return l10n.isha;
      default: return key;
    }
  }
}
