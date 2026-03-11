import 'package:flutter/material.dart';
import 'package:projet_aaa_fixed/core/services/settings_service.dart';
import 'package:projet_aaa_fixed/models/settings_model.dart';
import 'package:projet_aaa_fixed/core/theme.dart';
import 'package:projet_aaa_fixed/core/services/local_storage_service.dart';

class ThemeProvider with ChangeNotifier {
  AppSettings _settings = AppSettings.defaultSettings();
  AppSettings get settings => _settings;
  
  Locale _locale = const Locale('ar');
  Locale get locale => _locale;

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
    _initialize();
  }

  Future<void> _initialize() async {
    await loadSettings();
    final langCode = await LocalStorageService.getLanguage();
    _locale = Locale(langCode);
    notifyListeners();
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

  Future<void> setLocale(String langCode) async {
    _locale = Locale(langCode);
    await LocalStorageService.saveLanguage(langCode);
    notifyListeners();
  }

  Future<void> setTheme(bool isDarkMode) async {
    final newSettings = _settings.copyWith(isDarkMode: isDarkMode);
    await updateSettings(newSettings);
  }
}
