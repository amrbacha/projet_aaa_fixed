
PRAYER SESSION INTEGRATION

This package connects the new PrayerSessionOrchestrator with the existing prayer screen.

HOW TO USE

1. Import controller inside PrayerScreen

import 'package:projet_aaa_fixed/features/prayer_session/controllers/prayer_session_controller.dart';

2. Create controller

late PrayerSessionController session;

3. Initialize when prayer starts

session = PrayerSessionController();
session.initialize(
  cameraEnabled: cameraEnabled,
  micEnabled: micEnabled,
);

4. Read current stage

session.stage

5. Trigger transitions

Camera detected movement:
session.cameraTransition()

Voice detected cue:
session.voiceTransition()

Timer fallback:
session.timerTransition()

Manual debug:
session.nextManualStage()

This keeps existing Quran reading logic intact while allowing stage control.
