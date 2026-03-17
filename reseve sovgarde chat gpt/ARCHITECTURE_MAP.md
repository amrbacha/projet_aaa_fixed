# PROJECT_CONTEXT_MASTER.md

## Project Identity
Project Name: projet_aaa_fixed  
Platform: Flutter / Dart  
Type: Comprehensive Islamic Application  
Target: Global multilingual Islamic assistant

The application integrates Quran reading, prayer, memorization,
AI posture detection, and Islamic learning tools into a unified system.

---

# Core Vision

The application is centered around **Quran completion through daily worship**.

The primary journey:

Quran → Prayer → Understanding → Dhikr → Spiritual growth

Main pillars:

1. Quran completion by reading
2. Quran completion through prayer
3. Quran memorization
4. AI-assisted prayer coaching
5. Islamic knowledge and daily worship

---

# Primary Strategic Feature

AI Prayer Coach

This system:

• Detects prayer postures  
• Tracks prayer stages  
• Synchronizes Quran reading with prayer  
• Automatically advances stages  

The coach supports **three control modes**:

1. Camera mode
2. Voice mode
3. Timed mode

Priority order:

Camera → Voice → Timer fallback

---

# Prayer Session Logic

The prayer session progresses through stages:

Takbir  
Istiftah  
Fatiha  
Quran Recitation  
Ruku  
I'tidal  
Sujud 1  
Jalsa  
Sujud 2  
Tashahhud  
Taslim

Transitions depend on the selected control mode.

---

# Control Modes

## Camera Mode

Uses ML Kit pose detection.

Detects transitions:

Qiyam → Ruku  
Ruku → I'tidal  
I'tidal → Sujud  
Sujud → Jalsa

This allows users to:

• prolong recitation  
• make personal dua  
• maintain natural prayer speed

---

## Voice Mode

When camera is disabled:

Speech detection listens for cues such as:

"سمع الله لمن حمده"

or other stage signals.

Transitions occur after detection.

---

## Timed Mode

If camera and microphone are both disabled:

Transitions follow configured speeds:

• Reading speed
• Transition speed

This ensures the prayer can still continue automatically.

---

# Quran Systems

The Quran engine contains three major subsystems.

## Reading Completion

Tracks progress of Quran reading.

Features:

• Quran page progression
• Completion tracking
• Reading speed adjustment

---

## Prayer Completion

The unique feature of the app.

Users complete the Quran by reading during prayer.

Features:

• Wird division
• Prayer-based reading
• Progress tracking

---

## Memorization

Allows memorizing surahs and verses.

Features:

• Surah selection
• Memorization sessions
• Review flow

---

# Main Modules


lib/
core/
features/
adhkar/
asma_allah/
main_menu/
memorization/
onboarding/
prayer/
prayer_coach/
reading/
search/
settings/
tafseer/
tasbeeh/
tracking/
qibla/


---

# Feature Responsibilities

## prayer
Handles the prayer flow.

Responsible for:

• prayer models  
• prayer settings  
• prayer screen  

---

## prayer_coach

AI posture engine.

Contains:

• pose detection  
• posture classifier  
• sequence state machine  
• smoothing logic  
• debug screen  

---

## tracking

Tracks user progress.

Includes:

• khatma progress
• statistics
• dashboards

---

## reading

Handles Quran reading sessions.

---

## memorization

Handles memorization sessions.

---

## adhkar

Daily supplications.

---

## tafseer

Quran explanation and contemplation.

---

## tasbeeh

Digital tasbeeh counter.

---

## asma_allah

Names of Allah module.

---

## qibla

Qibla direction tool.

---

# User Journey

The onboarding flow:

Splash  
Language Selection  
Profile Setup  
Voice Calibration  
Theme Customization  
Main Menu

---

# Main Menu Structure

Primary features:

• Quran completion through prayer  
• Quran completion by reading  
• Quran memorization  
• Tafseer & contemplation  

Secondary features:

• Adhkar  
• Tasbeeh  
• Asma Allah  
• Prayer learning  
• Qibla  

---

# Development Rules

To protect project stability:

1. Never break working systems:
   - Quran completion logic
   - Reading progress
   - Memorization

2. Extend functionality with new modules.

3. Maintain clear feature separation.

4. Avoid mixing AI logic with UI layers.

---

# Current Development Focus

The next architectural step:

Prayer Session Orchestrator

Responsibilities:

• unify camera / voice / timer transitions  
• control prayer stage progression  
• integrate with Quran reading flow  

---

# Future Roadmap

Planned improvements:

1. Full integration of prayer coach with prayer completion.
2. Educational prayer module for beginners and children.
3. Global multilingual expansion.
4. Enhanced AI posture analysis.

---

# Project Philosophy

This is not a simple Quran app.

It is a **complete Islamic spiritual assistant**.

The design philosophy:

Prayer + Quran + Learning + Dhikr

in one unified experience.