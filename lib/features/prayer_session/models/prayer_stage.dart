enum PrayerStage {
  takbir,
  istiftah,
  fatiha,
  quran,
  ruku,
  itidal,
  sujud1,
  jalsa,
  sujud2,
  tashahhud,
  taslim,
  finished,
}

extension PrayerStageX on PrayerStage {
  String get labelAr {
    switch (this) {
      case PrayerStage.takbir:
        return 'تكبيرة الإحرام';
      case PrayerStage.istiftah:
        return 'دعاء الاستفتاح';
      case PrayerStage.fatiha:
        return 'قراءة الفاتحة';
      case PrayerStage.quran:
        return 'تلاوة الورد';
      case PrayerStage.ruku:
        return 'الركوع';
      case PrayerStage.itidal:
        return 'الاعتدال';
      case PrayerStage.sujud1:
        return 'السجود الأول';
      case PrayerStage.jalsa:
        return 'الجلسة بين السجدتين';
      case PrayerStage.sujud2:
        return 'السجود الثاني';
      case PrayerStage.tashahhud:
        return 'التشهد';
      case PrayerStage.taslim:
        return 'السلام';
      case PrayerStage.finished:
        return 'انتهت الصلاة';
    }
  }
}
