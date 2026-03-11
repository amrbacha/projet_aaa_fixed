import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:flutter/foundation.dart';
import 'dart:math' as math;

enum PrayerPosition { standing, ruku, sujud, sitting, takbir, unknown }

class PoseVisibility {
  final bool isFullBody;
  final bool isTooClose;
  final bool needsTiltUp;
  final bool needsTiltDown;
  final PrayerPosition position;
  final double confidence; // إضافة معامل الثقة بالوضعية

  PoseVisibility({
    required this.isFullBody,
    required this.isTooClose,
    required this.needsTiltUp,
    required this.needsTiltDown,
    required this.position,
    this.confidence = 0.0,
  });
}

class PoseDetectionService {
  late PoseDetector _poseDetector;
  bool _isBusy = false;
  
  // نظام الذاكرة الحركية لمنع التذبذب في النتائج
  PrayerPosition _lastStablePos = PrayerPosition.unknown;
  int _stabilityCounter = 0;
  static const int _requiredStabilityFrames = 3;

  PoseDetectionService() {
    final options = PoseDetectorOptions(
      mode: PoseDetectionMode.stream,
      model: PoseDetectionModel.base, // استخدام النموذج الأساسي للتوازن بين الدقة والسرعة
    );
    _poseDetector = PoseDetector(options: options);
  }

  Future<PoseVisibility> analyzePose(InputImage inputImage) async {
    if (_isBusy) return _emptyVisibility();
    _isBusy = true;

    try {
      final poses = await _poseDetector.processImage(inputImage);
      if (poses.isEmpty) return _emptyVisibility();

      final pose = poses.first;
      final nose = pose.landmarks[PoseLandmarkType.nose];
      final lShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
      final rShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
      final lHip = pose.landmarks[PoseLandmarkType.leftHip];
      final rHip = pose.landmarks[PoseLandmarkType.rightHip];
      final lWrist = pose.landmarks[PoseLandmarkType.leftWrist];
      final rWrist = pose.landmarks[PoseLandmarkType.rightWrist];

      // 1. تحليل المسافة والموقع بدقة
      double imageWidth = inputImage.metadata?.size.width ?? 720;
      double imageHeight = inputImage.metadata?.size.height ?? 1280;

      bool isTooClose = false;
      if (lShoulder != null && rShoulder != null) {
        double sWidth = (lShoulder.x - rShoulder.x).abs();
        if (sWidth > imageWidth * 0.75) isTooClose = true;
      }

      bool isFullBody = (nose != null && lShoulder != null && lHip != null);

      // 2. كشف الوضعية بمنطق رياضي متطور
      PrayerPosition currentPos = PrayerPosition.unknown;

      if (nose == null || (lShoulder != null && nose.y > lShoulder.y + 50)) {
        // إذا كان الرأس منخفضاً جداً أو غير مرئي والكتف منخفض -> سجود
        currentPos = PrayerPosition.sujud;
      } else if (lShoulder != null && rShoulder != null && lHip != null) {
        double avgShoulderY = (lShoulder.y + rShoulder.y) / 2;
        double avgHipY = (lHip != null && rHip != null) ? (lHip.y + rHip.y) / 2 : lHip.y;

        // حساب المسافة الرأسية بين الرأس والحوض
        double headToHipDist = (nose.y - avgHipY).abs();

        if (lWrist != null && rWrist != null && lWrist.y < lShoulder.y - 20) {
          currentPos = PrayerPosition.takbir;
        } else if (headToHipDist < 150 && nose.y < avgHipY) {
          // الرأس قريب من مستوى الحوض أفقياً -> ركوع
          currentPos = PrayerPosition.ruku;
        } else if (avgHipY - avgShoulderY < 100) {
          // تقارب الكتف والحوض -> جلوس
          currentPos = PrayerPosition.sitting;
        } else {
          currentPos = PrayerPosition.standing;
        }
      }

      // 3. فلترة النتائج لضمان الاستقرار (Stability Filter)
      if (currentPos == _lastStablePos) {
        _stabilityCounter = 0;
      } else {
        _stabilityCounter++;
        if (_stabilityCounter >= _requiredStabilityFrames) {
          _lastStablePos = currentPos;
          _stabilityCounter = 0;
        }
      }

      return PoseVisibility(
        isFullBody: isFullBody,
        isTooClose: isTooClose,
        needsTiltUp: nose != null && nose.y < imageHeight * 0.1,
        needsTiltDown: nose != null && nose.y > imageHeight * 0.4,
        position: _lastStablePos,
      );
    } catch (e) {
      return _emptyVisibility();
    } finally {
      _isBusy = false;
    }
  }

  PoseVisibility _emptyVisibility() {
    return PoseVisibility(
      isFullBody: false, isTooClose: false, needsTiltUp: false, 
      needsTiltDown: false, position: _lastStablePos
    );
  }

  void dispose() => _poseDetector.close();
}
