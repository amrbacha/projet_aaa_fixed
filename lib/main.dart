import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:projet_aaa_fixed/core/services/notification_service.dart';
import 'package:projet_aaa_fixed/core/services/assistant_service.dart';
import 'package:projet_aaa_fixed/core/services/quran_service.dart';
import 'app.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      debugPrint("🔴 [UI Framework Error]: ${details.exception}");
    };

    _configureSystemUI();

    runApp(const ProjetAaaApp());

    unawaited(_initializeBackgroundServices());

  }, (error, stack) {
    debugPrint("🔴 [Global Critical Error]: $error");
    debugPrint("Stack: $stack");
  });
}

void _configureSystemUI() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.black,
    systemNavigationBarIconBrightness: Brightness.light,
    systemNavigationBarDividerColor: Colors.transparent,
  ));

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}

Future<void> _initializeBackgroundServices() async {
  try {
    await NotificationService().init();
    await AssistantService().init();
    await QuranService().getAllVerses(excludeFatiha: false);
    debugPrint("✨ [System] All smart services initialized successfully.");
  } catch (e) {
    debugPrint("⚠️ [System Warning] Background initialization error: $e");
  }
}
