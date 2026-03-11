import 'dart:io';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter/material.dart';

enum AnisVoiceProfile {
  sage,      // الوقور (عميق جداً)
  orator,    // الخطيب (جهوري وقوي)
  companion, // الرفيق (رجالي دافئ)
  motivator, // المحفز (رجالي حيوي)
  peaceful,  // الهادئ (رجالي خفيض)
  mentor     // الناصح (واضح ومتزن)
}

class AssistantService {
  static final AssistantService _instance = AssistantService._internal();
  factory AssistantService() => _instance;
  AssistantService._internal();

  final FlutterTts _tts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();
  
  bool isListening = false;
  String _currentLocale = "ar-SA";

  Future<void> init() async {
    if (Platform.isIOS) {
       await _tts.setSharedInstance(true);
       await _tts.setIosAudioCategory(IosTextToSpeechAudioCategory.playAndRecord,
           [IosTextToSpeechAudioCategoryOptions.allowBluetooth, IosTextToSpeechAudioCategoryOptions.defaultToSpeaker],
           IosTextToSpeechAudioMode.voicePrompt
       );
    }
    await updateLanguage("ar");
    await applyVoiceProfile(AnisVoiceProfile.companion); 
  }

  Future<void> applyVoiceProfile(AnisVoiceProfile profile) async {
    switch (profile) {
      case AnisVoiceProfile.sage:
        await _tts.setPitch(0.5); await _tts.setSpeechRate(0.4); break;
      case AnisVoiceProfile.orator:
        await _tts.setPitch(0.7); await _tts.setSpeechRate(0.5); break;
      case AnisVoiceProfile.companion:
        await _tts.setPitch(0.85); await _tts.setSpeechRate(0.5); break;
      case AnisVoiceProfile.motivator:
        await _tts.setPitch(0.8); await _tts.setSpeechRate(0.6); break;
      case AnisVoiceProfile.peaceful:
        await _tts.setPitch(0.6); await _tts.setSpeechRate(0.35); break;
      case AnisVoiceProfile.mentor:
        await _tts.setPitch(0.75); await _tts.setSpeechRate(0.45); break;
    }
  }

  Future<void> updateLanguage(String langCode) async {
    _currentLocale = _getLocaleFullCode(langCode);
    await _tts.setLanguage(_currentLocale);
  }

  String _getLocaleFullCode(String code) {
    switch (code) {
      case 'en': return "en-US";
      case 'fr': return "fr-FR";
      case 'es': return "es-ES";
      case 'tr': return "tr-TR";
      case 'id': return "id-ID";
      case 'ur': return "ur-PK";
      case 'ms': return "ms-MY";
      default: return "ar-SA";
    }
  }

  Future<void> speak(String text) async {
    if (text.isEmpty) return;
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> welcomeUser(String userName) async {
    final hour = DateTime.now().hour;
    String greeting = (hour < 12) ? "صباح الخير" : (hour < 18) ? "طاب يومك" : "مساء الخير";
    await speak("$greeting $userName. معك أنيس، رفيقك في دروب الطاعة.");
  }

  Future<void> giveSmartAdvice({required String userName, required double progress}) async {
    await provideProactiveAdvice(userName: userName, progress: progress, completedPrayersToday: 0);
  }

  Future<void> explainPage(String pageName, {Map<String, String>? translations}) async {
    if (translations != null && translations.containsKey(pageName)) {
      await speak(translations[pageName]!);
      return;
    }
    String explanation = "";
    if (_currentLocale.startsWith("ar")) {
      switch (pageName) {
        case 'home': explanation = "هنا لوحة المتابعة، تظهر تقدمك في الختمة ومواعيد صلاتك."; break;
        case 'main-menu': explanation = "هذه القائمة الرئيسية، اختر منها العبادة التي تود القيام بها."; break;
        case 'settings': explanation = "هنا يمكنك تخصيص تجربتي وضبط إعدادات التطبيق."; break;
        default: explanation = "أنا معك، كيف يمكنني مساعدتك في هذه الصفحة؟";
      }
    } else {
      explanation = "I am Anis, your companion. How can I help you on this page?";
    }
    await speak(explanation);
  }

  Future<void> provideProactiveAdvice({
    required String userName,
    required double progress,
    int completedPrayersToday = 0,
  }) async {
    final hour = DateTime.now().hour;
    String advice = "";
    if (hour < 10 && progress < 0.1) {
      advice = "صباح الخير $userName، يوم جديد بفرص جديدة للتقرب من الله. ما رأيك ببدء وردك الآن؟";
    } else if (completedPrayersToday >= 5) {
      advice = "ما شاء الله يا $userName، أتممت صلوات اليوم. زادك الله نوراً وثباتاً.";
    } else if (progress > 0.9) {
      advice = "أنت على وشك ختم وردك اليومي! استمر، الله معك.";
    } else {
      advice = "أهلاً بك يا $userName، أنيس رفيقك يذكرك بذكر الله.";
    }
    await speak(advice);
  }

  Future<void> speakPositionGuidance(String directive) async {
    String text = "";
    if (_currentLocale.startsWith("ar")) {
      switch (directive) {
        case 'too_close': text = "تراجع قليلاً، المسافة قريبة جداً."; break;
        case 'tilt_up': text = "ارفع الهاتف للأعلى قليلاً."; break;
        case 'tilt_down': text = "أمل الهاتف للأسفل."; break;
        case 'good': text = "هكذا تماماً، استعد للبدء."; break;
        case 'start_prompt': text = "أنا معك، ابدأ صلاتك حينما تشاء."; break;
      }
    } else {
      text = "Positioning adjusted. Ready to start.";
    }
    if (text.isNotEmpty) await speak(text);
  }

  Future<void> startListening({
    required String langCode,
    required Function(String) onCommand,
    required Function(String) onPartialResult,
  }) async {
    bool available = await _speech.initialize(
       onStatus: (status) { if (status == 'notListening') isListening = false; },
       onError: (error) => debugPrint('Anis Error: $error'),
    );
    if (available) {
      isListening = true;
      _speech.listen(
        localeId: _getLocaleFullCode(langCode),
        onResult: (result) {
          String words = result.recognizedWords.toLowerCase();
          onPartialResult(words); 
          if (words.contains("صلاة") || words.contains("pray")) onCommand("/prayer");
          if (words.contains("أذكار") || words.contains("dhikr")) onCommand("/adhkar");
          if (words.contains("سبحة") || words.contains("tasbeeh")) onCommand("/tasbeeh");
          if (words.contains("إعدادات") || words.contains("settings")) onCommand("/settings");
        },
        listenFor: const Duration(seconds: 10),
        pauseFor: const Duration(milliseconds: 1500),
        partialResults: true,
      );
    }
  }

  void stopListening() => _speech.stop();
}
