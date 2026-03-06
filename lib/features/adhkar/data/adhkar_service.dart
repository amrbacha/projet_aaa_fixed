import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class AdhkarService {
  static const String _kLastMorningAdhkarDate = 'last_morning_adhkar_date';
  static const String _kLastEveningAdhkarDate = 'last_evening_adhkar_date';
  static const String _kMorningStreak = 'morning_adhkar_streak';
  static const String _kEveningStreak = 'evening_adhkar_streak';

  /// تحديث حالة إكمال أذكار الصباح
  static Future<void> markMorningCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    await prefs.setString(_kLastMorningAdhkarDate, today);
    
    // تحديث الـ Streak (بسيط)
    int currentStreak = prefs.getInt(_kMorningStreak) ?? 0;
    await prefs.setInt(_kMorningStreak, currentStreak + 1);
  }

  /// تحديث حالة إكمال أذكار المساء
  static Future<void> markEveningCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    await prefs.setString(_kLastEveningAdhkarDate, today);
    
    int currentStreak = prefs.getInt(_kEveningStreak) ?? 0;
    await prefs.setInt(_kEveningStreak, currentStreak + 1);
  }

  /// التحقق مما إذا تم إكمال أذكار الصباح اليوم
  static Future<bool> isMorningCompletedToday() async {
    final prefs = await SharedPreferences.getInstance();
    final lastDate = prefs.getString(_kLastMorningAdhkarDate);
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return lastDate == today;
  }

  /// التحقق مما إذا تم إكمال أذكار المساء اليوم
  static Future<bool> isEveningCompletedToday() async {
    final prefs = await SharedPreferences.getInstance();
    final lastDate = prefs.getString(_kLastEveningAdhkarDate);
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return lastDate == today;
  }
}
