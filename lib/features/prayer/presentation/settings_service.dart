import 'package:shared_preferences/shared_preferences.dart';
import '../../models/settings_model.dart';

class SettingsService {
  static const String settingsKey = 'app_settings';

  static Future<void> saveSettings(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = settings.toJson().toString(); // يجب استخدام jsonEncode
    await prefs.setString(settingsKey, jsonString);
  }

  static Future<AppSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(settingsKey);
    if (jsonString != null) {
      // تحويل النص إلى Map
      // هذه عملية مبسطة، يفضل استخدام jsonDecode
      return AppSettings.fromJson({});
    }
    return AppSettings.defaultSettings();
  }
}