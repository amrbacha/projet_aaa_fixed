
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:provider/provider.dart';
import 'package:projet_aaa_fixed/core/models/quran_data.dart';
import 'package:projet_aaa_fixed/core/providers/audio_provider.dart';
import 'package:projet_aaa_fixed/core/providers/theme_provider.dart';
import 'package:projet_aaa_fixed/core/services/assistant_service.dart';
import 'package:projet_aaa_fixed/core/services/local_storage_service.dart';
import 'package:projet_aaa_fixed/core/services/quran_service.dart';
import 'package:projet_aaa_fixed/core/services/smart_quran_service.dart';
import 'package:projet_aaa_fixed/core/services/windowed_wird_recitation_engine.dart' as wird_matcher;
import 'package:projet_aaa_fixed/features/prayer_coach/application/controllers/prayer_coach_controller.dart';
import 'package:projet_aaa_fixed/features/prayer_coach/application/state/prayer_coach_debug_state.dart';
import 'package:projet_aaa_fixed/features/prayer_coach/domain/enums/prayer_posture.dart';
import 'package:projet_aaa_fixed/features/prayer_coach/presentation/widgets/camera_pose_preview.dart';
import 'package:projet_aaa_fixed/features/prayer_session/controllers/prayer_session_controller.dart';
import 'package:projet_aaa_fixed/features/prayer_session/services/smart_prayer_engine.dart';
import 'package:projet_aaa_fixed/widgets/islamic_background.dart';
import '../../../l10n/app_localizations.dart';

enum PrayerPosition { standing, ruku, sujud, sitting, takbir, unknown }

class PrayerFlowStep {
  final String title;
  final String? content;
  final String? surahName;
  final int? ayahNumber;
  final int rakahNumber;
  final bool isRecitation;
  final int? surahNumber;
  final bool isAction;
  final PrayerPosition expectedPosition;
  final int repetitionCount;
  final Duration pauseAfter;
  final int? wirdIndex;
  PrayerFlowStep(this.title, this.rakahNumber,
      {this.content,
      this.surahName,
      this.ayahNumber,
      this.isRecitation = false,
      this.surahNumber,
      this.isAction = false,
      this.expectedPosition = PrayerPosition.standing,
      this.repetitionCount = 1,
      this.pauseAfter = const Duration(milliseconds: 1000),
      this.wirdIndex});
}

class PrayerScreen extends StatefulWidget {
  final String prayerName;
  final List<Ayah> wird;
  const PrayerScreen({super.key, required this.prayerName, required this.wird});
  @override
  State<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends State<PrayerScreen> {
  int _currentStepIndex = 0;
  List<PrayerFlowStep> _fullPrayerFlow = [];
  bool _isLoading = true, _isCalibrating = true, _prayerStarted = false, _isExecutingStep = false;
  late bool _isCameraEnabled;
  bool _isAnisListening = true, _isQariAudioEnabled = true;
  double _qariSpeed = 1.0, _transitionSpeedFactor = 1.0, _quranFontSize = 44;
  int _fontMode = 1;

  CameraController? _cameraController;
  final AssistantService _anis = AssistantService();
  final QuranService _quranService = QuranService();
  final SmartQuranService _smartQuran = SmartQuranService();
  final PoseDetector _poseDetector = PoseDetector(
    options: PoseDetectorOptions(model: PoseDetectionModel.accurate, mode: PoseDetectionMode.stream),
  );
  final PrayerCoachController _coachController = PrayerCoachController();

  bool _isCameraReady = false, _isFrontCamera = true, _isProcessingFrame = false;
  int _frameCounter = 0;
  PrayerCoachDebugState _coachState = PrayerCoachDebugState.initial();
  String _guidanceMessage = 'قف أمام الهاتف حتى تتم المطابقة.', _lastSpokenGuidance = '', _lastRecognizedText = '', _matchStatus = '';
  DateTime _lastGuidanceSpokenAt = DateTime.fromMillisecondsSinceEpoch(0);
  bool _isListeningForUser = false;
  PrayerSessionController? _sessionController;
  SmartPrayerEngine? _smartPrayerEngine;
  static const int _maxVerseRetries = 2;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAllResources());
  }

  void _setFontMode(int mode) {
    setState(() {
      _fontMode = mode;
      _quranFontSize = mode == 0 ? 36 : mode == 1 ? 44 : 60;
    });
  }

  Future<void> _loadAllResources() async {
    final settings = Provider.of<ThemeProvider>(context, listen: false).settings;
    final l10n = AppLocalizations.of(context);
    _isCameraEnabled = settings.isCameraOn;
    _isCalibrating = _isCameraEnabled;
    final allVerses = await _quranService.getAllVerses(excludeFatiha: false);
    final fatihaVerses = allVerses.where((a) => a.surahNumber == 1).toList();
    if (l10n != null) _fullPrayerFlow = _buildFullPrayerFlow(widget.prayerName, widget.wird, fatihaVerses, l10n);
    if (_isCameraEnabled) await _initCamera();
    if (_isCalibrating) {
      await _speakGuidance('قف أمام الهاتف حتى تتم المطابقة.');
      _setupCalibrationTakbirListening();
    } else {
      await _startPrayer();
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;
    final front = cameras.firstWhere((c) => c.lensDirection == CameraLensDirection.front, orElse: () => cameras.first);
    _isFrontCamera = front.lensDirection == CameraLensDirection.front;
    _cameraController = CameraController(front, ResolutionPreset.high, enableAudio: false, imageFormatGroup: ImageFormatGroup.nv21);
    await _cameraController!.initialize();
    await _cameraController!.startImageStream((image) async => _processCameraImage(image, front));
    if (mounted) setState(() => _isCameraReady = true);
  }

  Future<void> _processCameraImage(CameraImage image, CameraDescription camera) async {
    if (!_isCameraEnabled || !mounted || _isProcessingFrame) return;
    _frameCounter++;
    if (_frameCounter % 2 != 0) return;
    _isProcessingFrame = true;
    try {
      final inputImage = _convertCameraImageToInputImage(image, camera);
      if (inputImage == null) return;
      final poses = await _poseDetector.processImage(inputImage);
      final effectiveSize = _effectiveImageSizeForDisplay(rawImageSize: Size(image.width.toDouble(), image.height.toDouble()), sensorOrientation: camera.sensorOrientation);
      final state = poses.isEmpty ? _coachController.buildNoPoseState(imageSize: effectiveSize) : _coachController.processPose(pose: poses.first, imageSize: effectiveSize);
      final guidance = _buildGuidanceMessage(state);
      if (!mounted) return;
      setState(() {
        _coachState = state;
        _guidanceMessage = guidance;
      });
      if (_isCalibrating) await _speakGuidance(guidance);
      if (_prayerStarted && _isTrackablePrayerPosture(state.statePosture)) {
        _smartPrayerEngine?.markPoseMatched();
        _trySmartAdvance();
      }
    } finally {
      _isProcessingFrame = false;
    }
  }

  InputImage? _convertCameraImageToInputImage(CameraImage image, CameraDescription camera) {
    try {
      final WriteBuffer allBytes = WriteBuffer();
      for (final plane in image.planes) { allBytes.putUint8List(plane.bytes); }
      final bytes = allBytes.done().buffer.asUint8List();
      final imageSize = Size(image.width.toDouble(), image.height.toDouble());
      final rotation = InputImageRotationValue.fromRawValue(camera.sensorOrientation) ?? InputImageRotation.rotation0deg;
      final format = InputImageFormatValue.fromRawValue(image.format.raw) ?? InputImageFormat.nv21;
      final metadata = InputImageMetadata(size: imageSize, rotation: rotation, format: format, bytesPerRow: image.planes.first.bytesPerRow);
      return InputImage.fromBytes(bytes: bytes, metadata: metadata);
    } catch (_) { return null; }
  }

  Size _effectiveImageSizeForDisplay({required Size rawImageSize, required int sensorOrientation}) {
    if (sensorOrientation == 90 || sensorOrientation == 270) return Size(rawImageSize.height, rawImageSize.width);
    return rawImageSize;
  }

  String _buildGuidanceMessage(PrayerCoachDebugState state) {
    if (state.matchScore < 0.25) return 'قف في منتصف الشاشة حتى يظهر جسمك بوضوح.';
    final msg = state.statusMessage.toLowerCase();
    if (msg.contains('left') || msg.contains('right')) return 'تحرك قليلًا نحو الوسط.';
    if (msg.contains('close')) return 'ابتعد قليلًا عن الهاتف.';
    if (msg.contains('far')) return 'اقترب قليلًا من الهاتف.';
    if (_isCalibrationReady) return 'نحن جاهزون الآن. كبّر لبدء الصلاة أو اضغط زر البدء.';
    return state.statusMessage.isNotEmpty ? state.statusMessage : 'اضبط تمركزك أمام الكاميرا.';
  }

  bool get _isCalibrationReady =>
      _coachState.matchScore >= 0.72 &&
      (_coachState.statePosture == PrayerPosture.qiyam || _coachState.statePosture == PrayerPosture.unknown) &&
      _coachState.shouldersVisible &&
      _coachState.hipsVisible;

  Future<void> _speakGuidance(String message) async {
    if (message.trim().isEmpty) return;
    final now = DateTime.now();
    if (_lastSpokenGuidance == message && now.difference(_lastGuidanceSpokenAt).inSeconds < 3) return;
    _lastSpokenGuidance = message;
    _lastGuidanceSpokenAt = now;
    if (!_isAnisListening) return;
    await _anis.speak(message);
  }

  void _setupCalibrationTakbirListening() async {
    if (!_isAnisListening) { _smartQuran.stopListening(); return; }
    await _smartQuran.startListening((text) {
      if (!_isCalibrating || !_isCalibrationReady || !mounted) return;
      final cleaned = _smartQuran.cleanText(text);
      if (cleaned.contains('الله اكبر') || cleaned.contains('الله أكبر')) _startPrayer();
    });
  }

  bool _isTrackablePrayerPosture(PrayerPosture p) => p == PrayerPosture.qiyam || p == PrayerPosture.ruku || p == PrayerPosture.sujud || p == PrayerPosture.jalsa;

  Future<void> _startPrayer() async {
    if (_prayerStarted) return;
    await _smartQuran.stopListening();
    if (mounted) setState(() { _isCalibrating = false; _prayerStarted = true; _matchStatus = 'بدأت الصلاة'; });
    _sessionController = PrayerSessionController();
    _sessionController!.initialize(cameraEnabled: _isCameraEnabled, micEnabled: _isAnisListening);
    _smartPrayerEngine = SmartPrayerEngine(controller: _sessionController!);
    final audio = Provider.of<AudioProvider>(context, listen: false);
    await audio.setPlaybackRate(_qariSpeed);
    final l10n = AppLocalizations.of(context)!;
    await _anis.speak(l10n.prayerStartConfirm);
    await Future.delayed(const Duration(milliseconds: 700));
    await _executeCurrentStep();
  }

  Future<void> _executeCurrentStep() async {
    if (!_prayerStarted || _isExecutingStep || _currentStepIndex >= _fullPrayerFlow.length) return;
    _isExecutingStep = true;
    await _smartPrayerEngine?.stopListening();
    if (mounted) setState(() { _isListeningForUser = false; _lastRecognizedText = ''; });
    final step = _fullPrayerFlow[_currentStepIndex];
    final audio = Provider.of<AudioProvider>(context, listen: false);
    _smartPrayerEngine?.beginStep(step: step, fallbackDuration: step.isRecitation ? const Duration(seconds: 20) : const Duration(seconds: 12));
    if (!_isCameraEnabled && !_isAnisListening) {
      await _executeTimedStep(step, audio);
    } else if (step.isRecitation && step.wirdIndex != null) {
      await _executeWirdRecitationStep(step, audio, retryCount: 0);
    } else if (step.isRecitation) {
      await _executeGenericRecitationStep(step, audio);
    } else {
      await _executeActionStep(step, audio);
    }
    _isExecutingStep = false;
  }

  Future<void> _executeTimedStep(PrayerFlowStep step, AudioProvider audio) async {
    if (_isQariAudioEnabled) {
      if (step.isRecitation && step.surahNumber != null && step.ayahNumber != null) {
        await audio.playVerse(step.surahNumber!, step.ayahNumber!);
        await audio.onPlayerComplete.first;
      } else if (step.content != null && step.content!.isNotEmpty) {
        for (int i = 0; i < step.repetitionCount; i++) { await audio.speakActionAndWait(step.content!); }
      }
    } else {
      await Future.delayed(step.pauseAfter);
    }
    _smartPrayerEngine?.markQariFinished();
    _trySmartAdvance(forceFallbackIfNeeded: true);
  }

  Future<void> _executeGenericRecitationStep(PrayerFlowStep step, AudioProvider audio) async {
    if (_isQariAudioEnabled && step.surahNumber != null && step.ayahNumber != null) {
      await audio.playVerse(step.surahNumber!, step.ayahNumber!);
      await audio.onPlayerComplete.first;
    } else {
      await Future.delayed(Duration(milliseconds: (1800 / _qariSpeed).toInt()));
    }
    _smartPrayerEngine?.markQariFinished();
    _trySmartAdvance(forceFallbackIfNeeded: true);
  }

  Future<void> _executeWirdRecitationStep(PrayerFlowStep step, AudioProvider audio, {required int retryCount}) async {
    if (step.wirdIndex == null || _smartPrayerEngine == null) { await _executeGenericRecitationStep(step, audio); return; }
    bool shouldRetry = false;
    if (_isAnisListening) {
      await _smartPrayerEngine!.startWirdListening(
        wird: widget.wird,
        wirdIndex: step.wirdIndex!,
        onDecision: (text, decision) {
          if (!mounted) return;
          setState(() {
            _isListeningForUser = true;
            _lastRecognizedText = text;
            _matchStatus = decision.reason;
          });
          if (decision.type == wird_matcher.WirdRecitationDecisionType.retryCurrentAyah) shouldRetry = true;
          _trySmartAdvance();
        },
      );
    }
    if (_isQariAudioEnabled && step.surahNumber != null && step.ayahNumber != null) {
      await audio.playVerse(step.surahNumber!, step.ayahNumber!);
      await audio.onPlayerComplete.first;
    } else {
      await Future.delayed(Duration(milliseconds: (1800 / _qariSpeed).toInt()));
    }
    _smartPrayerEngine!.markQariFinished();
    _trySmartAdvance();
    await Future.delayed(const Duration(milliseconds: 700));
    final result = _smartPrayerEngine!.evaluate(step: step, cameraEnabled: _isCameraEnabled, micEnabled: _isAnisListening);
    if (!result.shouldAdvance && shouldRetry && retryCount < _maxVerseRetries) {
      if (mounted) setState(() => _matchStatus = 'أعد الآية الحالية من الورد للتصحيح');
      await _smartPrayerEngine!.stopListening();
      await Future.delayed(const Duration(milliseconds: 250));
      await _executeWirdRecitationStep(step, audio, retryCount: retryCount + 1);
      return;
    }
    if (!result.shouldAdvance) {
      _smartPrayerEngine!.applyAdvanceReason(SmartAdvanceReason.timedFallback);
      _advanceToNextStep();
    }
  }

  Future<void> _executeActionStep(PrayerFlowStep step, AudioProvider audio) async {
    if (_isQariAudioEnabled && step.content != null && step.content!.isNotEmpty) {
      for (int i = 0; i < step.repetitionCount; i++) {
        await audio.speakActionAndWait(step.content!);
        await Future.delayed(Duration(milliseconds: (950 / _transitionSpeedFactor).toInt()));
      }
    } else {
      await Future.delayed(step.pauseAfter);
    }
    _smartPrayerEngine?.markQariFinished();
    if (!_needsPoseForStep(step)) { _trySmartAdvance(forceFallbackIfNeeded: true); return; }
    await Future.delayed(const Duration(milliseconds: 500));
    _trySmartAdvance();
  }

  bool _needsPoseForStep(PrayerFlowStep step) => step.isAction && step.expectedPosition != PrayerPosition.standing;

  PrayerPosition _currentTrackedPosition() {
    switch (_coachState.statePosture) {
      case PrayerPosture.qiyam:
        return PrayerPosition.standing;
      case PrayerPosture.ruku:
        return PrayerPosition.ruku;
      case PrayerPosture.sujud:
        return PrayerPosition.sujud;
      case PrayerPosture.jalsa:
        return PrayerPosition.sitting;
      case PrayerPosture.unknown:
        return PrayerPosition.unknown;
    }
  }

  void _trySmartAdvance({bool forceFallbackIfNeeded = false}) {
    if (_smartPrayerEngine == null || _currentStepIndex >= _fullPrayerFlow.length) return;
    final step = _fullPrayerFlow[_currentStepIndex];
    final trackedPosition = _currentTrackedPosition();
    if (_needsPoseForStep(step) && trackedPosition == step.expectedPosition) _smartPrayerEngine?.markPoseMatched();
    final result = _smartPrayerEngine!.evaluate(step: step, cameraEnabled: _isCameraEnabled, micEnabled: _isAnisListening);
    if (mounted) setState(() => _matchStatus = result.message);
    if (result.shouldAdvance && result.reason != null) {
      _smartPrayerEngine!.applyAdvanceReason(result.reason!);
      _advanceToNextStep();
      return;
    }
    if (forceFallbackIfNeeded && !_needsPoseForStep(step)) {
      _smartPrayerEngine!.applyAdvanceReason(SmartAdvanceReason.timedFallback);
      _advanceToNextStep();
    }
  }

  void _advanceToNextStep() {
    if (!mounted || !_prayerStarted) return;
    if (_currentStepIndex < _fullPrayerFlow.length - 1) {
      setState(() { _currentStepIndex++; _isListeningForUser = false; _lastRecognizedText = ''; });
      unawaited(_executeCurrentStep());
    } else {
      unawaited(_finishPrayer());
    }
  }

  Future<void> _finishPrayer() async {
    await LocalStorageService.markPrayerAsCompleted(widget.prayerName);
    await _smartPrayerEngine?.dispose();
    await _anis.speak('تقبل الله طاعتك. تم إكمال الصلاة بنجاح.');
    if (mounted) context.pop();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _poseDetector.close();
    _coachController.reset();
    _smartPrayerEngine?.dispose();
    _smartQuran.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(backgroundColor: Color(0xFF0D3B2E), body: Center(child: CircularProgressIndicator(color: Color(0xFFF5A623))));
    }
    final l10n = AppLocalizations.of(context)!;
    final step = _fullPrayerFlow[_currentStepIndex];
    return IslamicBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.black45,
          elevation: 0,
          leading: IconButton(icon: const Icon(Icons.close, color: Colors.white70), onPressed: () => context.pop()),
          title: Text(_isCalibrating ? 'تحديد الوضعية والسرعة' : step.title, style: GoogleFonts.amiri(color: const Color(0xFFF5A623), fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: _isCalibrating ? _buildCalibrationUI(l10n) : _buildPrayerUI(step),
      ),
    );
  }

  Widget _buildCalibrationUI(AppLocalizations l10n) {
    return SingleChildScrollView(
      child: Column(children: [
        const SizedBox(height: 15),
        _buildFontSizeSelector(),
        const SizedBox(height: 18),
        _buildCalibrationPreview(),
        const SizedBox(height: 16),
        _buildCalibrationGuidanceCard(),
        const SizedBox(height: 18),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF5A623), padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35))),
          onPressed: _startPrayer,
          icon: const Icon(Icons.play_arrow_rounded, color: Colors.black, size: 30),
          label: Text('ابدأ الصلاة الآن', style: GoogleFonts.amiri(color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 30),
      ]),
    );
  }

  Widget _buildFontSizeSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(25), border: Border.all(color: Colors.white10)),
      child: Column(children: [
        Text('قياس خط الورد', style: GoogleFonts.amiri(color: const Color(0xFFF5A623), fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: _fontModeButton('صغير', 0)),
          const SizedBox(width: 8),
          Expanded(child: _fontModeButton('كبير', 1)),
          const SizedBox(width: 8),
          Expanded(child: _fontModeButton('كبير جدًا', 2)),
        ]),
      ]),
    );
  }

  Widget _fontModeButton(String label, int mode) {
    final selected = _fontMode == mode;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: selected ? const Color(0xFFF5A623) : Colors.white10, foregroundColor: selected ? Colors.black : Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
      onPressed: () => _setFontMode(mode),
      child: Text(label, textAlign: TextAlign.center),
    );
  }

  Widget _buildCalibrationPreview() {
    if (!_isCameraReady || _cameraController == null) {
      return Container(height: MediaQuery.of(context).size.height * 0.35, margin: const EdgeInsets.symmetric(horizontal: 20), decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(28)), child: Center(child: Text('الكاميرا غير جاهزة', style: GoogleFonts.amiri(color: Colors.white70))));
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: CameraPosePreview(
        controller: _cameraController!,
        displayPreviewSize: Size(_cameraController!.value.previewSize!.height, _cameraController!.value.previewSize!.width),
        latestImageSize: _coachState.latestImageSize,
        smoothedLandmarks: _coachState.smoothedLandmarks,
        isFrontCamera: _isFrontCamera,
        maxHeight: MediaQuery.of(context).size.height * 0.40,
      ),
    );
  }

  Widget _buildCalibrationGuidanceCard() {
    final ready = _isCalibrationReady;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: ready ? Colors.green.withOpacity(0.12) : Colors.black38, borderRadius: BorderRadius.circular(22), border: Border.all(color: ready ? Colors.greenAccent.withOpacity(0.35) : const Color(0xFFF5A623).withOpacity(0.28))),
      child: Column(children: [
        Text(ready ? 'نحن جاهزون الآن' : 'تعليمات المعايرة', style: GoogleFonts.amiri(color: ready ? Colors.greenAccent : const Color(0xFFF5A623), fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(_guidanceMessage, textAlign: TextAlign.center, style: GoogleFonts.amiri(color: Colors.white, fontSize: 16, height: 1.6)),
      ]),
    );
  }

  Widget _buildPrayerUI(PrayerFlowStep step) {
    return Column(children: [
      const SizedBox(height: 10),
      if (_isCameraEnabled) _buildPrayerTrackingBubble(),
      const SizedBox(height: 10),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.32), borderRadius: BorderRadius.circular(22), border: Border.all(color: Colors.white10)),
                child: Text(step.content ?? '', textAlign: TextAlign.center, style: GoogleFonts.amiri(color: Colors.white, fontSize: _quranFontSize, height: 2.1, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ),
      ),
      const SizedBox(height: 24),
    ]);
  }

  Widget _buildPrayerTrackingBubble() {
    if (!_isCameraReady || _cameraController == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 16, end: 16),
      child: Row(children: [
        Container(
          width: 112,
          height: 112,
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFF4DFF88).withOpacity(0.85), width: 2.2)),
          child: ClipOval(
            child: CameraPosePreview(
              controller: _cameraController!,
              displayPreviewSize: Size(_cameraController!.value.previewSize!.height, _cameraController!.value.previewSize!.width),
              latestImageSize: _coachState.latestImageSize,
              smoothedLandmarks: _coachState.smoothedLandmarks,
              isFrontCamera: _isFrontCamera,
              maxHeight: 112,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text('الوضعية الحالية: ${_postureLabel(_coachState.statePosture)}', style: GoogleFonts.amiri(color: Colors.white, fontSize: 15))),
      ]),
    );
  }

  String _postureLabel(PrayerPosture posture) {
    switch (posture) {
      case PrayerPosture.qiyam: return 'قيام';
      case PrayerPosture.ruku: return 'ركوع';
      case PrayerPosture.sujud: return 'سجود';
      case PrayerPosture.jalsa: return 'جلوس';
      case PrayerPosture.unknown: return 'غير واضحة';
    }
  }

  List<PrayerFlowStep> _buildFullPrayerFlow(String prayerName, List<Ayah> wird, List<Ayah> fatiha, AppLocalizations l10n) {
    final flow = <PrayerFlowStep>[];
    final name = prayerName.toLowerCase();
    final totalRakahs = (name.contains('fajr') || name.contains('فجر')) ? 2 : (name.contains('maghrib') || name.contains('مغرب')) ? 3 : 4;
    final firstRakahWird = wird.isEmpty ? <Ayah>[] : wird.sublist(0, (wird.length / 2).ceil());
    final secondRakahWird = wird.isEmpty ? <Ayah>[] : wird.sublist((wird.length / 2).ceil());
    for (int r = 1; r <= totalRakahs; r++) {
      for (final f in fatiha) {
        flow.add(PrayerFlowStep('سورة الفاتحة', r, content: f.text, surahName: 'سورة الفاتحة', ayahNumber: f.ayahNumber, isRecitation: true, surahNumber: 1));
      }
      final rakahWird = r == 1 ? firstRakahWird : secondRakahWird;
      if (r <= 2 && rakahWird.isNotEmpty) {
        for (final a in rakahWird) {
          flow.add(PrayerFlowStep('تلاوة الورد', r, content: a.text, surahName: a.surahName, ayahNumber: a.ayahNumber, isRecitation: true, surahNumber: a.surahNumber, wirdIndex: widget.wird.indexOf(a)));
        }
      }
      flow.add(PrayerFlowStep('الركوع', r, content: 'سُبْحَانَ رَبِّيَ الْعَظِيمِ', isAction: true, expectedPosition: PrayerPosition.ruku, repetitionCount: 3));
      flow.add(PrayerFlowStep('السجود الأول', r, content: 'سُبْحَانَ رَبِّيَ الْأَعْلَى', isAction: true, expectedPosition: PrayerPosition.sujud, repetitionCount: 3));
      flow.add(PrayerFlowStep('الجلوس', r, content: 'رَبِّ اغْفِرْ لِي', isAction: true, expectedPosition: PrayerPosition.sitting));
      flow.add(PrayerFlowStep('السجود الثاني', r, content: 'سُبْحَانَ رَبِّيَ الْأَعْلَى', isAction: true, expectedPosition: PrayerPosition.sujud, repetitionCount: 3));
    }
    return flow;
  }
}
