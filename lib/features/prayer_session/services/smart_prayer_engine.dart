import 'dart:async';
import 'package:projet_aaa_fixed/core/models/quran_data.dart';
import 'package:projet_aaa_fixed/core/services/windowed_wird_recitation_engine.dart';
import 'package:projet_aaa_fixed/features/prayer/presentation/prayer_screen.dart';
import 'package:projet_aaa_fixed/features/prayer_session/controllers/prayer_session_controller.dart';

enum SmartAdvanceReason { qariAndVoiceMatched, qariAndPoseMatched, timedFallback, manual }

class SmartPrayerAdvanceResult {
  final bool shouldAdvance;
  final SmartAdvanceReason? reason;
  final String message;
  const SmartPrayerAdvanceResult({required this.shouldAdvance, required this.reason, required this.message});
}

class SmartPrayerEngine {
  final PrayerSessionController controller;
  final WindowedWirdRecitationEngine wirdEngine;
  bool _qariFinished = false, _voiceMatched = false, _poseMatched = false, _manualAdvanceRequested = false, _timedFallbackReached = false;
  Timer? _fallbackTimer;
  SmartPrayerEngine({required this.controller, WindowedWirdRecitationEngine? wirdEngine}) : wirdEngine = wirdEngine ?? WindowedWirdRecitationEngine();

  void beginStep({required PrayerFlowStep step, required Duration fallbackDuration}) {
    _qariFinished = false; _voiceMatched = false; _poseMatched = false; _manualAdvanceRequested = false; _timedFallbackReached = false;
    _fallbackTimer?.cancel();
    _fallbackTimer = Timer(fallbackDuration, () { _timedFallbackReached = true; });
  }

  Future<void> startWirdListening({required List<Ayah> wird, required int wirdIndex, required void Function(String transcript, WirdRecitationDecision decision) onDecision}) async {
    await wirdEngine.startListening((text) {
      final decision = wirdEngine.evaluateWithinWird(wird: wird, currentIndex: wirdIndex, transcript: text);
      if (decision.matched) _voiceMatched = true;
      onDecision(text, decision);
    });
  }

  Future<void> stopListening() async => wirdEngine.stopListening();
  void markQariFinished() => _qariFinished = true;
  void markPoseMatched() => _poseMatched = true;
  void requestManualAdvance() => _manualAdvanceRequested = true;

  SmartPrayerAdvanceResult evaluate({required PrayerFlowStep step, required bool cameraEnabled, required bool micEnabled}) {
    if (_manualAdvanceRequested) {
      _manualAdvanceRequested = false;
      return const SmartPrayerAdvanceResult(shouldAdvance: true, reason: SmartAdvanceReason.manual, message: 'تم الانتقال اليدوي');
    }
    final needsPose = step.isAction && step.expectedPosition != PrayerPosition.standing;
    if (step.isRecitation) {
      if (micEnabled) {
        if (_voiceMatched && _qariFinished) return const SmartPrayerAdvanceResult(shouldAdvance: true, reason: SmartAdvanceReason.qariAndVoiceMatched, message: 'تمت المطابقة');
        if (_voiceMatched && !_qariFinished) return const SmartPrayerAdvanceResult(shouldAdvance: false, reason: null, message: 'بانتظار نهاية المقرئ');
        if (!_voiceMatched && _qariFinished) return const SmartPrayerAdvanceResult(shouldAdvance: false, reason: null, message: 'انتهى المقرئ ولم تتحقق المطابقة');
        return const SmartPrayerAdvanceResult(shouldAdvance: false, reason: null, message: 'النظام يتابع صوت المستخدم');
      }
      if (_qariFinished) return const SmartPrayerAdvanceResult(shouldAdvance: true, reason: SmartAdvanceReason.timedFallback, message: 'انتهت التلاوة');
      return const SmartPrayerAdvanceResult(shouldAdvance: false, reason: null, message: 'ينتظر انتهاء التلاوة');
    }
    if (needsPose && cameraEnabled) {
      if (_qariFinished && _poseMatched) return const SmartPrayerAdvanceResult(shouldAdvance: true, reason: SmartAdvanceReason.qariAndPoseMatched, message: 'انتهى الذكر وثبتت الوضعية');
      if (_poseMatched && !_qariFinished) return const SmartPrayerAdvanceResult(shouldAdvance: false, reason: null, message: 'ثبتت الوضعية وينتظر انتهاء الذكر');
      if (_qariFinished && !_poseMatched) return const SmartPrayerAdvanceResult(shouldAdvance: false, reason: null, message: 'ينتظر الوضعية الصحيحة');
      return const SmartPrayerAdvanceResult(shouldAdvance: false, reason: null, message: 'يتابع الذكر والحركة');
    }
    if (_timedFallbackReached || _qariFinished) return const SmartPrayerAdvanceResult(shouldAdvance: true, reason: SmartAdvanceReason.timedFallback, message: 'انتقال احتياطي');
    return const SmartPrayerAdvanceResult(shouldAdvance: false, reason: null, message: 'ينتظر تحقق الشروط');
  }

  void applyAdvanceReason(SmartAdvanceReason reason) {
    switch (reason) {
      case SmartAdvanceReason.qariAndVoiceMatched: controller.voiceTransition(); break;
      case SmartAdvanceReason.qariAndPoseMatched: controller.cameraTransition(); break;
      case SmartAdvanceReason.timedFallback: controller.timerTransition(); break;
      case SmartAdvanceReason.manual: controller.nextManualStage(); break;
    }
  }

  Future<void> dispose() async { _fallbackTimer?.cancel(); await wirdEngine.stopListening(); }
}
