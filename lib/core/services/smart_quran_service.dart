import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:string_similarity/string_similarity.dart';
import 'package:flutter/foundation.dart';

class SmartQuranService {
  static final SmartQuranService _instance = SmartQuranService._internal();
  factory SmartQuranService() => _instance;
  SmartQuranService._internal();

  // استخدام نسخة واحدة مشتركة من المحرك لمنع التضارب
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;

  Future<bool> init() async {
    if (_isInitialized) return true;
    _isInitialized = await _speech.initialize(
      onStatus: (status) => debugPrint('STT Status: $status'),
      onError: (error) => debugPrint('STT Error: $error'),
    );
    return _isInitialized;
  }

  String cleanText(String text) {
    if (text.isEmpty) return "";
    final RegExp tashkeel = RegExp(r'[\u064B-\u0652\u0670]');
    final RegExp symbols = RegExp(r'[﴿﴾۩ۖۗۚۛۙۘ]');
    return text
        .replaceAll(tashkeel, '')
        .replaceAll(symbols, '')
        .replaceAll('آ', 'ا')
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('ى', 'ي')
        .trim();
  }

  Future<void> startListening(Function(String) onResult) async {
    if (!_isInitialized) await init();
    
    // إيقاف أي استماع سابق قبل البدء لضمان تحرير الميكروفون
    await _speech.stop();
    await Future.delayed(const Duration(milliseconds: 100));

    await _speech.listen(
      localeId: 'ar-SA',
      onResult: (result) {
        onResult(result.recognizedWords);
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 10),
      partialResults: true,
      listenMode: stt.ListenMode.confirmation,
    );
  }

  double checkSimilarity(String original, String recognized) {
    if (recognized.isEmpty) return 0.0;
    String s1 = cleanText(original);
    String s2 = cleanText(recognized);
    if (s2.contains(s1) || s1.contains(s2)) return 0.95;
    return s1.similarityTo(s2);
  }

  void stopListening() => _speech.stop();
  bool get isListening => _speech.isListening;
  stt.SpeechToText get speechEngine => _speech; // للوصول المشترك
}
