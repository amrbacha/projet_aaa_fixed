import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:flutter/foundation.dart';

enum PrayerPosition { standing, ruku, sujud, sitting, takbir, unknown }

class PoseVisibility {
  final bool isFullBody;
  final bool isTooClose;
  final bool needsTiltUp;
  final bool needsTiltDown;
  final PrayerPosition position;

  PoseVisibility({
    required this.isFullBody,
    required this.isTooClose,
    required this.needsTiltUp,
    required this.needsTiltDown,
    required this.position,
  });
}

class PoseDetectionService {
  late PoseDetector _poseDetector;
  bool _isBusy = false;

  PoseDetectionService() {
    final options = PoseDetectorOptions(mode: PoseDetectionMode.stream);
    _poseDetector = PoseDetector(options: options);
  }

  Future<PoseVisibility> analyzePose(InputImage inputImage) async {
    if (_isBusy) {
      return PoseVisibility(
        isFullBody: false, isTooClose: false, needsTiltUp: false, 
        needsTiltDown: false, position: PrayerPosition.unknown
      );
    }
    _isBusy = true;

    try {
      final poses = await _poseDetector.processImage(inputImage);
      if (poses.isEmpty) {
        return PoseVisibility(
            isFullBody: false, isTooClose: false, needsTiltUp: false, 
            needsTiltDown: false, position: PrayerPosition.unknown);
      }

      final pose = poses.first;
      final nose = pose.landmarks[PoseLandmarkType.nose];
      final lShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
      final rShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
      final lHip = pose.landmarks[PoseLandmarkType.leftHip];
      final rHip = pose.landmarks[PoseLandmarkType.rightHip];
      final lAnkle = pose.landmarks[PoseLandmarkType.leftAnkle];
      final rAnkle = pose.landmarks[PoseLandmarkType.rightAnkle];
      final lWrist = pose.landmarks[PoseLandmarkType.leftWrist];
      final rWrist = pose.landmarks[PoseLandmarkType.rightWrist];

      // 1. تحليل المسافة (هل المستخدم قريب جداً؟)
      // إذا كان عرض الأكتاف يأخذ أكثر من 70% من عرض الكاميرا
      bool isTooClose = false;
      if (lShoulder != null && rShoulder != null) {
        double shoulderWidth = (lShoulder.x - rShoulder.x).abs();
        if (shoulderWidth > inputImage.metadata!.size.width * 0.7) {
          isTooClose = true;
        }
      }

      // 2. تحليل ظهور الجسم بالكامل
      bool isFullBody = (nose != null && lShoulder != null && rShoulder != null && lHip != null && rHip != null);
      
      // 3. تحليل ميلان الهاتف (Tilt)
      bool needsTiltUp = false;
      bool needsTiltDown = false;
      if (nose != null) {
        // إذا كان الرأس قريباً جداً من الحافة العلوية
        if (nose.y < inputImage.metadata!.size.height * 0.1) needsTiltUp = true;
        // إذا كان الرأس منخفضاً جداً في الشاشة وهو في حالة قيام
        if (nose.y > inputImage.metadata!.size.height * 0.4) needsTiltDown = true;
      }

      // 4. تحديد الوضعية (المنطق السابق)
      PrayerPosition pos = PrayerPosition.unknown;
      if (nose == null || lShoulder == null || rShoulder == null) {
        pos = PrayerPosition.sujud;
      } else {
        double avgS = (lShoulder.y + rShoulder.y) / 2;
        double avgH = (lHip != null && rHip != null) ? (lHip.y + rHip.y) / 2 : 0;

        if (lWrist != null && rWrist != null && lWrist.y < lShoulder.y && rWrist.y < rShoulder.y) {
          pos = PrayerPosition.takbir;
        } else if (nose.y > avgS + 40) {
          pos = PrayerPosition.sujud;
        } else if (avgH != 0 && (nose.y - avgH).abs() < 100 && nose.y < avgH) {
          pos = PrayerPosition.ruku;
        } else if (nose.y < avgS - 40) {
          pos = PrayerPosition.standing;
        }
      }

      return PoseVisibility(
        isFullBody: isFullBody,
        isTooClose: isTooClose,
        needsTiltUp: needsTiltUp,
        needsTiltDown: needsTiltDown,
        position: pos,
      );
    } catch (e) {
      return PoseVisibility(
          isFullBody: false, isTooClose: false, needsTiltUp: false, 
          needsTiltDown: false, position: PrayerPosition.unknown);
    } finally {
      _isBusy = false;
    }
  }

  void dispose() => _poseDetector.close();
}
