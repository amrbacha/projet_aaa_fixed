import '../enums/prayer_posture.dart';
import '../enums/prayer_sequence_state.dart';

String labelForPosture(PrayerPosture posture) {
  switch (posture) {
    case PrayerPosture.qiyam:
      return 'قيام';
    case PrayerPosture.ruku:
      return 'ركوع';
    case PrayerPosture.sujud:
      return 'سجود';
    case PrayerPosture.jalsa:
      return 'جلسة';
    case PrayerPosture.unknown:
      return 'غير محسوم';
  }
}

String labelForSequence(PrayerSequenceState state) {
  switch (state) {
    case PrayerSequenceState.unknown:
      return 'غير محدد';
    case PrayerSequenceState.qiyamStart:
      return 'قيام البداية';
    case PrayerSequenceState.ruku:
      return 'ركوع';
    case PrayerSequenceState.qawmah:
      return 'قومة بعد الركوع';
    case PrayerSequenceState.sujud1:
      return 'السجدة الأولى';
    case PrayerSequenceState.jalsa:
      return 'الجلسة بين السجدتين';
    case PrayerSequenceState.sujud2:
      return 'السجدة الثانية';
    case PrayerSequenceState.qiyamBetweenRakats:
      return 'قيام بين الركعات';
  }
}