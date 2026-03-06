import 'package:shared_preferences/shared_preferences.dart';

class ReadingSettingsService {
  static const String _durationKey = 'reading_khatma_duration';

  static Future<void> saveDuration(int durationInDays) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_durationKey, durationInDays);
  }

  static Future<int> loadDuration() async {
    final prefs = await SharedPreferences.getInstance();
    // Default to 30 days if not set
    return prefs.getInt(_durationKey) ?? 30;
  }
}
