
# PROJECT_CONTEXT_SUMMARY.md

## Project
Name: projet_aaa_fixed  
Platform: Flutter / Dart  
Type: Multilingual Islamic application.

## Main Vision
A comprehensive Islamic platform centered around:
1. Quran completion (reading).
2. Quran completion through prayer.
3. Quran memorization.
4. AI‑assisted prayer coaching using camera pose detection.

The application aims to combine **prayer + Quran + learning** into one system.

## Core Strategic Feature
AI Prayer Coach:
- Uses pose detection.
- Tracks prayer positions (qiyam, ruku, sujud, jalsa).
- Controls transitions between prayer stages.
- Can operate using:
  - Camera (movement detection)
  - Voice detection
  - Timed transitions

## Main Functional Areas

### Quran
- Reading khatma system
- Prayer khatma system
- Memorization system
- Progress tracking

### Prayer
- Prayer flow system
- Prayer settings
- AI posture detection
- Prayer session orchestration

### Learning
- Prayer learning module
- Tafseer and contemplation

### Daily Worship
- Adhkar
- Tasbeeh
- Asma Allah
- Qibla direction

## Architecture (Simplified)

lib/
core/
features/
    prayer/
    prayer_coach/
    reading/
    memorization/
    tracking/
    adhkar/
    tafseer/
    tasbeeh/
    asma_allah/
    qibla/
    onboarding/
    settings/
main_menu/

## Key Engines

### Prayer Engine
Controls prayer flow and UI.

### Prayer Coach Engine
Pose detection and posture classification.

### Tracking Engine
Handles progress dashboards and statistics.

### Quran Engine
Manages reading sessions and khatma progress.

## Development Principles

1. Never break working systems:
   - Quran khatma logic
   - Reading progress
   - Memorization

2. Extend features through new modules rather than modifying stable engines.

3. Maintain modular feature separation.

## Current Development Direction

Next major improvements:

1. Prayer Session Orchestrator
   - unify camera + voice + timer transitions

2. Integrate AI prayer coach with Quran‑during‑prayer flow.

3. Build educational prayer module for beginners and children.
