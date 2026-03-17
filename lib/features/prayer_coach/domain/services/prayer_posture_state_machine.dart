import '../enums/prayer_posture.dart';
import '../models/posture_classification.dart';

class PrayerPostureStateMachineUpdate {
  final PostureClassification candidateClassification;
  final PostureClassification stableClassification;
  final int candidateStreak;
  final PrayerPosture currentState;
  final int transitionStreak;
  final Set<PrayerPosture> allowedNext;

  const PrayerPostureStateMachineUpdate({
    required this.candidateClassification,
    required this.stableClassification,
    required this.candidateStreak,
    required this.currentState,
    required this.transitionStreak,
    required this.allowedNext,
  });
}

class PrayerPostureStateMachine {
  final int requiredStableFrames;
  final int requiredTransitionFrames;

  PrayerPosture _candidatePosture = PrayerPosture.unknown;
  int _candidateStreak = 0;

  PrayerPosture _statePosture = PrayerPosture.unknown;
  int _stateTransitionStreak = 0;
  PrayerPosture _lastTransitionCandidate = PrayerPosture.unknown;

  PostureClassification? _stableClassification;

  PrayerPostureStateMachine({
    this.requiredStableFrames = 4,
    this.requiredTransitionFrames = 5,
  });

  PrayerPostureStateMachineUpdate update(PostureClassification rawCandidate) {
    final candidate = _updateCandidatePosture(rawCandidate);
    final stable = _updatePrayerStateMachine(candidate);
    _stableClassification = stable;

    return PrayerPostureStateMachineUpdate(
      candidateClassification: candidate,
      stableClassification: stable,
      candidateStreak: _candidateStreak,
      currentState: _statePosture,
      transitionStreak: _stateTransitionStreak,
      allowedNext: allowedNextPostures(_statePosture),
    );
  }

  void reset() {
    _candidatePosture = PrayerPosture.unknown;
    _candidateStreak = 0;
    _statePosture = PrayerPosture.unknown;
    _stateTransitionStreak = 0;
    _lastTransitionCandidate = PrayerPosture.unknown;
    _stableClassification = null;
  }

  Set<PrayerPosture> allowedNextPostures(PrayerPosture current) {
    switch (current) {
      case PrayerPosture.unknown:
        return {
          PrayerPosture.qiyam,
          PrayerPosture.ruku,
          PrayerPosture.sujud,
          PrayerPosture.jalsa,
        };
      case PrayerPosture.qiyam:
        return {
          PrayerPosture.ruku,
          PrayerPosture.jalsa,
        };
      case PrayerPosture.ruku:
        return {
          PrayerPosture.qiyam,
          PrayerPosture.sujud,
          PrayerPosture.jalsa,
        };
      case PrayerPosture.sujud:
        return {
          PrayerPosture.jalsa,
          PrayerPosture.qiyam,
        };
      case PrayerPosture.jalsa:
        return {
          PrayerPosture.sujud,
          PrayerPosture.qiyam,
        };
    }
  }

  PostureClassification _updateCandidatePosture(
    PostureClassification rawCandidate,
  ) {
    if (rawCandidate.posture == _candidatePosture) {
      _candidateStreak++;
    } else {
      _candidatePosture = rawCandidate.posture;
      _candidateStreak = 1;
    }

    if (rawCandidate.posture == PrayerPosture.unknown) {
      return PostureClassification(
        posture: PrayerPosture.unknown,
        confidence: rawCandidate.confidence,
        reason: rawCandidate.reason,
      );
    }

    final smoothedConfidence = rawCandidate.confidence *
        (_candidateStreak >= requiredStableFrames ? 1.0 : 0.75);

    return PostureClassification(
      posture: rawCandidate.posture,
      confidence: smoothedConfidence.clamp(0.0, 1.0),
      reason:
          '${rawCandidate.reason} (ترشيح ثابت ${_candidateStreak}/$requiredStableFrames)',
    );
  }

  PostureClassification _updatePrayerStateMachine(
    PostureClassification candidate,
  ) {
    final candidatePosture = candidate.posture;
    final currentState = _statePosture;

    if (candidatePosture == PrayerPosture.unknown) {
      return _buildStateClassification(
        posture: _statePosture,
        confidence: (_stableClassification?.confidence ?? 0.0) * 0.98,
        reason: _stableClassification?.reason ?? 'نحتفظ بآخر حالة مستقرة',
      );
    }

    if (currentState == PrayerPosture.unknown) {
      if (_candidateStreak >= requiredStableFrames) {
        _statePosture = candidatePosture;
        _stateTransitionStreak = 0;
        _lastTransitionCandidate = PrayerPosture.unknown;

        return _buildStateClassification(
          posture: _statePosture,
          confidence: candidate.confidence,
          reason: 'تم تثبيت الحالة الأولى: ${_labelForPosture(_statePosture)}',
        );
      }

      return _buildStateClassification(
        posture: PrayerPosture.unknown,
        confidence: candidate.confidence * 0.6,
        reason:
            'ترشيح أولي: ${_labelForPosture(candidatePosture)} بانتظار التثبيت',
      );
    }

    if (candidatePosture == currentState) {
      _stateTransitionStreak = 0;
      _lastTransitionCandidate = PrayerPosture.unknown;

      return _buildStateClassification(
        posture: currentState,
        confidence: candidate.confidence > 0.70 ? candidate.confidence : 0.70,
        reason: 'استمرار في ${_labelForPosture(currentState)} بدون انتقال جديد',
      );
    }

    final allowedNext = allowedNextPostures(currentState);
    final transitionAllowed = allowedNext.contains(candidatePosture);

    if (!transitionAllowed) {
      return _buildStateClassification(
        posture: currentState,
        confidence: (_stableClassification?.confidence ?? 0.70).clamp(0.0, 1.0),
        reason:
            'تم رفض انتقال غير منطقي: ${_labelForPosture(currentState)} → ${_labelForPosture(candidatePosture)}',
      );
    }

    if (_lastTransitionCandidate == candidatePosture) {
      _stateTransitionStreak++;
    } else {
      _lastTransitionCandidate = candidatePosture;
      _stateTransitionStreak = 1;
    }

    if (_stateTransitionStreak >= requiredTransitionFrames &&
        _candidateStreak >= requiredStableFrames) {
      _statePosture = candidatePosture;
      _stateTransitionStreak = 0;
      _lastTransitionCandidate = PrayerPosture.unknown;

      return _buildStateClassification(
        posture: _statePosture,
        confidence: candidate.confidence,
        reason: 'انتقال منطقي مثبت إلى ${_labelForPosture(_statePosture)}',
      );
    }

    return _buildStateClassification(
      posture: currentState,
      confidence: (_stableClassification?.confidence ?? 0.70).clamp(0.0, 1.0),
      reason:
          'مرشح الانتقال: ${_labelForPosture(candidatePosture)} | progress ${_stateTransitionStreak}/$requiredTransitionFrames',
    );
  }

  PostureClassification _buildStateClassification({
    required PrayerPosture posture,
    required double confidence,
    required String reason,
  }) {
    return PostureClassification(
      posture: posture,
      confidence: confidence.clamp(0.0, 1.0),
      reason: reason,
    );
  }

  String _labelForPosture(PrayerPosture posture) {
    switch (posture) {
      case PrayerPosture.qiyam:
        return 'قيام';
      case PrayerPosture.ruku:
        return 'ركوع';
      case PrayerPosture.sujud:
        return 'سجود';
      case PrayerPosture.jalsa:
        return 'جلسة';
      case PrayerPosture.unknown:
        return 'غير محسوم';
    }
  }
}