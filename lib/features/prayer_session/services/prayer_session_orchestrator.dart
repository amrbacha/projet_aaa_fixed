import '../models/prayer_session_mode.dart';
import '../models/prayer_session_state.dart';
import '../models/prayer_stage.dart';

class PrayerSessionOrchestrator {
  PrayerSessionState _state;
  final Duration readingDuration;
  final Duration transitionDuration;

  bool _qariFinished = false;
  bool _voiceMatched = false;
  bool _poseMatched = false;
  bool _timerElapsed = false;

  PrayerSessionOrchestrator({
    required PrayerSessionMode mode,
    required bool cameraEnabled,
    required bool micEnabled,
    this.readingDuration = const Duration(seconds: 30),
    this.transitionDuration = const Duration(seconds: 8),
  }) : _state = PrayerSessionState.initial(
    mode: mode,
    cameraEnabled: cameraEnabled,
    micEnabled: micEnabled,
    timedFallbackEnabled: true,
  );

  PrayerSessionState get state => _state;

  static PrayerSessionMode resolveMode({
    required bool cameraEnabled,
    required bool micEnabled,
  }) {
    if (cameraEnabled) return PrayerSessionMode.camera;
    if (micEnabled) return PrayerSessionMode.voice;
    return PrayerSessionMode.timed;
  }

  void start() {
    _resetGuards();
    _state = _state.copyWith(
      stage: PrayerStage.takbir,
      statusMessage: 'بدأت جلسة الصلاة',
      updatedAt: DateTime.now(),
    );
  }

  void beginStageCycle() {
    _resetGuards();
    _state = _state.copyWith(
      statusMessage: 'بدأت متابعة ${_state.stage.labelAr}',
      updatedAt: DateTime.now(),
    );
  }

  void markQariFinished() {
    _qariFinished = true;
    _attemptAdvance(source: 'انتهاء المقرئ');
  }

  void advanceFromVoice() {
    if (!_state.micEnabled) return;
    _voiceMatched = true;
    _attemptAdvance(source: 'المطابقة الصوتية');
  }

  void advanceFromCamera() {
    if (!_state.cameraEnabled) return;
    _poseMatched = true;
    _attemptAdvance(source: 'الحركة');
  }

  void advanceFromTimer() {
    _timerElapsed = true;
    _attemptAdvance(source: 'المؤقت');
  }

  void nextManualStage() {
    _forceAdvance('يدويًا');
  }

  void nextStage({
    bool fromCamera = false,
    bool fromVoice = false,
    bool fromTimer = false,
  }) {
    final source = fromCamera
        ? 'بالحركة'
        : fromVoice
        ? 'بالصوت'
        : fromTimer
        ? 'بالمؤقت'
        : 'يدويًا';

    _forceAdvance(source);
  }

  void reset({
    PrayerSessionMode? mode,
    bool? cameraEnabled,
    bool? micEnabled,
  }) {
    _resetGuards();
    _state = PrayerSessionState.initial(
      mode: mode ?? _state.mode,
      cameraEnabled: cameraEnabled ?? _state.cameraEnabled,
      micEnabled: micEnabled ?? _state.micEnabled,
      timedFallbackEnabled: true,
    );
  }

  void _attemptAdvance({required String source}) {
    if (_state.stage == PrayerStage.finished) return;

    final needsPose = _stageNeedsPose(_state.stage);
    final hasVoicePath = _state.micEnabled;
    final hasCameraPath = _state.cameraEnabled && needsPose;
    final timedOnly = !_state.cameraEnabled && !_state.micEnabled;

    // fallback pure timed mode
    if (timedOnly && _timerElapsed) {
      _forceAdvance('بالمؤقت');
      return;
    }

    // recitation / spoken stages
    if (!needsPose) {
      if (hasVoicePath) {
        // user may match before qari finishes
        if (_voiceMatched && (_qariFinished || _voiceMatched)) {
          _forceAdvance(source);
          return;
        }
      } else if (_qariFinished || _timerElapsed) {
        _forceAdvance(source);
        return;
      }
    }

    // motion stages
    if (needsPose) {
      if (hasCameraPath && _qariFinished && _poseMatched) {
        _forceAdvance(source);
        return;
      }

      if (!hasCameraPath && (_qariFinished || _timerElapsed)) {
        _forceAdvance(source);
        return;
      }

      if (_timerElapsed && _state.timedFallbackEnabled) {
        _forceAdvance('بالمؤقت الاحتياطي');
        return;
      }
    }

    _state = _state.copyWith(
      statusMessage: _buildWaitingMessage(
        needsPose: needsPose,
        source: source,
      ),
      updatedAt: DateTime.now(),
    );
  }

  void _forceAdvance(String source) {
    final current = _state.stage;
    final next = _computeNextStage(current);

    _state = _state.copyWith(
      stage: next,
      rakah: _computeNextRakah(current, next, _state.rakah),
      statusMessage: 'تم الانتقال إلى ${next.labelAr} $source',
      updatedAt: DateTime.now(),
    );

    _resetGuards();
  }

  void _resetGuards() {
    _qariFinished = false;
    _voiceMatched = false;
    _poseMatched = false;
    _timerElapsed = false;
  }

  bool _stageNeedsPose(PrayerStage stage) {
    switch (stage) {
      case PrayerStage.ruku:
      case PrayerStage.sujud1:
      case PrayerStage.jalsa:
      case PrayerStage.sujud2:
        return true;
      default:
        return false;
    }
  }

  PrayerStage _computeNextStage(PrayerStage current) {
    switch (current) {
      case PrayerStage.takbir:
        return PrayerStage.istiftah;
      case PrayerStage.istiftah:
        return PrayerStage.fatiha;
      case PrayerStage.fatiha:
        return PrayerStage.quran;
      case PrayerStage.quran:
        return PrayerStage.ruku;
      case PrayerStage.ruku:
        return PrayerStage.itidal;
      case PrayerStage.itidal:
        return PrayerStage.sujud1;
      case PrayerStage.sujud1:
        return PrayerStage.jalsa;
      case PrayerStage.jalsa:
        return PrayerStage.sujud2;
      case PrayerStage.sujud2:
        return PrayerStage.tashahhud;
      case PrayerStage.tashahhud:
        return PrayerStage.taslim;
      case PrayerStage.taslim:
        return PrayerStage.finished;
      case PrayerStage.finished:
        return PrayerStage.finished;
    }
  }

  int _computeNextRakah(PrayerStage current, PrayerStage next, int rakah) {
    // اتركها بسيطة الآن حتى لا نكسر بقية المشروع.
    // لاحقًا سنربطها بعدد ركعات الصلاة ونوع التشهد.
    return rakah;
  }

  String _buildWaitingMessage({
    required bool needsPose,
    required String source,
  }) {
    if (needsPose) {
      if (!_qariFinished) {
        return 'تم رصد $source لكن النظام ينتظر انتهاء المقرئ أولًا';
      }
      if (_state.cameraEnabled && !_poseMatched) {
        return 'انتهى الذكر، والنظام ينتظر الحركة الصحيحة';
      }
      return 'ينتظر تحقق شرط الانتقال الحركي';
    }

    if (_state.micEnabled && !_voiceMatched) {
      return 'النظام ينتظر المطابقة الصوتية';
    }

    if (!_qariFinished) {
      return 'النظام ينتظر انتهاء المقرئ';
    }

    return 'ينتظر تحقق شرط الانتقال';
  }
}