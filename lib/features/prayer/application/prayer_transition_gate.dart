
import 'dart:async';

enum PrayerTransitionMode {
  timedOnly,
  voiceOnly,
  cameraOnly,
  voiceAndCamera,
}

class PrayerTransitionGate {
  final PrayerTransitionMode mode;
  final Duration graceAfterAudioEnds;
  final Duration timedFallbackDuration;

  bool _audioFinished = false;
  bool _voiceMatched = false;
  bool _cameraMatched = false;
  bool _transitionLocked = false;
  Timer? _fallbackTimer;

  PrayerTransitionGate({
    required this.mode,
    required this.graceAfterAudioEnds,
    required this.timedFallbackDuration,
  });

  bool get requiresVoice =>
      mode == PrayerTransitionMode.voiceOnly ||
      mode == PrayerTransitionMode.voiceAndCamera;

  bool get requiresCamera =>
      mode == PrayerTransitionMode.cameraOnly ||
      mode == PrayerTransitionMode.voiceAndCamera;

  void markAudioFinished() => _audioFinished = true;
  void markVoiceMatched() => _voiceMatched = true;
  void markCameraMatched() => _cameraMatched = true;

  bool canAdvance() {
    if (_transitionLocked) return false;
    switch (mode) {
      case PrayerTransitionMode.timedOnly:
        return true;
      case PrayerTransitionMode.voiceOnly:
        return _audioFinished && _voiceMatched;
      case PrayerTransitionMode.cameraOnly:
        return _audioFinished && _cameraMatched;
      case PrayerTransitionMode.voiceAndCamera:
        return _audioFinished && _voiceMatched && _cameraMatched;
    }
  }

  void lockAdvance() => _transitionLocked = true;
  void cancelTimers() => _fallbackTimer?.cancel();
  void dispose() => _fallbackTimer?.cancel();

  void startTimedFallback(void Function() onTimeout) {
    _fallbackTimer?.cancel();
    _fallbackTimer = Timer(timedFallbackDuration, onTimeout);
  }

  void startGraceWindow(void Function() onTimeout) {
    _fallbackTimer?.cancel();
    _fallbackTimer = Timer(graceAfterAudioEnds, onTimeout);
  }
}
