import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:projet_aaa_fixed/core/models/quran_data.dart';

class QuranService {
  static final QuranService _instance = QuranService._internal();
  factory QuranService() => _instance;
  QuranService._internal();

  List<Surah>? _quranData;
  List<Ayah>? _allVersesCache;

  static List<Surah> _parseQuran(String jsonString) {
    final dynamic decoded = json.decode(jsonString);
    if (decoded is Map<String, dynamic>) {
      final List<dynamic> surates = (decoded['surates'] ?? []) as List<dynamic>;
      return surates
          .whereType<Map<String, dynamic>>()
          .map((m) => Surah.fromJson(m))
          .toList();
    } else if (decoded is List) {
      return decoded
          .whereType<Map<String, dynamic>>()
          .map((m) => Surah.fromJson(m))
          .toList();
    }
    return [];
  }

  Future<List<Surah>> _loadQuranData() async {
    if (_quranData != null) return _quranData!;
    try {
      final String jsonString = await rootBundle.loadString('assets/quran/quran.json');
      _quranData = await compute(_parseQuran, jsonString);
      return _quranData!;
    } catch (e) {
      return [];
    }
  }

  Future<List<Ayah>> getAllVerses({bool excludeFatiha = true}) async {
    if (_allVersesCache != null && excludeFatiha) return _allVersesCache!;
    final quran = await _loadQuranData();
    if (quran.isEmpty) return [];
    final allAyahs = await compute(_flattenAyahs, _FlattenParams(quran, excludeFatiha));
    if (excludeFatiha) _allVersesCache = allAyahs;
    return allAyahs;
  }

  static List<Ayah> _flattenAyahs(_FlattenParams params) {
    final allAyahs = <Ayah>[];
    for (final surah in params.quran) {
      if (params.excludeFatiha && surah.surahNumber == 1) continue;
      allAyahs.addAll(surah.verses);
    }
    return allAyahs;
  }
}

class _FlattenParams {
  final List<Surah> quran;
  final bool excludeFatiha;
  _FlattenParams(this.quran, this.excludeFatiha);
}
