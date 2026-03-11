import 'package:projet_aaa_fixed/core/models/quran_data.dart';
import 'package:projet_aaa_fixed/core/services/quran_service.dart';
import 'local_storage_service.dart';

class WirdService {
  final QuranService _quranService = QuranService();

  /// يجلب الورد القادم بناءً على عدد الآيات المطلوبة والتقدم الحالي
  Future<List<Ayah>> getNextWird(int versesCount) async {
    final allVerses = await _quranService.getAllVerses(excludeFatiha: true);
    if (allVerses.isEmpty) return [];

    // الحصول على آخر فهرس توقف عنده المستخدم
    int lastIndex = await LocalStorageService.getQuranProgress();
    
    // إذا ختم المستخدم القرآن، نبدأ من جديد
    if (lastIndex >= allVerses.length) {
      lastIndex = 0;
      await LocalStorageService.saveQuranProgress(0);
    }

    final startIndex = lastIndex;
    final endIndex = (startIndex + versesCount).clamp(0, allVerses.length);

    return allVerses.sublist(startIndex, endIndex);
  }

  /// تحديث التقدم بعد الانتهاء من الصلاة
  Future<void> updateProgress(int newLastIndex) async {
    await LocalStorageService.saveQuranProgress(newLastIndex);
  }
}
