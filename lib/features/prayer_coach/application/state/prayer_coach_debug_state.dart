import 'dart:ui';

import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../../domain/enums/prayer_posture.dart';
import '../../domain/enums/prayer_sequence_state.dart';
import '../../domain/models/pose_metrics.dart';
import '../../domain/models/posture_classification.dart';

class PrayerCoachDebugState {
  final String statusTitle;
  final String statusMessage;
  final double matchScore;

  final PoseMetrics? metrics;
  final PostureClassification? candidateClassification;
  final PostureClassification? stableClassification;

  final int candidateStreak;
  final PrayerPosture statePosture;
  final int transitionStreak;
  final Set<PrayerPosture> allowedNextPostures;

  final PrayerSequenceState sequenceState;
  final PrayerSequenceState sequenceCandidate;
  final int sequenceCandidateStreak;
  final Set<PrayerSequenceState> expectedNextSequence;

  final bool noseVisible;
  final bool shouldersVisible;
  final bool hipsVisible;
  final bool kneesVisible;
  final bool anklesVisible;

  final Map<PoseLandmarkType, Offset> smoothedLandmarks;
  final Size? latestImageSize;

  const PrayerCoachDebugState({
    required this.statusTitle,
    required this.statusMessage,
    required this.matchScore,
    required this.metrics,
    required this.candidateClassification,
    required this.stableClassification,
    required this.candidateStreak,
    required this.statePosture,
    required this.transitionStreak,
    required this.allowedNextPostures,
    required this.sequenceState,
    required this.sequenceCandidate,
    required this.sequenceCandidateStreak,
    required this.expectedNextSequence,
    required this.noseVisible,
    required this.shouldersVisible,
    required this.hipsVisible,
    required this.kneesVisible,
    required this.anklesVisible,
    required this.smoothedLandmarks,
    required this.latestImageSize,
  });

  factory PrayerCoachDebugState.initial() {
    return const PrayerCoachDebugState(
      statusTitle: 'جارٍ التحضير...',
      statusMessage: 'هذه الشاشة مخصصة لمطابقة الهيكل مع الجسم.',
      matchScore: 0.0,
      metrics: null,
      candidateClassification: null,
      stableClassification: null,
      candidateStreak: 0,
      statePosture: PrayerPosture.unknown,
      transitionStreak: 0,
      allowedNextPostures: {
        PrayerPosture.qiyam,
        PrayerPosture.ruku,
        PrayerPosture.sujud,
        PrayerPosture.jalsa,
      },
      sequenceState: PrayerSequenceState.unknown,
      sequenceCandidate: PrayerSequenceState.unknown,
      sequenceCandidateStreak: 0,
      expectedNextSequence: {
        PrayerSequenceState.qiyamStart,
      },
      noseVisible: false,
      shouldersVisible: false,
      hipsVisible: false,
      kneesVisible: false,
      anklesVisible: false,
      smoothedLandmarks: {},
      latestImageSize: null,
    );
  }

  PrayerCoachDebugState copyWith({
    String? statusTitle,
    String? statusMessage,
    double? matchScore,
    PoseMetrics? metrics,
    PostureClassification? candidateClassification,
    PostureClassification? stableClassification,
    int? candidateStreak,
    PrayerPosture? statePosture,
    int? transitionStreak,
    Set<PrayerPosture>? allowedNextPostures,
    PrayerSequenceState? sequenceState,
    PrayerSequenceState? sequenceCandidate,
    int? sequenceCandidateStreak,
    Set<PrayerSequenceState>? expectedNextSequence,
    bool? noseVisible,
    bool? shouldersVisible,
    bool? hipsVisible,
    bool? kneesVisible,
    bool? anklesVisible,
    Map<PoseLandmarkType, Offset>? smoothedLandmarks,
    Size? latestImageSize,
  }) {
    return PrayerCoachDebugState(
      statusTitle: statusTitle ?? this.statusTitle,
      statusMessage: statusMessage ?? this.statusMessage,
      matchScore: matchScore ?? this.matchScore,
      metrics: metrics ?? this.metrics,
      candidateClassification:
          candidateClassification ?? this.candidateClassification,
      stableClassification: stableClassification ?? this.stableClassification,
      candidateStreak: candidateStreak ?? this.candidateStreak,
      statePosture: statePosture ?? this.statePosture,
      transitionStreak: transitionStreak ?? this.transitionStreak,
      allowedNextPostures: allowedNextPostures ?? this.allowedNextPostures,
      sequenceState: sequenceState ?? this.sequenceState,
      sequenceCandidate: sequenceCandidate ?? this.sequenceCandidate,
      sequenceCandidateStreak:
          sequenceCandidateStreak ?? this.sequenceCandidateStreak,
      expectedNextSequence: expectedNextSequence ?? this.expectedNextSequence,
      noseVisible: noseVisible ?? this.noseVisible,
      shouldersVisible: shouldersVisible ?? this.shouldersVisible,
      hipsVisible: hipsVisible ?? this.hipsVisible,
      kneesVisible: kneesVisible ?? this.kneesVisible,
      anklesVisible: anklesVisible ?? this.anklesVisible,
      smoothedLandmarks: smoothedLandmarks ?? this.smoothedLandmarks,
      latestImageSize: latestImageSize ?? this.latestImageSize,
    );
  }
}