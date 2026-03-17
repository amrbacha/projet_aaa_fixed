import 'package:projet_aaa_fixed/core/models/quran_data.dart';
import 'package:projet_aaa_fixed/core/services/pose_detection_service.dart';

import '../models/prayer_flow_step.dart';
import '../models/prayer_step_type.dart';
import '../models/rakah_flow.dart';

class PrayerFlowBuilder {
  const PrayerFlowBuilder();

  int resolveRakahCount(String prayerName) {
    final name = prayerName.toLowerCase().trim();

    if (name.contains('fajr') || name.contains('فجر')) return 2;
    if (name.contains('dhuhr') || name.contains('ظهر')) return 4;
    if (name.contains('asr') || name.contains('عصر')) return 4;
    if (name.contains('maghrib') || name.contains('مغرب')) return 3;
    if (name.contains('isha') || name.contains('عشاء')) return 4;

    return 4;
  }

  List<RakahFlow> buildRakahs({
    required String prayerName,
    required List<Ayah> fatihaVerses,
    required List<Ayah> wirdVerses,
  }) {
    final totalRakahs = resolveRakahCount(prayerName);
    final rakahs = <RakahFlow>[];

    for (int rakah = 1; rakah <= totalRakahs; rakah++) {
      final isFirstTwo = rakah <= 2;
      final hasFirstTashahhud = totalRakahs > 2 && rakah == 2;
      final hasFinalTashahhud = rakah == totalRakahs;

      final steps = <PrayerFlowStep>[
        PrayerFlowStep(
          type: PrayerStepType.transition,
          title: rakah == 1 ? 'تكبيرة الإحرام' : 'تكبيرة القيام',
          content: 'اللَّهُ أَكْبَرُ',
          rakahNumber: rakah,
          pauseAfter: const Duration(milliseconds: 900),
        ),
      ];

      if (rakah == 1) {
        steps.add(
          const PrayerFlowStep(
            type: PrayerStepType.dhikr,
            title: 'دعاء الاستفتاح',
            content: 'سُبْحَانَكَ اللَّهُمَّ وَبِحَمْدِكَ، وَتَبَارَكَ اسْمُكَ، وَتَعَالَى جَدُّكَ، وَلَا إِلَهَ غَيْرُكَ',
            rakahNumber: 1,
            pauseAfter: Duration(milliseconds: 1100),
          ),
        );
      }

      steps.addAll(_buildStandingRecitation(
        rakahNumber: rakah,
        fatihaVerses: fatihaVerses,
        wirdVerses: isFirstTwo ? wirdVerses : const [],
      ));

      steps.addAll(_buildRukuBlock(rakah));
      steps.addAll(_buildSujudBlock(rakah));

      if (hasFirstTashahhud) {
        steps.addAll(_buildFirstTashahhud(rakah));
      }

      if (hasFinalTashahhud) {
        steps.addAll(_buildFinalTashahhud(rakah));
      }

      rakahs.add(
        RakahFlow(
          rakahNumber: rakah,
          steps: steps,
          hasFirstTashahhud: hasFirstTashahhud,
          hasFinalTashahhud: hasFinalTashahhud,
        ),
      );
    }

    return rakahs;
  }

  List<PrayerFlowStep> flatten({
    required String prayerName,
    required List<Ayah> fatihaVerses,
    required List<Ayah> wirdVerses,
  }) {
    return buildRakahs(
      prayerName: prayerName,
      fatihaVerses: fatihaVerses,
      wirdVerses: wirdVerses,
    ).expand((r) => r.steps).toList();
  }

  List<PrayerFlowStep> _buildStandingRecitation({
    required int rakahNumber,
    required List<Ayah> fatihaVerses,
    required List<Ayah> wirdVerses,
  }) {
    final steps = <PrayerFlowStep>[];

    if (rakahNumber == 1) {
      steps.add(
        PrayerFlowStep(
          type: PrayerStepType.dhikr,
          title: 'الاستعاذة',
          content: 'أَعُوذُ بِاللَّهِ مِنَ الشَّيْطَانِ الرَّجِيمِ',
          rakahNumber: rakahNumber,
        ),
      );
    }

    steps.add(
      PrayerFlowStep(
        type: PrayerStepType.dhikr,
        title: 'البسملة',
        content: 'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
        rakahNumber: rakahNumber,
      ),
    );

    for (final ayah in fatihaVerses) {
      steps.add(
        PrayerFlowStep(
          type: PrayerStepType.recitation,
          title: 'سورة الفاتحة',
          content: ayah.text,
          rakahNumber: rakahNumber,
          surahNumber: ayah.surahNumber,
          ayahNumber: ayah.ayahNumber,
          surahName: 'سورة الفاتحة',
          requiresExactMatch: true,
          requiresUserRecitation: true,
          pauseAfter: const Duration(milliseconds: 700),
        ),
      );
    }

    steps.add(
      PrayerFlowStep(
        type: PrayerStepType.dhikr,
        title: 'آمين',
        content: 'آمِين',
        rakahNumber: rakahNumber,
        pauseAfter: const Duration(milliseconds: 800),
      ),
    );

    if (wirdVerses.isNotEmpty) {
      steps.add(
        PrayerFlowStep(
          type: PrayerStepType.dhikr,
          title: 'البسملة',
          content: 'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
          rakahNumber: rakahNumber,
        ),
      );

      for (final ayah in wirdVerses) {
        steps.add(
          PrayerFlowStep(
            type: PrayerStepType.recitation,
            title: 'تلاوة الورد',
            content: ayah.text,
            rakahNumber: rakahNumber,
            surahNumber: ayah.surahNumber,
            ayahNumber: ayah.ayahNumber,
            surahName: ayah.surahName,
            requiresExactMatch: true,
            requiresUserRecitation: true,
            pauseAfter: const Duration(milliseconds: 700),
          ),
        );
      }
    }

    return steps;
  }

  List<PrayerFlowStep> _buildRukuBlock(int rakahNumber) {
    return [
      PrayerFlowStep(
        type: PrayerStepType.transition,
        title: 'التكبير للركوع',
        content: 'اللَّهُ أَكْبَرُ',
        rakahNumber: rakahNumber,
      ),
      PrayerFlowStep(
        type: PrayerStepType.movement,
        title: 'الركوع',
        content: 'سُبْحَانَ رَبِّيَ الْعَظِيمِ',
        rakahNumber: rakahNumber,
        expectedPosition: PrayerPosition.ruku,
        repetition: 3,
        pauseAfter: const Duration(milliseconds: 1200),
      ),
      PrayerFlowStep(
        type: PrayerStepType.transition,
        title: 'الرفع من الركوع',
        content: 'سَمِعَ اللَّهُ لِمَنْ حَمِدَهُ',
        rakahNumber: rakahNumber,
        expectedPosition: PrayerPosition.standing,
      ),
      PrayerFlowStep(
        type: PrayerStepType.dhikr,
        title: 'الاعتدال',
        content: 'رَبَّنَا وَلَكَ الْحَمْدُ',
        rakahNumber: rakahNumber,
        expectedPosition: PrayerPosition.standing,
        pauseAfter: const Duration(milliseconds: 1400),
      ),
    ];
  }

  List<PrayerFlowStep> _buildSujudBlock(int rakahNumber) {
    return [
      PrayerFlowStep(
        type: PrayerStepType.transition,
        title: 'التكبير للسجود',
        content: 'اللَّهُ أَكْبَرُ',
        rakahNumber: rakahNumber,
      ),
      PrayerFlowStep(
        type: PrayerStepType.movement,
        title: 'السجود الأول',
        content: 'سُبْحَانَ رَبِّيَ الْأَعْلَى',
        rakahNumber: rakahNumber,
        expectedPosition: PrayerPosition.sujud,
        repetition: 3,
        pauseAfter: const Duration(milliseconds: 1200),
      ),
      PrayerFlowStep(
        type: PrayerStepType.transition,
        title: 'التكبير للجلوس',
        content: 'اللَّهُ أَكْبَرُ',
        rakahNumber: rakahNumber,
      ),
      PrayerFlowStep(
        type: PrayerStepType.movement,
        title: 'الجلوس بين السجدتين',
        content: 'رَبِّ اغْفِرْ لِي',
        rakahNumber: rakahNumber,
        expectedPosition: PrayerPosition.sitting,
        repetition: 1,
        pauseAfter: const Duration(milliseconds: 1200),
      ),
      PrayerFlowStep(
        type: PrayerStepType.transition,
        title: 'التكبير للسجود',
        content: 'اللَّهُ أَكْبَرُ',
        rakahNumber: rakahNumber,
      ),
      PrayerFlowStep(
        type: PrayerStepType.movement,
        title: 'السجود الثاني',
        content: 'سُبْحَانَ رَبِّيَ الْأَعْلَى',
        rakahNumber: rakahNumber,
        expectedPosition: PrayerPosition.sujud,
        repetition: 3,
        pauseAfter: const Duration(milliseconds: 1200),
      ),
    ];
  }

  List<PrayerFlowStep> _buildFirstTashahhud(int rakahNumber) {
    return [
      PrayerFlowStep(
        type: PrayerStepType.transition,
        title: 'الجلوس للتشهد الأول',
        content: 'اللَّهُ أَكْبَرُ',
        rakahNumber: rakahNumber,
      ),
      PrayerFlowStep(
        type: PrayerStepType.movement,
        title: 'التشهد الأول',
        content: 'التَّحِيَّاتُ لِلَّهِ وَالصَّلَوَاتُ وَالطَّيِّبَاتُ، السَّلَامُ عَلَيْكَ أَيُّهَا النَّبِيُّ وَرَحْمَةُ اللَّهِ وَبَرَكَاتُهُ، السَّلَامُ عَلَيْنَا وَعَلَى عِبَادِ اللَّهِ الصَّالِحِينَ، أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، وَأَشْهَدُ أَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُولُهُ',
        rakahNumber: rakahNumber,
        expectedPosition: PrayerPosition.sitting,
        pauseAfter: const Duration(milliseconds: 1800),
      ),
    ];
  }

  List<PrayerFlowStep> _buildFinalTashahhud(int rakahNumber) {
    return [
      PrayerFlowStep(
        type: PrayerStepType.transition,
        title: 'الجلوس للتشهد الأخير',
        content: 'اللَّهُ أَكْبَرُ',
        rakahNumber: rakahNumber,
      ),
      PrayerFlowStep(
        type: PrayerStepType.movement,
        title: 'التشهد الأخير',
        content: 'التَّحِيَّاتُ لِلَّهِ وَالصَّلَوَاتُ وَالطَّيِّبَاتُ، السَّلَامُ عَلَيْكَ أَيُّهَا النَّبِيُّ وَرَحْمَةُ اللَّهِ وَبَرَكَاتُهُ، السَّلَامُ عَلَيْنَا وَعَلَى عِبَادِ اللَّهِ الصَّالِحِينَ، أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، وَأَشْهَدُ أَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُولُهُ',
        rakahNumber: rakahNumber,
        expectedPosition: PrayerPosition.sitting,
        pauseAfter: const Duration(milliseconds: 1800),
      ),
      PrayerFlowStep(
        type: PrayerStepType.dhikr,
        title: 'الصلاة الإبراهيمية',
        content: 'اللهم صلِ على محمد وعلى آل محمد، كما صليت على إبراهيم وعلى آل إبراهيم، إنك حميد مجيد، اللهم بارك على محمد وعلى آل محمد، كما باركت على إبراهيم وعلى آل إبراهيم، إنك حميد مجيد',
        rakahNumber: rakahNumber,
        expectedPosition: PrayerPosition.sitting,
        pauseAfter: const Duration(milliseconds: 1800),
      ),
      PrayerFlowStep(
        type: PrayerStepType.dhikr,
        title: 'الاستعاذة قبل التسليم',
        content: 'اللهم إني أعوذ بك من عذاب جهنم، ومن عذاب القبر، ومن فتنة المحيا والممات، ومن شر فتنة المسيح الدجال',
        rakahNumber: rakahNumber,
        expectedPosition: PrayerPosition.sitting,
        pauseAfter: const Duration(milliseconds: 1600),
      ),
      PrayerFlowStep(
        type: PrayerStepType.transition,
        title: 'التسليمة الأولى',
        content: 'السَّلَامُ عَلَيْكُمْ وَرَحْمَةُ اللَّهِ',
        rakahNumber: rakahNumber,
        expectedPosition: PrayerPosition.sitting,
        pauseAfter: const Duration(milliseconds: 1200),
      ),
      PrayerFlowStep(
        type: PrayerStepType.transition,
        title: 'التسليمة الثانية',
        content: 'السَّلَامُ عَلَيْكُمْ وَرَحْمَةُ اللَّهِ',
        rakahNumber: rakahNumber,
        expectedPosition: PrayerPosition.sitting,
        pauseAfter: const Duration(milliseconds: 1200),
      ),
    ];
  }
}
