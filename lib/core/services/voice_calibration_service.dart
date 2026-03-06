import 'package:shared_preferences/shared_preferences.dart';
import 'smart_quran_service.dart';

class UserVoiceProfile {
  final double speedFactor; // 1.0 = عادي، 1.2 = سريع، 0.8 = بطيء
  final String gender;      // man, child, woman
  final double sensitivity; // قوة رصد الصوت

  UserVoiceProfile({
    required this.speedFactor,
    required this.gender,
    required this.sensitivity,
  });
}

class VoiceCalibrationService {
  static const String _speedKey = 'user_voice_speed';
  static const String _genderKey = 'user_voice_gender';

  /// معايرة سرعة المستخدم بناءً على قراءة آية تجريبية
  static Future<double> calibrateSpeed(String originalText, String recognizedText, Duration duration) async {
    final cleanOriginal = SmartQuranService().cleanText(originalText);
    final wordCount = cleanOriginal.split(' ').length;
    
    // حساب عدد الكلمات في الثانية
    double wordsPerSecond = wordCount / (duration.inMilliseconds / 1000);
    
    // متوسط سرعة المقرئ حوالي 1.5 كلمة في الثانية
    double speedFactor = wordsPerSecond / 1.5;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_speedKey, speedFactor);
    return speedFactor;
  }

  static Future<double> getUserSpeedFactor() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_speedKey) ?? 1.0;
  }
}
