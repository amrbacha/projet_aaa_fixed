import 'package:projet_aaa/core/models/quran_data.dart';
import 'package:projet_aaa/core/services/quran_service.dart';
import 'package:projet_aaa/features/adhkar/data/adhkar_data.dart';
import 'package:projet_aaa/features/adhkar/data/models/adhkar_model.dart';

class SearchResult {
  final String title;
  final String content;
  final String type; // 'quran', 'adhkar', 'tafseer'
  final dynamic extra; // To store Ayah or AthkarItem for navigation

  SearchResult({required this.title, required this.content, required this.type, this.extra});
}

class GlobalSearchService {
  final QuranService _quranService = QuranService();

  Future<List<SearchResult>> search(String query) async {
    if (query.isEmpty) return [];
    
    List<SearchResult> results = [];
    String cleanQuery = _cleanArabicText(query);

    // 1. البحث في القرآن
    final allAyahs = await _quranService.getAllVerses(excludeFatiha: false);
    for (var ayah in allAyahs) {
      if (_cleanArabicText(ayah.text).contains(cleanQuery)) {
        results.add(SearchResult(
          title: "سورة ${ayah.surahName} - آية ${ayah.ayahNumber}",
          content: ayah.text,
          type: 'quran',
          extra: ayah,
        ));
      }
    }

    // 2. البحث في الأذكار
    for (var itemMap in rawAthkarItems) {
      final item = AthkarItem.fromJson(itemMap);
      if (_cleanArabicText(item.text).contains(cleanQuery)) {
        results.add(SearchResult(
          title: "من الأذكار والأدعية",
          content: item.text,
          type: 'adhkar',
          extra: item,
        ));
      }
    }

    return results;
  }

  String _cleanArabicText(String text) {
    final RegExp tashkeel = RegExp(r'[\u064B-\u0652\u0670]');
    return text
        .replaceAll(tashkeel, '')
        .replaceAll('آ', 'ا')
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('ى', 'ي')
        .trim();
  }
}
