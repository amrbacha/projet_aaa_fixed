import 'package:projet_aaa/models/quran_data.dart';

// A temporary, standalone provider to return a hardcoded wird.
// This has no dependencies on other services.
class TempWirdProvider {
  static List<Ayah> getTemporaryWird() {
    return [
      Ayah(surahNumber: 112, verseNumber: 1, text: "قُلْ هُوَ اللَّهُ أَحَدٌ"),
      Ayah(surahNumber: 112, verseNumber: 2, text: "اللَّهُ الصَّمَدُ"),
      Ayah(surahNumber: 112, verseNumber: 3, text: "لَمْ يَلِدْ وَلَمْ يُولَدْ"),
      Ayah(surahNumber: 112, verseNumber: 4, text: "وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ"),
    ];
  }
}
