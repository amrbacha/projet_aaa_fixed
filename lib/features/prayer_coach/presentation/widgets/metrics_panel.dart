import 'dart:ui';

import 'package:flutter/material.dart';

import '../../domain/enums/prayer_posture.dart';
import '../../domain/enums/prayer_sequence_state.dart';
import '../../domain/models/pose_metrics.dart';
import '../../domain/models/posture_classification.dart';
import '../../domain/utils/posture_labels.dart';

class MetricsPanel extends StatelessWidget {
  final PoseMetrics? metrics;
  final PostureClassification? stableClassification;
  final PostureClassification? candidateClassification;
  final int streak;
  final PrayerPosture statePosture;
  final int transitionStreak;
  final Set<PrayerPosture> allowedNext;
  final PrayerSequenceState sequenceState;
  final PrayerSequenceState sequenceCandidate;
  final int sequenceCandidateStreak;
  final Set<PrayerSequenceState> expectedSequenceNext;

  const MetricsPanel({
    super.key,
    required this.metrics,
    required this.stableClassification,
    required this.candidateClassification,
    required this.streak,
    required this.statePosture,
    required this.transitionStreak,
    required this.allowedNext,
    required this.sequenceState,
    required this.sequenceCandidate,
    required this.sequenceCandidateStreak,
    required this.expectedSequenceNext,
  });

  String _fmt(double? value) {
    if (value == null) return '--';
    return value.toStringAsFixed(1);
  }

  Widget _metric(String label, double? value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          _fmt(value),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final allowedText = allowedNext.map(labelForPosture).join(', ');
    final expectedSeqText =
        expectedSequenceNext.map(labelForSequence).join(', ');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.62),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.greenAccent.withOpacity(0.30),
          width: 1.0,
        ),
      ),
      child: Column(
        children: [
          const Text(
            'Pose Metrics & Sequence Debug',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          _metric('Shoulder Angle', metrics?.shoulderAngle),
          const SizedBox(height: 4),
          _metric('Hip Line Angle', metrics?.hipAngle),
          const SizedBox(height: 4),
          _metric('Knee Angle', metrics?.kneeAngle),
          const SizedBox(height: 4),
          _metric('Spine From Vertical', metrics?.spineAngle),
          const SizedBox(height: 4),
          _metric('Torso From Horizontal', metrics?.torsoAngleFromHorizontal),
          const SizedBox(height: 4),
          _metric('Hip Bend Angle', metrics?.hipBendAngle),
          const SizedBox(height: 4),
          _metric('Body Height Ratio', metrics?.bodyHeightRatio),
          const SizedBox(height: 4),
          _metric('Shoulder Height Ratio', metrics?.shoulderHeightRatio),
          const SizedBox(height: 4),
          _metric('Hip Height Ratio', metrics?.hipHeightRatio),
          const SizedBox(height: 4),
          _metric('Nose Height Ratio', metrics?.noseHeightRatio),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Stable posture: ${stableClassification?.reason ?? '--'}',
              style: const TextStyle(color: Colors.white60, fontSize: 11),
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Candidate posture: ${candidateClassification?.reason ?? '--'} | streak=$streak',
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'State posture: ${labelForPosture(statePosture)} | transition streak=$transitionStreak',
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Allowed next posture: $allowedText',
              style: const TextStyle(color: Colors.white38, fontSize: 11),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Sequence state: ${labelForSequence(sequenceState)}',
              style: const TextStyle(color: Colors.cyanAccent, fontSize: 11),
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Sequence candidate: ${labelForSequence(sequenceCandidate)} | streak=$sequenceCandidateStreak',
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Expected next sequence: $expectedSeqText',
              style: const TextStyle(color: Colors.white38, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}