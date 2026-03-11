import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:projet_aaa_fixed/widgets/islamic_background.dart';
import '../data/models/asma_model.dart';
import '../data/asma_data.dart';

class AsmaQuizScreen extends StatefulWidget {
  const AsmaQuizScreen({super.key});

  @override
  State<AsmaQuizScreen> createState() => _AsmaQuizScreenState();
}

class _AsmaQuizScreenState extends State<AsmaQuizScreen> {
  late List<AsmaAllah> allAsma;
  int currentQuestionIndex = 0;
  int score = 0;
  late AsmaAllah currentAsma;
  late List<String> options;
  bool? isCorrect;
  bool answered = false;

  @override
  void initState() {
    super.initState();
    allAsma = rawAsmaAllah.map((e) => AsmaAllah.fromJson(e)).toList();
    _generateQuestion();
  }

  void _generateQuestion() {
    currentAsma = allAsma[Random().nextInt(allAsma.length)];
    List<String> wrongOptions = allAsma
        .where((e) => e.id != currentAsma.id)
        .map((e) => e.meaning)
        .toList();
    wrongOptions.shuffle();
    
    options = [currentAsma.meaning, ...wrongOptions.take(3)];
    options.shuffle();
    
    setState(() {
      answered = false;
      isCorrect = null;
    });
  }

  void _checkAnswer(String selected) {
    if (answered) return;
    setState(() {
      answered = true;
      isCorrect = (selected == currentAsma.meaning);
      if (isCorrect!) score++;
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (currentQuestionIndex < 9) {
        setState(() {
          currentQuestionIndex++;
          _generateQuestion();
        });
      } else {
        _showResults();
      }
    });
  }

  void _showResults() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0D3B2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('انتهى التحدي', textAlign: TextAlign.center, style: GoogleFonts.amiri(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('نتيجتك هي: $score من 10', style: GoogleFonts.amiri(color: const Color(0xFFF5A623), fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            score == 10 ? const Text('ما شاء الله! لقد نلت الدرجة الكاملة بجدارة.') : (score >= 7 ? const Text('أحسنت! علمك بأسماء الله واسع.') : const Text('محاولة جيدة، استمر في التعلم والتدبر.')),
          ],
        ),
        actions: [
          if (score == 10)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.workspace_premium, color: Colors.white),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF5A623)),
                  onPressed: () {
                    Navigator.pop(context);
                    context.push('/certificate-viewer', extra: 'asma_quiz_perfection');
                  },
                  label: Text('استلم شهادتك', style: GoogleFonts.amiri(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.pop();
              },
              child: Text('إغلاق', style: GoogleFonts.amiri(color: Colors.white70)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IslamicBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('تحدي الأسماء', style: GoogleFonts.amiri(color: Colors.white, fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              LinearProgressIndicator(
                value: (currentQuestionIndex + 1) / 10,
                backgroundColor: Colors.white10,
                color: const Color(0xFFF5A623),
              ),
              const SizedBox(height: 30),
              Text('ما هو معنى اسم الله:', style: GoogleFonts.amiri(color: Colors.white70, fontSize: 18)),
              const SizedBox(height: 10),
              Text(currentAsma.name, style: GoogleFonts.amiri(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),
              ...options.map((opt) => _buildOption(opt)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOption(String text) {
    Color borderColor = Colors.white10;
    Color bgColor = Colors.white.withOpacity(0.05);

    if (answered) {
      if (text == currentAsma.meaning) {
        borderColor = Colors.green;
        bgColor = Colors.green.withOpacity(0.2);
      }
    }

    return GestureDetector(
      onTap: () => _checkAnswer(text),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
        width: double.infinity,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: borderColor),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: GoogleFonts.amiri(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}
