/// Represents a single Ayah (verse) of the Quran.
class Ayah {
  final int surahNumber;
  final int verseNumber;
  final String text;

  Ayah({required this.surahNumber, required this.verseNumber, required this.text});

  factory Ayah.fromJson(Map<String, dynamic> json, int surahNum) {
    return Ayah(
      surahNumber: surahNum,
      verseNumber: json['verse_number'] as int,
      text: json['text'] as String,
    );
  }
}

/// Represents a single Surah (chapter) of the Quran, containing a list of Ayahs.
class Surah {
  final int surahNumber;
  final String name;
  final List<Ayah> verses;

  Surah({required this.surahNumber, required this.name, required this.verses});

  factory Surah.fromJson(Map<String, dynamic> json) {
    final int surahNum = json['surah_number'] as int;
    final versesList = (json['verses'] as List)
        .map((v) => Ayah.fromJson(v, surahNum))
        .toList();

    return Surah(
      surahNumber: surahNum,
      name: json['name'] as String,
      verses: versesList,
    );
  }
}
