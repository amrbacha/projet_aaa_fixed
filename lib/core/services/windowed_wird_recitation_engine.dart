import 'package:projet_aaa_fixed/core/models/quran_data.dart';
import 'package:projet_aaa_fixed/core/services/smart_quran_service.dart';

enum WirdRecitationDecisionType {
  none,
  currentAyahMatched,
  nextAyahMatched,
  retryCurrentAyah,
  outOfScope,
}

class WirdRecitationDecision {
  final WirdRecitationDecisionType type;
  final String transcript;
  final Ayah? matchedAyah;
  final int? matchedIndexInWird;
  final double currentScore;
  final double nextScore;
  final String reason;

  const WirdRecitationDecision({
    required this.type,
    required this.transcript,
    required this.matchedAyah,
    required this.matchedIndexInWird,
    required this.currentScore,
    required this.nextScore,
    required this.reason,
  });

  bool get matched =>
      type == WirdRecitationDecisionType.currentAyahMatched ||
      type == WirdRecitationDecisionType.nextAyahMatched;
}

class WindowedWirdRecitationEngine {
  final SmartQuranService _smartQuranService;

  WindowedWirdRecitationEngine({
    SmartQuranService? smartQuranService,
  }) : _smartQuranService = smartQuranService ?? SmartQuranService();

  Future<void> startListening(void Function(String text) onResult) async {
    await _smartQuranService.startListening(onResult);
  }

  Future<void> stopListening() async {
    await _smartQuranService.stopListening();
  }

  String normalize(String text) => _smartQuranService.cleanText(text);

  WirdRecitationDecision evaluateWithinWird({
    required List<Ayah> wird,
    required int currentIndex,
    required String transcript,
  }) {
    if (wird.isEmpty) {
      return WirdRecitationDecision(
        type: WirdRecitationDecisionType.outOfScope,
        transcript: transcript,
        matchedAyah: null,
        matchedIndexInWird: null,
        currentScore: 0.0,
        nextScore: 0.0,
        reason: 'الورد الحالي فارغ',
      );
    }

    if (currentIndex < 0 || currentIndex >= wird.length) {
      return WirdRecitationDecision(
        type: WirdRecitationDecisionType.outOfScope,
        transcript: transcript,
        matchedAyah: null,
        matchedIndexInWird: null,
        currentScore: 0.0,
        nextScore: 0.0,
        reason: 'فهرس الآية الحالية خارج حدود الورد',
      );
    }

    final currentAyah = wird[currentIndex];
    final Ayah? nextAyah =
        currentIndex + 1 < wird.length ? wird[currentIndex + 1] : null;

    final result = _smartQuranService.compareAgainstWindow(
      recognizedText: transcript,
      currentAyah: currentAyah.text,
      nextAyah: nextAyah?.text,
    );

    switch (result.type) {
      case SmartRecitationMatchType.current:
        return WirdRecitationDecision(
          type: WirdRecitationDecisionType.currentAyahMatched,
          transcript: result.transcript,
          matchedAyah: currentAyah,
          matchedIndexInWird: currentIndex,
          currentScore: result.currentScore,
          nextScore: result.nextScore,
          reason: 'تمت مطابقة الآية الحالية داخل الورد',
        );
      case SmartRecitationMatchType.next:
        return WirdRecitationDecision(
          type: WirdRecitationDecisionType.nextAyahMatched,
          transcript: result.transcript,
          matchedAyah: nextAyah,
          matchedIndexInWird: nextAyah == null ? null : currentIndex + 1,
          currentScore: result.currentScore,
          nextScore: result.nextScore,
          reason: 'تم قبول سبق المستخدم إلى الآية التالية داخل الورد',
        );
      case SmartRecitationMatchType.none:
        final hasEnoughSpeech =
            normalize(transcript).split(' ').where((e) => e.isNotEmpty).length >= 3;
        return WirdRecitationDecision(
          type: hasEnoughSpeech
              ? WirdRecitationDecisionType.retryCurrentAyah
              : WirdRecitationDecisionType.none,
          transcript: result.transcript,
          matchedAyah: null,
          matchedIndexInWird: null,
          currentScore: result.currentScore,
          nextScore: result.nextScore,
          reason: hasEnoughSpeech
              ? 'لم تتحقق المطابقة داخل نافذة الورد الحالية'
              : 'النص الملتقط ما زال قصيرًا وغير كافٍ للحكم',
        );
    }
  }
}
