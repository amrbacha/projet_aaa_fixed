import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/providers/audio_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/theme.dart';
import 'core/l10n.dart';
import 'core/router.dart';
import 'core/services/prayer_times_service.dart';
import 'core/services/assistant_service.dart';

class ProjetAaaApp extends StatefulWidget {
  const ProjetAaaApp({super.key});

  @override
  State<ProjetAaaApp> createState() => _ProjetAaaAppState();
}

class _ProjetAaaAppState extends State<ProjetAaaApp> {
  @override
  void initState() {
    super.initState();
    _initializePrayerScheduling();
  }

  Future<void> _initializePrayerScheduling() async {
    try {
      await PrayerTimesService.refreshAndScheduleAllPrayers();
    } catch (e) {
      debugPrint("Error scheduling prayers: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AudioProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'مساعد الصلاة',
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.themeMode,
            locale: const Locale('ar'),
            supportedLocales: AppL10n.supportedLocales,
            localizationsDelegates: AppL10n.delegates,
            routerConfig: AppRouter.router,
            builder: (context, child) {
              return Stack(
                children: [
                  child!,
                  const SmartAssistantButton(),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class SmartAssistantButton extends StatefulWidget {
  const SmartAssistantButton({super.key});

  @override
  State<SmartAssistantButton> createState() => _SmartAssistantButtonState();
}

class _SmartAssistantButtonState extends State<SmartAssistantButton> {
  final AssistantService _anis = AssistantService();
  bool _isListening = false;
  String _liveText = "";

  void _handleTap() {
     final router = AppRouter.router;
     final String location = router.routerDelegate.currentConfiguration.fullPath;
     final String pageName = location.replaceAll('/', '');
     _anis.explainPage(pageName.isEmpty ? 'home' : pageName);
  }

  void _handleLongPress() async {
    setState(() {
       _isListening = true;
       _liveText = "أنا أسمعك..";
    });
    
    await _anis.speak("نعم، تفضل.. كيف أساعدك؟");
    
    await _anis.startListening(
      onPartialResult: (text) {
        if (mounted) setState(() => _liveText = text);
      },
      onCommand: (route) {
        if (mounted) {
          setState(() {
            _isListening = false;
            _liveText = "";
          });
          context.push(route);
        }
      }
    );

    // مؤقت أمان لإغلاق الاستماع إذا لم يتم رصد أمر
    Future.delayed(const Duration(seconds: 8), () {
      if (mounted && _isListening) {
        setState(() {
           _isListening = false;
           _liveText = "";
        });
        _anis.stopListening();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 80,
      right: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (_isListening && _liveText.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 10, right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xFFF5A623), width: 1),
              ),
              child: Text(
                _liveText,
                style: GoogleFonts.amiri(color: Colors.white, fontSize: 14),
              ),
            ),
          Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: _handleTap,
              onLongPress: _handleLongPress,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isListening ? Colors.redAccent : const Color(0xFFF5A623),
                  boxShadow: [
                    BoxShadow(
                      color: (_isListening ? Colors.redAccent : const Color(0xFFF5A623)).withOpacity(0.4),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  _isListening ? Icons.mic : Icons.lightbulb_outline,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
