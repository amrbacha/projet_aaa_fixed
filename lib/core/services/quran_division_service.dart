import 'dart:async'; // استيراد للمؤقت
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:projet_aaa/core/models/quran_data.dart';
import 'package:projet_aaa/core/services/quran_service.dart';

class Wird {
  final int day;
  final String prayerName;
  final List<Ayah> ayahs;
  Wird({required this.day, required this.prayerName, required this.ayahs});
}

class QuranDivisionService {
  static final QuranDivisionService _instance = QuranDivisionService._internal();
  factory QuranDivisionService() => _instance;
  QuranDivisionService._internal();

  List<Wird>? _khatmaPlan;
  // متغير لتتبع عملية إنشاء الخطة الجارية
  Future<void>? _planGenerationFuture;

  Future<void> generatePlan(int durationInDays) async {
    // استخدام Completer لإنشاء Future يمكننا التحكم به
    final completer = Completer<void>();
    _planGenerationFuture = completer.future;

    try {
      debugPrint("[QuranDivisionService] Generating new plan for $durationInDays days.");
      final allVerses = await QuranService().getAllVerses();

      if (allVerses.isEmpty || durationInDays <= 0) {
        debugPrint("[QuranDivisionService] No verses found or invalid duration. Plan is empty.");
        _khatmaPlan = [];
        completer.complete(); // إكمال الـ Future بنجاح
        _planGenerationFuture = null; // إعادة التعيين
        return;
      }

      final totalPrayerSlots = durationInDays * 5;
      final versesPerSlot = (allVerses.length / totalPrayerSlots).ceil();

      List<Wird> plan = [];
      int currentVerseIndex = 0;
      final prayerNames = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

      for (int day = 1; day <= durationInDays; day++) {
        for (final prayerName in prayerNames) {
          if (currentVerseIndex >= allVerses.length) {
            plan.add(Wird(day: day, prayerName: prayerName, ayahs: []));
            continue;
          }

          final startIndex = currentVerseIndex;
          final endIndex = min(startIndex + versesPerSlot, allVerses.length);

          List<Ayah> wirdAyahs = allVerses.sublist(startIndex, endIndex);
          plan.add(Wird(day: day, prayerName: prayerName, ayahs: wirdAyahs));

          currentVerseIndex = endIndex;
        }
      }
      _khatmaPlan = plan;
      debugPrint("[QuranDivisionService] Plan generated successfully with ${_khatmaPlan?.length} wirds.");
      completer.complete(); // إكمال الـ Future بنجاح
    } catch (e) {
      debugPrint("[QuranDivisionService] Error generating plan: $e");
      completer.completeError(e); // إكمال الـ Future مع خطأ
    } finally {
      _planGenerationFuture = null; // إعادة التعيين دائمًا
    }
  }

  Future<List<Ayah>> getWirdForPrayer(int day, String prayer) async {
    // إذا كانت هناك عملية إنشاء خطة جارية، انتظرها حتى تنتهي
    if (_planGenerationFuture != null) {
      debugPrint("[QuranDivisionService] Waiting for existing plan generation to complete...");
      await _planGenerationFuture;
    }

    // إذا كانت الخطة لا تزال فارغة بعد الانتظار، قم بإنشاء واحدة
    if (_khatmaPlan == null) {
      debugPrint("[QuranDivisionService] Plan not generated. Generating a default 30-day plan.");
      // استدعاء وانتظار generatePlan
      await generatePlan(30);
    }

    final prayerInEnglish = prayer.toLowerCase();
    debugPrint("[QuranDivisionService] Searching for wird for Day: $day, Prayer: $prayerInEnglish");

    // بعد التأكد من وجود الخطة، ابدأ البحث
    var wird = _khatmaPlan?.firstWhere(
          (w) => w.day == day && w.prayerName.toLowerCase() == prayerInEnglish,
      orElse: () {
        debugPrint("[QuranDivisionService] ==> WIRD NOT FOUND for Day $day, Prayer $prayerInEnglish");
        return Wird(day: day, prayerName: prayer, ayahs: []);
      },
    );

    if (wird != null && wird.ayahs.isNotEmpty) {
      debugPrint("[QuranDivisionService] ==> Found wird with ${wird.ayahs.length} ayahs.");
    } else if (wird != null) {
      debugPrint("[QuranDivisionService] ==> Found wird but it is EMPTY.");
    }

    return wird?.ayahs ?? [];
  }
}
