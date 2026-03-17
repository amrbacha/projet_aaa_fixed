import '../models/prayer_session_mode.dart';
import '../models/prayer_session_state.dart';
import '../models/prayer_stage.dart';

class PrayerSessionOrchestrator {
  PrayerSessionState _state;
  final Duration readingDuration;
  final Duration transitionDuration;

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
    _state = _state.copyWith(
      stage: PrayerStage.takbir,
      statusMessage: 'بدأت جلسة الصلاة',
      updatedAt: DateTime.now(),
    );
  }

  void nextStage({
    bool fromCamera = false,
    bool fromVoice = false,
    bool fromTimer = false,
  }) {
    final current = _state.stage;
    final next = _computeNextStage(current);

    _state = _state.copyWith(
      stage: next,
      rakah: _computeNextRakah(current, next, _state.rakah),
      statusMessage: _buildStatusMessage(
        next: next,
        fromCamera: fromCamera,
        fromVoice: fromVoice,
        fromTimer: fromTimer,
      ),
      updatedAt: DateTime.now(),
    );
  }

  void advanceFromCamera() {
    if (_state.mode == PrayerSessionMode.camera) {
      nextStage(fromCamera: true);
    }
  }

  void advanceFromVoice() {
    if (_state.mode == PrayerSessionMode.voice) {
      nextStage(fromVoice: true);
    }
  }

  void advanceFromTimer() {
    if (_state.mode == PrayerSessionMode.timed) {
      nextStage(fromTimer: true);
    }
  }

  void reset({
    PrayerSessionMode? mode,
    bool? cameraEnabled,
    bool? micEnabled,
  }) {
    _state = PrayerSessionState.initial(
      mode: mode ?? _state.mode,
      cameraEnabled: cameraEnabled ?? _state.cameraEnabled,
      micEnabled: micEnabled ?? _state.micEnabled,
      timedFallbackEnabled: true,
    );
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
    if (current == PrayerStage.sujud2 && next == PrayerStage.tashahhud) {
      return rakah;
    }
    return rakah;
  }

  String _buildStatusMessage({
    required PrayerStage next,
    required bool fromCamera,
    required bool fromVoice,
    required bool fromTimer,
  }) {
    final source = fromCamera
        ? 'بالحركة'
        : fromVoice
            ? 'بالصوت'
            : fromTimer
                ? 'بالمؤقت'
                : 'يدويًا';

    return 'تم الانتقال إلى ${next.labelAr} $source';
  }
}
