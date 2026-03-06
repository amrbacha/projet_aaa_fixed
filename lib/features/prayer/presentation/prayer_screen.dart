import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:projet_aaa/core/models/quran_data.dart';
import 'package:projet_aaa/core/services/wird_service.dart';
import 'package:projet_aaa/core/services/local_storage_service.dart';
import 'package:projet_aaa/core/services/smart_quran_service.dart';
import 'package:projet_aaa/core/providers/audio_provider.dart';
import 'package:projet_aaa/core/services/pose_detection_service.dart';
import 'package:projet_aaa/core/services/camera_utils.dart';
import 'package:projet_aaa/core/providers/theme_provider.dart';
import 'package:projet_aaa/core/services/assistant_service.dart';
import 'package:projet_aaa/core/services/voice_calibration_service.dart';

class PrayerFlowStep {
  final String title;
  final String? content;
  final int rakahNumber;
  final bool isRecitation;
  final int? surahNumber;
  final int? ayahNumber;
  final bool isAction;
  final PrayerPosition expectedPosition;
  final int repetitionCount;

  PrayerFlowStep(this.title, this.rakahNumber, {
    this.content, 
    this.isRecitation = false, 
    this.surahNumber, 
    this.ayahNumber, 
    this.isAction = false,
    this.expectedPosition = PrayerPosition.standing,
    this.repetitionCount = 1,
  });
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
  bool _isLoading = true;
  bool _isCalibrating = true;
  bool _prayerStarted = false;
  
  late bool _isCameraEnabled;
  bool _isAudioEnabled = true;
  double _userSpeedFactor = 1.0;
  
  CameraController? _cameraController;
  final PoseDetectionService _poseService = PoseDetectionService();
  final SmartQuranService _smartQuran = SmartQuranService();
  final AssistantService _anis = AssistantService();
  bool _isCameraReady = false;
  PoseVisibility? _lastVisibility;
  bool _isListeningForUser = false;
  String _lastRecognizedText = "";
  Timer? _manualTransitionTimer;
  DateTime? _lastGuidanceTime;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = Provider.of<ThemeProvider>(context, listen: false).settings;
    _isCameraEnabled = settings.isCameraOn;
    _isCalibrating = _isCameraEnabled;
    _userSpeedFactor = await VoiceCalibrationService.getUserSpeedFactor();
    
    _fullPrayerFlow = _buildFullPrayerFlow(widget.prayerName, widget.wird);
    
    if (_isCameraEnabled) await _initCamera();
    
    if (_isCalibrating) {
      _anis.speakPositionGuidance('start_prompt');
      _startListeningForStartCommand();
    } else {
      _startPrayer();
    }
    
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;
      final front = cameras.firstWhere((c) => c.lensDirection == CameraLensDirection.front, orElse: () => cameras.first);
      
      _cameraController = CameraController(front, ResolutionPreset.medium, enableAudio: false, imageFormatGroup: ImageFormatGroup.yuv420);
      await _cameraController!.initialize();
      
      _cameraController!.startImageStream((image) async {
        if (!_isCameraEnabled || !mounted) return;
        final inputImage = CameraUtils.inputImageFromCameraImage(image, front);
        if (inputImage != null) {
          final visibility = await _poseService.analyzePose(inputImage);
          if (mounted) {
            setState(() => _lastVisibility = visibility);
            if (_isCalibrating) _handleCalibrationGuidance(visibility);
            
            if (!_prayerStarted && visibility.position == PrayerPosition.takbir) {
              _startPrayer();
            } else if (_prayerStarted) {
              _handlePositionChange(visibility.position);
            }
          }
        }
      });
      if (mounted) setState(() => _isCameraReady = true);
    } catch (e) { debugPrint("Camera Error: $e"); }
  }

  void _handleCalibrationGuidance(PoseVisibility v) {
    if (_lastGuidanceTime != null && DateTime.now().difference(_lastGuidanceTime!) < const Duration(seconds: 5)) return;
    _lastGuidanceTime = DateTime.now();
    if (v.isTooClose) _anis.speakPositionGuidance('too_close');
    else if (v.needsTiltUp) _anis.speakPositionGuidance('tilt_up');
    else if (v.needsTiltDown) _anis.speakPositionGuidance('tilt_down');
    else if (v.isFullBody) _anis.speakPositionGuidance('good');
  }

  void _startListeningForStartCommand() async {
    await _smartQuran.startListening((text) {
      if (mounted && !_prayerStarted && (text.contains("الله أكبر") || text.contains("اكبر"))) {
        _startPrayer();
      }
    });
  }

  void _startPrayer() async {
    if (_prayerStarted) return;
    _smartQuran.stopListening();
    if (mounted) setState(() { _isCalibrating = false; _prayerStarted = true; });
    await _anis.speak("تقبل الله، لنبدأ الصلاة");
    _executeCurrentStep();
  }

  void _handlePositionChange(PrayerPosition pos) {
    if (pos == PrayerPosition.unknown) return;
    final step = _fullPrayerFlow[_currentStepIndex];
    if (pos == step.expectedPosition && step.isAction && step.expectedPosition != PrayerPosition.standing) {
      _nextStep();
    }
  }

  Future<void> _executeCurrentStep() async {
    if (_currentStepIndex >= _fullPrayerFlow.length || !_prayerStarted) return;
    final step = _fullPrayerFlow[_currentStepIndex];
    final audio = Provider.of<AudioProvider>(context, listen: false);

    _smartQuran.stopListening();
    if (mounted) setState(() { _isListeningForUser = false; _lastRecognizedText = ""; });

    if (_isAudioEnabled) {
      if (step.isRecitation) {
        await audio.playVerse(step.surahNumber!, step.ayahNumber!);
        _startSimultaneousListening(step);
      } else {
        await _executeActionWithRepetition(step, audio);
      }
    } else {
      _startManualTimer();
    }
  }

  void _startSimultaneousListening(PrayerFlowStep step) async {
    if (mounted) setState(() => _isListeningForUser = true);
    await _smartQuran.startListening((text) {
      if (mounted) {
        setState(() => _lastRecognizedText = text);
        if (_smartQuran.checkSimilarity(step.content ?? "", text) > 0.8) {
          _smartQuran.stopListening();
          _nextStep();
        }
      }
    });
    
    final audio = Provider.of<AudioProvider>(context, listen: false);
    audio.onPlayerComplete.first.then((_) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted && _isListeningForUser) _nextStep();
      });
    });
  }

  Future<void> _executeActionWithRepetition(PrayerFlowStep step, AudioProvider audio) async {
    for (int i = 0; i < step.repetitionCount; i++) {
      if (!mounted) return;
      await audio.speakAction(step.content!);
      if (i < step.repetitionCount - 1) {
        await Future.delayed(Duration(milliseconds: (1800 / _userSpeedFactor).toInt()));
      }
    }
    _nextStep();
  }

  void _nextStep() {
    if (!mounted || !_prayerStarted) return;
    if (_currentStepIndex < _fullPrayerFlow.length - 1) {
      setState(() => _currentStepIndex++);
      _executeCurrentStep();
    } else {
      _finishPrayer();
    }
  }

  void _startManualTimer() {
    _manualTransitionTimer?.cancel();
    _manualTransitionTimer = Timer(const Duration(seconds: 5), () => _nextStep());
  }

  Future<void> _finishPrayer() async {
    await LocalStorageService.markPrayerAsCompleted(widget.prayerName);
    if (mounted) {
      await _anis.speak("تقبل الله طاعتكم، تم تسجيل صلاتكم بنجاح");
      if (mounted) context.go('/main-menu');
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _poseService.dispose();
    _smartQuran.stopListening();
    _manualTransitionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator(color: Color(0xFFF5A623))));
    final step = _fullPrayerFlow[_currentStepIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF0D3B2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.close, color: Colors.white70), onPressed: () => context.pop()),
        title: Text(_isCalibrating ? "المعايرة والاستعداد" : step.title, style: GoogleFonts.amiri(color: const Color(0xFFF5A623), fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _isCalibrating ? _buildCalibrationUI() : _buildPrayerUI(step),
    );
  }

  Widget _buildCalibrationUI() {
    return Column(
      children: [
        Expanded(
          flex: 3,
          child: Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              height: MediaQuery.of(context).size.height * 0.5,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30), 
                border: Border.all(color: const Color(0xFFF5A623), width: 4),
                boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 20)],
              ),
              child: ClipRRect(borderRadius: BorderRadius.circular(26), child: _isCameraReady && _cameraController != null ? CameraPreview(_cameraController!) : Container(color: Colors.black)),
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_getStatusText(), textAlign: TextAlign.center, style: GoogleFonts.amiri(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text("قل 'الله أكبر' أو ارفع يديك للتكبير", style: GoogleFonts.amiri(color: Colors.white54, fontSize: 14)),
                const SizedBox(height: 25),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF5A623), 
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: _startPrayer,
                  icon: const Icon(Icons.play_arrow, color: Colors.black),
                  label: Text("ابدأ الآن", style: GoogleFonts.amiri(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  String _getStatusText() {
    if (_lastVisibility == null) return "بانتظار ظهورك أمام الكاميرا...";
    if (_lastVisibility!.isTooClose) return "أنت قريب جداً! تراجع للخلف";
    if (_lastVisibility!.needsTiltUp) return "ارفع وجه الهاتف للأعلى قليلاً";
    if (_lastVisibility!.needsTiltDown) return "أمل الهاتف للأسفل قليلاً";
    if (_lastVisibility!.isFullBody) return "الوضعية ممتازة! كبّر للبدء";
    return "جاري التحقق من الوضعية...";
  }

  Widget _buildPrayerUI(PrayerFlowStep step) {
    return Stack(
      children: [
        if (_isCameraEnabled && _isCameraReady)
          Positioned(
            top: 20, left: 20,
            child: Container(
              width: 90, height: 90,
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFFF5A623).withOpacity(0.5), width: 2)),
              child: ClipOval(child: CameraPreview(_cameraController!)),
            ),
          ),
        Column(
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("الركعة ${_toArabicOrdinal(step.rakahNumber)}", style: GoogleFonts.amiri(color: const Color(0xFFF5A623), fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 30),
                      Text(step.content ?? "", textAlign: TextAlign.center, style: GoogleFonts.amiri(color: Colors.white, fontSize: 34, height: 1.6, fontWeight: FontWeight.w500)),
                      if (_isListeningForUser)
                        Container(
                          margin: const EdgeInsets.only(top: 40),
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                          decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.mic, color: Colors.redAccent, size: 18),
                              const SizedBox(width: 10),
                              Text("أكمل الآية بصوتك...", style: GoogleFonts.amiri(color: Colors.redAccent, fontSize: 16)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            _buildBottomControls(),
            const SizedBox(height: 20),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.white10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildControlIcon(_isAudioEnabled ? Icons.volume_up : Icons.volume_off, "الصوت", _isAudioEnabled, () => setState(() => _isAudioEnabled = !_isAudioEnabled)),
          _buildControlIcon(Icons.skip_next, "تخطي", true, _nextStep),
          _buildControlIcon(_isCameraEnabled ? Icons.videocam : Icons.videocam_off, "الكاميرا", _isCameraEnabled, () {
             setState(() {
                _isCameraEnabled = !_isCameraEnabled;
                if (_isCameraEnabled) _initCamera(); else _cameraController?.dispose();
             });
          }),
        ],
      ),
    );
  }

  Widget _buildControlIcon(IconData icon, String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? const Color(0xFFF5A623) : Colors.white24, size: 24),
          const SizedBox(height: 4),
          Text(label, style: GoogleFonts.amiri(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  String _toArabicOrdinal(int n) => {1: 'الأولى', 2: 'الثانية', 3: 'الثالثة', 4: 'الرابعة'}[n] ?? n.toString();

  List<PrayerFlowStep> _buildFullPrayerFlow(String prayerName, List<Ayah> wird) {
    List<PrayerFlowStep> flow = [];
    final prayer = prayerName.toLowerCase();
    int totalRakahs = prayer.contains('fajr') ? 2 : (prayer.contains('maghrib') ? 3 : 4);

    for (int r = 1; r <= totalRakahs; r++) {
      if (r == 1) flow.add(PrayerFlowStep("دعاء الاستفتاح", r, content: "سبحانك اللهم وبحمدك وتبارك اسمك وتعالى جدك ولا إله غيرك", isAction: true));
      flow.add(PrayerFlowStep("الفاتحة", r, content: "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ. الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ...", isRecitation: true, surahNumber: 1, ayahNumber: 1));
      flow.add(PrayerFlowStep("تأمين", r, content: "آمِين", isAction: true));
      if (r <= 2) {
        for (var a in wird) { flow.add(PrayerFlowStep("الورد", r, content: a.text, isRecitation: true, surahNumber: a.surahNumber, ayahNumber: a.ayahNumber)); }
      }
      flow.add(PrayerFlowStep("الركوع", r, content: "سبحان ربي العظيم", isAction: true, expectedPosition: PrayerPosition.ruku, repetitionCount: 3));
      flow.add(PrayerFlowStep("الرفع", r, content: "سمع الله لمن حمده. ربنا ولك الحمد", isAction: true, expectedPosition: PrayerPosition.standing));
      flow.add(PrayerFlowStep("السجود الأول", r, content: "سبحان ربي الأعلى", isAction: true, expectedPosition: PrayerPosition.sujud, repetitionCount: 3));
      flow.add(PrayerFlowStep("الجلسة", r, content: "رب اغفر لي", isAction: true, expectedPosition: PrayerPosition.sitting, repetitionCount: 2));
      flow.add(PrayerFlowStep("السجود الثاني", r, content: "سبحان ربي الأعلى", isAction: true, expectedPosition: PrayerPosition.sujud, repetitionCount: 3));
      
      if (r == 2 && totalRakahs > 2) flow.add(PrayerFlowStep("التشهد الأوسط", r, content: "التحيات لله والصلوات والطيبات...", isAction: true, expectedPosition: PrayerPosition.sitting));
      if (r == totalRakahs) {
        flow.add(PrayerFlowStep("التشهد الأخير", r, content: "التحيات لله... اللهم صل على محمد...", isAction: true, expectedPosition: PrayerPosition.sitting));
        flow.add(PrayerFlowStep("التسليم يميناً", r, content: "السلام عليكم ورحمة الله", isAction: true, expectedPosition: PrayerPosition.sitting));
        flow.add(PrayerFlowStep("التسليم يساراً", r, content: "السلام عليكم ورحمة الله", isAction: true, expectedPosition: PrayerPosition.sitting));
      }
    }
    return flow;
  }
}
