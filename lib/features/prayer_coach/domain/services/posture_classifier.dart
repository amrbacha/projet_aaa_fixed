import 'dart:ui';

import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../enums/prayer_posture.dart';
import '../models/pose_metrics.dart';
import '../models/posture_classification.dart';

class PostureClassifier {
  PostureClassification classify({
    required PoseMetrics? metrics,
    required Map<PoseLandmarkType, Offset> landmarks,
  }) {
    if (metrics == null) {
      return const PostureClassification(
        posture: PrayerPosture.unknown,
        confidence: 0.0,
        reason: 'لا توجد قياسات كافية بعد',
      );
    }

    final spine = metrics.spineAngle;
    final knee = metrics.kneeAngle;
    final torso = metrics.torsoAngleFromHorizontal;
    final hipBend = metrics.hipBendAngle;
    final shoulderHeight = metrics.shoulderHeightRatio;
    final hipHeight = metrics.hipHeightRatio;
    final noseHeight = metrics.noseHeightRatio;
    final bodyHeightRatio = metrics.bodyHeightRatio;
    final torsoDropRatio = metrics.torsoDropRatio;

    if (spine == null || knee == null) {
      return const PostureClassification(
        posture: PrayerPosture.unknown,
        confidence: 0.10,
        reason: 'العمود أو الركبتان غير واضحتين',
      );
    }

    if (spine <= 20 &&
        knee >= 150 &&
        (torso == null || torso >= 70) &&
        (hipBend == null || hipBend >= 145)) {
      final confidence = _confidenceFromRules(
        values: [
          _scoreRange(spine, 0, 16),
          _scoreRange(knee, 158, 180),
          if (torso != null) _scoreRange(torso, 72, 90),
          if (hipBend != null) _scoreRange(hipBend, 150, 180),
        ],
      );

      return PostureClassification(
        posture: PrayerPosture.qiyam,
        confidence: confidence,
        reason: 'الجذع شبه عمودي والركبتان مستقيمتان تقريبًا',
      );
    }

    if (spine >= 42 &&
        spine <= 82 &&
        knee >= 140 &&
        torso != null &&
        torso >= 8 &&
        torso <= 46 &&
        (hipBend == null || hipBend <= 148) &&
        (shoulderHeight == null || shoulderHeight < 0.64)) {
      final confidence = _confidenceFromRules(
        values: [
          _scoreRange(spine, 48, 76),
          _scoreRange(knee, 145, 180),
          _scoreRange(torso, 10, 34),
          if (hipBend != null) _scoreRange(hipBend, 92, 145),
        ],
      );

      return PostureClassification(
        posture: PrayerPosture.ruku,
        confidence: confidence,
        reason: 'انحناء واضح للأمام مع بقاء الساقين شبه مستقيمتين',
      );
    }

    if (knee <= 142 &&
        (
          (bodyHeightRatio != null && bodyHeightRatio <= 0.62) ||
          (torsoDropRatio != null && torsoDropRatio >= 0.18) ||
          (hipHeight != null && hipHeight >= 0.48)
        ) &&
        (
          (noseHeight != null && noseHeight <= 0.58) ||
          (shoulderHeight != null && shoulderHeight <= 0.68)
        )) {
      final confidence = _confidenceFromRules(
        values: [
          _scoreRange(knee, 55, 132),
          if (bodyHeightRatio != null) _scoreRange(bodyHeightRatio, 0.20, 0.58),
          if (noseHeight != null) _scoreRange(noseHeight, 0.18, 0.56),
          if (shoulderHeight != null) _scoreRange(shoulderHeight, 0.26, 0.66),
          if (torsoDropRatio != null) _scoreRange(torsoDropRatio, 0.18, 0.55),
          if (hipHeight != null) _scoreRange(hipHeight, 0.48, 0.86),
        ],
      );

      return PostureClassification(
        posture: PrayerPosture.sujud,
        confidence: confidence,
        reason: 'وضعية منخفضة مع انكماش واضح في الجسم وانخفاض الرأس أو الكتفين',
      );
    }

    if (spine <= 42 &&
        knee >= 58 &&
        knee <= 142 &&
        (
          (hipHeight != null && hipHeight >= 0.40) ||
          (bodyHeightRatio != null && bodyHeightRatio <= 0.82)
        ) &&
        (torsoDropRatio == null || torsoDropRatio <= 0.34)) {
      final confidence = _confidenceFromRules(
        values: [
          _scoreRange(spine, 0, 34),
          _scoreRange(knee, 72, 132),
          if (hipHeight != null) _scoreRange(hipHeight, 0.42, 0.82),
          if (bodyHeightRatio != null) _scoreRange(bodyHeightRatio, 0.34, 0.80),
          if (torsoDropRatio != null) _scoreRange(torsoDropRatio, 0.04, 0.30),
        ],
      );

      return PostureClassification(
        posture: PrayerPosture.jalsa,
        confidence: confidence,
        reason: 'ثني واضح في الركبتين مع جذع أقرب للعمودي وارتفاع متوسط للجسم',
      );
    }

    return PostureClassification(
      posture: PrayerPosture.unknown,
      confidence: 0.20,
      reason:
          'القياسات الحالية بينية: spine=${spine.toStringAsFixed(1)} knee=${knee.toStringAsFixed(1)}',
    );
  }

  double _scoreRange(double value, double goodMin, double goodMax) {
    if (value >= goodMin && value <= goodMax) {
      return 1.0;
    }

    final distance = value < goodMin ? goodMin - value : value - goodMax;
    final tolerance = (goodMax - goodMin).abs().clamp(1.0, 999999.0) * 0.85;
    final normalized = 1.0 - (distance / tolerance);
    return normalized.clamp(0.0, 1.0);
  }

  double _confidenceFromRules({required List<double> values}) {
    if (values.isEmpty) return 0.0;
    final sum = values.reduce((a, b) => a + b);
    return (sum / values.length).clamp(0.0, 1.0);
  }
}
