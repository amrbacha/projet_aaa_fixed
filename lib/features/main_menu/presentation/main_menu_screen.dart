import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/assistant_service.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  final AssistantService _anis = AssistantService();

  @override
  void initState() {
    super.initState();
    _anis.init();
  }

  void _openAssistant() {
    _anis.speak("مرحباً، أنا أنيس. كيف أساعدك؟");
  }

  void _openPrayerCoach() {
    context.push('/prayer-coach-debug');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: const Color(0xFF0F4C3A),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 30),
                const Text(
                  "مساعد الصلاة",
                  style: TextStyle(
                    fontSize: 26,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: ElevatedButton(
                    onPressed: _openPrayerCoach,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      minimumSize: const Size(double.infinity, 60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      "تشغيل تصحيح وضعية الصلاة",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 30,
            right: 20,
            child: FloatingActionButton(
              onPressed: _openAssistant,
              backgroundColor: Colors.orange,
              child: const Icon(Icons.mic),
            ),
          ),
        ],
      ),
    );
  }
}