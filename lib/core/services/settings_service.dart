import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/settings_model.dart';

class SettingsService {
  static const String settingsKey = 'app_settings';

  static Future<void> saveSettings(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(settings.toJson());
    await prefs.setString(settingsKey, jsonString);
  }

  static Future<AppSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(settingsKey);
    if (jsonString != null) {
      try {
        final Map<String, dynamic> jsonMap = json.decode(jsonString);
        return AppSettings.fromJson(jsonMap);
      } catch (e) {
        return AppSettings.defaultSettings();
      }
    }
    return AppSettings.defaultSettings();
  }
}