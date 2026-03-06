import 'package:flutter/material.dart';
import 'package:projet_aaa/core/services/settings_service.dart';
import 'package:projet_aaa/models/settings_model.dart';
import 'package:projet_aaa/core/theme.dart';

class ThemeProvider with ChangeNotifier {
  AppSettings _settings = AppSettings.defaultSettings();
  AppSettings get settings => _settings;

  ThemeData get lightTheme => AppTheme.light(
        primaryColor: Color(settings.primaryColor),
        accentColor: Color(settings.accentColor),
      );

  ThemeData get darkTheme => AppTheme.dark(
        primaryColor: Color(settings.primaryColor),
        accentColor: Color(settings.accentColor),
      );

  ThemeMode get themeMode => settings.isDarkMode ? ThemeMode.dark : ThemeMode.light;

  ThemeProvider() {
    loadSettings();
  }

  Future<void> loadSettings() async {
    _settings = await SettingsService.loadSettings();
    notifyListeners();
  }

  Future<void> updateSettings(AppSettings newSettings) async {
    _settings = newSettings;
    await SettingsService.saveSettings(newSettings);
    notifyListeners();
  }

  // Helper to update just the dark mode
  Future<void> setTheme(bool isDarkMode) async {
    final newSettings = _settings.copyWith(isDarkMode: isDarkMode);
    await updateSettings(newSettings);
  }
}
