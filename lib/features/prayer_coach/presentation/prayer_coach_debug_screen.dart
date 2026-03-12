import 'dart:math' as math;
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:permission_handler/permission_handler.dart';

class PrayerCoachDebugScreen extends StatefulWidget {
  const PrayerCoachDebugScreen({super.key});

  @override
  State<PrayerCoachDebugScreen> createState() => _PrayerCoachDebugScreenState();
}

class _PrayerCoachDebugScreenState extends State<PrayerCoachDebugScreen> {
  CameraController? _cameraController;

  final PoseDetector _poseDetector = PoseDetector(
    options: PoseDetectorOptions(
      model: PoseDetectionModel.accurate,
      mode: PoseDetectionMode.stream,
    ),
  );

  static const double _smoothingAlpha = 0.28;
  static const int _requiredStableFrames = 4;
  static const int _requiredTransitionFrames = 5;

  bool _isInitializing = true;
  bool _permissionDenied = false;
  bool _isProcessing = false;
  bool _isFrontCamera = true;

  Pose? _latestPose;
  Size? _latestImageSize;
  int _sensorOrientation = 0;

  final Map<PoseLandmarkType, Offset> _smoothedLandmarks = {};

  int _frameCounter = 0;

  String _statusTitle = 'جارٍ التحضير...';
  String _statusMessage = 'هذه الشاشة مخصصة لمطابقة الهيكل مع الجسم.';
  double _matchScore = 0.0;

  bool _noseVisible = false;
  bool _shouldersVisible = false;
  bool _hipsVisible = false;
  bool _kneesVisible = false;
  bool _anklesVisible = false;

  _PoseMetrics? _latestMetrics;
  _PostureClassification? _latestCandidateClassification;
  _PostureClassification? _stableClassification;

  PrayerPosture _candidatePosture = PrayerPosture.unknown;
  int _candidateStreak = 0;

  PrayerPosture _statePosture = PrayerPosture.unknown;
  int _stateTransitionStreak = 0;
  PrayerPosture _lastTransitionCandidate = PrayerPosture.unknown;

  @override
  void initState() {
    super.initState();
    _initializeEverything();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _poseDetector.close();
    super.dispose();
  }

  Future<void> _initializeEverything() async {
    try {
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        setState(() {
          _permissionDenied = true;
          _isInitializing = false;
        });
        return;
      }

      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() {
          _statusTitle = 'لا توجد كاميرا';
          _statusMessage = 'تعذر العثور على كاميرا في الجهاز.';
          _isInitializing = false;
        });
        return;
      }

      CameraDescription selectedCamera = cameras.first;
      for (final cam in cameras) {
        if (cam.lensDirection == CameraLensDirection.front) {
          selectedCamera = cam;
          break;
        }
      }

      _sensorOrientation = selectedCamera.sensorOrientation;
      _isFrontCamera = selectedCamera.lensDirection == CameraLensDirection.front;

      final controller = CameraController(
        selectedCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.nv21,
      );

      await controller.initialize();

      final minZoom = await controller.getMinZoomLevel();
      await controller.setZoomLevel(minZoom);

      await controller.startImageStream((CameraImage image) {
        _processCameraImage(image, selectedCamera);
      });

      if (!mounted) return;

      setState(() {
        _cameraController = controller;
        _isInitializing = false;
        _statusTitle = 'جاهز';
        _statusMessage =
        'قف أمام الهاتف بشكل طبيعي. الهدف الآن أن يطابق الهيكل جسمك بالكامل.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _statusTitle = 'حدث خطأ';
        _statusMessage = 'تعذر تشغيل الكاميرا: $e';
        _isInitializing = false;
      });
    }
  }

  Future<void> _processCameraImage(
      CameraImage image,
      CameraDescription camera,
      ) async {
    if (_isProcessing) return;

    _frameCounter++;
    if (_frameCounter % 2 != 0) return;

    _isProcessing = true;

    try {
      final inputImage = _convertCameraImageToInputImage(image, camera);
      if (inputImage == null) return;

      final poses = await _poseDetector.processImage(inputImage);

      if (!mounted) return;

      final effectiveImageSize = _effectiveImageSizeForDisplay(
        rawImageSize: Size(image.width.toDouble(), image.height.toDouble()),
        sensorOrientation: camera.sensorOrientation,
      );

      if (poses.isEmpty) {
        _smoothedLandmarks.clear();
        _candidatePosture = PrayerPosture.unknown;
        _candidateStreak = 0;
        _stateTransitionStreak = 0;
        _lastTransitionCandidate = PrayerPosture.unknown;

        setState(() {
          _latestPose = null;
          _latestImageSize = effectiveImageSize;
          _latestMetrics = null;
          _latestCandidateClassification = null;
          _stableClassification = const _PostureClassification(
            posture: PrayerPosture.unknown,
            confidence: 0.0,
            reason: 'لا توجد هيئة واضحة',
          );
          _statusTitle = 'غير واضح';
          _statusMessage = 'لم يتم العثور على جسم واضح. قف في منتصف الشاشة.';
          _matchScore = 0.0;
          _noseVisible = false;
          _shouldersVisible = false;
          _hipsVisible = false;
          _kneesVisible = false;
          _anklesVisible = false;
        });
        return;
      }

      final pose = poses.first;
      final analysis = _analyzePose(
        pose,
        effectiveImageSize,
      );

      _updateSmoothedLandmarks(pose);
      final metrics = _extractPoseMetrics(_smoothedLandmarks, effectiveImageSize);

      final rawCandidate = _classifyPosture(
        metrics: metrics,
        landmarks: _smoothedLandmarks,
        imageSize: effectiveImageSize,
      );

      final smoothedCandidate = _updateCandidatePosture(rawCandidate);
      final stateDrivenStable = _updatePrayerStateMachine(smoothedCandidate);

      setState(() {
        _latestPose = pose;
        _latestImageSize = effectiveImageSize;
        _latestMetrics = metrics;
        _latestCandidateClassification = smoothedCandidate;
        _stableClassification = stateDrivenStable;
        _statusTitle = analysis.title;
        _statusMessage = analysis.message;
        _matchScore = analysis.score;
        _noseVisible = analysis.noseVisible;
        _shouldersVisible = analysis.shouldersVisible;
        _hipsVisible = analysis.hipsVisible;
        _kneesVisible = analysis.kneesVisible;
        _anklesVisible = analysis.anklesVisible;
      });
    } catch (_) {
      // نتجاهل أخطاء بعض الإطارات الفردية
    } finally {
      _isProcessing = false;
    }
  }

  _PostureClassification _updateCandidatePosture(
      _PostureClassification rawCandidate,
      ) {
    if (rawCandidate.posture == _candidatePosture) {
      _candidateStreak++;
    } else {
      _candidatePosture = rawCandidate.posture;
      _candidateStreak = 1;
    }

    if (rawCandidate.posture == PrayerPosture.unknown) {
      return _PostureClassification(
        posture: PrayerPosture.unknown,
        confidence: rawCandidate.confidence,
        reason: rawCandidate.reason,
      );
    }

    final smoothedConfidence = rawCandidate.confidence *
        (_candidateStreak >= _requiredStableFrames ? 1.0 : 0.75);

    return _PostureClassification(
      posture: rawCandidate.posture,
      confidence: smoothedConfidence.clamp(0.0, 1.0),
      reason:
      '${rawCandidate.reason} (ترشيح ثابت ${_candidateStreak}/${_requiredStableFrames})',
    );
  }

  _PostureClassification _updatePrayerStateMachine(
      _PostureClassification candidate,
      ) {
    final candidatePosture = candidate.posture;
    final currentState = _statePosture;

    if (candidatePosture == PrayerPosture.unknown) {
      return _buildStateClassification(
        posture: _statePosture,
        confidence: (_stableClassification?.confidence ?? 0.0) * 0.98,
        reason: _stableClassification?.reason ?? 'نحتفظ بآخر حالة مستقرة',
      );
    }

    if (currentState == PrayerPosture.unknown) {
      if (_candidateStreak >= _requiredStableFrames) {
        _statePosture = candidatePosture;
        _stateTransitionStreak = 0;
        _lastTransitionCandidate = PrayerPosture.unknown;

        return _buildStateClassification(
          posture: _statePosture,
          confidence: candidate.confidence,
          reason: 'تم تثبيت الحالة الأولى: ${_labelForPosture(_statePosture)}',
        );
      }

      return _buildStateClassification(
        posture: PrayerPosture.unknown,
        confidence: candidate.confidence * 0.6,
        reason:
        'ترشيح أولي: ${_labelForPosture(candidatePosture)} بانتظار التثبيت',
      );
    }

    if (candidatePosture == currentState) {
      _stateTransitionStreak = 0;
      _lastTransitionCandidate = PrayerPosture.unknown;

      return _buildStateClassification(
        posture: currentState,
        confidence: math.max(candidate.confidence, 0.70),
        reason:
        'استمرار في ${_labelForPosture(currentState)} بدون انتقال جديد',
      );
    }

    final allowedNext = _allowedNextPostures(currentState);
    final transitionAllowed = allowedNext.contains(candidatePosture);

    if (!transitionAllowed) {
      return _buildStateClassification(
        posture: currentState,
        confidence: (_stableClassification?.confidence ?? 0.70).clamp(0.0, 1.0),
        reason:
        'تم رفض انتقال غير منطقي: ${_labelForPosture(currentState)} → ${_labelForPosture(candidatePosture)}',
      );
    }

    if (_lastTransitionCandidate == candidatePosture) {
      _stateTransitionStreak++;
    } else {
      _lastTransitionCandidate = candidatePosture;
      _stateTransitionStreak = 1;
    }

    if (_stateTransitionStreak >= _requiredTransitionFrames &&
        _candidateStreak >= _requiredStableFrames) {
      _statePosture = candidatePosture;
      _stateTransitionStreak = 0;
      _lastTransitionCandidate = PrayerPosture.unknown;

      return _buildStateClassification(
        posture: _statePosture,
        confidence: candidate.confidence,
        reason:
        'انتقال منطقي مثبت إلى ${_labelForPosture(_statePosture)}',
      );
    }

    return _buildStateClassification(
      posture: currentState,
      confidence: (_stableClassification?.confidence ?? 0.70).clamp(0.0, 1.0),
      reason:
      'مرشح الانتقال: ${_labelForPosture(candidatePosture)} | progress ${_stateTransitionStreak}/${_requiredTransitionFrames}',
    );
  }

  Set<PrayerPosture> _allowedNextPostures(PrayerPosture current) {
    switch (current) {
      case PrayerPosture.unknown:
        return {
          PrayerPosture.qiyam,
          PrayerPosture.ruku,
          PrayerPosture.sujud,
          PrayerPosture.jalsa,
        };
      case PrayerPosture.qiyam:
        return {
          PrayerPosture.ruku,
          PrayerPosture.jalsa,
        };
      case PrayerPosture.ruku:
        return {
          PrayerPosture.qiyam,
          PrayerPosture.sujud,
          PrayerPosture.jalsa,
        };
      case PrayerPosture.sujud:
        return {
          PrayerPosture.jalsa,
          PrayerPosture.qiyam,
        };
      case PrayerPosture.jalsa:
        return {
          PrayerPosture.sujud,
          PrayerPosture.qiyam,
        };
    }
  }

  _PostureClassification _buildStateClassification({
    required PrayerPosture posture,
    required double confidence,
    required String reason,
  }) {
    return _PostureClassification(
      posture: posture,
      confidence: confidence.clamp(0.0, 1.0),
      reason: reason,
    );
  }

  String _labelForPosture(PrayerPosture posture) {
    switch (posture) {
      case PrayerPosture.qiyam:
        return 'قيام';
      case PrayerPosture.ruku:
        return 'ركوع';
      case PrayerPosture.sujud:
        return 'سجود';
      case PrayerPosture.jalsa:
        return 'جلسة';
      case PrayerPosture.unknown:
        return 'غير محسوم';
    }
  }

  InputImage? _convertCameraImageToInputImage(
      CameraImage image,
      CameraDescription camera,
      ) {
    try {
      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      final imageSize = Size(
        image.width.toDouble(),
        image.height.toDouble(),
      );

      final rotation =
          InputImageRotationValue.fromRawValue(camera.sensorOrientation) ??
              InputImageRotation.rotation0deg;

      final format =
          InputImageFormatValue.fromRawValue(image.format.raw) ??
              InputImageFormat.nv21;

      final metadata = InputImageMetadata(
        size: imageSize,
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes.first.bytesPerRow,
      );

      return InputImage.fromBytes(
        bytes: bytes,
        metadata: metadata,
      );
    } catch (_) {
      return null;
    }
  }

  Size _effectiveImageSizeForDisplay({
    required Size rawImageSize,
    required int sensorOrientation,
  }) {
    if (sensorOrientation == 90 || sensorOrientation == 270) {
      return Size(rawImageSize.height, rawImageSize.width);
    }
    return rawImageSize;
  }

  void _updateSmoothedLandmarks(Pose pose) {
    const trackedTypes = <PoseLandmarkType>{
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

    for (final type in trackedTypes) {
      final lm = pose.landmarks[type];
      if (lm == null) continue;

      final current = Offset(lm.x, lm.y);
      final previous = _smoothedLandmarks[type];

      if (previous == null) {
        _smoothedLandmarks[type] = current;
      } else {
        _smoothedLandmarks[type] = Offset(
          _lerp(previous.dx, current.dx, _smoothingAlpha),
          _lerp(previous.dy, current.dy, _smoothingAlpha),
        );
      }
    }
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t;

  _PoseMetrics? _extractPoseMetrics(
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

    final shoulderMid = _midPoint(leftShoulder, rightShoulder);
    final hipMid = _midPoint(leftHip, rightHip);
    final kneeMid = _midPoint(leftKnee, rightKnee);
    final ankleMid = _midPoint(leftAnkle, rightAnkle);

    final shoulderAngle = (leftShoulder != null && rightShoulder != null)
        ? _lineAngleFromHorizontal(leftShoulder, rightShoulder)
        : null;

    final hipAngle = (leftHip != null && rightHip != null)
        ? _lineAngleFromHorizontal(leftHip, rightHip)
        : null;

    double? leftKneeAngle;
    if (leftHip != null && leftKnee != null && leftAnkle != null) {
      leftKneeAngle = _jointAngle(leftHip, leftKnee, leftAnkle);
    }

    double? rightKneeAngle;
    if (rightHip != null && rightKnee != null && rightAnkle != null) {
      rightKneeAngle = _jointAngle(rightHip, rightKnee, rightAnkle);
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
      spineAngle = _lineAngleFromVertical(shoulderMid, hipMid);
      torsoAngleFromHorizontal = _lineAngleFromHorizontal(shoulderMid, hipMid);
    }

    double? hipBendAngle;
    if (shoulderMid != null && hipMid != null && kneeMid != null) {
      hipBendAngle = _jointAngle(shoulderMid, hipMid, kneeMid);
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

    return _PoseMetrics(
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

  _PostureClassification _classifyPosture({
    required _PoseMetrics? metrics,
    required Map<PoseLandmarkType, Offset> landmarks,
    required Size imageSize,
  }) {
    if (metrics == null) {
      return const _PostureClassification(
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
      return const _PostureClassification(
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

      return _PostureClassification(
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
        (shoulderHeight == null || shoulderHeight < 0.60)) {
      final confidence = _confidenceFromRules(
        values: [
          _scoreRange(spine, 48, 76),
          _scoreRange(knee, 145, 180),
          _scoreRange(torso, 10, 34),
          if (hipBend != null) _scoreRange(hipBend, 92, 145),
        ],
      );

      return _PostureClassification(
        posture: PrayerPosture.ruku,
        confidence: confidence,
        reason: 'انحناء واضح للأمام مع بقاء الساقين شبه مستقيمتين',
      );
    }

    if (knee <= 138 &&
        ((noseHeight != null && noseHeight >= 0.42) ||
            (shoulderHeight != null && shoulderHeight >= 0.48)) &&
        ((hipHeight != null && hipHeight >= 0.54) ||
            (bodyHeightRatio != null && bodyHeightRatio <= 0.56))) {
      final confidence = _confidenceFromRules(
        values: [
          _scoreRange(knee, 55, 128),
          if (noseHeight != null) _scoreRange(noseHeight, 0.45, 0.92),
          if (shoulderHeight != null) _scoreRange(shoulderHeight, 0.50, 0.90),
          if (hipHeight != null) _scoreRange(hipHeight, 0.56, 0.92),
          if (bodyHeightRatio != null) _scoreRange(bodyHeightRatio, 0.18, 0.55),
        ],
      );

      return _PostureClassification(
        posture: PrayerPosture.sujud,
        confidence: confidence,
        reason: 'انخفاض واضح للرأس والكتفين مع انكماش قوي في الجسم',
      );
    }

    if (spine <= 36 &&
        knee >= 65 &&
        knee <= 138 &&
        (hipHeight != null && hipHeight >= 0.46) &&
        (torsoDropRatio == null || torsoDropRatio <= 0.26)) {
      final confidence = _confidenceFromRules(
        values: [
          _scoreRange(spine, 0, 28),
          _scoreRange(knee, 78, 128),
          if (hipHeight != null) _scoreRange(hipHeight, 0.48, 0.82),
          if (torsoDropRatio != null) _scoreRange(torsoDropRatio, 0.08, 0.23),
        ],
      );

      return _PostureClassification(
        posture: PrayerPosture.jalsa,
        confidence: confidence,
        reason: 'الجذع أقرب للعمودي مع ثني واضح في الركبتين والورك',
      );
    }

    return _PostureClassification(
      posture: PrayerPosture.unknown,
      confidence: 0.20,
      reason:
      'القياسات الحالية بينية: spine=${spine.toStringAsFixed(1)} knee=${knee.toStringAsFixed(1)}',
    );
  }

  Offset? _midPoint(Offset? a, Offset? b) {
    if (a == null || b == null) return null;
    return Offset(
      (a.dx + b.dx) / 2,
      (a.dy + b.dy) / 2,
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

  double _lineAngleFromHorizontal(Offset a, Offset b) {
    final radians = math.atan2(b.dy - a.dy, b.dx - a.dx);
    final degrees = radians * 180 / math.pi;
    return degrees.abs();
  }

  double _lineAngleFromVertical(Offset a, Offset b) {
    final dx = b.dx - a.dx;
    final dy = b.dy - a.dy;
    final radians = math.atan2(dx.abs(), dy.abs());
    return radians * 180 / math.pi;
  }

  double _jointAngle(Offset a, Offset b, Offset c) {
    final ab = Offset(a.dx - b.dx, a.dy - b.dy);
    final cb = Offset(c.dx - b.dx, c.dy - b.dy);

    final dot = (ab.dx * cb.dx) + (ab.dy * cb.dy);
    final magAB = math.sqrt((ab.dx * ab.dx) + (ab.dy * ab.dy));
    final magCB = math.sqrt((cb.dx * cb.dx) + (cb.dy * cb.dy));

    if (magAB == 0 || magCB == 0) return 0.0;

    final cosine = (dot / (magAB * magCB)).clamp(-1.0, 1.0);
    return math.acos(cosine) * 180 / math.pi;
  }

  _PoseAnalysis _analyzePose(Pose pose, Size imageSize) {
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

    String title = 'هيكل جزئي';
    String message = 'نلتقط بعض النقاط، لكننا نحتاج رؤية أوضح للجسم كله.';

    if (!noseVisible || !shouldersVisible || !hipsVisible) {
      return _PoseAnalysis(
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

    final leftEdge = _minValues(pointsX);
    final rightEdge = _maxValues(pointsX);
    final topEdge = _minValues(pointsY);
    final bottomEdge = _maxValues(pointsY);

    final marginX = imageSize.width * 0.06;
    final marginTop = imageSize.height * 0.06;
    final marginBottom = imageSize.height * 0.05;

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

    return _PoseAnalysis(
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

  double _minValues(List<double> values) => values.reduce(math.min);
  double _maxValues(List<double> values) => values.reduce(math.max);

  @override
  Widget build(BuildContext context) {
    final controller = _cameraController;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('مساعد الصلاة التجريبي'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: _isInitializing
          ? const Center(child: CircularProgressIndicator())
          : _permissionDenied
          ? const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'تم رفض إذن الكاميرا.\nاسمح للتطبيق باستخدام الكاميرا ثم أعد المحاولة.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      )
          : controller == null || !controller.value.isInitialized
          ? const Center(
        child: Text(
          'تعذر تشغيل الكاميرا',
          style: TextStyle(color: Colors.white),
        ),
      )
          : SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final previewSize = controller.value.previewSize!;
            final displayPreviewSize = Size(
              previewSize.height,
              previewSize.width,
            );

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              child: Column(
                children: [
                  _InfoCard(
                    title: _statusTitle,
                    message: _statusMessage,
                    score: _matchScore,
                  ),
                  const SizedBox(height: 12),
                  _PostureBanner(
                    classification: _stableClassification,
                    candidate: _latestCandidateClassification,
                    streak: _candidateStreak,
                    requiredStableFrames: _requiredStableFrames,
                    currentState: _statePosture,
                    allowedNext: _allowedNextPostures(_statePosture),
                    transitionStreak: _stateTransitionStreak,
                    requiredTransitionFrames:
                    _requiredTransitionFrames,
                  ),
                  const SizedBox(height: 12),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: constraints.maxHeight * 0.34,
                    ),
                    child: AspectRatio(
                      aspectRatio:
                      displayPreviewSize.width /
                          displayPreviewSize.height,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.orange.withOpacity(
                                    0.35,
                                  ),
                                  width: 2,
                                ),
                                borderRadius:
                                BorderRadius.circular(18),
                              ),
                              child: FittedBox(
                                fit: BoxFit.contain,
                                child: SizedBox(
                                  width: displayPreviewSize.width,
                                  height: displayPreviewSize.height,
                                  child: CameraPreview(controller),
                                ),
                              ),
                            ),
                            if (_latestImageSize != null)
                              CustomPaint(
                                painter: _PosePainter(
                                  landmarks:
                                  _smoothedLandmarks.isEmpty
                                      ? null
                                      : _smoothedLandmarks,
                                  imageSize: _latestImageSize!,
                                  isFrontCamera: _isFrontCamera,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _MetricsPanel(
                    metrics: _latestMetrics,
                    stableClassification: _stableClassification,
                    candidateClassification:
                    _latestCandidateClassification,
                    streak: _candidateStreak,
                    statePosture: _statePosture,
                    transitionStreak: _stateTransitionStreak,
                    allowedNext: _allowedNextPostures(_statePosture),
                  ),
                  const SizedBox(height: 12),
                  _LandmarkStatusCard(
                    noseVisible: _noseVisible,
                    shouldersVisible: _shouldersVisible,
                    hipsVisible: _hipsVisible,
                    kneesVisible: _kneesVisible,
                    anklesVisible: _anklesVisible,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String message;
  final double score;

  const _InfoCard({
    required this.title,
    required this.message,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (score * 100).round();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.62),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFF5A623),
          width: 1.2,
        ),
      ),
      child: Column(
        children: [
          Text(
            'حالة المطابقة: $title',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: score.clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFFF5A623),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'جودة المطابقة: $percent%',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _PostureBanner extends StatelessWidget {
  final _PostureClassification? classification;
  final _PostureClassification? candidate;
  final int streak;
  final int requiredStableFrames;
  final PrayerPosture currentState;
  final Set<PrayerPosture> allowedNext;
  final int transitionStreak;
  final int requiredTransitionFrames;

  const _PostureBanner({
    required this.classification,
    required this.candidate,
    required this.streak,
    required this.requiredStableFrames,
    required this.currentState,
    required this.allowedNext,
    required this.transitionStreak,
    required this.requiredTransitionFrames,
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

  String _labelFor(PrayerPosture posture) {
    switch (posture) {
      case PrayerPosture.qiyam:
        return 'قيام';
      case PrayerPosture.ruku:
        return 'ركوع';
      case PrayerPosture.sujud:
        return 'سجود';
      case PrayerPosture.jalsa:
        return 'جلسة';
      case PrayerPosture.unknown:
        return 'غير محسوم';
    }
  }

  @override
  Widget build(BuildContext context) {
    final stable = classification;
    final posture = stable?.posture ?? PrayerPosture.unknown;
    final color = _colorFor(posture);
    final confidence = ((stable?.confidence ?? 0.0) * 100).round();
    final candidateLabel = _labelFor(candidate?.posture ?? PrayerPosture.unknown);
    final allowedText = allowedNext.map(_labelFor).join(' ← ');

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
            'الوضعية المستقرة: ${_labelFor(posture)}',
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
            'State: ${_labelFor(currentState)} | transition: $transitionStreak / $requiredTransitionFrames',
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            'Allowed next: $allowedText',
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _MetricsPanel extends StatelessWidget {
  final _PoseMetrics? metrics;
  final _PostureClassification? stableClassification;
  final _PostureClassification? candidateClassification;
  final int streak;
  final PrayerPosture statePosture;
  final int transitionStreak;
  final Set<PrayerPosture> allowedNext;

  const _MetricsPanel({
    required this.metrics,
    required this.stableClassification,
    required this.candidateClassification,
    required this.streak,
    required this.statePosture,
    required this.transitionStreak,
    required this.allowedNext,
  });

  String _fmt(double? value) {
    if (value == null) return '--';
    return value.toStringAsFixed(1);
  }

  String _labelFor(PrayerPosture posture) {
    switch (posture) {
      case PrayerPosture.qiyam:
        return 'قيام';
      case PrayerPosture.ruku:
        return 'ركوع';
      case PrayerPosture.sujud:
        return 'سجود';
      case PrayerPosture.jalsa:
        return 'جلسة';
      case PrayerPosture.unknown:
        return 'غير محسوم';
    }
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
    final allowedText = allowedNext.map(_labelFor).join(', ');

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
            'Pose Metrics & State Debug',
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
              'Stable: ${stableClassification?.reason ?? '--'}',
              style: const TextStyle(color: Colors.white60, fontSize: 11),
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Candidate: ${candidateClassification?.reason ?? '--'} | streak=$streak',
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'State posture: ${_labelFor(statePosture)} | transition streak=$transitionStreak',
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Allowed next: $allowedText',
              style: const TextStyle(color: Colors.white38, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

class _LandmarkStatusCard extends StatelessWidget {
  final bool noseVisible;
  final bool shouldersVisible;
  final bool hipsVisible;
  final bool kneesVisible;
  final bool anklesVisible;

  const _LandmarkStatusCard({
    required this.noseVisible,
    required this.shouldersVisible,
    required this.hipsVisible,
    required this.kneesVisible,
    required this.anklesVisible,
  });

  Widget _item(String label, bool ok) {
    return Row(
      children: [
        Icon(
          ok ? Icons.check_circle : Icons.cancel,
          color: ok ? Colors.greenAccent : Colors.redAccent,
          size: 18,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.62),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF5A623),
          width: 1.0,
        ),
      ),
      child: Column(
        children: [
          const Text(
            'حالة النقاط الملتقطة',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          _item('الرأس / الأنف', noseVisible),
          const SizedBox(height: 6),
          _item('الكتفان', shouldersVisible),
          const SizedBox(height: 6),
          _item('الورك', hipsVisible),
          const SizedBox(height: 6),
          _item('الركبتان', kneesVisible),
          const SizedBox(height: 6),
          _item('الكاحلان', anklesVisible),
        ],
      ),
    );
  }
}

class _PosePainter extends CustomPainter {
  final Map<PoseLandmarkType, Offset>? landmarks;
  final Size imageSize;
  final bool isFrontCamera;

  _PosePainter({
    required this.landmarks,
    required this.imageSize,
    required this.isFrontCamera,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (landmarks == null || landmarks!.isEmpty) return;

    final pointPaint = Paint()
      ..color = const Color(0xFFFFB300)
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = Colors.greenAccent
      ..strokeWidth = 3.2
      ..style = PaintingStyle.stroke;

    final strongLinePaint = Paint()
      ..color = const Color(0xFF00E676)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    Offset? mapLandmark(PoseLandmarkType type) {
      final lm = landmarks![type];
      if (lm == null) return null;

      double dx = (lm.dx / imageSize.width) * size.width;
      final dy = (lm.dy / imageSize.height) * size.height;

      if (isFrontCamera) {
        dx = size.width - dx;
      }

      return Offset(dx, dy);
    }

    void drawLine(
        PoseLandmarkType a,
        PoseLandmarkType b, {
          bool strong = false,
        }) {
      final p1 = mapLandmark(a);
      final p2 = mapLandmark(b);
      if (p1 == null || p2 == null) return;
      canvas.drawLine(p1, p2, strong ? strongLinePaint : linePaint);
    }

    const connections = [
      [PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder],
      [PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow],
      [PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist],
      [PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow],
      [PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist],
      [PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip],
      [PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip],
      [PoseLandmarkType.leftHip, PoseLandmarkType.rightHip],
      [PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee],
      [PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle],
      [PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee],
      [PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle],
    ];

    for (final pair in connections) {
      drawLine(
        pair[0],
        pair[1],
        strong: (pair[0] == PoseLandmarkType.leftShoulder &&
            pair[1] == PoseLandmarkType.rightShoulder) ||
            (pair[0] == PoseLandmarkType.leftHip &&
                pair[1] == PoseLandmarkType.rightHip),
      );
    }

    for (final type in landmarks!.keys) {
      final p = mapLandmark(type);
      if (p == null) continue;
      canvas.drawCircle(p, 5.5, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _PosePainter oldDelegate) {
    return oldDelegate.landmarks != landmarks ||
        oldDelegate.imageSize != imageSize ||
        oldDelegate.isFrontCamera != isFrontCamera;
  }
}

class _PoseAnalysis {
  final String title;
  final String message;
  final double score;
  final bool noseVisible;
  final bool shouldersVisible;
  final bool hipsVisible;
  final bool kneesVisible;
  final bool anklesVisible;

  const _PoseAnalysis({
    required this.title,
    required this.message,
    required this.score,
    required this.noseVisible,
    required this.shouldersVisible,
    required this.hipsVisible,
    required this.kneesVisible,
    required this.anklesVisible,
  });
}

class _PoseMetrics {
  final double? shoulderAngle;
  final double? hipAngle;
  final double? kneeAngle;
  final double? spineAngle;
  final double? torsoAngleFromHorizontal;
  final double? hipBendAngle;
  final double? leftKneeAngle;
  final double? rightKneeAngle;
  final double? bodyHeightRatio;
  final double? shoulderHeightRatio;
  final double? hipHeightRatio;
  final double? noseHeightRatio;
  final double? torsoDropRatio;

  const _PoseMetrics({
    required this.shoulderAngle,
    required this.hipAngle,
    required this.kneeAngle,
    required this.spineAngle,
    required this.torsoAngleFromHorizontal,
    required this.hipBendAngle,
    required this.leftKneeAngle,
    required this.rightKneeAngle,
    required this.bodyHeightRatio,
    required this.shoulderHeightRatio,
    required this.hipHeightRatio,
    required this.noseHeightRatio,
    required this.torsoDropRatio,
  });
}

enum PrayerPosture {
  qiyam,
  ruku,
  sujud,
  jalsa,
  unknown,
}

class _PostureClassification {
  final PrayerPosture posture;
  final double confidence;
  final String reason;

  const _PostureClassification({
    required this.posture,
    required this.confidence,
    required this.reason,
  });
}