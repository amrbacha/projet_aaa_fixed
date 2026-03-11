import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'l10n/app_localizations.dart';
import 'core/providers/audio_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/router.dart';
import 'core/services/prayer_times_service.dart';

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
            title: 'Projet AAA',
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.themeMode,
            
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: themeProvider.locale, 
            
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}
