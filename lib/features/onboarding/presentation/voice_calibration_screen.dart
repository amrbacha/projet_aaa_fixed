import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
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
    _startCalibrationProcess();
  }

  Future<void> _startCalibrationProcess() async {
    await _anis.speak("من فضلك، اقرأ سورة الإخلاص لكي أتعرف على سرعة تلاوتك ونبرة صوتك.");
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
    _stopListening();
    final duration = DateTime.now().difference(_startTime!);
    await VoiceCalibrationService.calibrateSpeed(_testVerse, _recognizedText, duration);
    
    setState(() => _isCompleted = true);
    await _anis.speak("رائع! تم حفظ بصمتك الصوتية بنجاح. سأكون متناغماً معك في الصلاة.");
    
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) context.push('/theme-customization');
    });
  }

  @override
  Widget build(BuildContext context) {
    return IslamicBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("معايرة الصوت", 
                style: GoogleFonts.amiri(color: const Color(0xFFF5A623), fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),
              
              _buildVerseCard(),
              
              const SizedBox(height: 40),
              _buildMicButton(),
              
              const SizedBox(height: 20),
              Text(_isListening ? "أنا أسمعك.. ابدأ القراءة" : "اضغط على الميكروفون وابدأ",
                style: GoogleFonts.amiri(color: Colors.white70, fontSize: 16)),
              
              const SizedBox(height: 40),
              if (_recognizedText.isNotEmpty)
                Text(_recognizedText, 
                  textAlign: TextAlign.center,
                  style: GoogleFonts.amiri(color: Colors.white.withOpacity(0.5), fontSize: 18)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerseCard() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _isCompleted ? Colors.green : const Color(0xFFF5A623).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(_testVerse, 
            textAlign: TextAlign.center,
            style: GoogleFonts.amiri(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          if (_isCompleted)
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: Icon(Icons.check_circle, color: Colors.green, size: 40),
            ),
        ],
      ),
    );
  }

  Widget _buildMicButton() {
    return GestureDetector(
      onTap: _toggleListening,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _isListening ? Colors.redAccent : const Color(0xFFF5A623),
          boxShadow: [
            BoxShadow(
              color: (_isListening ? Colors.redAccent : const Color(0xFFF5A623)).withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 5,
            )
          ],
        ),
        child: Icon(_isListening ? Icons.mic : Icons.mic_none, color: Colors.white, size: 40),
      ),
    );
  }
}
