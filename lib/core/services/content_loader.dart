import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class ContentLoaderService {
  static Future<Map<String, dynamic>> _loadContent() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/reading_material.json');
      return json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return {
        "fatiha": "Failed to load Al-Fatiha.",
        "daily_wird": "Failed to load the daily wird."
      };
    }
  }

  static Future<String> getFatiha() async {
    final content = await _loadContent();
    return content['fatiha'] ?? "";
  }

  static Future<String> getDailyWird() async {
    final content = await _loadContent();
    return content['daily_wird'] ?? "";
  }
}
