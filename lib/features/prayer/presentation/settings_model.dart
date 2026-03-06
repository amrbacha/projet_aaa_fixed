class AppSettings {
  final int khatmaDuration; // مدة الختمة بالأيام
  final String qari; // اسم القارئ
  final bool adhanEnabled; // تفعيل الأذان
  final String calculationMethod; // طريقة الحساب

  AppSettings({
    required this.khatmaDuration,
    required this.qari,
    required this.adhanEnabled,
    required this.calculationMethod,
  });

  factory AppSettings.defaultSettings() {
    return AppSettings(
      khatmaDuration: 30,
      qari: 'مشاري العفاسي',
      adhanEnabled: true,
      calculationMethod: 'شافعي',
    );
  }

  Map<String, dynamic> toJson() => {
    'khatmaDuration': khatmaDuration,
    'qari': qari,
    'adhanEnabled': adhanEnabled,
    'calculationMethod': calculationMethod,
  };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      khatmaDuration: json['khatmaDuration'] ?? 30,
      qari: json['qari'] ?? 'مشاري العفاسي',
      adhanEnabled: json['adhanEnabled'] ?? true,
      calculationMethod: json['calculationMethod'] ?? 'شافعي',
    );
  }
}