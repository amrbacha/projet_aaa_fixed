import 'dart:ui';

import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../models/pose_metrics.dart';
import '../utils/geometry_utils.dart';

class PoseMetricsExtractor {
  PoseMetrics? extract(
    Map<PoseLandmarkType, Offset> landmarks,
    Size imageSize,
  ) {
    final leftShoulder = landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = landmarks[PoseLandmarkType.rightShoulder];
    final leftHip = landmarks[PoseLandmarkType.leftHip];
    final rightHip = landmarks[PoseLandmarkType.rightHip];
    final leftKnee = landmarks[PoseLandmarkType.leftKnee];
    final rightKnee = landmarks[PoseLandmarkType.rightKnee];
    final leftAnkle = landmarks[PoseLandmarkType.leftAnkle];
    final rightAnkle = landmarks[PoseLandmarkType.rightAnkle];
    final nose = landmarks[PoseLandmarkType.nose];

    final shoulderMid = GeometryUtils.midPoint(leftShoulder, rightShoulder);
    final hipMid = GeometryUtils.midPoint(leftHip, rightHip);
    final kneeMid = GeometryUtils.midPoint(leftKnee, rightKnee);
    final ankleMid = GeometryUtils.midPoint(leftAnkle, rightAnkle);

    final shoulderAngle = (leftShoulder != null && rightShoulder != null)
        ? GeometryUtils.lineAngleFromHorizontal(leftShoulder, rightShoulder)
        : null;

    final hipAngle = (leftHip != null && rightHip != null)
        ? GeometryUtils.lineAngleFromHorizontal(leftHip, rightHip)
        : null;

    double? leftKneeAngle;
    if (leftHip != null && leftKnee != null && leftAnkle != null) {
      leftKneeAngle = GeometryUtils.jointAngle(leftHip, leftKnee, leftAnkle);
    }

    double? rightKneeAngle;
    if (rightHip != null && rightKnee != null && rightAnkle != null) {
      rightKneeAngle = GeometryUtils.jointAngle(rightHip, rightKnee, rightAnkle);
    }

    double? averageKneeAngle;
    if (leftKneeAngle != null && rightKneeAngle != null) {
      averageKneeAngle = (leftKneeAngle + rightKneeAngle) / 2.0;
    } else {
      averageKneeAngle = leftKneeAngle ?? rightKneeAngle;
    }

    double? spineAngle;
    double? torsoAngleFromHorizontal;
    if (shoulderMid != null && hipMid != null) {
      spineAngle = GeometryUtils.lineAngleFromVertical(shoulderMid, hipMid);
      torsoAngleFromHorizontal =
          GeometryUtils.lineAngleFromHorizontal(shoulderMid, hipMid);
    }

    double? hipBendAngle;
    if (shoulderMid != null && hipMid != null && kneeMid != null) {
      hipBendAngle = GeometryUtils.jointAngle(shoulderMid, hipMid, kneeMid);
    }

    final bodyHeightRatio = (nose != null && ankleMid != null)
        ? ((ankleMid.dy - nose.dy) / imageSize.height).clamp(0.0, 1.0)
        : null;

    final shoulderHeightRatio = shoulderMid != null
        ? (shoulderMid.dy / imageSize.height).clamp(0.0, 1.0)
        : null;

    final hipHeightRatio = hipMid != null
        ? (hipMid.dy / imageSize.height).clamp(0.0, 1.0)
        : null;

    final noseHeightRatio = nose != null
        ? (nose.dy / imageSize.height).clamp(0.0, 1.0)
        : null;

    final torsoDropRatio = (shoulderMid != null && hipMid != null)
        ? ((hipMid.dy - shoulderMid.dy) / imageSize.height).clamp(0.0, 1.0)
        : null;

    if (shoulderAngle == null &&
        hipAngle == null &&
        averageKneeAngle == null &&
        spineAngle == null &&
        torsoAngleFromHorizontal == null &&
        hipBendAngle == null) {
      return null;
    }

    return PoseMetrics(
      shoulderAngle: shoulderAngle,
      hipAngle: hipAngle,
      kneeAngle: averageKneeAngle,
      spineAngle: spineAngle,
      torsoAngleFromHorizontal: torsoAngleFromHorizontal,
      hipBendAngle: hipBendAngle,
      leftKneeAngle: leftKneeAngle,
      rightKneeAngle: rightKneeAngle,
      bodyHeightRatio: bodyHeightRatio,
      shoulderHeightRatio: shoulderHeightRatio,
      hipHeightRatio: hipHeightRatio,
      noseHeightRatio: noseHeightRatio,
      torsoDropRatio: torsoDropRatio,
    );
  }
}