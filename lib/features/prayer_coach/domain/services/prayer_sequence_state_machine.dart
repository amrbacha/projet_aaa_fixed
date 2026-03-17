import '../enums/prayer_posture.dart';
import '../enums/prayer_sequence_state.dart';

class PrayerSequenceStateMachineUpdate {
  final PrayerSequenceState sequenceState;
  final PrayerSequenceState sequenceCandidate;
  final int sequenceCandidateStreak;
  final Set<PrayerSequenceState> expectedNext;

  const PrayerSequenceStateMachineUpdate({
    required this.sequenceState,
    required this.sequenceCandidate,
    required this.sequenceCandidateStreak,
    required this.expectedNext,
  });
}

class PrayerSequenceStateMachine {
  final int requiredSequenceFrames;

  PrayerSequenceState _sequenceState = PrayerSequenceState.unknown;
  PrayerSequenceState _sequenceCandidate = PrayerSequenceState.unknown;
  int _sequenceCandidateStreak = 0;

  PrayerSequenceStateMachine({
    this.requiredSequenceFrames = 4,
  });

  PrayerSequenceStateMachineUpdate update(PrayerPosture stablePosture) {
    _updateSequenceStateMachine(stablePosture);

    return PrayerSequenceStateMachineUpdate(
      sequenceState: _sequenceState,
      sequenceCandidate: _sequenceCandidate,
      sequenceCandidateStreak: _sequenceCandidateStreak,
      expectedNext: allowedNextSequenceStates(_sequenceState),
    );
  }

  void reset() {
    _sequenceState = PrayerSequenceState.unknown;
    _sequenceCandidate = PrayerSequenceState.unknown;
    _sequenceCandidateStreak = 0;
  }

  Set<PrayerSequenceState> allowedNextSequenceStates(
    PrayerSequenceState current,
  ) {
    switch (current) {
      case PrayerSequenceState.unknown:
        return {
          PrayerSequenceState.qiyamStart,
        };
      case PrayerSequenceState.qiyamStart:
        return {
          PrayerSequenceState.ruku,
        };
      case PrayerSequenceState.ruku:
        return {
          PrayerSequenceState.qawmah,
          PrayerSequenceState.sujud1,
        };
      case PrayerSequenceState.qawmah:
        return {
          PrayerSequenceState.sujud1,
        };
      case PrayerSequenceState.sujud1:
        return {
          PrayerSequenceState.jalsa,
        };
      case PrayerSequenceState.jalsa:
        return {
          PrayerSequenceState.sujud2,
          PrayerSequenceState.qiyamBetweenRakats,
        };
      case PrayerSequenceState.sujud2:
        return {
          PrayerSequenceState.qiyamBetweenRakats,
          PrayerSequenceState.qiyamStart,
        };
      case PrayerSequenceState.qiyamBetweenRakats:
        return {
          PrayerSequenceState.ruku,
        };
    }
  }

  void _updateSequenceStateMachine(PrayerPosture stablePosture) {
    final mappedCandidate = _mapPostureToSequenceCandidate(
      stablePosture,
      _sequenceState,
    );

    if (mappedCandidate == PrayerSequenceState.unknown) {
      return;
    }

    if (_sequenceState == PrayerSequenceState.unknown) {
      if (mappedCandidate == PrayerSequenceState.qiyamStart ||
          mappedCandidate == PrayerSequenceState.qawmah ||
          mappedCandidate == PrayerSequenceState.qiyamBetweenRakats) {
        _sequenceState = PrayerSequenceState.qiyamStart;
        _sequenceCandidate = PrayerSequenceState.unknown;
        _sequenceCandidateStreak = 0;
      }
      return;
    }

    if (mappedCandidate == _sequenceState) {
      _sequenceCandidate = PrayerSequenceState.unknown;
      _sequenceCandidateStreak = 0;
      return;
    }

    final allowed = allowedNextSequenceStates(_sequenceState);
    if (!allowed.contains(mappedCandidate)) {
      return;
    }

    if (_sequenceCandidate == mappedCandidate) {
      _sequenceCandidateStreak++;
    } else {
      _sequenceCandidate = mappedCandidate;
      _sequenceCandidateStreak = 1;
    }

    if (_sequenceCandidateStreak >= requiredSequenceFrames) {
      _sequenceState = mappedCandidate;
      _sequenceCandidate = PrayerSequenceState.unknown;
      _sequenceCandidateStreak = 0;
    }
  }

  PrayerSequenceState _mapPostureToSequenceCandidate(
    PrayerPosture posture,
    PrayerSequenceState currentSequence,
  ) {
    switch (posture) {
      case PrayerPosture.qiyam:
        if (currentSequence == PrayerSequenceState.ruku) {
          return PrayerSequenceState.qawmah;
        }
        if (currentSequence == PrayerSequenceState.sujud2) {
          return PrayerSequenceState.qiyamBetweenRakats;
        }
        if (currentSequence == PrayerSequenceState.unknown) {
          return PrayerSequenceState.qiyamStart;
        }
        return PrayerSequenceState.qiyamStart;

      case PrayerPosture.ruku:
        return PrayerSequenceState.ruku;

      case PrayerPosture.sujud:
        if (currentSequence == PrayerSequenceState.jalsa) {
          return PrayerSequenceState.sujud2;
        }
        return PrayerSequenceState.sujud1;

      case PrayerPosture.jalsa:
        return PrayerSequenceState.jalsa;

      case PrayerPosture.unknown:
        return PrayerSequenceState.unknown;
    }
  }
}
