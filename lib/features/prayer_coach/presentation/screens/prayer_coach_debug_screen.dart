import 'dart:typed_data';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../application/controllers/prayer_coach_controller.dart';
import '../../application/state/prayer_coach_debug_state.dart';
import '../widgets/camera_pose_preview.dart';
import '../widgets/info_card.dart';
import '../widgets/landmark_status_card.dart';
import '../widgets/metrics_panel.dart';
import '../widgets/posture_banner.dart';

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

  final PrayerCoachController _coachController = PrayerCoachController();

  static const int _requiredStableFrames = 4;
  static const int _requiredTransitionFrames = 5;
  static const int _requiredSequenceFrames = 5;

  bool _isInitializing = true;
  bool _permissionDenied = false;
  bool _isProcessing = false;
  bool _isFrontCamera = true;

  int _sensorOrientation = 0;
  int _frameCounter = 0;

  PrayerCoachDebugState _viewState = PrayerCoachDebugState.initial();

  @override
  void initState() {
    super.initState();
    _initializeEverything();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _poseDetector.close();
    _coachController.reset();
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
          _viewState = _viewState.copyWith(
            statusTitle: 'لا توجد كاميرا',
            statusMessage: 'تعذر العثور على كاميرا في الجهاز.',
          );
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
        _viewState = _viewState.copyWith(
          statusTitle: 'جاهز',
          statusMessage:
              'قف أمام الهاتف بشكل طبيعي. الهدف الآن أن يطابق الهيكل جسمك بالكامل.',
        );
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _viewState = _viewState.copyWith(
          statusTitle: 'حدث خطأ',
          statusMessage: 'تعذر تشغيل الكاميرا: $e',
        );
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
        final state = _coachController.buildNoPoseState(
          imageSize: effectiveImageSize,
        );

        setState(() {
          _viewState = state;
        });
        return;
      }

      final pose = poses.first;

      final state = _coachController.processPose(
        pose: pose,
        imageSize: effectiveImageSize,
      );

      setState(() {
        _viewState = state;
      });
    } catch (_) {
      // تجاهل أخطاء بعض الإطارات
    } finally {
      _isProcessing = false;
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
      final Uint8List bytes = allBytes.done().buffer.asUint8List();

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

  @override
  Widget build(BuildContext context) {
    final controller = _cameraController;
    final state = _viewState;

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
                                InfoCard(
                                  title: state.statusTitle,
                                  message: state.statusMessage,
                                  score: state.matchScore,
                                ),
                                const SizedBox(height: 12),
                                PostureBanner(
                                  classification: state.stableClassification,
                                  candidate: state.candidateClassification,
                                  streak: state.candidateStreak,
                                  requiredStableFrames: _requiredStableFrames,
                                  currentState: state.statePosture,
                                  allowedNext: state.allowedNextPostures,
                                  transitionStreak: state.transitionStreak,
                                  requiredTransitionFrames:
                                      _requiredTransitionFrames,
                                  sequenceState: state.sequenceState,
                                  sequenceCandidate: state.sequenceCandidate,
                                  sequenceCandidateStreak:
                                      state.sequenceCandidateStreak,
                                  expectedSequenceNext:
                                      state.expectedNextSequence,
                                  requiredSequenceFrames:
                                      _requiredSequenceFrames,
                                ),
                                const SizedBox(height: 12),
                                CameraPosePreview(
                                  controller: controller,
                                  displayPreviewSize: displayPreviewSize,
                                  latestImageSize: state.latestImageSize,
                                  smoothedLandmarks: state.smoothedLandmarks,
                                  isFrontCamera: _isFrontCamera,
                                  maxHeight: constraints.maxHeight * 0.34,
                                ),
                                const SizedBox(height: 12),
                                MetricsPanel(
                                  metrics: state.metrics,
                                  stableClassification:
                                      state.stableClassification,
                                  candidateClassification:
                                      state.candidateClassification,
                                  streak: state.candidateStreak,
                                  statePosture: state.statePosture,
                                  transitionStreak: state.transitionStreak,
                                  allowedNext: state.allowedNextPostures,
                                  sequenceState: state.sequenceState,
                                  sequenceCandidate: state.sequenceCandidate,
                                  sequenceCandidateStreak:
                                      state.sequenceCandidateStreak,
                                  expectedSequenceNext:
                                      state.expectedNextSequence,
                                ),
                                const SizedBox(height: 12),
                                LandmarkStatusCard(
                                  noseVisible: state.noseVisible,
                                  shouldersVisible: state.shouldersVisible,
                                  hipsVisible: state.hipsVisible,
                                  kneesVisible: state.kneesVisible,
                                  anklesVisible: state.anklesVisible,
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