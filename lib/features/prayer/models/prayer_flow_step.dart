import 'package:projet_aaa_fixed/core/services/pose_detection_service.dart';

import 'prayer_step_type.dart';

class PrayerFlowStep {
  final PrayerStepType type;
  final String title;
  final String? content;
  final int rakahNumber;
  final int? surahNumber;
  final int? ayahNumber;
  final String? surahName;
  final PrayerPosition? expectedPosition;
  final int repetition;
  final bool requiresExactMatch;
  final bool requiresUserRecitation;
  final Duration pauseAfter;

  const PrayerFlowStep({
    required this.type,
    required this.title,
    required this.rakahNumber,
    this.content,
    this.surahNumber,
    this.ayahNumber,
    this.surahName,
    this.expectedPosition,
    this.repetition = 1,
    this.requiresExactMatch = false,
    this.requiresUserRecitation = false,
    this.pauseAfter = const Duration(milliseconds: 1000),
  });

  bool get isRecitation => type == PrayerStepType.recitation;
  bool get isDhikr => type == PrayerStepType.dhikr;
  bool get isMovement => type == PrayerStepType.movement;
  bool get isTransition => type == PrayerStepType.transition;
}
