// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'مساعد الصلاة';

  @override
  String get welcomeMessage =>
      'أهلاً بك في رحابة الطاعة. اختر وجهتك اليوم لترتقي سوياً في درجات الإيمان';

  @override
  String get startPrayer => 'ابدأ الصلاة الآن';

  @override
  String get qiblaDirection => 'اتجاه القبلة';

  @override
  String get khatmaProgress => 'تقدم الختمة';

  @override
  String get smartAssistant => 'أنيس - المساعد الذكي';

  @override
  String get settings => 'الإعدادات الشاملة';

  @override
  String get readingQuran => 'ختم القرآن بالقراءة';

  @override
  String get prayerKhatma => 'ختم القرآن بالصلاة';

  @override
  String get memorization => 'حفظ القرآن الكريم';

  @override
  String get tafseer => 'التفسير والتدبر';

  @override
  String get adhkar => 'الأذكار والأدعية';

  @override
  String get tasbeeh => 'التسبيح';

  @override
  String get asmaAllah => 'أسماء الله الحسنى';

  @override
  String get language => 'اللغة';

  @override
  String get theme => 'المظهر';

  @override
  String get male => 'ذكر';

  @override
  String get female => 'أنثى';

  @override
  String get child => 'طفل';

  @override
  String get young => 'شاب';

  @override
  String get senior => 'كبير';

  @override
  String get readingSpeed => 'سرعة القراءة';

  @override
  String get slow => 'هادئ';

  @override
  String get medium => 'متوسط';

  @override
  String get fast => 'سريع';

  @override
  String get calibration => 'معايرة الصوت';

  @override
  String get saveChanges => 'حفظ جميع التغييرات';

  @override
  String get prayerPosition => 'وضعية الصلاة';

  @override
  String get takbir => 'تكبيرة الإحرام';

  @override
  String get ruku => 'الركوع';

  @override
  String get sujud => 'السجود';

  @override
  String get sitting => 'الجلوس';

  @override
  String get standing => 'القيام';

  @override
  String get nextStep => 'تخطي';

  @override
  String get previousStep => 'السابق';

  @override
  String get finish => 'إنهاء';

  @override
  String greeting(Object userName) {
    return 'السلام عليكم، $userName';
  }

  @override
  String get servicesTitle => 'الخدمات والبرامج';

  @override
  String get recommended => 'موصى به';

  @override
  String get khatmaJourney => 'رحلة الختمة المباركة';

  @override
  String get khatmaDesc =>
      'ابدأ رحلة الإيمان لختم القرآن الكريم تلاوةً أو في صلواتك اليومية.';

  @override
  String get certificatesTitle => 'شهادات الإنجاز والمكافأة';

  @override
  String get certificatesDesc => 'استعرض وثق نجاحاتك في رحلتك مع القرآن.';

  @override
  String get startNow => 'ابدأ الآن';

  @override
  String get confirmExit => 'تأكيد الخروج';

  @override
  String get exitMessage => 'هل أنت متأكد أنك تريد الخروج من التطبيق؟';

  @override
  String get no => 'لا';

  @override
  String get yes => 'نعم';

  @override
  String get cameraAnalysis => 'تحليل وضعية الجسم (AI)';

  @override
  String get cameraFollowUp => 'متابعة وتصحيح الوضعية';

  @override
  String get locationService => 'الموقع الجغفي';

  @override
  String get locationDesc => 'لتحديد مواقيت الصلاة بدقة';

  @override
  String get updateNow => 'تحديث الآن';

  @override
  String get prayerSettings => 'إعدادات الصلاة والتنبيهات';

  @override
  String get athanNotifications => 'تنبيهات الأذان';

  @override
  String get prefAthanVoice => 'صوت الأذان المفضل';

  @override
  String get prePrayerReminder => 'تنبيه قبل الصلاة';

  @override
  String reminderTime(Object minutes) {
    return 'التنبيه قبل بـ $minutes دقيقة';
  }

  @override
  String get calculationMethod => 'طريقة حساب المواقيت';

  @override
  String get khatmaSettings => 'التخصيص والختمة';

  @override
  String get darkMode => 'الوضع الليلي';

  @override
  String khatmaDuration(Object days) {
    return 'مدة ختم القرآن: $days يوم';
  }

  @override
  String get prefQari => 'القارئ المفضل';

  @override
  String get dataManagement => 'إدارة البيانات والتقدم';

  @override
  String get resetKhatma => 'تصفير تقدم الختمة';

  @override
  String get resetDailyPrayers => 'تصفير صلوات اليوم';

  @override
  String get saveSuccess => 'تم حفظ الإعدادات وتحديث التنبيهات';

  @override
  String get locationUpdateSuccess => 'تم تحديث الموقع وأوقات الصلاة بنجاح';

  @override
  String get locationUpdateError =>
      'فشل تحديث الموقع، يرجى التأكد من الصلاحيات';

  @override
  String get cancel => 'إلغاء';

  @override
  String get confirm => 'تأكيد';

  @override
  String get confirmResetKhatma =>
      'هل أنت متأكد من تصفير تقدم الختمة والبدء من جديد؟';

  @override
  String get confirmResetPrayers => 'هل أنت متأكد من مسح صلوات اليوم وإعادتها؟';

  @override
  String get resetKhatmaSuccess => 'تم تصفير الختمة بنجاح';

  @override
  String get resetPrayersSuccess => 'تم تصفير صلوات اليوم بنجاح';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get jobTitle => 'صفتك (مثلاً: طالب علم)';

  @override
  String get personalInfo => 'لنتعرف عليك';

  @override
  String get calibrationPrompt =>
      'هل ترغب في قراءة آية قصيرة لمرة واحدة فقط لكي يضبط التطبيق نفسه على سرعة تلاوتك؟ (اختياري)';

  @override
  String get dhikrOfDay => 'ذِكْرُ اليَوْمِ';

  @override
  String get peaceOfMind => 'ألا بذكر الله تطمئن القلوب';

  @override
  String targetedDuaCount(Object count) {
    return '$count دعاء هادف';
  }

  @override
  String get fullList => 'القائمة الكاملة';

  @override
  String get startChallenge => 'ابدأ التحدي';

  @override
  String get asmaOfTheDay => 'اسم اليوم التدبري';

  @override
  String get tadabburNow => 'تدبر الآن';

  @override
  String get copied => 'تم النسخ';

  @override
  String get remaining => 'تبقّى';

  @override
  String get target => 'الهدف';

  @override
  String get cycles => 'الدورات';

  @override
  String get vibration => 'الاهتزاز';

  @override
  String get sound => 'الصوت';

  @override
  String get selectZikr => 'اختر الذكر';

  @override
  String get setTarget => 'تحديد الهدف';

  @override
  String get searchSurah => 'ابحث عن سورة...';

  @override
  String get savedSurahs => 'السور المحفوظة';

  @override
  String get savedAyahs => 'الآيات المحفوظة';

  @override
  String get achievementRate => 'نسبة الإنجاز';

  @override
  String verseCount(Object count) {
    return 'عدد آياتها: $count';
  }

  @override
  String ayahNumber(Object number) {
    return 'آية $number';
  }

  @override
  String get clickForTadabbur => 'انقر للتدبر والتفسير';

  @override
  String get tafseerTab => 'التفسير';

  @override
  String get tadabburTab => 'التدبر';

  @override
  String get reflectionsTab => 'خواطري';

  @override
  String get easyMeaning => 'المعنى الميسر';

  @override
  String get wordMeanings => 'معاني الكلمات';

  @override
  String get reflectiveQuestion => 'سؤال تأملي';

  @override
  String get practicalApplication => 'تطبيق عملي';

  @override
  String get reflectionHint => 'اكتب خواطرك وتأملاتك حول هذه الآية...';

  @override
  String get saveReflection => 'حفظ التأمل';

  @override
  String get reflectionSaved => 'تم حفظ الخاطرة بنجاح';

  @override
  String get meaningAndSignificance => 'المعنى والدلالة';

  @override
  String get legalEvidence => 'الدليل الشرعي';

  @override
  String get contemplativeNote => 'لفتة تدبرية';

  @override
  String get traditionalSupplication => 'دعاء مأثور';

  @override
  String motivationStart(Object userName) {
    return 'أهلاً بك $userName، اليوم هو بداية رحلة عظيمة مع القرآن. هل نبدأ بوردك الأول؟';
  }

  @override
  String motivationProgress(Object percent, Object userName) {
    return 'رائع يا $userName، لقد قطعت $percent% من رحلة الختمة. استمر، أنت تبلي بلاءً حسناً!';
  }

  @override
  String motivationHalfway(Object userName) {
    return 'ما شاء الله يا $userName! تجاوزت منتصف الطريق. الجنة تناديك، بقي القليل!';
  }

  @override
  String motivationAlmost(Object userName) {
    return 'أنت على وشك الختام يا $userName! يا له من إنجاز عظيم يفتخر به الملائكة.';
  }

  @override
  String get customizeInterface => 'خصص واجهتك النورانية';

  @override
  String get displayMode => 'نمط العرض';

  @override
  String get night => 'ليلي';

  @override
  String get day => 'نهاري';

  @override
  String get chooseBackground => 'اختر الخلفية';

  @override
  String get suggestedBackgrounds => 'خلفيات مقترحة';

  @override
  String get fromDevice => 'من جهازك';

  @override
  String get primaryColor => 'اللون الأساسي للأزرار';

  @override
  String get accentColor => 'لون التفاصيل والكتابة';

  @override
  String get livePreview => 'معاينة حية';

  @override
  String get primaryText => 'نص أساسي';

  @override
  String get secondaryText => 'نص ثانوي';

  @override
  String get exampleButton => 'زر مثال';

  @override
  String get startMyJourney => 'ابدأ رحلتي الآن';

  @override
  String get chooseSuggestedBackground => 'اختر خلفية مقترحة';

  @override
  String get close => 'إغلاق';

  @override
  String get nextPrayer => 'الصلاة القادمة';

  @override
  String get currentDay => 'اليوم الحالي';

  @override
  String get inJourney => 'في الرحلة';

  @override
  String get previousKhatmas => 'ختمات سابقة';

  @override
  String get days => 'يوم';

  @override
  String get prayerTimes => 'مواقيت الصلاة';

  @override
  String get startDailyWird => 'ابدأ الورد اليومي';

  @override
  String get wirdReady => 'وردك القرآني جاهز، اضغط للبدء..';

  @override
  String get calibrationTitle => 'المعايرة والاستعداد';

  @override
  String get rakahLabel => 'الركعة';

  @override
  String get rakah1 => 'الأولى';

  @override
  String get rakah2 => 'الثانية';

  @override
  String get rakah3 => 'الثالثة';

  @override
  String get rakah4 => 'الرابعة';

  @override
  String get completeAyahVoice => 'أكمل الآية بصوتك...';

  @override
  String get waitingForCamera => 'بانتظار ظهورك أمام الكاميرا...';

  @override
  String get tooClose => 'أنت قريب جداً! تراجع للخلف';

  @override
  String get tiltUp => 'ارفع وجه الهاتف للأعلى قليلاً';

  @override
  String get tiltDown => 'أمل الهاتف للأسفل قليلاً';

  @override
  String get perfectPosition => 'الوضعية ممتازة! كبّر للبدء';

  @override
  String get checkingPosition => 'جاري التحقق من الوضعية...';

  @override
  String get takbirPrompt => 'قل \'الله أكبر\' أو ارفع يديك للتكبير';

  @override
  String get skip => 'تخطي';

  @override
  String get camera => 'الكاميرا';

  @override
  String get istiftahDua => 'دعاء الاستفتاح';

  @override
  String get fatiha => 'الفاتحة';

  @override
  String get amin => 'تأمين';

  @override
  String get rukuLabel => 'الركوع';

  @override
  String get risingLabel => 'الرفع';

  @override
  String get sujud1Label => 'السجود الأول';

  @override
  String get sittingLabel => 'الجلسة';

  @override
  String get sujud2Label => 'السجود الثاني';

  @override
  String get tashahhudMiddle => 'التشهد الأوسط';

  @override
  String get tashahhudFinal => 'التشهد الأخير';

  @override
  String get tasleemRight => 'التسليم يميناً';

  @override
  String get tasleemLeft => 'التسليم يساراً';

  @override
  String get prayerStartConfirm => 'تقبل الله، لنبدأ الصلاة';

  @override
  String get prayerFinished => 'تقبل الله طاعتكم، تم تسجيل صلاتكم بنجاح';

  @override
  String get anisPersonality => 'شخصية أنيس (صوته)';

  @override
  String get sage => 'الوقور';

  @override
  String get companion => 'الرفيق';

  @override
  String get motivator => 'المحفز';

  @override
  String get peaceful => 'الهادئ';

  @override
  String get orator => 'الخطيب';

  @override
  String get mentor => 'الناصح';

  @override
  String get tryVoice => 'تجربة الصوت';

  @override
  String get selectLanguage => 'اختر اللغة';

  @override
  String get gender => 'الجنس';

  @override
  String get ageGroup => 'الفئة العمرية';

  @override
  String get calibrationInstruction =>
      'من فضلك، اقرأ الآية لكي أتعرف على سرعة تلاوتك ونبرة صوتك.';

  @override
  String get calibrationSuccess =>
      'رائع! تم حفظ بصمتك الصوتية بنجاح. سأكون متناغماً معك في الصلاة.';

  @override
  String get goodMorning => 'صباح الخير';

  @override
  String get goodDay => 'طاب يومك';

  @override
  String get goodEvening => 'مساء الخير';

  @override
  String get anisIntro => 'أنا أنيس، رفيقك في هذه الرحلة المباركة.';

  @override
  String get fajr => 'الفجر';

  @override
  String get dhuhr => 'الظهر';

  @override
  String get asr => 'العصر';

  @override
  String get maghrib => 'المغرب';

  @override
  String get isha => 'العشاء';

  @override
  String startPrayerAction(Object prayerName) {
    return 'ابدأ صلاة $prayerName';
  }

  @override
  String get wirdReadyForPrayer => 'وردك القرآني جاهز للصلاة..';

  @override
  String get morningAdhkar => 'أذكار الصباح';

  @override
  String get eveningAdhkar => 'أذكار المساء';

  @override
  String get afterPrayerAdhkar => 'أذكار بعد الصلاة';

  @override
  String get propheticDuas => 'أدعية نبوية';

  @override
  String get quranicDuas => 'أدعية قرآنية';

  @override
  String get wakingUpAdhkar => 'أذكار الاستيقاظ';

  @override
  String get sleepingAdhkar => 'أذكار النوم';

  @override
  String get travelAdhkar => 'أذكار السفر';

  @override
  String get distressDuas => 'أدعية الكرب';

  @override
  String get tasbeehTitle => 'التسبيح';

  @override
  String get targetLabel => 'الهدف';

  @override
  String get cyclesLabel => 'الدورات';

  @override
  String get selectDhikr => 'اختر الذكر';

  @override
  String get rakah => 'الركعة';
}
