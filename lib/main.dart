import 'package:flutter/material.dart';
import 'package:projet_aaa/core/services/notification_service.dart';
import 'package:projet_aaa/core/services/assistant_service.dart';
import 'app.dart';

void main() async {
  // 1. التأكد من تهيئة Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // 2. تشغيل التطبيق فوراً لتجنب التوقف عند شاشة البداية
  runApp(const ProjetAaaApp());

  // 3. تهيئة الخدمات في الخلفية بعد تشغيل الواجهة
  _initializeServices();
}

Future<void> _initializeServices() async {
  try {
    // تهيئة الإشعارات
    final notificationService = NotificationService();
    await notificationService.init();
    
    // تهيئة المساعد الذكي "أنيس"
    final assistantService = AssistantService();
    await assistantService.init();
    
    debugPrint("All Services (Notifications & Assistant) initialized successfully");
  } catch (e) {
    debugPrint("Error initializing services: $e");
  }
}
