import 'dart:io';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter/material.dart';

class AssistantService {
  static final AssistantService _instance = AssistantService._internal();
  factory AssistantService() => _instance;
  AssistantService._internal();

  final FlutterTts _tts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();
  
  bool isListening = false;
  String lastWords = "";

  Future<void> init() async {
    if (Platform.isIOS) {
       await _tts.setSharedInstance(true);
       await _tts.setIosAudioCategory(IosTextToSpeechAudioCategory.playAndRecord,
           [
             IosTextToSpeechAudioCategoryOptions.allowBluetooth,
             IosTextToSpeechAudioCategoryOptions.defaultToSpeaker
           ],
           IosTextToSpeechAudioMode.voicePrompt
       );
    }
    
    await _tts.setLanguage("ar-SA");
    await _tts.setSpeechRate(0.5); 
    await _tts.setPitch(1.0);
  }

  Future<void> speak(String text) async {
    if (text.isEmpty) return;
    await _tts.stop();
    await _tts.speak(text);
  }

  /// توجيهات التموضع الذكية
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
    if (text.isNotEmpty) await speak(text);
  }

  /// تعليمات المعايرة
  Future<void> speakCalibrationInstruction(String step) async {
    String text = "";
    switch (step) {
      case 'start':
        text = "مرحباً بك، أنا أنيس مساعدك الذكي. دعنا نضبط الكاميرا أولاً لضمان أفضل تجربة.";
        break;
      case 'position':
        text = "ضع الهاتف أمامك وسأرشدك للوضعية الصحيحة صوتياً لكي لا تضطر للنظر للشاشة.";
        break;
      case 'success':
        text = "رائع! تم ضبط الوضعية بنجاح. نحن جاهزون للبدء.";
        break;
      case 'zoom_hint':
        text = "يمكنك استخدام شريط التمرير لضبط الزوم إذا كنت بعيداً جداً.";
        break;
    }
    if (text.isNotEmpty) await speak(text);
  }

  /// الاستماع فائق السرعة مع تحليل لحظي
  Future<void> startListening({
    required Function(String) onCommand,
    required Function(String) onPartialResult,
  }) async {
    bool available = await _speech.initialize(
       onStatus: (status) {
         if (status == 'notListening') isListening = false;
       },
       onError: (error) => debugPrint('Anis Error: $error'),
       finalTimeout: const Duration(milliseconds: 1500),
    );
    
    if (available) {
      isListening = true;
      _speech.listen(
        localeId: 'ar-SA',
        onResult: (result) {
          lastWords = result.recognizedWords;
          onPartialResult(lastWords); 

          String? foundRoute = _smartSearch(lastWords);
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
  }

  String? _smartSearch(String text) {
    if (text.isEmpty) return null;
    String t = text.toLowerCase();
    final Map<String, List<String>> dictionary = {
      '/adhkar': ['أذكار', 'اذكار', 'تسبيح', 'سبحة', 'ذكر', 'ورد'],
      '/qibla': ['قبلة', 'القبلة', 'فين مكة', 'اتجاه', 'كعبة'],
      '/tafseer': ['تفسير', 'التفسير', 'معنى', 'تدبر', 'أفهم الآية'],
      '/tasbeeh': ['سبحة', 'أسبح', 'عداد'],
      '/settings': ['إعدادات', 'اعدادات', 'تغيير', 'ضبط', 'الوان'],
      '/main-menu': ['الرئيسية', 'القائمة', 'الرجوع', 'خروج', 'أرجع'],
      '/reading': ['قرآن', 'قراءة', 'مصحف', 'سورة', 'أقرأ'],
      '/asma-allah': ['أسماء الله', 'الحسنى', 'أسماء'],
      '/search': ['بحث', 'دور', 'أبحث'],
    };

    for (var entry in dictionary.entries) {
      for (var keyword in entry.value) {
        if (t.contains(keyword)) return entry.key;
      }
    }
    return null;
  }

  Future<void> explainPage(String pageName) async {
    String explanation = "";
    switch (pageName) {
      case 'home': explanation = "هنا لوحة المتابعة، تعرض لك أوقات الصلاة والورد الحالي."; break;
      case 'adhkar': explanation = "هذه صفحة الأذكار، يمكنك اختيار الفئة التي تريد قرائتها."; break;
      case 'qibla': explanation = "هنا بوصلة القبلة، وجه الهاتف لليسار أو اليمين لتحديد الاتجاه."; break;
    }
    if (explanation.isNotEmpty) await speak(explanation);
  }

  void stopListening() {
    _speech.stop();
    isListening = false;
  }
}
