import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../../../l10n/app_localizations.dart';
import '../../../core/services/smart_quran_service.dart';
import '../../../core/services/voice_calibration_service.dart';
import '../../../core/services/assistant_service.dart';
import '../../../widgets/islamic_background.dart';

class VoiceCalibrationScreen extends StatefulWidget {
  const VoiceCalibrationScreen({super.key});

  @override
  State<VoiceCalibrationScreen> createState() => _VoiceCalibrationScreenState();
}

class _VoiceCalibrationScreenState extends State<VoiceCalibrationScreen> {
  final SmartQuranService _smartQuran = SmartQuranService();
  final AssistantService _anis = AssistantService();
  
  bool _isListening = false;
  String _recognizedText = "";
  double _similarity = 0.0;
  final String _testVerse = "قُلْ هُوَ اللَّهُ أَحَدٌ اللَّهُ الصَّمَدُ";
  DateTime? _startTime;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    // تأخير طفيف لضمان تحميل الصفحة قبل تحدث أنيس
    Future.delayed(const Duration(milliseconds: 500), () {
      _startCalibrationProcess();
    });
  }

  Future<void> _startCalibrationProcess() async {
    final l10n = AppLocalizations.of(context)!;
    await _anis.speak(l10n.calibrationInstruction);
  }

  void _toggleListening() async {
    if (_isListening) {
      _stopListening();
    } else {
      setState(() {
        _isListening = true;
        _recognizedText = "";
        _startTime = DateTime.now();
      });
      
      await _smartQuran.startListening((text) {
        setState(() {
          _recognizedText = text;
          _similarity = _smartQuran.checkSimilarity(_testVerse, text);
        });

        if (_similarity > 0.8) {
          _finishCalibration();
        }
      });
    }
  }

  void _stopListening() {
    _smartQuran.stopListening();
    setState(() => _isListening = false);
  }

  void _finishCalibration() async {
    final l10n = AppLocalizations.of(context)!;
    _stopListening();
    final duration = DateTime.now().difference(_startTime!);
    await VoiceCalibrationService.calibrateSpeed(_testVerse, _recognizedText, duration);
    
    setState(() => _isCompleted = true);
    await _anis.speak(l10n.calibrationSuccess);
    
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) context.push('/theme-customization');
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return IslamicBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent, 
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => context.pop(),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(l10n.calibration, 
                style: GoogleFonts.amiri(color: const Color(0xFFF5A623), fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(
                _isCompleted ? l10n.resetKhatmaSuccess : l10n.checkingPosition, // استخدام مفاتيح تقريبية حالياً لضمان الترجمة
                style: GoogleFonts.amiri(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 40),
              
              _buildVerseCard(),
              
              const SizedBox(height: 50),
              _buildMicButton(),
              
              const SizedBox(height: 24),
              Text(_isListening ? "..." : l10n.startNow,
                style: GoogleFonts.amiri(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500)),
              
              const SizedBox(height: 40),
              if (_recognizedText.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(_recognizedText, 
                    textAlign: TextAlign.center,
                    style: GoogleFonts.amiri(color: const Color(0xFFF5A623).withOpacity(0.8), fontSize: 20, fontStyle: FontStyle.italic)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerseCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(35),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: _isCompleted ? Colors.green : const Color(0xFFF5A623).withOpacity(0.2), width: 2),
        boxShadow: [
          if (_isCompleted) BoxShadow(color: Colors.green.withOpacity(0.2), blurRadius: 15, spreadRadius: 2)
        ],
      ),
      child: Column(
        children: [
          Text(_testVerse, 
            textAlign: TextAlign.center,
            style: GoogleFonts.amiri(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold, height: 1.8)),
          if (_isCompleted)
            const Padding(
              padding: EdgeInsets.only(top: 20),
              child: Icon(Icons.verified, color: Colors.green, size: 50),
            ),
        ],
      ),
    );
  }

  Widget _buildMicButton() {
    return GestureDetector(
      onTap: _toggleListening,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (_isListening)
            _buildRippleEffect(),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isListening ? Colors.redAccent : const Color(0xFFF5A623),
              boxShadow: [
                BoxShadow(
                  color: (_isListening ? Colors.redAccent : const Color(0xFFF5A623)).withOpacity(0.4),
                  blurRadius: 25,
                  spreadRadius: 5,
                )
              ],
            ),
            child: Icon(_isListening ? Icons.stop : Icons.mic, color: Colors.white, size: 45),
          ),
        ],
      ),
    );
  }

  Widget _buildRippleEffect() {
    return TweenAnimationBuilder(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(seconds: 2),
      builder: (context, double value, child) {
        return Container(
          width: 100 + (value * 50),
          height: 100 + (value * 50),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.redAccent.withOpacity(1 - value), width: 2),
          ),
        );
      },
      onEnd: () => setState(() {}),
    );
  }
}
