import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    try {
      final dynamic location = await FlutterTimezone.getLocalTimezone();
      final String timeZoneName = location.toString();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // منطق التفاعل مع التنبيه
      },
    );

    if (Platform.isAndroid) {
      // طلب إذن الإشعارات لأندرويد 13+
      await Permission.notification.request();
      
      // طلب إذن التنبيهات الدقيقة لأندرويد 12+ لتجنب الانهيار
      if (await Permission.scheduleExactAlarm.isDenied) {
        // يمكنك توجيه المستخدم لفتح الإعدادات أو المحاولة مرة أخرى لاحقاً
        // حالياً سنكتفي بطلب الإذن
        await Permission.scheduleExactAlarm.request();
      }
    }

    // جدولة أذكار الصباح والمساء تلقائياً عند التشغيل
    try {
      await scheduleDailyAdhkarNotifications();
    } catch (e) {
      debugPrint("Error scheduling notifications during init: $e");
    }
  }

  /// جدولة تنبيه للصلاة
  Future<void> schedulePrayerNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    final tz.TZDateTime tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);
    if (tzScheduledDate.isBefore(tz.TZDateTime.now(tz.local))) return;

    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tzScheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'adhan_channel',
            'تنبيهات الأذان',
            channelDescription: 'قناة مخصصة لتنبيهات أوقات الصلاة',
            importance: Importance.max,
            priority: Priority.high,
            sound: RawResourceAndroidNotificationSound('adhan'),
            playSound: true,
          ),
          iOS: DarwinNotificationDetails(
            sound: 'adhan.caf',
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      // إذا فشلت الجدولة الدقيقة، نستخدم الجدولة التقريبية كبديل لتجنب الانهيار
      debugPrint("Exact schedule failed, using inexact: $e");
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tzScheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'adhan_channel',
            'تنبيهات الأذان (تقريبية)',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  /// جدولة أذكار الصباح والمساء يومياً
  Future<void> scheduleDailyAdhkarNotifications() async {
    await _scheduleDailyNotification(
      id: 1001,
      title: 'أذكار الصباح ☀️',
      body: 'ألا بذكر الله تطمئن القلوب.. حان وقت أذكار الصباح',
      hour: 7,
      minute: 0,
    );

    await _scheduleDailyNotification(
      id: 1002,
      title: 'أذكار المساء 🌙',
      body: 'يقول الله تعالى: "وسبح بحمد ربك قبل طلوع الشمس وقبل غروبها"',
      hour: 17,
      minute: 0,
    );
  }

  Future<void> _scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'adhkar_channel',
            'تنبيهات الأذكار',
            channelDescription: 'تذكير يومي بأذكار الصباح والمساء',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint("Daily notification schedule failed: $e");
      // بديل تقريبي
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails('adhkar_channel', 'تنبيهات الأذكار (تقريبية)'),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
