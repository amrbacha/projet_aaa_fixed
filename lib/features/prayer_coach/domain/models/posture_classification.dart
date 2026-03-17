import '../enums/prayer_posture.dart';

class PostureClassification {
  final PrayerPosture posture;
  final double confidence;
  final String reason;

  const PostureClassification({
    required this.posture,
    required this.confidence,
    required this.reason,
  });
}