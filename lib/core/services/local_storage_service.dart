import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class LocalStorageService {
  static Future<void> saveLanguage(String langCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lang', langCode);
  }

  static Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('lang') ?? 'ar';
  }

  static Future<void> saveUserData({
    required String fullName,
    required String jobTitle,
    required String gender,
    required String ageGroup,
    String readingSpeed = 'متوسط',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fullName', fullName);
    await prefs.setString('jobTitle', jobTitle);
    await prefs.setString('gender', gender);
    await prefs.setString('ageGroup', ageGroup);
    await prefs.setString('readingSpeed', readingSpeed);
    await prefs.setBool('isRegistered', true);
  }

  static Future<bool> isRegistered() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isRegistered') ?? false;
  }

  static Future<Map<String, String>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'fullName': prefs.getString('fullName') ?? '',
      'jobTitle': prefs.getString('jobTitle') ?? '',
      'gender': prefs.getString('gender') ?? '',
      'ageGroup': prefs.getString('ageGroup') ?? '',
      'readingSpeed': prefs.getString('readingSpeed') ?? 'متوسط',
    };
  }

  // ميزات الورد القرآني
  static Future<void> saveQuranProgress(int lastVerseIndex) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_verse_index', lastVerseIndex);
  }

  static Future<int> getQuranProgress() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('last_verse_index') ?? 0;
  }

  // ميزات تتبع الصلوات المكتملة
  static Future<void> markPrayerAsCompleted(String prayerNameInEnglish) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final key = 'completed_prayers_$today';
    
    List<String> completed = prefs.getStringList(key) ?? [];
    if (!completed.contains(prayerNameInEnglish)) {
      completed.add(prayerNameInEnglish);
      await prefs.setStringList(key, completed);
    }
  }

  static Future<List<String>> getCompletedPrayers() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final key = 'completed_prayers_$today';
    return prefs.getStringList(key) ?? [];
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
