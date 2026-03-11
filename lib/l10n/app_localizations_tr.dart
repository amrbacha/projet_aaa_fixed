// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Namaz Asistanı';

  @override
  String get welcomeMessage =>
      'İbadet diyarına hoş geldiniz. İman derecelerinde birlikte yükselmek için bugün rotanızı seçin';

  @override
  String get startPrayer => 'Şimdi Namaza Başla';

  @override
  String get qiblaDirection => 'Kıble Yönü';

  @override
  String get khatmaProgress => 'Hatim İlerlemesi';

  @override
  String get smartAssistant => 'Anis - Akıllı Asistan';

  @override
  String get settings => 'Kapsamlı Ayarlar';

  @override
  String get readingQuran => 'Okuyarak Hatim';

  @override
  String get prayerKhatma => 'Namazla Hatim';

  @override
  String get memorization => 'Kur\'an-ı Kerim Ezberi';

  @override
  String get tafseer => 'Tefsir ve Tevekkür';

  @override
  String get adhkar => 'Zikirler ve Dualar';

  @override
  String get tasbeeh => 'Tesbih';

  @override
  String get asmaAllah => 'Esmaül Hüsna';

  @override
  String get language => 'Dil';

  @override
  String get theme => 'Görünüm';

  @override
  String get male => 'Erkek';

  @override
  String get female => 'Kadın';

  @override
  String get child => 'Çocuk';

  @override
  String get young => 'Genç';

  @override
  String get senior => 'Yaşlı';

  @override
  String get readingSpeed => 'Okuma Hızı';

  @override
  String get slow => 'Yavaş';

  @override
  String get medium => 'Orta';

  @override
  String get fast => 'Hızlı';

  @override
  String get calibration => 'Ses Kalibrasyonu';

  @override
  String get saveChanges => 'Tüm Değişiklikleri Kaydet';

  @override
  String get prayerPosition => 'Namaz Pozisyonu';

  @override
  String get takbir => 'İftitah Tekbiri';

  @override
  String get ruku => 'Rüku';

  @override
  String get sujud => 'Secde';

  @override
  String get sitting => 'Oturuş';

  @override
  String get standing => 'Kıyam';

  @override
  String get nextStep => 'Atla';

  @override
  String get previousStep => 'Önceki';

  @override
  String get finish => 'Bitir';

  @override
  String greeting(Object userName) {
    return 'Selamun Aleyküm, $userName';
  }

  @override
  String get servicesTitle => 'Hizmetler ve Programlar';

  @override
  String get recommended => 'Önerilen';

  @override
  String get khatmaJourney => 'Mübarek Hatim Yolculuğu';

  @override
  String get khatmaDesc =>
      'Kur\'an-ı Kerim\'i tilavetle veya günlük namazlarınızda hatmetmek için iman yolculuğuna başlayın.';

  @override
  String get certificatesTitle => 'Başarı ve Ödül Sertifikaları';

  @override
  String get certificatesDesc =>
      'Kur\'an ile olan yolculuğunuzdaki başarılarınızı inceleyin ve belgeleyin.';

  @override
  String get startNow => 'Şimdi Başla';

  @override
  String get confirmExit => 'Çıkışı Onayla';

  @override
  String get exitMessage => 'Uygulamadan çıkmak istediğinizden emin misiniz?';

  @override
  String get no => 'Hayır';

  @override
  String get yes => 'Evet';

  @override
  String get cameraAnalysis => 'Vücut Pozisyon Analizi (AI)';

  @override
  String get cameraFollowUp => 'Takip ve pozisyon düzeltme';

  @override
  String get locationService => 'Konum Servisi';

  @override
  String get locationDesc => 'Namaz vakitlerini doğru belirlemek için';

  @override
  String get updateNow => 'Şimdi Güncelle';

  @override
  String get prayerSettings => 'Namaz Ayarları ve Bildirimler';

  @override
  String get athanNotifications => 'Ezan Bildirimleri';

  @override
  String get prefAthanVoice => 'Tercih Edilen Ezan Sesi';

  @override
  String get prePrayerReminder => 'Namaz Öncesi Hatırlatıcı';

  @override
  String reminderTime(Object minutes) {
    return '$minutes dakika önce hatırlat';
  }

  @override
  String get calculationMethod => 'Hesaplama Yöntemi';

  @override
  String get khatmaSettings => 'Özelleştirme ve Hatim';

  @override
  String get darkMode => 'Karanlık Mod';

  @override
  String khatmaDuration(Object days) {
    return 'Hatim Süresi: $days gün';
  }

  @override
  String get prefQari => 'Tercih Edilen Kâri';

  @override
  String get dataManagement => 'Veri ve İlerleme Yönetimi';

  @override
  String get resetKhatma => 'Hatim İlerlemesini Sıfırla';

  @override
  String get resetDailyPrayers => 'Bugünkü Namazları Sıfırla';

  @override
  String get saveSuccess => 'Ayarlar kaydedildi ve bildirimler güncellendi';

  @override
  String get locationUpdateSuccess =>
      'Konum ve namaz vakitleri başarıyla güncellendi';

  @override
  String get locationUpdateError =>
      'Konum güncellenemedi, lütfen izinleri kontrol edin';

  @override
  String get cancel => 'İptal';

  @override
  String get confirm => 'Onayla';

  @override
  String get confirmResetKhatma =>
      'Hatim ilerlemesini sıfırlayıp baştan başlamak istediğinizden emin misiniz?';

  @override
  String get confirmResetPrayers =>
      'Bugünkü namazları temizleyip tekrar yapmak istediğinizden emin misiniz?';

  @override
  String get resetKhatmaSuccess => 'Hatim başarıyla sıfırlandı';

  @override
  String get resetPrayersSuccess => 'Bugünkü namazlar başarıyla sıfırlandı';

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
  String get nextPrayer => 'Sıradaki Namaz';

  @override
  String get currentDay => 'Şu Anki Gün';

  @override
  String get inJourney => 'Yolculukta';

  @override
  String get previousKhatmas => 'Önceki Hatimler';

  @override
  String get days => 'Gün';

  @override
  String get prayerTimes => 'Namaz Vakitleri';

  @override
  String get startDailyWird => 'Günlük Virde Başla';

  @override
  String get wirdReady => 'Kur\'an virdiniz hazır, başlamak için dokunun..';

  @override
  String get calibrationTitle => 'Kalibrasyon ve Hazırlık';

  @override
  String get rakahLabel => 'Rekat';

  @override
  String get rakah1 => 'Birinci';

  @override
  String get rakah2 => 'İkinci';

  @override
  String get rakah3 => 'Üçüncü';

  @override
  String get rakah4 => 'Dördüncü';

  @override
  String get completeAyahVoice => 'Ayeti sesinizle tamamlayın...';

  @override
  String get waitingForCamera => 'Kamera önünde görünmeniz bekleniyor...';

  @override
  String get tooClose => 'Çok yakındasınız! Lütfen geri çekilin';

  @override
  String get tiltUp => 'Telefonu hafifçe yukarı kaldırın';

  @override
  String get tiltDown => 'Telefonu hafifçe aşağı indirin';

  @override
  String get perfectPosition =>
      'Mükemmel pozisyon! Başlamak için tekbir getirin';

  @override
  String get checkingPosition => 'Pozisyon kontrol ediliyor...';

  @override
  String get takbirPrompt =>
      'Başlamak için \'Allahu Ekber\' deyin veya ellerinizi kaldırın';

  @override
  String get skip => 'Atla';

  @override
  String get camera => 'Kamera';

  @override
  String get istiftahDua => 'Sübhaneke Duası';

  @override
  String get fatiha => 'Fatiha Suresi';

  @override
  String get amin => 'Amin';

  @override
  String get rukuLabel => 'Rüku';

  @override
  String get risingLabel => 'Doğrulma';

  @override
  String get sujud1Label => 'Birinci Secde';

  @override
  String get sittingLabel => 'Oturuş';

  @override
  String get sujud2Label => 'İkinci Secde';

  @override
  String get tashahhudMiddle => 'İlk Tahiyyat';

  @override
  String get tashahhudFinal => 'Son Tahiyyat';

  @override
  String get tasleemRight => 'Sağa Selam';

  @override
  String get tasleemLeft => 'Sola Selam';

  @override
  String get prayerStartConfirm => 'Allah kabul etsin, namaza başlayalım';

  @override
  String get prayerFinished =>
      'Allah kabul etsin, namazınız başarıyla kaydedildi';

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
