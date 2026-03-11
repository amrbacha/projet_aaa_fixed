import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projet_aaa_fixed/core/services/local_storage_service.dart';
import 'package:projet_aaa_fixed/widgets/islamic_background.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    _controller.forward();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    // محاكاة تحميل البيانات والخدمات
    await Future.delayed(const Duration(seconds: 3));
    
    if (!mounted) return;
    
    // التحقق إذا كان المستخدم مسجلاً أم لا
    final registered = await LocalStorageService.isRegistered();
    if (registered) {
      context.go('/main-menu');
    } else {
      context.go('/language');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IslamicBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFF5A623).withOpacity(0.2),
                        blurRadius: 50,
                        spreadRadius: 10,
                      )
                    ],
                  ),
                  child: const Icon(Icons.mosque, size: 100, color: Color(0xFFF5A623)),
                ),
                const SizedBox(height: 24),
                Text(
                  'مساعد الصلاة',
                  style: GoogleFonts.amiri(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'رفيقك الذكي في رحاب الطاعة',
                  style: GoogleFonts.amiri(
                    color: Colors.white70,
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 50),
                const CircularProgressIndicator(
                  color: Color(0xFFC19A6B),
                  strokeWidth: 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
