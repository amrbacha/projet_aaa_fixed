import 'dart:math' as math;
import 'dart:ui';

import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../models/pose_analysis.dart';
import '../utils/geometry_utils.dart';

class SceneAlignmentEvaluator {
  PoseAnalysis evaluate(Pose pose, Size imageSize) {
    final nose = pose.landmarks[PoseLandmarkType.nose];
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final leftHip = pose.landmarks[PoseLandmarkType.leftHip];
    final rightHip = pose.landmarks[PoseLandmarkType.rightHip];
    final leftKnee = pose.landmarks[PoseLandmarkType.leftKnee];
    final rightKnee = pose.landmarks[PoseLandmarkType.rightKnee];
    final leftAnkle = pose.landmarks[PoseLandmarkType.leftAnkle];
    final rightAnkle = pose.landmarks[PoseLandmarkType.rightAnkle];

    final noseVisible = nose != null;
    final shouldersVisible = leftShoulder != null && rightShoulder != null;
    final hipsVisible = leftHip != null && rightHip != null;
    final kneesVisible = leftKnee != null && rightKnee != null;
    final anklesVisible = leftAnkle != null && rightAnkle != null;

    double score = 0.0;
    if (noseVisible) score += 0.15;
    if (shouldersVisible) score += 0.20;
    if (hipsVisible) score += 0.20;
    if (kneesVisible) score += 0.20;
    if (anklesVisible) score += 0.25;

    if (!noseVisible || !shouldersVisible || !hipsVisible) {
      return PoseAnalysis(
        title: 'غير واضح',
        message:
            'اجعل الرأس والكتفين والورك ظاهرين بوضوح. هذا هو الحد الأدنى لمطابقة الهيكل.',
        score: score,
        noseVisible: noseVisible,
        shouldersVisible: shouldersVisible,
        hipsVisible: hipsVisible,
        kneesVisible: kneesVisible,
        anklesVisible: anklesVisible,
      );
    }

    final pointsX = <double>[
      if (nose != null) nose.x,
      if (leftShoulder != null) leftShoulder.x,
      if (rightShoulder != null) rightShoulder.x,
      if (leftHip != null) leftHip.x,
      if (rightHip != null) rightHip.x,
      if (leftKnee != null) leftKnee.x,
      if (rightKnee != null) rightKnee.x,
      if (leftAnkle != null) leftAnkle.x,
      if (rightAnkle != null) rightAnkle.x,
    ];

    final pointsY = <double>[
      if (nose != null) nose.y,
      if (leftShoulder != null) leftShoulder.y,
      if (rightShoulder != null) rightShoulder.y,
      if (leftHip != null) leftHip.y,
      if (rightHip != null) rightHip.y,
      if (leftKnee != null) leftKnee.y,
      if (rightKnee != null) rightKnee.y,
      if (leftAnkle != null) leftAnkle.y,
      if (rightAnkle != null) rightAnkle.y,
    ];

    final leftEdge = GeometryUtils.minValues(pointsX);
    final rightEdge = GeometryUtils.maxValues(pointsX);
    final topEdge = GeometryUtils.minValues(pointsY);
    final bottomEdge = GeometryUtils.maxValues(pointsY);

    final marginX = imageSize.width * 0.06;
    final marginTop = imageSize.height * 0.06;
    final marginBottom = imageSize.height * 0.05;

    String title = 'هيكل جزئي';
    String message = 'نلتقط بعض النقاط، لكننا نحتاج رؤية أوضح للجسم كله.';

    if (leftEdge < marginX || rightEdge > imageSize.width - marginX) {
      title = 'خارج المنتصف';
      message = 'تمركز أكثر في منتصف الشاشة حتى يطابق الهيكل جسمك.';
      score = math.min(score, 0.55);
    } else if (topEdge < marginTop) {
      title = 'الرأس قريب من الأعلى';
      message = 'أنزل الهاتف قليلًا أو أبعده قليلًا حتى يظهر الرأس كاملًا.';
      score = math.min(score, 0.55);
    } else if (bottomEdge > imageSize.height - marginBottom) {
      title = 'الجزء السفلي قريب جدًا';
      message = 'الجزء السفلي قريب من أسفل الإطار. أبعد الهاتف قليلًا أو ارفعه.';
      score = math.min(score, 0.55);
    } else if (!anklesVisible) {
      title = 'الكاحلان غير ظاهرين';
      message =
          'الهيكل يطابق الجزء العلوي والمتوسط، لكن الكاحلين غير ظاهرين بعد. عدل المسافة أو زاوية الهاتف قليلًا.';
      score = math.max(score, 0.65);
    } else {
      title = 'مطابقة جيدة';
      message =
          'الهيكل الآن أقرب لمطابقة الجسم بالكامل. هذه هي القاعدة الصحيحة قبل تحليل وضعيات الصلاة.';
      score = math.max(score, 0.90);
    }

    return PoseAnalysis(
      title: title,
      message: message,
      score: score.clamp(0.0, 1.0),
      noseVisible: noseVisible,
      shouldersVisible: shouldersVisible,
      hipsVisible: hipsVisible,
      kneesVisible: kneesVisible,
      anklesVisible: anklesVisible,
    );
  }

  PoseAnalysis noPose(Size imageSize) {
    return const PoseAnalysis(
      title: 'غير واضح',
      message: 'لم يتم العثور على جسم واضح. قف في منتصف الشاشة.',
      score: 0.0,
      noseVisible: false,
      shouldersVisible: false,
      hipsVisible: false,
      kneesVisible: false,
      anklesVisible: false,
    );
  }
}