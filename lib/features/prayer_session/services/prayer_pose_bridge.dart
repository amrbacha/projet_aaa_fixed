import 'package:projet_aaa_fixed/core/services/pose_detection_service.dart';
import 'package:projet_aaa_fixed/features/prayer/models/prayer_flow_step.dart';

class PrayerPoseBridgeDecision {
  final bool shouldAdvance;
  final String message;
  final int stableFrames;

  const PrayerPoseBridgeDecision({
    required this.shouldAdvance,
    required this.message,
    required this.stableFrames,
  });
}

class PrayerPoseBridge {
  PrayerPosition? _lastPosition;
  int _stableFrames = 0;

  final int requiredStableFrames;

  PrayerPoseBridge({
    this.requiredStableFrames = 6,
  });

  void reset() {
    _lastPosition = null;
    _stableFrames = 0;
  }

  PrayerPoseBridgeDecision evaluate({
    required PrayerFlowStep currentStep,
    required PrayerPosition detectedPosition,
    required bool isBodyCentered,
  }) {
    if (!currentStep.isMovement || currentStep.expectedPosition == null) {
      return const PrayerPoseBridgeDecision(
        shouldAdvance: false,
        message: 'هذه المرحلة لا تعتمد على الحركة',
        stableFrames: 0,
      );
    }

    if (!isBodyCentered) {
      _lastPosition = null;
      _stableFrames = 0;
      return const PrayerPoseBridgeDecision(
        shouldAdvance: false,
        message: 'تمركز أكثر في وسط الكاميرا',
        stableFrames: 0,
      );
    }

    if (detectedPosition == PrayerPosition.unknown) {
      _lastPosition = null;
      _stableFrames = 0;
      return const PrayerPoseBridgeDecision(
        shouldAdvance: false,
        message: 'تأكد من ظهور الجسم كاملًا',
        stableFrames: 0,
      );
    }

    if (detectedPosition != currentStep.expectedPosition) {
      _lastPosition = detectedPosition;
      _stableFrames = 1;
      return PrayerPoseBridgeDecision(
        shouldAdvance: false,
        message: _messageForPosition(
          detectedPosition,
          expected: currentStep.expectedPosition!,
        ),
        stableFrames: _stableFrames,
      );
    }

    if (_lastPosition == detectedPosition) {
      _stableFrames += 1;
    } else {
      _lastPosition = detectedPosition;
      _stableFrames = 1;
    }

    final ok = _stableFrames >= requiredStableFrames;
    return PrayerPoseBridgeDecision(
      shouldAdvance: ok,
      message: ok
          ? 'تم تثبيت الوضعية بنجاح'
          : 'ثبّت الوضعية قليلًا (${_stableFrames}/${requiredStableFrames})',
      stableFrames: _stableFrames,
    );
  }

  String _messageForPosition(
    PrayerPosition detected, {
    required PrayerPosition expected,
  }) {
    return 'الوضعية الحالية ${_label(detected)} والمطلوب ${_label(expected)}';
  }

  String _label(PrayerPosition p) {
    switch (p) {
      case PrayerPosition.standing:
        return 'قيام';
      case PrayerPosition.ruku:
        return 'ركوع';
      case PrayerPosition.sujud:
        return 'سجود';
      case PrayerPosition.sitting:
        return 'جلوس';
      case PrayerPosition.takbir:
        return 'تكبيرة';
      case PrayerPosition.unknown:
        return 'غير واضحة';
    }
  }
}
