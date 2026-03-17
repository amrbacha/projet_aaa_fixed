import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:string_similarity/string_similarity.dart';

enum SmartRecitationMatchType { none, current, next }

class SmartRecitationMatchResult {
  final SmartRecitationMatchType type;
  final String transcript;
  final double currentScore;
  final double nextScore;

  const SmartRecitationMatchResult({
    required this.type,
    required this.transcript,
    required this.currentScore,
    required this.nextScore,
  });

  bool get matched => type != SmartRecitationMatchType.none;
}

class SmartQuranService {
  static final SmartQuranService _instance = SmartQuranService._internal();
  factory SmartQuranService() => _instance;
  SmartQuranService._internal();

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;

  Future<bool> init() async {
    if (_isInitialized) return true;
    _isInitialized = await _speech.initialize(
      onStatus: (status) => debugPrint('STT status: $status'),
      onError: (error) => debugPrint('STT error: $error'),
    );
    return _isInitialized;
  }

  Future<void> stopListening() async {
    if (_speech.isListening) {
      await _speech.stop();
    }
  }

  Future<void> startListening(
    void Function(String text) onResult, {
    Duration listenFor = const Duration(seconds: 40),
    Duration pauseFor = const Duration(seconds: 4),
  }) async {
    if (!_isInitialized) {
      await init();
    }
    await stopListening();
    await Future.delayed(const Duration(milliseconds: 120));
    await _speech.listen(
      localeId: 'ar-SA',
      partialResults: true,
      cancelOnError: false,
      listenFor: listenFor,
      pauseFor: pauseFor,
      listenMode: stt.ListenMode.dictation,
      onResult: (result) => onResult(result.recognizedWords),
    );
  }

  bool get isListening => _speech.isListening;

  String normalizeArabic(String input) {
    if (input.isEmpty) return '';
    final diacritics = RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED]');
    final punctuation = RegExp(r'[^\u0621-\u063A\u0641-\u064A0-9\s]');
    return input
        .replaceAll(diacritics, '')
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ى', 'ي')
        .replaceAll('ؤ', 'و')
        .replaceAll('ئ', 'ي')
        .replaceAll('ة', 'ه')
        .replaceAll(punctuation, ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  String cleanText(String input) => normalizeArabic(input);

  List<String> _tokens(String text) {
    final n = normalizeArabic(text);
    if (n.isEmpty) return const [];
    return n.split(' ').where((e) => e.trim().isNotEmpty).toList();
  }

  double checkSimilarity(String original, String recognized) {
    final a = normalizeArabic(original);
    final b = normalizeArabic(recognized);
    if (a.isEmpty || b.isEmpty) return 0.0;
    if (a == b) return 1.0;
    if (a.contains(b) || b.contains(a)) return 0.95;
    return a.similarityTo(b);
  }

  double _coverageScore(String target, String recognized) {
    final t = _tokens(target);
    final r = _tokens(recognized);
    if (t.isEmpty || r.isEmpty) return 0.0;
    int matched = 0;
    for (final word in r) {
      if (t.contains(word)) matched++;
    }
    final recognizedCoverage = matched / r.length;
    final targetCoverage = matched / t.length;
    return (recognizedCoverage * 0.70) + (targetCoverage * 0.30);
  }

  bool _hasMinimumWords(String text) => _tokens(text).length >= 3;

  SmartRecitationMatchResult compareAgainstWindow({
    required String recognizedText,
    required String currentAyah,
    String? nextAyah,
  }) {
    if (!_hasMinimumWords(recognizedText)) {
      return SmartRecitationMatchResult(
        type: SmartRecitationMatchType.none,
        transcript: recognizedText,
        currentScore: 0.0,
        nextScore: 0.0,
      );
    }

    final currentScore = (checkSimilarity(currentAyah, recognizedText) * 0.55) +
        (_coverageScore(currentAyah, recognizedText) * 0.45);

    double nextScore = 0.0;
    if (nextAyah != null && nextAyah.trim().isNotEmpty) {
      nextScore = (checkSimilarity(nextAyah, recognizedText) * 0.55) +
          (_coverageScore(nextAyah, recognizedText) * 0.45);
    }

    if (currentScore >= 0.90 && currentScore >= nextScore) {
      return SmartRecitationMatchResult(
        type: SmartRecitationMatchType.current,
        transcript: recognizedText,
        currentScore: currentScore,
        nextScore: nextScore,
      );
    }

    if (nextScore >= 0.92 && nextScore > currentScore) {
      return SmartRecitationMatchResult(
        type: SmartRecitationMatchType.next,
        transcript: recognizedText,
        currentScore: currentScore,
        nextScore: nextScore,
      );
    }

    return SmartRecitationMatchResult(
      type: SmartRecitationMatchType.none,
      transcript: recognizedText,
      currentScore: currentScore,
      nextScore: nextScore,
    );
  }
}
