import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:projet_aaa_fixed/core/models/quran_data.dart';
import 'package:projet_aaa_fixed/core/services/quran_service.dart';
import 'package:projet_aaa_fixed/core/services/local_storage_service.dart';
import 'package:projet_aaa_fixed/core/services/smart_quran_service.dart';
import 'package:projet_aaa_fixed/core/providers/audio_provider.dart';
import 'package:projet_aaa_fixed/widgets/islamic_background.dart';

class ReadingScreen extends StatefulWidget {
  const ReadingScreen({super.key});

  @override
  State<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen> {
  List<Ayah> _allVerses = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  
  bool _isSmartMentorEnabled = false; 
  bool _hasError = false;
  String _currentVoiceInput = "";
  StreamSubscription? _audioSubscription;
  Timer? _pageFlipTimer;
  double _pageFlipSpeed = 1.0; 

  final SmartQuranService _smartService = SmartQuranService();
  final QuranService _quranService = QuranService();

  @override
  void initState() {
    super.initState();
    _loadQuranAndProgress();
  }

  Future<void> _loadQuranAndProgress() async {
    final verses = await _quranService.getAllVerses(excludeFatiha: false);
    final lastSavedIndex = await LocalStorageService.getQuranProgress();
    
    if (mounted) {
      setState(() {
        _allVerses = verses;
        _currentIndex = lastSavedIndex < verses.length ? lastSavedIndex : 0;
        _isLoading = false;
      });
      _handleVerseActivation();
    }
  }

  @override
  void dispose() {
    _smartService.stopListening();
    _audioSubscription?.cancel();
    _pageFlipTimer?.cancel();
    super.dispose();
  }

  void _handleVerseActivation() async {
    if (_allVerses.isEmpty) return;
    final ayah = _allVerses[_currentIndex];
    final audio = Provider.of<AudioProvider>(context, listen: false);
    
    _smartService.stopListening();
    _audioSubscription?.cancel();
    _pageFlipTimer?.cancel();
    if (mounted) setState(() { _hasError = false; _currentVoiceInput = ""; });

    await audio.playVerse(ayah.surahNumber, ayah.ayahNumber);
    await LocalStorageService.saveQuranProgress(_currentIndex);

    _audioSubscription = audio.onPlayerComplete.listen((_) {
      if (_isSmartMentorEnabled) {
        _startSmartVerification();
      } else {
        _triggerPageFlipDelay();
      }
    });
  }

  void _triggerPageFlipDelay() {
    _pageFlipTimer?.cancel();
    int delayMs = (2000 / _pageFlipSpeed).round();
    _pageFlipTimer = Timer(Duration(milliseconds: delayMs), () => _nextAyah());
  }

  void _startSmartVerification() async {
    await _smartService.startListening((text) {
      if (!mounted) return;
      setState(() => _currentVoiceInput = text);
      if (text.isNotEmpty && _smartService.checkSimilarity(_allVerses[_currentIndex].text, text) > 0.75) {
        _nextAyah();
      }
    });
    
    _pageFlipTimer = Timer(const Duration(seconds: 12), () {
      if (mounted && _isSmartMentorEnabled && _currentVoiceInput.isEmpty) {
        _handleRecitationError();
      }
    });
  }

  void _handleRecitationError() {
    if (_hasError) return;
    setState(() => _hasError = true);
    final audio = Provider.of<AudioProvider>(context, listen: false);
    audio.playVerse(_allVerses[_currentIndex].surahNumber, _allVerses[_currentIndex].ayahNumber);
    Future.delayed(const Duration(seconds: 4), () { if (mounted) setState(() => _hasError = false); });
  }

  void _nextAyah() {
    if (!mounted) return;
    if (_currentIndex < _allVerses.length - 1) {
      setState(() => _currentIndex++);
      _handleVerseActivation();
    } else {
      context.go('/certificate-selector');
    }
  }

  void _previousAyah() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
      _handleVerseActivation();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(backgroundColor: Colors.black, body: Center(child: CircularProgressIndicator(color: Color(0xFFF5A623))));
    final ayah = _allVerses[_currentIndex];
    final audio = Provider.of<AudioProvider>(context);

    return IslamicBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _buildProfessionalAppBar(ayah),
        body: Column(
          children: [
            const SizedBox(height: 10),
            _buildSmartStatusIndicator(),
            _buildAyahDisplay(ayah),
            _buildSmartControlPanel(audio),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSmartStatusIndicator() {
    if (!_isSmartMentorEnabled) return const SizedBox(height: 40);
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: _hasError ? Colors.red.withOpacity(0.2) : (_currentVoiceInput.isNotEmpty ? Colors.green.withOpacity(0.2) : Colors.blue.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _hasError ? Colors.redAccent : (_currentVoiceInput.isNotEmpty ? Colors.greenAccent : Colors.blueAccent), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_hasError ? Icons.warning_amber_rounded : Icons.mic, 
               color: _hasError ? Colors.redAccent : (_currentVoiceInput.isNotEmpty ? Colors.greenAccent : Colors.blueAccent), size: 18),
          const SizedBox(width: 10),
          Text(
            _hasError ? "لم نلتقط القراءة، استمع ثم أعد" : (_currentVoiceInput.isNotEmpty ? "قراءة صحيحة.. جاري الانتقال" : "أنيس يستمع لتلاوتك الآن..."),
            style: GoogleFonts.amiri(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildProfessionalAppBar(Ayah ayah) {
    int estimatedJuz = (ayah.surahNumber / 4).ceil().clamp(1, 30);
    return AppBar(
      backgroundColor: Colors.black45,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white70), onPressed: () => context.pop()),
      title: Column(
        children: [
          Text("سورة ${ayah.surahName}", style: GoogleFonts.amiri(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFFF5A623))),
          Text("الجزء ${_toArabicDigits(estimatedJuz)} - آية ${_toArabicDigits(ayah.ayahNumber)}", 
            style: GoogleFonts.notoSans(fontSize: 12, color: Colors.white70)),
        ],
      ),
      actions: [
        IconButton(icon: const Icon(Icons.info_outline, color: Colors.white38), onPressed: () {}),
      ],
    );
  }

  Widget _buildAyahDisplay(Ayah ayah) {
    return Expanded(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xFFF5A623).withOpacity(0.3), width: 1.5),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20, spreadRadius: 5)],
        ),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Text(
                    ayah.text,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.amiri(
                      fontSize: ayah.text.length > 100 ? 28 : 34, 
                      height: 1.7,
                      color: _hasError ? Colors.redAccent : Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [const Shadow(color: Colors.black, blurRadius: 10)],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xFFF5A623).withOpacity(0.5)),
              ),
              child: Text(_toArabicDigits(ayah.ayahNumber), style: GoogleFonts.amiri(color: const Color(0xFFF5A623), fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmartControlPanel(AudioProvider audio) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildControlIcon(_isSmartMentorEnabled ? Icons.mic : Icons.mic_off, () {
            setState(() => _isSmartMentorEnabled = !_isSmartMentorEnabled);
            _handleVerseActivation();
          }, isActive: _isSmartMentorEnabled),
          
          _buildActionBtn(Icons.skip_previous, _previousAyah),
          
          GestureDetector(
            onTap: _nextAyah,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(color: Color(0xFFF5A623), shape: BoxShape.circle),
              child: const Icon(Icons.arrow_forward_ios, color: Colors.black, size: 24),
            ),
          ),
          
          _buildActionBtn(Icons.speed, () => _showSpeedMenu(audio)),
          
          _buildControlIcon(Icons.auto_stories, () => _showPageFlipMenu(), isActive: _pageFlipSpeed > 1.0),
        ],
      ),
    );
  }

  Widget _buildControlIcon(IconData icon, VoidCallback onTap, {bool isActive = false}) {
    return IconButton(
      icon: Icon(icon, color: isActive ? const Color(0xFFF5A623) : Colors.white60, size: 22),
      onPressed: onTap,
    );
  }

  Widget _buildActionBtn(IconData icon, VoidCallback onTap) {
    return IconButton(icon: Icon(icon, color: Colors.white70, size: 22), onPressed: onTap);
  }

  void _showSpeedMenu(AudioProvider audio) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0D3B2E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => _buildOptionMenu("سرعة المقرئ", [0.5, 0.75, 1.0, 1.25, 1.5], (v) => audio.setPlaybackRate(v), audio.playbackRate),
    );
  }

  void _showPageFlipMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0D3B2E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) {
        return _buildOptionMenu("سرعة القلب التلقائي", [0.5, 1.0, 2.0, 3.0], (v) => setState(() => _pageFlipSpeed = v), _pageFlipSpeed);
      }
    );
  }

  Widget _buildOptionMenu(String title, List<double> options, Function(double) onSelect, double currentVal) {
    return Padding(
      padding: const EdgeInsets.all(25),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: GoogleFonts.amiri(color: const Color(0xFFF5A623), fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Wrap(
            spacing: 15,
            runSpacing: 15,
            children: options.map((o) => ChoiceChip(
              backgroundColor: Colors.white10,
              selectedColor: const Color(0xFFF5A623),
              label: Text("${o}x", style: TextStyle(color: currentVal == o ? Colors.black : Colors.white)),
              selected: currentVal == o,
              onSelected: (selected) { if (selected) { onSelect(o); context.pop(); } },
            )).toList(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  String _toArabicDigits(int n) => n.toString().split('').map((c) => '٠١٢٣٤٥٦٧٨٩'[int.parse(c)]).join();
}
