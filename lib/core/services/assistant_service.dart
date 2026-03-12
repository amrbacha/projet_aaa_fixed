import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

enum AnisVoiceProfile {
  companion,
  sage,
  motivator,
  peaceful,
  orator,
  mentor,
}

class AssistantService {
  static final AssistantService _instance = AssistantService._internal();

  factory AssistantService() => _instance;

  AssistantService._internal();

  final FlutterTts _tts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();

  bool isListening = false;
  String lastWords = "";
  AnisVoiceProfile _currentProfile = AnisVoiceProfile.companion;

  Future<void> init() async {
    if (Platform.isIOS) {
      await _tts.setSharedInstance(true);
      await _tts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playAndRecord,
        [
          IosTextToSpeechAudioCategoryOptions.allowBluetooth,
          IosTextToSpeechAudioCategoryOptions.defaultToSpeaker,
        ],
        IosTextToSpeechAudioMode.voicePrompt,
      );
    }

    await _tts.setLanguage("ar-SA");
    await _tts.setSpeechRate(0.5);
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);
  }

  Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> stopSpeaking() async {
    await _tts.stop();
  }

  Future<void> applyVoiceProfile(AnisVoiceProfile profile) async {
    _currentProfile = profile;

    switch (profile) {
      case AnisVoiceProfile.sage:
        await _tts.setSpeechRate(0.42);
        await _tts.setPitch(0.95);
        break;
      case AnisVoiceProfile.motivator:
        await _tts.setSpeechRate(0.56);
        await _tts.setPitch(1.08);
        break;
      case AnisVoiceProfile.peaceful:
        await _tts.setSpeechRate(0.40);
        await _tts.setPitch(0.90);
        break;
      case AnisVoiceProfile.orator:
        await _tts.setSpeechRate(0.50);
        await _tts.setPitch(1.02);
        break;
      case AnisVoiceProfile.mentor:
        await _tts.setSpeechRate(0.47);
        await _tts.setPitch(0.98);
        break;
      case AnisVoiceProfile.companion:
        await _tts.setSpeechRate(0.50);
        await _tts.setPitch(1.00);
        break;
    }
  }

  Future<void> welcomeUser(String? userName) async {
    final name = (userName ?? '').trim();
    final greeting = name.isEmpty
        ? 'مرحباً، أنا أنيس. سعيد بمرافقتك اليوم.'
        : 'مرحباً يا $name، أنا أنيس. سعيد بمرافقتك اليوم.';
    await speak(greeting);
  }

  Future<void> giveSmartAdvice({
    required String userName,
    required double progress,
  }) async {
    final safeName = userName.trim().isEmpty ? 'صديقي' : userName.trim();

    String advice;
    if (progress >= 0.85) {
      advice =
          'أحسنت يا $safeName، تقدمك ممتاز اليوم. حافظ على هذا الثبات وأكمل وردك بهدوء.';
    } else if (progress >= 0.50) {
      advice =
          'أنت على الطريق الصحيح يا $safeName. بقي القليل فقط لتكمل هدفك اليومي.';
    } else if (progress > 0.0) {
      advice =
          'بداية طيبة يا $safeName. خطوة صغيرة الآن أفضل من التأجيل، هل نكمل معاً؟';
    } else {
      advice =
          'يا $safeName، لنبدأ بخطوة خفيفة اليوم: ذكر قصير أو آيات قليلة، ثم نبني عليها.';
    }

    await speak(advice);
  }

  Future<void> speakPositionGuidance(String directive) async {
    String text = "";

    switch (directive) {
      case 'too_close':
        text = "أنت قريب جداً، من فضلك تراجع خطوة للخلف لكي أراك بوضوح.";
        break;
      case 'tilt_up':
        text = "ارفع وجه الهاتف للأعلى قليلاً لكي يظهر جسمك بالكامل.";
        break;
      case 'tilt_down':
        text = "أمل الهاتف للأسفل قليلاً لكي أرى مكان السجود.";
        break;
      case 'good':
        text = "وضعية ممتازة، الآن أنا أراك بوضوح. يمكنك البدء بالتكبير.";
        break;
    }

    if (text.isNotEmpty) {
      await speak(text);
    }
  }

  Future<void> speakCalibrationInstruction(String step) async {
    String text = "";

    switch (step) {
      case 'start':
        text =
            "مرحباً بك، أنا أنيس مساعدك الذكي. دعنا نضبط الكاميرا أولاً لضمان أفضل تجربة.";
        break;
      case 'position':
        text =
            "ضع الهاتف أمامك وسأرشدك للوضعية الصحيحة صوتياً لكي لا تضطر للنظر للشاشة.";
        break;
      case 'success':
        text = "رائع! تم ضبط الوضعية بنجاح. نحن جاهزون للبدء.";
        break;
      case 'zoom_hint':
        text = "يمكنك استخدام شريط التمرير لضبط الزوم إذا كنت بعيداً جداً.";
        break;
    }

    if (text.isNotEmpty) {
      await speak(text);
    }
  }

  Future<void> startListening({
    required Function(String) onCommand,
    required Function(String) onPartialResult,
  }) async {
    final available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'notListening') {
          isListening = false;
        }
      },
      onError: (error) => debugPrint('Anis Error: $error'),
      finalTimeout: const Duration(milliseconds: 1500),
    );

    if (!available) return;

    isListening = true;

    _speech.listen(
      localeId: 'ar-SA',
      onResult: (result) {
        lastWords = result.recognizedWords;
        onPartialResult(lastWords);

        final foundRoute = _smartSearch(lastWords);
        if (foundRoute != null) {
          _speech.stop();
          onCommand(foundRoute);
          isListening = false;
        }
      },
      listenFor: const Duration(seconds: 10),
      pauseFor: const Duration(milliseconds: 1500),
      partialResults: true,
    );
  }

  String? _smartSearch(String text) {
    if (text.isEmpty) return null;

    final t = text.toLowerCase();

    final Map<String, List<String>> dictionary = {
      '/adhkar': [
        'أذكار',
        'اذكار',
        'ذكر',
        'ورد',
      ],
      '/qibla': [
        'قبلة',
        'القبلة',
        'اتجاه القبلة',
        'اتجاه',
        'كعبة',
        'فين مكة',
      ],
      '/tafseer': [
        'تفسير',
        'التفسير',
        'معنى',
        'تدبر',
        'أفهم الآية',
      ],
      '/tasbeeh': [
        'سبحة',
        'تسبيح',
        'أسبح',
        'عداد',
      ],
      '/settings': [
        'إعدادات',
        'اعدادات',
        'تغيير',
        'ضبط',
        'ألوان',
        'الوان',
      ],
      '/main-menu': [
        'الرئيسية',
        'القائمة',
        'الرجوع',
        'أرجع',
        'خروج',
      ],
      '/reading': [
        'قرآن',
        'قراءة',
        'مصحف',
        'سورة',
        'أقرأ',
      ],
      '/asma-allah': [
        'أسماء الله',
        'الاسماء الحسنى',
        'الحسنى',
        'أسماء',
      ],
      '/search': [
        'بحث',
        'دور',
        'أبحث',
      ],
      '/prayer-coach-debug': [
        'مساعد الصلاة',
        'تصحيح الصلاة',
        'ابدأ الصلاة',
        'دربني على الصلاة',
        'الصلاة بالكاميرا',
        'تحليل الصلاة',
      ],
    };

    for (final entry in dictionary.entries) {
      for (final keyword in entry.value) {
        if (t.contains(keyword.toLowerCase())) {
          return entry.key;
        }
      }
    }

    return null;
  }

  Future<void> explainPage(String pageName) async {
    String explanation = "";

    switch (pageName) {
      case 'home':
        explanation = "هنا لوحة المتابعة، تعرض لك أوقات الصلاة والورد الحالي.";
        break;
      case 'adhkar':
        explanation = "هذه صفحة الأذكار، يمكنك اختيار الفئة التي تريد قرائتها.";
        break;
      case 'qibla':
        explanation = "هنا بوصلة القبلة، وجه الهاتف لليسار أو اليمين لتحديد الاتجاه.";
        break;
      case 'prayer-coach-debug':
        explanation =
            "هذه شاشة مساعد الصلاة التجريبي. سأحاول التعرف على القيام والركوع والسجود بشكل مبدئي.";
        break;
    }

    if (explanation.isNotEmpty) {
      await speak(explanation);
    }
  }

  void stopListening() {
    _speech.stop();
    isListening = false;
  }
}