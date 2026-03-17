enum PrayerSessionMode {
  camera,
  voice,
  timed,
}

extension PrayerSessionModeX on PrayerSessionMode {
  String get label {
    switch (this) {
      case PrayerSessionMode.camera:
        return 'camera';
      case PrayerSessionMode.voice:
        return 'voice';
      case PrayerSessionMode.timed:
        return 'timed';
    }
  }
}
