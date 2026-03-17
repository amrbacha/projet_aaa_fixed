import 'package:projet_aaa_fixed/core/models/quran_data.dart';
import 'package:projet_aaa_fixed/core/services/local_storage_service.dart';
import 'package:projet_aaa_fixed/core/services/quran_division_service.dart';

class WirdService {
  final QuranDivisionService _divisionService = QuranDivisionService();

  Future<List<Ayah>> getWirdForPrayer({
    required int day,
    required String prayerName,
    required int khatmaDuration,
  }) async {
    await _divisionService.generatePlan(khatmaDuration);
    return _divisionService.getWirdForPrayer(
      day,
      prayerName,
      durationInDays: khatmaDuration,
    );
  }

  Future<int> getCurrentDay(int khatmaDuration) async {
    final progress = await LocalStorageService.getPrayerProgress();
    return _divisionService.getCurrentDayForProgress(
      progress,
      durationInDays: khatmaDuration,
    );
  }
}
