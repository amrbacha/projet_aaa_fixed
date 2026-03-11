import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:projet_aaa_fixed/core/models/quran_data.dart';
import 'package:projet_aaa_fixed/core/services/smart_quran_service.dart';
import 'package:projet_aaa_fixed/core/providers/audio_provider.dart';
import 'package:projet_aaa_fixed/core/services/pose_detection_service.dart';
import 'package:projet_aaa_fixed/core/services/camera_utils.dart';
import 'package:projet_aaa_fixed/core/providers/theme_provider.dart';
import 'package:projet_aaa_fixed/core/services/assistant_service.dart';
import 'package:projet_aaa_fixed/core/services/quran_service.dart';
import 'package:projet_aaa_fixed/core/services/local_storage_service.dart';
import 'package:projet_aaa_fixed/widgets/islamic_background.dart';
import '../../../l10n/app_localizations.dart';

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

  PrayerFlowStep(this.title, this.rakahNumber, {
    this.content, 
    this.surahName,
    this.ayahNumber,
    this.isRecitation = false,
    this.surahNumber, 
    this.isAction = false,
    this.expectedPosition = PrayerPosition.standing,
    this.repetitionCount = 1,
    this.pauseAfter = const Duration(milliseconds: 1000),
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
  bool _isAnisListening = true;
  bool _isQariAudioEnabled = true;
  
  double _qariSpeed = 1.0; 
  double _transitionSpeedFactor = 1.0; 

  CameraController? _cameraController;
  final PoseDetectionService _poseService = PoseDetectionService();
  final SmartQuranService _smartQuran = SmartQuranService();
  final AssistantService _anis = AssistantService();
  final QuranService _quranService = QuranService();

  bool _isCameraReady = false;
  PoseVisibility? _lastVisibility;
  
  // متغيرات المصحح الذكي
  bool _isListeningForUser = false;
  String _lastRecognizedText = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAllResources());
  }

  Future<void> _loadAllResources() async {
    final settings = Provider.of<ThemeProvider>(context, listen: false).settings;
    final l10n = AppLocalizations.of(context);
    
    _isCameraEnabled = settings.isCameraOn;
    _isCalibrating = _isCameraEnabled;

    final allVerses = await _quranService.getAllVerses(excludeFatiha: false);
    final fatihaVerses = allVerses.where((a) => a.surahNumber == 1).toList();

    if (l10n != null) {
      _fullPrayerFlow = _buildFullPrayerFlow(widget.prayerName, widget.wird, fatihaVerses, l10n);
    }
    
    if (_isCameraEnabled) await _initCamera();
    
    if (_isCalibrating) {
      await _anis.speakPositionGuidance('start_prompt');
      _setupAnisListening();
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
            if (!_prayerStarted && visibility.position == PrayerPosition.takbir) {
              _startPrayer();
            } else if (_prayerStarted) {
              _handleDynamicTransitions(visibility.position);
            }
          }
        }
      });
      if (mounted) setState(() => _isCameraReady = true);
    } catch (e) { debugPrint("Camera Error: $e"); }
  }

  void _setupAnisListening() async {
    if (!_isAnisListening) {
      _smartQuran.stopListening();
      return;
    }
    await _smartQuran.startListening((text) {
      if (mounted && !_prayerStarted && _isAnisListening && (text.contains("الله أكبر") || text.contains("اكبر"))) {
        _startPrayer();
      }
    });
  }

  void _startPrayer() async {
    if (_prayerStarted) return;
    _smartQuran.stopListening();
    if (mounted) setState(() { _isCalibrating = false; _prayerStarted = true; });
    
    final audio = Provider.of<AudioProvider>(context, listen: false);
    await audio.setPlaybackRate(_qariSpeed);
    
    final l10n = AppLocalizations.of(context)!;
    await _anis.speak(l10n.prayerStartConfirm);
    await Future.delayed(const Duration(seconds: 1));
    _executeCurrentStep();
  }

  void _handleDynamicTransitions(PrayerPosition pos) {
    if (pos == PrayerPosition.unknown) return;
    final step = _fullPrayerFlow[_currentStepIndex];
    if (step.isAction && pos == step.expectedPosition && pos != PrayerPosition.standing) {
       _nextStep();
    }
  }

  Future<void> _executeCurrentStep() async {
    if (_currentStepIndex >= _fullPrayerFlow.length || !_prayerStarted) return;
    final step = _fullPrayerFlow[_currentStepIndex];
    final audio = Provider.of<AudioProvider>(context, listen: false);
    
    _smartQuran.stopListening();
    if (mounted) setState(() { _isListeningForUser = false; _lastRecognizedText = ""; });

    if (_isQariAudioEnabled) {
      if (step.isRecitation) {
        await audio.playVerse(step.surahNumber!, step.ayahNumber!);
        
        // تفعيل المصحح الذكي أثناء التلاوة
        _startRecitationMonitoring(step);

        await audio.onPlayerComplete.first;
        await Future.delayed(Duration(milliseconds: (1500 / _transitionSpeedFactor).toInt()));
        _nextStep();
      } else {
        await _executeActionWithAudio(step, audio);
      }
    } else {
      // إذا كان الصوت معطلاً، المصحح الذكي هو المحرك الأساسي
      if (step.isRecitation) {
        _startRecitationMonitoring(step);
      } else {
        await Future.delayed(Duration(seconds: (step.content?.length ?? 5) ~/ (4 * _transitionSpeedFactor).toInt() + 1));
        _nextStep();
      }
    }
  }

  void _startRecitationMonitoring(PrayerFlowStep step) async {
    if (mounted) setState(() => _isListeningForUser = true);
    await _smartQuran.startListening((text) {
      if (mounted) {
        setState(() => _lastRecognizedText = text);
        // إذا تطابقت التلاوة بنسبة عالية، ننتقل تلقائياً (تصحيح ذكي)
        if (_smartQuran.checkSimilarity(step.content ?? "", text) > 0.85) {
          _smartQuran.stopListening();
          _nextStep();
        }
      }
    });
  }

  Future<void> _executeActionWithAudio(PrayerFlowStep step, AudioProvider audio) async {
    for (int i = 0; i < step.repetitionCount; i++) {
      if (!mounted) return;
      await audio.speakActionAndWait(step.content!);
      await Future.delayed(Duration(milliseconds: (1200 / _transitionSpeedFactor).toInt()));
    }
    await Future.delayed(Duration(milliseconds: (step.pauseAfter.inMilliseconds / _transitionSpeedFactor).toInt()));
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

  Future<void> _finishPrayer() async {
    await LocalStorageService.markPrayerAsCompleted(widget.prayerName);
    await _anis.speak("تقبل الله طاعتك. تم إكمال الصلاة بنجاح.");
    if (mounted) context.pop(); 
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _poseService.dispose();
    _smartQuran.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(backgroundColor: Color(0xFF0D3B2E), body: Center(child: CircularProgressIndicator(color: Color(0xFFF5A623))));
    final l10n = AppLocalizations.of(context)!;
    final step = _fullPrayerFlow[_currentStepIndex];

    return IslamicBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.black45,
          elevation: 0,
          leading: IconButton(icon: const Icon(Icons.close, color: Colors.white70), onPressed: () => context.pop()),
          title: Text(_isCalibrating ? "تحديد الوضعية والسرعة" : step.title, style: GoogleFonts.amiri(color: const Color(0xFFF5A623), fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: _isCalibrating ? _buildCalibrationUI(l10n) : _buildPrayerUI(step, l10n),
      ),
    );
  }

  Widget _buildCalibrationUI(AppLocalizations l10n) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 15),
          _buildQuickSettingsPanel(),
          const SizedBox(height: 15),
          _buildSpeedSettingsPanel(),
          const SizedBox(height: 20),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              height: MediaQuery.of(context).size.height * 0.35,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: const Color(0xFFF5A623), width: 3),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(27),
                child: _isCameraReady && _cameraController != null 
                    ? CameraPreview(_cameraController!)
                    : Container(color: Colors.black87),
              ),
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF5A623), padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35))),
            onPressed: _startPrayer,
            icon: const Icon(Icons.play_arrow_rounded, color: Colors.black, size: 30),
            label: Text("ابدأ الصلاة الآن", style: GoogleFonts.amiri(color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildQuickSettingsPanel() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(25), border: Border.all(color: Colors.white10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildToggleItem(icon: _isAnisListening ? Icons.mic : Icons.mic_off, label: "أنيس", value: _isAnisListening, onTap: () { setState(() => _isAnisListening = !_isAnisListening); _setupAnisListening(); }),
          _buildToggleItem(icon: _isQariAudioEnabled ? Icons.volume_up : Icons.volume_off, label: "المقرئ", value: _isQariAudioEnabled, onTap: () => setState(() => _isQariAudioEnabled = !_isQariAudioEnabled)),
          _buildToggleItem(icon: _isCameraEnabled ? Icons.videocam : Icons.videocam_off, label: "الكاميرا", value: _isCameraEnabled, onTap: () { setState(() => _isCameraEnabled = !_isCameraEnabled); if (_isCameraEnabled) _initCamera(); else _cameraController?.dispose(); }),
        ],
      ),
    );
  }

  Widget _buildSpeedSettingsPanel() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(25), border: Border.all(color: Colors.white10)),
      child: Column(
        children: [
          _buildSpeedSlider("سرعة تلاوة المقرئ", _qariSpeed, 0.75, 1.25, (v) => setState(() => _qariSpeed = v)),
          const Divider(color: Colors.white10, height: 25),
          _buildSpeedSlider("سرعة انتقال الأركان", _transitionSpeedFactor, 0.75, 1.5, (v) => setState(() => _transitionSpeedFactor = v)),
        ],
      ),
    );
  }

  Widget _buildSpeedSlider(String label, double value, double min, double max, Function(double) onChanged) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: GoogleFonts.amiri(color: Colors.white70, fontSize: 14)),
            Text(value == 1.0 ? "طبيعي" : value > 1.0 ? "سريع" : "هادئ", style: GoogleFonts.amiri(color: const Color(0xFFF5A623), fontSize: 12)),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: 4,
          activeColor: const Color(0xFFF5A623),
          inactiveColor: Colors.white10,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildToggleItem({required IconData icon, required String label, required bool value, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AnimatedContainer(duration: const Duration(milliseconds: 300), padding: const EdgeInsets.all(10), decoration: BoxDecoration(shape: BoxShape.circle, color: value ? const Color(0xFFF5A623).withOpacity(0.2) : Colors.white10, border: Border.all(color: value ? const Color(0xFFF5A623) : Colors.transparent)), child: Icon(icon, color: value ? const Color(0xFFF5A623) : Colors.white60, size: 24)),
          const SizedBox(height: 5),
          Text(label, style: GoogleFonts.amiri(color: Colors.white70, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildPrayerUI(PrayerFlowStep step, AppLocalizations l10n) {
    return Column(
      children: [
        const SizedBox(height: 20),
        if (step.isRecitation && step.surahName != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(color: const Color(0xFFF5A623).withOpacity(0.15), borderRadius: BorderRadius.circular(15), border: Border.all(color: const Color(0xFFF5A623).withOpacity(0.3))),
            child: Text("${step.surahName} - آية ${step.ayahNumber}", style: GoogleFonts.amiri(color: const Color(0xFFF5A623), fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        const SizedBox(height: 20),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Center(
              child: SingleChildScrollView(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: Text(step.content ?? "", key: ValueKey(step.content), textAlign: TextAlign.center, style: GoogleFonts.amiri(color: Colors.white, fontSize: 32, height: 1.8, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ),
        ),
        
        // إظهار مؤشر "المصحح الذكي" عندما يستمع النظام للمصلي
        if (_isListeningForUser)
          _buildSmartCorrectorUI(),

        _buildBottomControls(l10n),
        const SizedBox(height: 50),
      ],
    );
  }

  Widget _buildSmartCorrectorUI() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.mic, color: Colors.redAccent, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _lastRecognizedText.isEmpty ? "أكمل التلاوة بصوتك..." : _lastRecognizedText,
              style: GoogleFonts.amiri(color: Colors.white70, fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls(AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildControlBtn(_isQariAudioEnabled ? Icons.volume_up : Icons.volume_off, () => setState(() => _isQariAudioEnabled = !_isQariAudioEnabled)),
        const SizedBox(width: 25),
        FloatingActionButton(backgroundColor: const Color(0xFFF5A623), child: const Icon(Icons.skip_next, color: Colors.black, size: 30), onPressed: _nextStep),
        const SizedBox(width: 25),
        _buildControlBtn(_isCameraEnabled ? Icons.videocam : Icons.videocam_off, () { setState(() => _isCameraEnabled = !_isCameraEnabled); if (_isCameraEnabled) _initCamera(); else _cameraController?.dispose(); }),
      ],
    );
  }

  Widget _buildControlBtn(IconData icon, VoidCallback onTap) {
    return IconButton(icon: Icon(icon, color: Colors.white70, size: 28), onPressed: onTap);
  }

  List<PrayerFlowStep> _buildFullPrayerFlow(String prayerName, List<Ayah> wird, List<Ayah> fatiha, AppLocalizations l10n) {
    List<PrayerFlowStep> flow = [];
    final name = prayerName.toLowerCase();
    int totalRakahs = (name.contains('fajr') || name.contains('فجر')) ? 2 
                    : (name.contains('maghrib') || name.contains('مغرب')) ? 3 : 4;

    for (int r = 1; r <= totalRakahs; r++) {
      flow.add(PrayerFlowStep(r == 1 ? "تكبيرة الإحرام" : "تكبيرة القيام", r, content: "اللَّهُ أَكْبَرُ", isAction: true));
      if (r == 1) flow.add(PrayerFlowStep(l10n.istiftahDua, r, content: "سُبْحَانَكَ اللَّهُمَّ وَبِحَمْدِكَ، وَتَبَارَكَ اسْمُكَ، وَتَعَالَى جَدُّكَ، وَلَا إِلَهَ غَيْرُكَ", isAction: true));
      if (r == 1) flow.add(PrayerFlowStep("الاستعاذة", r, content: "أَعُوذُ بِاللَّهِ مِنَ الشَّيْطَانِ الرَّجِيمِ", isAction: true));
      flow.add(PrayerFlowStep("البسملة", r, content: "بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ", isAction: true));
      for (var f in fatiha) {
        flow.add(PrayerFlowStep("سورة الفاتحة", r, content: f.text, surahName: "سورة الفاتحة", ayahNumber: f.ayahNumber, isRecitation: true, surahNumber: 1));
      }
      flow.add(PrayerFlowStep(l10n.amin, r, content: "آمِين", isAction: true));
      if (r <= 2 && wird.isNotEmpty) {
        flow.add(PrayerFlowStep("البسملة", r, content: "بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ", isAction: true));
        for (var a in wird) {
          flow.add(PrayerFlowStep("تلاوة الورد", r, content: a.text, surahName: a.surahName, ayahNumber: a.ayahNumber, isRecitation: true, surahNumber: a.surahNumber));
        }
      }
      flow.add(PrayerFlowStep("التكبير للركوع", r, content: "اللَّهُ أَكْبَرُ", isAction: true));
      flow.add(PrayerFlowStep(l10n.rukuLabel, r, content: "سُبْحَانَ رَبِّيَ الْعَظِيمِ", isAction: true, expectedPosition: PrayerPosition.ruku, repetitionCount: 3));
      flow.add(PrayerFlowStep("الرفع من الركوع", r, content: "سَمِعَ اللَّهُ لِمَنْ حَمِدَهُ", isAction: true, expectedPosition: PrayerPosition.standing));
      flow.add(PrayerFlowStep("التحميد", r, content: "رَبَّنَا وَلَكَ الْحَمْدُ", isAction: true, expectedPosition: PrayerPosition.standing, pauseAfter: const Duration(milliseconds: 1500)));
      flow.add(PrayerFlowStep("التكبير للسجود", r, content: "اللَّهُ أَكْبَرُ", isAction: true));
      flow.add(PrayerFlowStep(l10n.sujud1Label, r, content: "سُبْحَانَ رَبِّيَ الْأَعْلَى", isAction: true, expectedPosition: PrayerPosition.sujud, repetitionCount: 3));
      flow.add(PrayerFlowStep("التكبير للجلوس", r, content: "اللَّهُ أَكْبَرُ", isAction: true));
      flow.add(PrayerFlowStep(l10n.sittingLabel, r, content: "رَبِّ اغْفِرْ لِي. رَبِّ اغْفِرْ لِي", isAction: true, expectedPosition: PrayerPosition.sitting));
      flow.add(PrayerFlowStep("التكبير للسجود", r, content: "اللَّهُ أَكْبَرُ", isAction: true));
      flow.add(PrayerFlowStep(l10n.sujud2Label, r, content: "سُبْحَانَ رَبِّيَ الْأَعْلَى", isAction: true, expectedPosition: PrayerPosition.sujud, repetitionCount: 3));
      if (r == 2 && totalRakahs > 2) {
        flow.add(PrayerFlowStep("التشهد الأول", r, content: "التَّحِيَّاتُ لِلَّهِ وَالصَّلَوَاتُ وَالطَّيِّبَاتُ، السَّلَامُ عَلَيْكَ أَيُّهَا النَّبِيُّ وَرَحْمَةُ اللَّهِ وَبَرَكَاتُهُ، السَّلَامُ عَلَيْنَا وَعَلَى عِبَادِ اللَّهِ الصَّالِحِينَ. أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا اللَّهُ وَأَشْهَدُ أَنْ لَا إِلَهَ إِلَّا اللَّهُ وَأَشْهَدُ أَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُولُهُ", isAction: true, expectedPosition: PrayerPosition.sitting));
      }
      if (r == totalRakahs) {
        flow.add(PrayerFlowStep("التشهد الأخير", r, content: "التَّحِيَّاتُ لِلَّهِ وَالصَّلَوَاتُ وَالطَّيِّبَاتُ، السَّلَامُ عَلَيْكَ أَيُّهَا النَّبِيُّ وَرَحْمَةُ اللَّهِ وَبَرَكَاتُهُ، السَّلَامُ عَلَيْنَا وَعَلَى عِبَادِ اللَّهِ الصَّالِحِينَ. أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا اللَّهُ وَأَشْهَدُ أَنْ لَا إِلَهَ إِلَّا اللَّهُ وَأَشْهَدُ أَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُولُهُ", isAction: true, expectedPosition: PrayerPosition.sitting));
        flow.add(PrayerFlowStep("الصلاة الإبراهيمية", r, content: "اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ، كَمَا صَلَّيْتَ عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ، إِنَّكَ حَمِيدٌ مَجِيدٌ. اللَّهُمَّ بَارِكْ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ، كَمَا بَارَكْتَ عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ، إِنَّكَ حَمِيدٌ مَجِيدٌ", isAction: true, expectedPosition: PrayerPosition.sitting));
        flow.add(PrayerFlowStep("دعاء الاستعاذة", r, content: "اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنْ عَذَابِ جَهَنَّمَ، وَمِنْ عَذَابِ الْقَبْرِ، وَمِنْ فِتْنَةِ الْمَحْيَا وَالْمَمَاتِ، وَمِنْ فِتْنَةِ الْمَسِيحِ الدَّجَّالِ", isAction: true));
        flow.add(PrayerFlowStep("التسليمة الأولى", r, content: "السَّلَامُ عَلَيْكُمْ وَرَحْمَةُ اللَّهِ", isAction: true, expectedPosition: PrayerPosition.sitting));
        flow.add(PrayerFlowStep("التسليمة الثانية", r, content: "السَّلَامُ عَلَيْكُمْ وَرَحْمَةُ اللَّهِ", isAction: true, expectedPosition: PrayerPosition.sitting));
      }
    }
    return flow;
  }
}
