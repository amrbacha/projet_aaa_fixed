import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:projet_aaa/core/models/quran_data.dart';
import 'package:projet_aaa/core/providers/audio_provider.dart';
import 'package:projet_aaa/widgets/islamic_background.dart';

class MemorizationSessionScreen extends StatefulWidget {
  final Surah surah;
  const MemorizationSessionScreen({super.key, required this.surah});

  @override
  State<MemorizationSessionScreen> createState() => _MemorizationSessionScreenState();
}

class _MemorizationSessionScreenState extends State<MemorizationSessionScreen> {
  int _currentAyahIndex = 0;
  int _repeatCount = 1;
  int _currentRepeat = 0;
  bool _isHidingText = false;
  bool _isPlaying = false;

  void _nextAyah() {
    if (_currentAyahIndex < widget.surah.verses.length - 1) {
      setState(() {
        _currentAyahIndex++;
        _currentRepeat = 0;
        _isHidingText = false;
      });
      if (_isPlaying) _playCurrentVerse();
    }
  }

  void _previousAyah() {
    if (_currentAyahIndex > 0) {
      setState(() {
        _currentAyahIndex--;
        _currentRepeat = 0;
        _isHidingText = false;
      });
      if (_isPlaying) _playCurrentVerse();
    }
  }

  void _playCurrentVerse() async {
    final audio = Provider.of<AudioProvider>(context, listen: false);
    final currentAyah = widget.surah.verses[_currentAyahIndex];
    setState(() => _isPlaying = true);
    
    await audio.playVerse(currentAyah.surahNumber, currentAyah.ayahNumber);
    
    audio.onPlayerComplete.first.then((_) {
      if (!mounted) return;
      if (_currentRepeat < _repeatCount - 1) {
        setState(() => _currentRepeat++);
        _playCurrentVerse();
      } else {
        setState(() {
          _isPlaying = false;
          _currentRepeat = 0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentAyah = widget.surah.verses[_currentAyahIndex];
    final progress = (_currentAyahIndex + 1) / widget.surah.verses.length;

    return IslamicBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(widget.surah.surahName, 
            style: GoogleFonts.amiri(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Column(
          children: [
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white10,
              color: const Color(0xFFF5A623),
              minHeight: 6,
            ),
            const SizedBox(height: 20),
            _buildAyahDisplay(currentAyah),
            const Spacer(),
            _buildControls(),
            _buildActionPanel(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildAyahDisplay(Ayah ayah) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(30),
      constraints: const BoxConstraints(minHeight: 250),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFC19A6B).withOpacity(0.3)),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20)],
      ),
      child: Center(
        child: AnimatedOpacity(
          opacity: _isHidingText ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 500),
          child: Text(
            ayah.text,
            textAlign: TextAlign.center,
            style: GoogleFonts.amiri(
              color: Colors.white,
              fontSize: 28,
              height: 1.8,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildRepeatBadge(),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.skip_next, color: Colors.white, size: 36),
                onPressed: _previousAyah, // في العربية التالي هو السابق بصرياً
              ),
              GestureDetector(
                onTap: () {
                  if (_isPlaying) {
                    Provider.of<AudioProvider>(context, listen: false).stop();
                    setState(() => _isPlaying = false);
                  } else {
                    _playCurrentVerse();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: const BoxDecoration(color: Color(0xFFF5A623), shape: BoxShape.circle),
                  child: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 40),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.skip_previous, color: Colors.white, size: 36),
                onPressed: _nextAyah,
              ),
            ],
          ),
          Text('آية ${_toArabicDigits(_currentAyahIndex + 1)}', 
            style: GoogleFonts.amiri(color: const Color(0xFFC19A6B), fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildRepeatBadge() {
    return PopupMenuButton<int>(
      initialValue: _repeatCount,
      onSelected: (v) => setState(() => _repeatCount = v),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          children: [
            const Icon(Icons.repeat, color: Color(0xFFF5A623), size: 18),
            const SizedBox(width: 5),
            Text('${_toArabicDigits(_repeatCount)} مرات', style: GoogleFonts.amiri(color: Colors.white, fontSize: 14)),
          ],
        ),
      ),
      itemBuilder: (context) => [1, 3, 5, 10].map((n) => PopupMenuItem(value: n, child: Text('تكرار $n مرات'))).toList(),
    );
  }

  Widget _buildActionPanel() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            icon: _isHidingText ? Icons.visibility : Icons.visibility_off,
            label: _isHidingText ? 'إظهار' : 'اختبار',
            onTap: () => setState(() => _isHidingText = !_isHidingText),
          ),
          _buildActionButton(
            icon: Icons.check_circle_outline,
            label: 'حفظت',
            onTap: () {
              HapticFeedback.heavyImpact();
              _nextAyah();
            },
          ),
          _buildActionButton(
            icon: Icons.mic_none,
            label: 'تسميع',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ميزة التسميع الذكي ستتوفر في التحديث القادم')));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFFC19A6B), size: 28),
          const SizedBox(height: 4),
          Text(label, style: GoogleFonts.amiri(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  String _toArabicDigits(int n) => n.toString().split('').map((c) => '٠١٢٣٤٥٦٧٨٩'[int.parse(c)]).join();
}
