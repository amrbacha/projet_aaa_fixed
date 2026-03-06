class AyahTafseer {
  final int surahNumber;
  final int ayahNumber;
  final String text;
  final String tafseer;
  final List<String>? wordMeanings;
  final String? tadabburQuestion;
  final String? practicalAction;

  AyahTafseer({
    required this.surahNumber,
    required this.ayahNumber,
    required this.text,
    required this.tafseer,
    this.wordMeanings,
    this.tadabburQuestion,
    this.practicalAction,
  });

  factory AyahTafseer.fromJson(Map<String, dynamic> json) => AyahTafseer(
        surahNumber: json['surahNumber'],
        ayahNumber: json['ayahNumber'],
        text: json['text'],
        tafseer: json['tafseer'],
        wordMeanings: json['wordMeanings'] != null ? List<String>.from(json['wordMeanings']) : null,
        tadabburQuestion: json['tadabburQuestion'],
        practicalAction: json['practicalAction'],
      );
}

class UserReflection {
  final int surahNumber;
  final int ayahNumber;
  final String note;
  final DateTime date;

  UserReflection({
    required this.surahNumber,
    required this.ayahNumber,
    required this.note,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'surahNumber': surahNumber,
        'ayahNumber': ayahNumber,
        'note': note,
        'date': date.toIso8601String(),
      };
}
