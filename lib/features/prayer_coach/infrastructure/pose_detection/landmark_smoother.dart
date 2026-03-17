import 'dart:ui';

import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../../domain/utils/geometry_utils.dart';

class LandmarkSmoother {
  final double alpha;
  final Map<PoseLandmarkType, Offset> _smoothedLandmarks = {};

  LandmarkSmoother({this.alpha = 0.28});

  static const trackedTypes = <PoseLandmarkType>{
    PoseLandmarkType.nose,
    PoseLandmarkType.leftShoulder,
    PoseLandmarkType.rightShoulder,
    PoseLandmarkType.leftElbow,
    PoseLandmarkType.rightElbow,
    PoseLandmarkType.leftWrist,
    PoseLandmarkType.rightWrist,
    PoseLandmarkType.leftHip,
    PoseLandmarkType.rightHip,
    PoseLandmarkType.leftKnee,
    PoseLandmarkType.rightKnee,
    PoseLandmarkType.leftAnkle,
    PoseLandmarkType.rightAnkle,
  };

  Map<PoseLandmarkType, Offset> update(Pose pose) {
    for (final type in trackedTypes) {
      final lm = pose.landmarks[type];
      if (lm == null) continue;

      final currentPoint = Offset(lm.x, lm.y);
      final previous = _smoothedLandmarks[type];

      if (previous == null) {
        _smoothedLandmarks[type] = currentPoint;
      } else {
        _smoothedLandmarks[type] = Offset(
          GeometryUtils.lerp(previous.dx, currentPoint.dx, alpha),
          GeometryUtils.lerp(previous.dy, currentPoint.dy, alpha),
        );
      }
    }

    return Map<PoseLandmarkType, Offset>.unmodifiable(_smoothedLandmarks);
  }

  Map<PoseLandmarkType, Offset> get current =>
      Map<PoseLandmarkType, Offset>.unmodifiable(_smoothedLandmarks);

  void clear() {
    _smoothedLandmarks.clear();
  }
}