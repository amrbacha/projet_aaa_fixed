import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:projet_aaa_fixed/core/models/quran_data.dart';
import 'package:projet_aaa_fixed/core/services/quran_service.dart';

class Wird {
  final int day;
  final String prayerName;
  final List<Ayah> ayahs;

  Wird({
    required this.day,
    required this.prayerName,
    required this.ayahs,
  });
}

class QuranDivisionService {
  static final QuranDivisionService _instance =
      QuranDivisionService._internal();

  factory QuranDivisionService() => _instance;

  QuranDivisionService._internal();

  static const List<String> _prayerNames = [
    'Fajr',
    'Dhuhr',
    'Asr',
    'Maghrib',
    'Isha',
  ];

  static const int _dailyReadingRakats = 10;
  static const int _minAyahsPerReadingUnit = 3;
  static const int _toleranceAyahs = 3;
  static const int _smallSurahMaxAyahs = 10;

  List<Wird>? _khatmaPlan;
  int? _cachedDurationInDays;
  Future<void>? _planGenerationFuture;

  Future<void> generatePlan(int durationInDays) async {
    if (_cachedDurationInDays == durationInDays && _khatmaPlan != null) {
      return;
    }

    if (_planGenerationFuture != null) {
      await _planGenerationFuture;
      if (_cachedDurationInDays == durationInDays && _khatmaPlan != null) {
        return;
      }
    }

    final completer = Completer<void>();
    _planGenerationFuture = completer.future;

    try {
      debugPrint(
        '[QuranDivisionService] Generating flexible plan for $durationInDays days.',
      );

      final allVerses = await QuranService().getAllVerses(excludeFatiha: true);

      if (allVerses.isEmpty || durationInDays <= 0) {
        _khatmaPlan = [];
        _cachedDurationInDays = durationInDays;
        completer.complete();
        return;
      }

      final totalReadingUnits = durationInDays * _dailyReadingRakats;
      int currentVerseIndex = 0;
      final List<List<Ayah>> unitPlan = [];

      for (int unit = 0; unit < totalReadingUnits; unit++) {
        final remainingVerses = allVerses.length - currentVerseIndex;
        final remainingUnits = totalReadingUnits - unit;

        if (remainingVerses <= 0) {
          unitPlan.add([]);
          continue;
        }

        final unitLength = _chooseUnitLength(
          verses: allVerses,
          startIndex: currentVerseIndex,
          remainingVerses: remainingVerses,
          remainingUnits: remainingUnits,
        );

        final endIndex = min(
          currentVerseIndex + unitLength,
          allVerses.length,
        );

        unitPlan.add(allVerses.sublist(currentVerseIndex, endIndex));
        currentVerseIndex = endIndex;
      }

      final List<Wird> plan = [];
      int unitCursor = 0;

      for (int day = 1; day <= durationInDays; day++) {
        for (final prayerName in _prayerNames) {
          final firstUnit =
              unitCursor < unitPlan.length ? unitPlan[unitCursor] : <Ayah>[];
          final secondUnit = unitCursor + 1 < unitPlan.length
              ? unitPlan[unitCursor + 1]
              : <Ayah>[];

          final prayerAyahs = <Ayah>[
            ...firstUnit,
            ...secondUnit,
          ];

          plan.add(
            Wird(
              day: day,
              prayerName: prayerName,
              ayahs: prayerAyahs,
            ),
          );

          unitCursor += 2;
        }
      }

      _khatmaPlan = plan;
      _cachedDurationInDays = durationInDays;

      debugPrint(
        '[QuranDivisionService] Flexible plan generated successfully with ${_khatmaPlan?.length ?? 0} prayer wirds.',
      );

      completer.complete();
    } catch (e) {
      debugPrint('[QuranDivisionService] Error generating plan: $e');
      completer.completeError(e);
    } finally {
      _planGenerationFuture = null;
    }
  }

  int _chooseUnitLength({
    required List<Ayah> verses,
    required int startIndex,
    required int remainingVerses,
    required int remainingUnits,
  }) {
    if (remainingUnits <= 1) return remainingVerses;
    if (remainingVerses <= _minAyahsPerReadingUnit) {
      return remainingVerses;
    }

    final target = remainingVerses / remainingUnits;
    final minCount = min(_minAyahsPerReadingUnit, remainingVerses);
    final maxCount = remainingVerses;

    int safeUpper = min(maxCount, target.ceil() + _toleranceAyahs);

    if (remainingVerses - safeUpper > 0 &&
        remainingVerses - safeUpper < _minAyahsPerReadingUnit &&
        remainingUnits > 1) {
      safeUpper = max(
        _minAyahsPerReadingUnit,
        remainingVerses - _minAyahsPerReadingUnit,
      );
    }

    int safeLower = max(
      minCount,
      target.floor() - _toleranceAyahs,
    );

    if (remainingVerses - safeLower > 0 &&
        remainingVerses - safeLower < _minAyahsPerReadingUnit &&
        remainingUnits > 1) {
      safeLower = max(
        minCount,
        remainingVerses - _minAyahsPerReadingUnit,
      );
    }

    if (safeLower > safeUpper) {
      safeLower = minCount;
      safeUpper = min(
        maxCount,
        max(minCount, target.round()),
      );
    }

    int bestCount = safeLower;
    double bestScore = double.infinity;

    for (int candidate = safeLower; candidate <= safeUpper; candidate++) {
      final leftover = remainingVerses - candidate;

      if (leftover > 0 &&
          remainingUnits > 1 &&
          leftover < _minAyahsPerReadingUnit) {
        continue;
      }

      final score = _scoreCandidate(
        verses: verses,
        startIndex: startIndex,
        candidateCount: candidate,
        target: target,
        leftover: leftover,
      );

      if (score < bestScore) {
        bestScore = score;
        bestCount = candidate;
      }
    }

    return bestCount;
  }

  double _scoreCandidate({
    required List<Ayah> verses,
    required int startIndex,
    required int candidateCount,
    required double target,
    required int leftover,
  }) {
    final endIndex = startIndex + candidateCount - 1;
    final endAyah = verses[endIndex];

    double score = (candidateCount - target).abs() * 10.0;

    final remainingInSurah =
        _remainingVersesInSameSurah(verses, endIndex);

    final totalSurahVerses = _totalVersesOfSurah(
      verses,
      endAyah.surahNumber,
    );

    if (remainingInSurah == 0) {
      score -= 6.0;
    }

    if (remainingInSurah > 0 && remainingInSurah <= 2) {
      score += 8.0;
    }

    if (totalSurahVerses <= _smallSurahMaxAyahs) {
      if (_startsAtBeginningOfSurah(verses, startIndex) && remainingInSurah == 0) {
        score -= 10.0;
      } else if (remainingInSurah > 0) {
        score += 12.0;
      }
    }

    if (leftover == 0) {
      score -= 3.0;
    }

    return score;
  }

  bool _startsAtBeginningOfSurah(List<Ayah> verses, int startIndex) {
    return startIndex == 0 ||
        verses[startIndex - 1].surahNumber != verses[startIndex].surahNumber;
  }

  int _remainingVersesInSameSurah(List<Ayah> verses, int endIndex) {
    final surahNumber = verses[endIndex].surahNumber;
    int remaining = 0;

    for (int i = endIndex + 1; i < verses.length; i++) {
      if (verses[i].surahNumber != surahNumber) break;
      remaining++;
    }

    return remaining;
  }

  int _totalVersesOfSurah(List<Ayah> verses, int surahNumber) {
    return verses.where((a) => a.surahNumber == surahNumber).length;
  }

  Future<List<Ayah>> getWirdForPrayer(
    int day,
    String prayer, {
    int durationInDays = 30,
  }) async {
    if (_planGenerationFuture != null) {
      await _planGenerationFuture;
    }

    if (_khatmaPlan == null || _cachedDurationInDays != durationInDays) {
      await generatePlan(durationInDays);
    }

    final prayerInEnglish = prayer.toLowerCase();

    final wird = _khatmaPlan?.firstWhere(
      (w) => w.day == day && w.prayerName.toLowerCase() == prayerInEnglish,
      orElse: () => Wird(day: day, prayerName: prayer, ayahs: []),
    );

    return wird?.ayahs ?? [];
  }

  Future<int> getCurrentDayForProgress(
    int progressIndex, {
    required int durationInDays,
  }) async {
    if (_khatmaPlan == null || _cachedDurationInDays != durationInDays) {
      await generatePlan(durationInDays);
    }

    final plan = _khatmaPlan ?? [];
    if (plan.isEmpty) return 1;
    if (progressIndex <= 0) return 1;

    int consumed = 0;
    for (final wird in plan) {
      consumed += wird.ayahs.length;
      if (progressIndex < consumed) {
        return wird.day;
      }
    }

    return durationInDays;
  }
}
