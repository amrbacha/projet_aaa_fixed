import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:projet_aaa/core/models/quran_data.dart';
import 'package:projet_aaa/core/services/quran_service.dart';
import 'package:projet_aaa/core/services/local_storage_service.dart';
import 'package:projet_aaa/core/services/smart_quran_service.dart';
import 'package:projet_aaa/core/providers/audio_provider.dart';

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
    setState(() { _hasError = false; _currentVoiceInput = ""; });

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
    int delayMs = (1000 / _pageFlipSpeed).round();
    _pageFlipTimer = Timer(Duration(milliseconds: delayMs), () => _nextAyah());
  }

  void _startSmartVerification() async {
    await _smartService.startListening((text) {
      if (!mounted) return;
      setState(() => _currentVoiceInput = text);
      if (text.isNotEmpty && _smartService.checkSimilarity(_allVerses[_currentIndex].text, text) > 0.6) {
        _nextAyah();
      }
    });
    
    _pageFlipTimer = Timer(const Duration(seconds: 8), () {
      if (mounted && _isSmartMentorEnabled && _currentVoiceInput.isEmpty) {
        _handleRecitationError();
      }
    });
  }

  void _handleRecitationError() {
    if (_hasError) return;
    setState(() => _hasError = true);
    final audio = Provider.of<AudioProvider>(context, listen: false);
    final ayah = _allVerses[_currentIndex];
    audio.playVerse(ayah.surahNumber, ayah.ayahNumber);
    
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('أعد القراءة مع المقرئ لتصحيح النطق', textAlign: TextAlign.center), backgroundColor: Colors.redAccent, duration: Duration(seconds: 2)));
    Future.delayed(const Duration(seconds: 3), () { if (mounted) setState(() => _hasError = false); });
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
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final ayah = _allVerses[_currentIndex];
    final audio = Provider.of<AudioProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      body: Stack(
        children: [
          Positioned.fill(top: 5, bottom: 95, child: CustomPaint(painter: LuxuryIslamicFramePainter())),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 45, right: 45),
                  child: _buildSurahCombinedHeader(ayah),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 0),
                  child: Row(
                    children: [
                      IconButton(icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1B5E20), size: 20), onPressed: _previousAyah),
                      Expanded(child: Text("سورة ${ayah.surahName}", textAlign: TextAlign.center, style: GoogleFonts.amiri(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF1B5E20)))),
                      IconButton(icon: const Icon(Icons.close, color: Color(0xFF1B5E20), size: 24), onPressed: () => context.pop()),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 55),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_isSmartMentorEnabled)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Text(_hasError ? "⚠️ أعد مع المقرئ" : "🎤 استماع نشط...", 
                                style: TextStyle(color: _hasError ? Colors.red : Colors.blue, fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "(${_toArabicDigits(ayah.ayahNumber)}) ",
                                  style: GoogleFonts.amiri(fontSize: 24, color: const Color(0xFFB71C1C), fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text: ayah.text,
                                  style: GoogleFonts.amiri(fontSize: 32, height: 1.8, color: _hasError ? Colors.red : const Color(0xFF1B5E20), fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
                _buildUnifiedBottomPanel(audio),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSurahCombinedHeader(Ayah ayah) {
    int estimatedJuz = (ayah.surahNumber / 4).ceil().clamp(1, 30);
    return Container(
      width: double.infinity, height: 85,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(size: const Size(double.infinity, 85), painter: SurahTitlePainter()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("الجزء ${_toArabicDigits(estimatedJuz)}", style: GoogleFonts.amiri(fontSize: 14, color: const Color(0xFF1B5E20), fontWeight: FontWeight.bold)),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("ختمة القراءة", textAlign: TextAlign.center, style: GoogleFonts.amiri(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFFB71C1C))),
                      Text("آية ${_toArabicDigits(ayah.ayahNumber)}", style: GoogleFonts.amiri(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1B5E20))),
                    ],
                  ),
                ),
                Text("سورة ${ayah.surahName}", style: GoogleFonts.amiri(fontSize: 14, color: const Color(0xFF1B5E20), fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnifiedBottomPanel(AudioProvider audio) {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 15),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: const Color(0xFF1B5E20).withOpacity(0.9), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(children: [
            const Text('المعلم', style: TextStyle(color: Colors.white, fontSize: 11)),
            Transform.scale(scale: 0.7, child: Switch(value: _isSmartMentorEnabled, onChanged: (v) { setState(() => _isSmartMentorEnabled = v); _handleVerseActivation(); }, activeColor: Colors.orangeAccent)),
          ]),
          Container(height: 20, width: 1, color: Colors.white24),
          PopupMenuButton<double>(
            initialValue: audio.playbackRate,
            onSelected: (v) => audio.setPlaybackRate(v),
            child: Row(children: [const Icon(Icons.speed, color: Colors.white, size: 16), Text(' ${audio.playbackRate}x', style: const TextStyle(color: Colors.white, fontSize: 11))]),
            itemBuilder: (context) => [0.5, 0.75, 1.0, 1.25, 1.5].map((s) => PopupMenuItem(value: s, child: Text('${s}x'))).toList(),
          ),
          Container(height: 20, width: 1, color: Colors.white24),
          PopupMenuButton<double>(
            initialValue: _pageFlipSpeed,
            onSelected: (v) => setState(() => _pageFlipSpeed = v),
            child: Row(children: [const Icon(Icons.auto_awesome_motion, color: Colors.white, size: 16), Text(' قلب:${_pageFlipSpeed}x', style: const TextStyle(color: Colors.white, fontSize: 11))]),
            itemBuilder: (context) => [0.5, 1.0, 2.0, 3.0, 5.0].map((s) => PopupMenuItem(value: s, child: Text('سرعة ${s}x'))).toList(),
          ),
          Container(height: 20, width: 1, color: Colors.white24),
          IconButton(onPressed: _nextAyah, icon: const Icon(Icons.skip_next, color: Color(0xFFC19A6B), size: 28)),
        ],
      ),
    );
  }

  String _toArabicDigits(int n) => n.toString().split('').map((c) => '٠١٢٣٤٥٦٧٨٩'[int.parse(c)]).join();
}

class LuxuryIslamicFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gold = Paint()..color = const Color(0xFFC19A6B)..style = PaintingStyle.stroke..strokeWidth = 2;
    canvas.drawRect(Rect.fromLTWH(10, 10, size.width - 20, size.height - 20), gold);
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class SurahTitlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gold = Paint()..color = const Color(0xFFC19A6B)..style = PaintingStyle.stroke..strokeWidth = 2;
    final bg = Paint()..color = const Color(0xFFF1F8E9)..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bg);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), gold);
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
