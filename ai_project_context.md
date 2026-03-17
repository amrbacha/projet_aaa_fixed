# AI_PROJECT_CONTEXT.md

## Project identity
- **Project name:** `projet_aaa_fixed`
- **Platform:** Flutter / Dart
- **Type:** Comprehensive Islamic app with multilingual UI
- **Primary strategic feature:** **AI Prayer Coach** using pose detection, Quran reading flow, and prayer sequence logic

## Product scope
The app is not a single-feature prayer app. It is a broader Islamic platform that includes:
- Quran reading and khatma flows
- Prayer flow and prayer settings
- AI prayer posture coaching
- Tafseer / contemplation features
- Adhkar
- Memorization
- Qibla
- Tracking / progress dashboard
- Theming, onboarding, settings, and personalization

## High-level `lib/` structure
```text
lib/
├── certificate
├── core
│   ├── data
│   ├── models
│   ├── providers
│   ├── services
│   └── widgets
├── debug
├── features
│   ├── adhkar
│   ├── asma_allah
│   ├── debug
│   ├── home
│   ├── main_menu
│   ├── memorization
│   ├── onboarding
│   ├── prayer
│   ├── prayer_coach
│   ├── qibla
│   ├── reading
│   ├── search
│   ├── settings
│   ├── tafseer
│   ├── tasbeeh
│   └── tracking
├── home
├── khatma
├── l10n
├── models
├── prayer
├── screens
└── widgets
```

## Core feature separation
### 1. `features/prayer`
Responsible for the **general prayer experience**:
- prayer data construction
- prayer models
- prayer screen
- prayer settings

Known files:
- `lib/features/prayer/data/prayer_builder.dart`
- `lib/features/prayer/data/prayer_models.dart`
- `lib/features/prayer/presentation/prayer_screen.dart`
- `lib/features/prayer/presentation/settings_model.dart`
- `lib/features/prayer/presentation/settings_service.dart`

### 2. `features/prayer_coach`
This is the **actual AI prayer posture engine**.
It contains the analysis pipeline, posture classification, smoothing, state machines, and debug UI.

### 3. `features/tracking`
This is a **tracking/dashboard layer**, not the pose engine.
Known files:
- `lib/features/tracking/presentation/tracking_screen.dart`
- widgets for header, khatma progress, prayer times, wird start, utilities

## `prayer_coach` architecture
```text
lib/features/prayer_coach/
├── application
│   ├── controllers
│   └── state
├── domain
│   ├── application
│   │   ├── controllers
│   │   └── state
│   ├── enums
│   ├── models
│   ├── services
│   └── utils
├── infrastructure
│   └── pose_detection
└── presentation
    ├── painters
    ├── screens
    └── widgets
```

## Important `prayer_coach` files
```text
lib/features/prayer_coach/application/controllers/prayer_coach_controller.dart
lib/features/prayer_coach/application/state/prayer_coach_debug_state.dart
lib/features/prayer_coach/domain/application/controllers/prayer_coach_controller.dart
lib/features/prayer_coach/domain/application/state/prayer_coach_debug_state.dart
lib/features/prayer_coach/domain/enums/prayer_posture.dart
lib/features/prayer_coach/domain/enums/prayer_sequence_state.dart
lib/features/prayer_coach/domain/models/pose_analysis.dart
lib/features/prayer_coach/domain/models/pose_metrics.dart
lib/features/prayer_coach/domain/models/posture_classification.dart
lib/features/prayer_coach/domain/services/pose_metrics_extractor.dart
lib/features/prayer_coach/domain/services/posture_classifier.dart
lib/features/prayer_coach/domain/services/prayer_posture_state_machine.dart
lib/features/prayer_coach/domain/services/prayer_sequence_state_machine.dart
lib/features/prayer_coach/domain/services/scene_alignment_evaluator.dart
lib/features/prayer_coach/domain/utils/geometry_utils.dart
lib/features/prayer_coach/domain/utils/posture_labels.dart
lib/features/prayer_coach/infrastructure/pose_detection/landmark_smoother.dart
lib/features/prayer_coach/presentation/painters/pose_painter.dart
lib/features/prayer_coach/presentation/screens/prayer_coach_debug_screen.dart
lib/features/prayer_coach/presentation/widgets/camera_pose_preview.dart
lib/features/prayer_coach/presentation/widgets/info_card.dart
lib/features/prayer_coach/presentation/widgets/landmark_status_card.dart
lib/features/prayer_coach/presentation/widgets/metrics_panel.dart
lib/features/prayer_coach/presentation/widgets/posture_banner.dart
```

## Confirmed pose-processing pipeline
The current controller shows the following sequence:

```text
Pose
→ SceneAlignmentEvaluator
→ LandmarkSmoother
→ PoseMetricsExtractor
→ PostureClassifier
→ PrayerPostureStateMachine
→ PrayerSequenceStateMachine
→ PrayerCoachDebugState
→ UI
```

## Confirmed controller behavior
`PrayerCoachController` currently:
- evaluates scene quality first
- smooths landmarks
- extracts pose metrics
- produces a raw posture candidate
- stabilizes posture through a posture state machine
- feeds the stable posture into a prayer sequence state machine
- returns a rich debug state for UI

Important observation:
- `buildNoPoseState()` resets both posture and sequence state machines.
- This may be too aggressive when the body temporarily disappears during **sujud** or low poses.
- That reset behavior is a likely contributor to low-pose tracking weakness.

## Current strengths of the AI prayer coach
Already present in the codebase:
- scene alignment evaluation
- landmark smoothing
- pose metrics extraction
- posture classification
- posture stabilization
- prayer sequence state machine
- debug UI with metrics and landmark visibility

## Current known product issue
The major current issue is **not qiyam or ruku**.
The reported weakness is specifically:
- **sujud**
- **jalsa / sitting**

Observed real-world reason:
- front camera works well for qiyam and ruku
- in sujud, the person may partially disappear from frame
- in jalsa, legs may not be visible enough
- low poses need stronger inference from sequence + partial visibility, not only direct pose geometry

## Product constraints and design principles
The app must support real users with different sensitivities and preferences:
- some users do not want camera-based tracking
- privacy concerns are important
- camera should be treated as **optional enhancement**, not a mandatory requirement
- reading from the phone and listening/recitation support must coexist with posture analysis

## Strategic design direction
### Visual poses that can be detected directly
- qiyam
- ruku
- i'tidal / standing return

### Low poses that need hybrid inference
- sujud
- jalsa

Hybrid inference should combine:
- partial landmark visibility
- body height reduction
- head/shoulder/hip ratios
- recent stable posture
- expected next posture / prayer sequence context

## Recommended next engineering focus
### Priority 1
Improve:
- `lib/features/prayer_coach/domain/services/posture_classifier.dart`
- `lib/features/prayer_coach/domain/services/prayer_sequence_state_machine.dart`

### Priority 2
Review:
- `lib/features/prayer_coach/application/controllers/prayer_coach_controller.dart`

Specifically inspect whether `buildNoPoseState()` should avoid full reset on short low-pose disappearance.

### Priority 3
Add privacy-aware operation modes
Suggested modes:
- camera + audio
- audio only / privacy mode
- reading only
- training mode

## Architectural note
There appears to be **duplication** in `prayer_coach`:
- `application/...`
- `domain/application/...`

And also possible duplicate screen/state/controller files.
This should be audited before major refactors, to avoid editing unused or legacy files.

## Working assumption for future chats
When continuing development, assume:
- `features/prayer_coach` is the main AI posture feature
- `features/prayer` is the user-facing prayer flow layer
- `features/tracking` is a dashboard/progress layer
- the main current bug to solve is **low-pose inference** for **sujud** and **jalsa**

## Recommended first files to inspect in future sessions
1. `lib/features/prayer_coach/domain/services/posture_classifier.dart`
2. `lib/features/prayer_coach/domain/services/prayer_sequence_state_machine.dart`
3. `lib/features/prayer_coach/domain/services/pose_metrics_extractor.dart`
4. `lib/features/prayer_coach/application/controllers/prayer_coach_controller.dart`
5. `lib/features/prayer_coach/presentation/widgets/camera_pose_preview.dart`

## Suggested prompt to resume work in a new chat
```text
Read AI_PROJECT_CONTEXT.md first.
Then help me continue the Flutter project `projet_aaa_fixed`.
We are currently focusing on `features/prayer_coach`, especially improving sujud and jalsa detection without breaking qiyam and ruku.
Start by reviewing `posture_classifier.dart` and `prayer_sequence_state_machine.dart`.
```

