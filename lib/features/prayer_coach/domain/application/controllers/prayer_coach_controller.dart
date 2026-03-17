import 'dart:ui';

import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../../domain/enums/prayer_posture.dart';
import '../../domain/enums/prayer_sequence_state.dart';
import '../../domain/models/pose_analysis.dart';
import '../../domain/services/pose_metrics_extractor.dart';
import '../../domain/services/posture_classifier.dart';
import '../../domain/services/prayer_posture_state_machine.dart';
import '../../domain/services/prayer_sequence_state_machine.dart';
import '../../domain/services/scene_alignment_evaluator.dart';
import '../../infrastructure/pose_detection/landmark_smoother.dart';
import '../state/prayer_coach_debug_state.dart';

class PrayerCoachController {
  final LandmarkSmoother _landmarkSmoother;
  final PoseMetricsExtractor _metricsExtractor;
  final PostureClassifier _postureClassifier;
  final PrayerPostureStateMachine _postureStateMachine;
  final PrayerSequenceStateMachine _sequenceStateMachine;
  final SceneAlignmentEvaluator _sceneAlignmentEvaluator;

  int _noPoseFrames = 0;
  PrayerCoachDebugState? _lastTrackedState;

  PrayerCoachController({
    LandmarkSmoother? landmarkSmoother,
    PoseMetricsExtractor? metricsExtractor,
    PostureClassifier? postureClassifier,
    PrayerPostureStateMachine? postureStateMachine,
    PrayerSequenceStateMachine? sequenceStateMachine,
    SceneAlignmentEvaluator? sceneAlignmentEvaluator,
  })  : _landmarkSmoother = landmarkSmoother ?? LandmarkSmoother(),
        _metricsExtractor = metricsExtractor ?? PoseMetricsExtractor(),
        _postureClassifier = postureClassifier ?? PostureClassifier(),
        _postureStateMachine =
            postureStateMachine ?? PrayerPostureStateMachine(),
        _sequenceStateMachine =
            sequenceStateMachine ?? PrayerSequenceStateMachine(),
        _sceneAlignmentEvaluator =
            sceneAlignmentEvaluator ?? SceneAlignmentEvaluator();

  PrayerCoachDebugState processPose({
    required Pose pose,
    required Size imageSize,
  }) {
    _noPoseFrames = 0;

    final PoseAnalysis analysis =
        _sceneAlignmentEvaluator.evaluate(pose, imageSize);

    final smoothedLandmarks = _landmarkSmoother.update(pose);
    final metrics = _metricsExtractor.extract(smoothedLandmarks, imageSize);

    final rawCandidate = _postureClassifier.classify(
      metrics: metrics,
      landmarks: smoothedLandmarks,
    );

    final postureUpdate = _postureStateMachine.update(rawCandidate);
    final sequenceUpdate =
        _sequenceStateMachine.update(postureUpdate.stableClassification.posture);

    final state = PrayerCoachDebugState(
      statusTitle: analysis.title,
      statusMessage: analysis.message,
      matchScore: analysis.score,
      metrics: metrics,
      candidateClassification: postureUpdate.candidateClassification,
      stableClassification: postureUpdate.stableClassification,
      candidateStreak: postureUpdate.candidateStreak,
      statePosture: postureUpdate.currentState,
      transitionStreak: postureUpdate.transitionStreak,
      allowedNextPostures: postureUpdate.allowedNext,
      sequenceState: sequenceUpdate.sequenceState,
      sequenceCandidate: sequenceUpdate.sequenceCandidate,
      sequenceCandidateStreak: sequenceUpdate.sequenceCandidateStreak,
      expectedNextSequence: sequenceUpdate.expectedNext,
      noseVisible: analysis.noseVisible,
      shouldersVisible: analysis.shouldersVisible,
      hipsVisible: analysis.hipsVisible,
      kneesVisible: analysis.kneesVisible,
      anklesVisible: analysis.anklesVisible,
      smoothedLandmarks: smoothedLandmarks,
      latestImageSize: imageSize,
    );

    _lastTrackedState = state;
    return state;
  }

  PrayerCoachDebugState buildNoPoseState({
    required Size imageSize,
  }) {
    _noPoseFrames++;
    final analysis = _sceneAlignmentEvaluator.noPose(imageSize);

    if (_noPoseFrames <= 18 && _lastTrackedState != null) {
      return PrayerCoachDebugState(
        statusTitle: analysis.title,
        statusMessage:
            '${analysis.message}\nنحتفظ مؤقتًا بآخر وضعية مستقرة حتى لا ينقطع التسلسل.',
        matchScore: analysis.score,
        metrics: _lastTrackedState!.metrics,
        candidateClassification: _lastTrackedState!.candidateClassification,
        stableClassification: _lastTrackedState!.stableClassification,
        candidateStreak: _lastTrackedState!.candidateStreak,
        statePosture: _lastTrackedState!.statePosture,
        transitionStreak: _lastTrackedState!.transitionStreak,
        allowedNextPostures: _lastTrackedState!.allowedNextPostures,
        sequenceState: _lastTrackedState!.sequenceState,
        sequenceCandidate: _lastTrackedState!.sequenceCandidate,
        sequenceCandidateStreak: _lastTrackedState!.sequenceCandidateStreak,
        expectedNextSequence: _lastTrackedState!.expectedNextSequence,
        noseVisible: analysis.noseVisible,
        shouldersVisible: analysis.shouldersVisible,
        hipsVisible: analysis.hipsVisible,
        kneesVisible: analysis.kneesVisible,
        anklesVisible: analysis.anklesVisible,
        smoothedLandmarks: _lastTrackedState!.smoothedLandmarks,
        latestImageSize: imageSize,
      );
    }

    _landmarkSmoother.clear();
    _postureStateMachine.reset();
    _sequenceStateMachine.reset();
    _lastTrackedState = null;

    return PrayerCoachDebugState(
      statusTitle: analysis.title,
      statusMessage: analysis.message,
      matchScore: analysis.score,
      metrics: null,
      candidateClassification: null,
      stableClassification: null,
      candidateStreak: 0,
      statePosture: PrayerPosture.unknown,
      transitionStreak: 0,
      allowedNextPostures: const {
        PrayerPosture.qiyam,
        PrayerPosture.ruku,
        PrayerPosture.sujud,
        PrayerPosture.jalsa,
      },
      sequenceState: PrayerSequenceState.unknown,
      sequenceCandidate: PrayerSequenceState.unknown,
      sequenceCandidateStreak: 0,
      expectedNextSequence: const {
        PrayerSequenceState.qiyamStart,
      },
      noseVisible: analysis.noseVisible,
      shouldersVisible: analysis.shouldersVisible,
      hipsVisible: analysis.hipsVisible,
      kneesVisible: analysis.kneesVisible,
      anklesVisible: analysis.anklesVisible,
      smoothedLandmarks: const {},
      latestImageSize: imageSize,
    );
  }

  void reset() {
    _noPoseFrames = 0;
    _lastTrackedState = null;
    _landmarkSmoother.clear();
    _postureStateMachine.reset();
    _sequenceStateMachine.reset();
  }
}
