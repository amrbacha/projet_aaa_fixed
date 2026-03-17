import '../services/prayer_session_orchestrator.dart';
import '../models/prayer_stage.dart';

class PrayerSessionController {
  late PrayerSessionOrchestrator orchestrator;

  void initialize({
    required bool cameraEnabled,
    required bool micEnabled,
  }) {
    final mode = PrayerSessionOrchestrator.resolveMode(
      cameraEnabled: cameraEnabled,
      micEnabled: micEnabled,
    );

    orchestrator = PrayerSessionOrchestrator(
      mode: mode,
      cameraEnabled: cameraEnabled,
      micEnabled: micEnabled,
    );

    orchestrator.start();
  }

  PrayerStage get stage => orchestrator.state.stage;

  int get rakah => orchestrator.state.rakah;

  String get status => orchestrator.state.statusMessage;

  void nextManualStage() {
    orchestrator.nextStage();
  }

  void cameraTransition() {
    orchestrator.advanceFromCamera();
  }

  void voiceTransition() {
    orchestrator.advanceFromVoice();
  }

  void timerTransition() {
    orchestrator.advanceFromTimer();
  }
}
