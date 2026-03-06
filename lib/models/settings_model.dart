class AppSettings {
  final int khatmaDuration;
  final String qari;
  final String madhab;
  final bool athanNotifications;
  final String adhanVoice; // مضاف: اختيار صوت الأذان
  final bool prePrayerReminder; // مضاف: تنبيه قبل الصلاة
  final int prePrayerReminderMinutes; // مضاف: عدد دقائق التنبيه المسبق
  final int calculationMethod; // مضاف: طريقة حساب أوقات الصلاة (Aladhan API Method)
  final bool isCameraOn;
  final bool isDarkMode;
  final int primaryColor;
  final int accentColor;
  final String backgroundImage;
  final bool isCustomBackground;

  AppSettings({
    required this.khatmaDuration,
    required this.qari,
    required this.madhab,
    required this.athanNotifications,
    required this.adhanVoice,
    required this.prePrayerReminder,
    required this.prePrayerReminderMinutes,
    required this.calculationMethod,
    required this.isCameraOn,
    required this.isDarkMode,
    required this.primaryColor,
    required this.accentColor,
    required this.backgroundImage,
    this.isCustomBackground = false,
  });

  factory AppSettings.defaultSettings() {
    return AppSettings(
      khatmaDuration: 30,
      qari: 'mishary',
      madhab: 'shafii',
      athanNotifications: true,
      adhanVoice: 'makkah',
      prePrayerReminder: false,
      prePrayerReminderMinutes: 10,
      calculationMethod: 5, // Default: Egyptian General Authority
      isCameraOn: true,
      isDarkMode: false,
      primaryColor: 0xff1E8449,
      accentColor: 0xfff5a623,
      backgroundImage: 'assets/images/backgrounds/bg1.png',
      isCustomBackground: false,
    );
  }

  AppSettings copyWith({
    int? khatmaDuration,
    String? qari,
    String? madhab,
    bool? athanNotifications,
    String? adhanVoice,
    bool? prePrayerReminder,
    int? prePrayerReminderMinutes,
    int? calculationMethod,
    bool? isCameraOn,
    bool? isDarkMode,
    int? primaryColor,
    int? accentColor,
    String? backgroundImage,
    bool? isCustomBackground,
  }) {
    return AppSettings(
      khatmaDuration: khatmaDuration ?? this.khatmaDuration,
      qari: qari ?? this.qari,
      madhab: madhab ?? this.madhab,
      athanNotifications: athanNotifications ?? this.athanNotifications,
      adhanVoice: adhanVoice ?? this.adhanVoice,
      prePrayerReminder: prePrayerReminder ?? this.prePrayerReminder,
      prePrayerReminderMinutes: prePrayerReminderMinutes ?? this.prePrayerReminderMinutes,
      calculationMethod: calculationMethod ?? this.calculationMethod,
      isCameraOn: isCameraOn ?? this.isCameraOn,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      primaryColor: primaryColor ?? this.primaryColor,
      accentColor: accentColor ?? this.accentColor,
      backgroundImage: backgroundImage ?? this.backgroundImage,
      isCustomBackground: isCustomBackground ?? this.isCustomBackground,
    );
  }

  Map<String, dynamic> toJson() => {
    'khatmaDuration': khatmaDuration,
    'qari': qari,
    'madhab': madhab,
    'athanNotifications': athanNotifications,
    'adhanVoice': adhanVoice,
    'prePrayerReminder': prePrayerReminder,
    'prePrayerReminderMinutes': prePrayerReminderMinutes,
    'calculationMethod': calculationMethod,
    'isCameraOn': isCameraOn,
    'isDarkMode': isDarkMode,
    'primaryColor': primaryColor,
    'accentColor': accentColor,
    'backgroundImage': backgroundImage,
    'isCustomBackground': isCustomBackground,
  };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      khatmaDuration: json['khatmaDuration'] as int? ?? 30,
      qari: json['qari'] as String? ?? 'mishary',
      madhab: json['madhab'] as String? ?? 'shafii',
      athanNotifications: json['athanNotifications'] as bool? ?? true,
      adhanVoice: json['adhanVoice'] as String? ?? 'makkah',
      prePrayerReminder: json['prePrayerReminder'] as bool? ?? false,
      prePrayerReminderMinutes: json['prePrayerReminderMinutes'] as int? ?? 10,
      calculationMethod: json['calculationMethod'] as int? ?? 5,
      isCameraOn: json['isCameraOn'] as bool? ?? true,
      isDarkMode: json['isDarkMode'] as bool? ?? false,
      primaryColor: json['primaryColor'] as int? ?? 0xff1E8449,
      accentColor: json['accentColor'] as int? ?? 0xfff5a623,
      backgroundImage: json['backgroundImage'] as String? ?? 'assets/images/backgrounds/bg1.png',
      isCustomBackground: json['isCustomBackground'] as bool? ?? false,
    );
  }
}
