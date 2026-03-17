import 'package:flutter/material.dart';

import '../../domain/enums/prayer_posture.dart';
import '../../domain/enums/prayer_sequence_state.dart';
import '../../domain/models/posture_classification.dart';
import '../../domain/utils/posture_labels.dart';

class PostureBanner extends StatelessWidget {
  final PostureClassification? classification;
  final PostureClassification? candidate;
  final int streak;
  final int requiredStableFrames;
  final PrayerPosture currentState;
  final Set<PrayerPosture> allowedNext;
  final int transitionStreak;
  final int requiredTransitionFrames;
  final PrayerSequenceState sequenceState;
  final PrayerSequenceState sequenceCandidate;
  final int sequenceCandidateStreak;
  final Set<PrayerSequenceState> expectedSequenceNext;
  final int requiredSequenceFrames;

  const PostureBanner({
    super.key,
    required this.classification,
    required this.candidate,
    required this.streak,
    required this.requiredStableFrames,
    required this.currentState,
    required this.allowedNext,
    required this.transitionStreak,
    required this.requiredTransitionFrames,
    required this.sequenceState,
    required this.sequenceCandidate,
    required this.sequenceCandidateStreak,
    required this.expectedSequenceNext,
    required this.requiredSequenceFrames,
  });

  Color _colorFor(PrayerPosture posture) {
    switch (posture) {
      case PrayerPosture.qiyam:
        return Colors.greenAccent;
      case PrayerPosture.ruku:
        return Colors.orangeAccent;
      case PrayerPosture.sujud:
        return Colors.lightBlueAccent;
      case PrayerPosture.jalsa:
        return Colors.purpleAccent;
      case PrayerPosture.unknown:
        return Colors.white70;
    }
  }

  @override
  Widget build(BuildContext context) {
    final stable = classification;
    final posture = stable?.posture ?? PrayerPosture.unknown;
    final color = _colorFor(posture);
    final confidence = ((stable?.confidence ?? 0.0) * 100).round();
    final candidateLabel =
        labelForPosture(candidate?.posture ?? PrayerPosture.unknown);
    final allowedText = allowedNext.map(labelForPosture).join(' ← ');
    final expectedSequenceText =
        expectedSequenceNext.map(labelForSequence).join(' ← ');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.62),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.7),
          width: 1.2,
        ),
      ),
      child: Column(
        children: [
          Text(
            'الوضعية المستقرة: ${labelForPosture(posture)}',
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'الثقة: $confidence%',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            stable?.reason ?? 'ننتظر قياسات أوضح...',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Candidate: $candidateLabel | streak: $streak / $requiredStableFrames',
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            'State: ${labelForPosture(currentState)} | transition: $transitionStreak / $requiredTransitionFrames',
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            'Allowed next posture: $allowedText',
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Text(
            'مرحلة الركعة: ${labelForSequence(sequenceState)}',
            style: const TextStyle(
              color: Colors.cyanAccent,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Sequence candidate: ${labelForSequence(sequenceCandidate)} | progress: $sequenceCandidateStreak / $requiredSequenceFrames',
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            'Expected next sequence: $expectedSequenceText',
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ],
      ),
    );
  }
}