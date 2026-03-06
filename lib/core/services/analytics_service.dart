import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AnalyticsService {
  static const String _kDailyPoints = 'daily_points_';

  /// تسجيل نقاط إنجاز (مثلاً: 10 نقاط لكل صلاة، نقطة لكل آية، 5 نقاط لكل ذكر)
  static Future<void> logAchievement(int points) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final key = '$_kDailyPoints$today';
    
    int currentPoints = prefs.getInt(key) ?? 0;
    await prefs.setInt(key, currentPoints + points);
  }

  /// جلب نقاط آخر 7 أيام للرسم البياني
  static Future<List<double>> getWeeklyProgress() async {
    final prefs = await SharedPreferences.getInstance();
    List<double> weeklyPoints = [];
    
    for (int i = 6; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final key = '$_kDailyPoints${DateFormat('yyyy-MM-dd').format(date)}';
      weeklyPoints.add((prefs.getInt(key) ?? 0).toDouble());
    }
    
    return weeklyPoints;
  }
}
