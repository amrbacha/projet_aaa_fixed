import 'package:projet_aaa/models/quran_data.dart';
import 'package:projet_aaa/core/services/quran_service.dart'; // Added the missing import

class DailyWird {
  final int day;
  final List<Ayah> ayahs;
  DailyWird({required this.day, required this.ayahs});
}

class ReadingWirdService {
  static Future<List<DailyWird>> generateReadingPlan(int durationInDays) async {
    final allVerses = await QuranService().getAllVerses();
    if (allVerses.isEmpty || durationInDays <= 0) {
      return [];
    }

    final List<DailyWird> plan = [];
    final totalEffort = allVerses.fold<int>(0, (sum, ayah) => sum + ayah.text.length);
    final effortPerDay = totalEffort / durationInDays;

    int verseIndex = 0;
    for (int day = 1; day <= durationInDays; day++) {
      List<Ayah> dailyAyahs = [];
      int currentDayEffort = 0;

      while (verseIndex < allVerses.length) {
        final currentAyah = allVerses[verseIndex];
        dailyAyahs.add(currentAyah);
        currentDayEffort += currentAyah.text.length;
        verseIndex++;

        if (currentDayEffort >= effortPerDay) {
          break;
        }
      }
      plan.add(DailyWird(day: day, ayahs: dailyAyahs));
      if(verseIndex >= allVerses.length) break;
    }

    return plan;
  }
}
