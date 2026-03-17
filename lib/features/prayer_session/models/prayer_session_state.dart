import 'prayer_session_mode.dart';
import 'prayer_stage.dart';

class PrayerSessionState {
  final PrayerStage stage;
  final int rakah;
  final PrayerSessionMode mode;
  final bool cameraEnabled;
  final bool micEnabled;
  final bool timedFallbackEnabled;
  final String statusMessage;
  final DateTime startedAt;
  final DateTime updatedAt;

  const PrayerSessionState({
    required this.stage,
    required this.rakah,
    required this.mode,
    required this.cameraEnabled,
    required this.micEnabled,
    required this.timedFallbackEnabled,
    required this.statusMessage,
    required this.startedAt,
    required this.updatedAt,
  });

  factory PrayerSessionState.initial({
    required PrayerSessionMode mode,
    required bool cameraEnabled,
    required bool micEnabled,
    required bool timedFallbackEnabled,
  }) {
    final now = DateTime.now();
    return PrayerSessionState(
      stage: PrayerStage.takbir,
      rakah: 1,
      mode: mode,
      cameraEnabled: cameraEnabled,
      micEnabled: micEnabled,
      timedFallbackEnabled: timedFallbackEnabled,
      statusMessage: 'جاهز لبدء الصلاة',
      startedAt: now,
      updatedAt: now,
    );
  }

  PrayerSessionState copyWith({
    PrayerStage? stage,
    int? rakah,
    PrayerSessionMode? mode,
    bool? cameraEnabled,
    bool? micEnabled,
    bool? timedFallbackEnabled,
    String? statusMessage,
    DateTime? startedAt,
    DateTime? updatedAt,
  }) {
    return PrayerSessionState(
      stage: stage ?? this.stage,
      rakah: rakah ?? this.rakah,
      mode: mode ?? this.mode,
      cameraEnabled: cameraEnabled ?? this.cameraEnabled,
      micEnabled: micEnabled ?? this.micEnabled,
      timedFallbackEnabled: timedFallbackEnabled ?? this.timedFallbackEnabled,
      statusMessage: statusMessage ?? this.statusMessage,
      startedAt: startedAt ?? this.startedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
