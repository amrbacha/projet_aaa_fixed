class Ayah {
  final int surahNumber;
  final String surahName;
  final int ayahNumber;
  final String text;
  final int words;

  const Ayah({
    required this.surahNumber,
    required this.surahName,
    required this.ayahNumber,
    required this.text,
    required this.words,
  });

  factory Ayah.fromJson(
      Map<String, dynamic> json, {
        required int surahNumber,
        required String surahName,
      }) {
    return Ayah(
      surahNumber: surahNumber,
      surahName: surahName,
      ayahNumber: (json['ayahNumber'] ?? json['numberInSurah'] ?? 0) as int,
      text: (json['text'] ?? '') as String,
      words: (json['words'] ?? 0) as int,
    );
  }
}

class Surah {
  final int surahNumber;
  final String surahName;
  final List<Ayah> verses;

  const Surah({
    required this.surahNumber,
    required this.surahName,
    required this.verses,
  });

  factory Surah.fromJson(Map<String, dynamic> json) {
    final int sn = (json['surahNumber'] ?? json['number'] ?? 0) as int;
    final String name = (json['surahName'] ?? json['name'] ?? '') as String;

    final List<dynamic> ayahsRaw =
    (json['ayahs'] ?? json['verses'] ?? json['ayahsList'] ?? []) as List<dynamic>;

    final verses = ayahsRaw
        .whereType<Map<String, dynamic>>()
        .map((a) => Ayah.fromJson(a, surahNumber: sn, surahName: name))
        .toList();

    return Surah(
      surahNumber: sn,
      surahName: name,
      verses: verses,
    );
  }
}