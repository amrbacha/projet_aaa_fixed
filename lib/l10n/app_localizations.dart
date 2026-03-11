import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_id.dart';
import 'app_localizations_ms.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_ur.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('id'),
    Locale('ms'),
    Locale('tr'),
    Locale('ur')
  ];

  /// No description provided for @appTitle.
  ///
  /// In ar, this message translates to:
  /// **'مساعد الصلاة'**
  String get appTitle;

  /// No description provided for @welcomeMessage.
  ///
  /// In ar, this message translates to:
  /// **'أهلاً بك في رحابة الطاعة. اختر وجهتك اليوم لترتقي سوياً في درجات الإيمان'**
  String get welcomeMessage;

  /// No description provided for @startPrayer.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ الصلاة الآن'**
  String get startPrayer;

  /// No description provided for @qiblaDirection.
  ///
  /// In ar, this message translates to:
  /// **'اتجاه القبلة'**
  String get qiblaDirection;

  /// No description provided for @khatmaProgress.
  ///
  /// In ar, this message translates to:
  /// **'تقدم الختمة'**
  String get khatmaProgress;

  /// No description provided for @smartAssistant.
  ///
  /// In ar, this message translates to:
  /// **'أنيس - المساعد الذكي'**
  String get smartAssistant;

  /// No description provided for @settings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات الشاملة'**
  String get settings;

  /// No description provided for @readingQuran.
  ///
  /// In ar, this message translates to:
  /// **'ختم القرآن بالقراءة'**
  String get readingQuran;

  /// No description provided for @prayerKhatma.
  ///
  /// In ar, this message translates to:
  /// **'ختم القرآن بالصلاة'**
  String get prayerKhatma;

  /// No description provided for @memorization.
  ///
  /// In ar, this message translates to:
  /// **'حفظ القرآن الكريم'**
  String get memorization;

  /// No description provided for @tafseer.
  ///
  /// In ar, this message translates to:
  /// **'التفسير والتدبر'**
  String get tafseer;

  /// No description provided for @adhkar.
  ///
  /// In ar, this message translates to:
  /// **'الأذكار والأدعية'**
  String get adhkar;

  /// No description provided for @tasbeeh.
  ///
  /// In ar, this message translates to:
  /// **'التسبيح'**
  String get tasbeeh;

  /// No description provided for @asmaAllah.
  ///
  /// In ar, this message translates to:
  /// **'أسماء الله الحسنى'**
  String get asmaAllah;

  /// No description provided for @language.
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In ar, this message translates to:
  /// **'المظهر'**
  String get theme;

  /// No description provided for @male.
  ///
  /// In ar, this message translates to:
  /// **'ذكر'**
  String get male;

  /// No description provided for @female.
  ///
  /// In ar, this message translates to:
  /// **'أنثى'**
  String get female;

  /// No description provided for @child.
  ///
  /// In ar, this message translates to:
  /// **'طفل'**
  String get child;

  /// No description provided for @young.
  ///
  /// In ar, this message translates to:
  /// **'شاب'**
  String get young;

  /// No description provided for @senior.
  ///
  /// In ar, this message translates to:
  /// **'كبير'**
  String get senior;

  /// No description provided for @readingSpeed.
  ///
  /// In ar, this message translates to:
  /// **'سرعة القراءة'**
  String get readingSpeed;

  /// No description provided for @slow.
  ///
  /// In ar, this message translates to:
  /// **'هادئ'**
  String get slow;

  /// No description provided for @medium.
  ///
  /// In ar, this message translates to:
  /// **'متوسط'**
  String get medium;

  /// No description provided for @fast.
  ///
  /// In ar, this message translates to:
  /// **'سريع'**
  String get fast;

  /// No description provided for @calibration.
  ///
  /// In ar, this message translates to:
  /// **'معايرة الصوت'**
  String get calibration;

  /// No description provided for @saveChanges.
  ///
  /// In ar, this message translates to:
  /// **'حفظ جميع التغييرات'**
  String get saveChanges;

  /// No description provided for @prayerPosition.
  ///
  /// In ar, this message translates to:
  /// **'وضعية الصلاة'**
  String get prayerPosition;

  /// No description provided for @takbir.
  ///
  /// In ar, this message translates to:
  /// **'تكبيرة الإحرام'**
  String get takbir;

  /// No description provided for @ruku.
  ///
  /// In ar, this message translates to:
  /// **'الركوع'**
  String get ruku;

  /// No description provided for @sujud.
  ///
  /// In ar, this message translates to:
  /// **'السجود'**
  String get sujud;

  /// No description provided for @sitting.
  ///
  /// In ar, this message translates to:
  /// **'الجلوس'**
  String get sitting;

  /// No description provided for @standing.
  ///
  /// In ar, this message translates to:
  /// **'القيام'**
  String get standing;

  /// No description provided for @nextStep.
  ///
  /// In ar, this message translates to:
  /// **'تخطي'**
  String get nextStep;

  /// No description provided for @previousStep.
  ///
  /// In ar, this message translates to:
  /// **'السابق'**
  String get previousStep;

  /// No description provided for @finish.
  ///
  /// In ar, this message translates to:
  /// **'إنهاء'**
  String get finish;

  /// No description provided for @greeting.
  ///
  /// In ar, this message translates to:
  /// **'السلام عليكم، {userName}'**
  String greeting(Object userName);

  /// No description provided for @servicesTitle.
  ///
  /// In ar, this message translates to:
  /// **'الخدمات والبرامج'**
  String get servicesTitle;

  /// No description provided for @recommended.
  ///
  /// In ar, this message translates to:
  /// **'موصى به'**
  String get recommended;

  /// No description provided for @khatmaJourney.
  ///
  /// In ar, this message translates to:
  /// **'رحلة الختمة المباركة'**
  String get khatmaJourney;

  /// No description provided for @khatmaDesc.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ رحلة الإيمان لختم القرآن الكريم تلاوةً أو في صلواتك اليومية.'**
  String get khatmaDesc;

  /// No description provided for @certificatesTitle.
  ///
  /// In ar, this message translates to:
  /// **'شهادات الإنجاز والمكافأة'**
  String get certificatesTitle;

  /// No description provided for @certificatesDesc.
  ///
  /// In ar, this message translates to:
  /// **'استعرض وثق نجاحاتك في رحلتك مع القرآن.'**
  String get certificatesDesc;

  /// No description provided for @startNow.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ الآن'**
  String get startNow;

  /// No description provided for @confirmExit.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الخروج'**
  String get confirmExit;

  /// No description provided for @exitMessage.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد أنك تريد الخروج من التطبيق؟'**
  String get exitMessage;

  /// No description provided for @no.
  ///
  /// In ar, this message translates to:
  /// **'لا'**
  String get no;

  /// No description provided for @yes.
  ///
  /// In ar, this message translates to:
  /// **'نعم'**
  String get yes;

  /// No description provided for @cameraAnalysis.
  ///
  /// In ar, this message translates to:
  /// **'تحليل وضعية الجسم (AI)'**
  String get cameraAnalysis;

  /// No description provided for @cameraFollowUp.
  ///
  /// In ar, this message translates to:
  /// **'متابعة وتصحيح الوضعية'**
  String get cameraFollowUp;

  /// No description provided for @locationService.
  ///
  /// In ar, this message translates to:
  /// **'الموقع الجغفي'**
  String get locationService;

  /// No description provided for @locationDesc.
  ///
  /// In ar, this message translates to:
  /// **'لتحديد مواقيت الصلاة بدقة'**
  String get locationDesc;

  /// No description provided for @updateNow.
  ///
  /// In ar, this message translates to:
  /// **'تحديث الآن'**
  String get updateNow;

  /// No description provided for @prayerSettings.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات الصلاة والتنبيهات'**
  String get prayerSettings;

  /// No description provided for @athanNotifications.
  ///
  /// In ar, this message translates to:
  /// **'تنبيهات الأذان'**
  String get athanNotifications;

  /// No description provided for @prefAthanVoice.
  ///
  /// In ar, this message translates to:
  /// **'صوت الأذان المفضل'**
  String get prefAthanVoice;

  /// No description provided for @prePrayerReminder.
  ///
  /// In ar, this message translates to:
  /// **'تنبيه قبل الصلاة'**
  String get prePrayerReminder;

  /// No description provided for @reminderTime.
  ///
  /// In ar, this message translates to:
  /// **'التنبيه قبل بـ {minutes} دقيقة'**
  String reminderTime(Object minutes);

  /// No description provided for @calculationMethod.
  ///
  /// In ar, this message translates to:
  /// **'طريقة حساب المواقيت'**
  String get calculationMethod;

  /// No description provided for @khatmaSettings.
  ///
  /// In ar, this message translates to:
  /// **'التخصيص والختمة'**
  String get khatmaSettings;

  /// No description provided for @darkMode.
  ///
  /// In ar, this message translates to:
  /// **'الوضع الليلي'**
  String get darkMode;

  /// No description provided for @khatmaDuration.
  ///
  /// In ar, this message translates to:
  /// **'مدة ختم القرآن: {days} يوم'**
  String khatmaDuration(Object days);

  /// No description provided for @prefQari.
  ///
  /// In ar, this message translates to:
  /// **'القارئ المفضل'**
  String get prefQari;

  /// No description provided for @dataManagement.
  ///
  /// In ar, this message translates to:
  /// **'إدارة البيانات والتقدم'**
  String get dataManagement;

  /// No description provided for @resetKhatma.
  ///
  /// In ar, this message translates to:
  /// **'تصفير تقدم الختمة'**
  String get resetKhatma;

  /// No description provided for @resetDailyPrayers.
  ///
  /// In ar, this message translates to:
  /// **'تصفير صلوات اليوم'**
  String get resetDailyPrayers;

  /// No description provided for @saveSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ الإعدادات وتحديث التنبيهات'**
  String get saveSuccess;

  /// No description provided for @locationUpdateSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث الموقع وأوقات الصلاة بنجاح'**
  String get locationUpdateSuccess;

  /// No description provided for @locationUpdateError.
  ///
  /// In ar, this message translates to:
  /// **'فشل تحديث الموقع، يرجى التأكد من الصلاحيات'**
  String get locationUpdateError;

  /// No description provided for @cancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد'**
  String get confirm;

  /// No description provided for @confirmResetKhatma.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من تصفير تقدم الختمة والبدء من جديد؟'**
  String get confirmResetKhatma;

  /// No description provided for @confirmResetPrayers.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من مسح صلوات اليوم وإعادتها؟'**
  String get confirmResetPrayers;

  /// No description provided for @resetKhatmaSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم تصفير الختمة بنجاح'**
  String get resetKhatmaSuccess;

  /// No description provided for @resetPrayersSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم تصفير صلوات اليوم بنجاح'**
  String get resetPrayersSuccess;

  /// No description provided for @fullName.
  ///
  /// In ar, this message translates to:
  /// **'الاسم الكامل'**
  String get fullName;

  /// No description provided for @jobTitle.
  ///
  /// In ar, this message translates to:
  /// **'صفتك (مثلاً: طالب علم)'**
  String get jobTitle;

  /// No description provided for @personalInfo.
  ///
  /// In ar, this message translates to:
  /// **'لنتعرف عليك'**
  String get personalInfo;

  /// No description provided for @calibrationPrompt.
  ///
  /// In ar, this message translates to:
  /// **'هل ترغب في قراءة آية قصيرة لمرة واحدة فقط لكي يضبط التطبيق نفسه على سرعة تلاوتك؟ (اختياري)'**
  String get calibrationPrompt;

  /// No description provided for @dhikrOfDay.
  ///
  /// In ar, this message translates to:
  /// **'ذِكْرُ اليَوْمِ'**
  String get dhikrOfDay;

  /// No description provided for @peaceOfMind.
  ///
  /// In ar, this message translates to:
  /// **'ألا بذكر الله تطمئن القلوب'**
  String get peaceOfMind;

  /// No description provided for @targetedDuaCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} دعاء هادف'**
  String targetedDuaCount(Object count);

  /// No description provided for @fullList.
  ///
  /// In ar, this message translates to:
  /// **'القائمة الكاملة'**
  String get fullList;

  /// No description provided for @startChallenge.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ التحدي'**
  String get startChallenge;

  /// No description provided for @asmaOfTheDay.
  ///
  /// In ar, this message translates to:
  /// **'اسم اليوم التدبري'**
  String get asmaOfTheDay;

  /// No description provided for @tadabburNow.
  ///
  /// In ar, this message translates to:
  /// **'تدبر الآن'**
  String get tadabburNow;

  /// No description provided for @copied.
  ///
  /// In ar, this message translates to:
  /// **'تم النسخ'**
  String get copied;

  /// No description provided for @remaining.
  ///
  /// In ar, this message translates to:
  /// **'تبقّى'**
  String get remaining;

  /// No description provided for @target.
  ///
  /// In ar, this message translates to:
  /// **'الهدف'**
  String get target;

  /// No description provided for @cycles.
  ///
  /// In ar, this message translates to:
  /// **'الدورات'**
  String get cycles;

  /// No description provided for @vibration.
  ///
  /// In ar, this message translates to:
  /// **'الاهتزاز'**
  String get vibration;

  /// No description provided for @sound.
  ///
  /// In ar, this message translates to:
  /// **'الصوت'**
  String get sound;

  /// No description provided for @selectZikr.
  ///
  /// In ar, this message translates to:
  /// **'اختر الذكر'**
  String get selectZikr;

  /// No description provided for @setTarget.
  ///
  /// In ar, this message translates to:
  /// **'تحديد الهدف'**
  String get setTarget;

  /// No description provided for @searchSurah.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن سورة...'**
  String get searchSurah;

  /// No description provided for @savedSurahs.
  ///
  /// In ar, this message translates to:
  /// **'السور المحفوظة'**
  String get savedSurahs;

  /// No description provided for @savedAyahs.
  ///
  /// In ar, this message translates to:
  /// **'الآيات المحفوظة'**
  String get savedAyahs;

  /// No description provided for @achievementRate.
  ///
  /// In ar, this message translates to:
  /// **'نسبة الإنجاز'**
  String get achievementRate;

  /// No description provided for @verseCount.
  ///
  /// In ar, this message translates to:
  /// **'عدد آياتها: {count}'**
  String verseCount(Object count);

  /// No description provided for @ayahNumber.
  ///
  /// In ar, this message translates to:
  /// **'آية {number}'**
  String ayahNumber(Object number);

  /// No description provided for @clickForTadabbur.
  ///
  /// In ar, this message translates to:
  /// **'انقر للتدبر والتفسير'**
  String get clickForTadabbur;

  /// No description provided for @tafseerTab.
  ///
  /// In ar, this message translates to:
  /// **'التفسير'**
  String get tafseerTab;

  /// No description provided for @tadabburTab.
  ///
  /// In ar, this message translates to:
  /// **'التدبر'**
  String get tadabburTab;

  /// No description provided for @reflectionsTab.
  ///
  /// In ar, this message translates to:
  /// **'خواطري'**
  String get reflectionsTab;

  /// No description provided for @easyMeaning.
  ///
  /// In ar, this message translates to:
  /// **'المعنى الميسر'**
  String get easyMeaning;

  /// No description provided for @wordMeanings.
  ///
  /// In ar, this message translates to:
  /// **'معاني الكلمات'**
  String get wordMeanings;

  /// No description provided for @reflectiveQuestion.
  ///
  /// In ar, this message translates to:
  /// **'سؤال تأملي'**
  String get reflectiveQuestion;

  /// No description provided for @practicalApplication.
  ///
  /// In ar, this message translates to:
  /// **'تطبيق عملي'**
  String get practicalApplication;

  /// No description provided for @reflectionHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب خواطرك وتأملاتك حول هذه الآية...'**
  String get reflectionHint;

  /// No description provided for @saveReflection.
  ///
  /// In ar, this message translates to:
  /// **'حفظ التأمل'**
  String get saveReflection;

  /// No description provided for @reflectionSaved.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ الخاطرة بنجاح'**
  String get reflectionSaved;

  /// No description provided for @meaningAndSignificance.
  ///
  /// In ar, this message translates to:
  /// **'المعنى والدلالة'**
  String get meaningAndSignificance;

  /// No description provided for @legalEvidence.
  ///
  /// In ar, this message translates to:
  /// **'الدليل الشرعي'**
  String get legalEvidence;

  /// No description provided for @contemplativeNote.
  ///
  /// In ar, this message translates to:
  /// **'لفتة تدبرية'**
  String get contemplativeNote;

  /// No description provided for @traditionalSupplication.
  ///
  /// In ar, this message translates to:
  /// **'دعاء مأثور'**
  String get traditionalSupplication;

  /// No description provided for @motivationStart.
  ///
  /// In ar, this message translates to:
  /// **'أهلاً بك {userName}، اليوم هو بداية رحلة عظيمة مع القرآن. هل نبدأ بوردك الأول؟'**
  String motivationStart(Object userName);

  /// No description provided for @motivationProgress.
  ///
  /// In ar, this message translates to:
  /// **'رائع يا {userName}، لقد قطعت {percent}% من رحلة الختمة. استمر، أنت تبلي بلاءً حسناً!'**
  String motivationProgress(Object percent, Object userName);

  /// No description provided for @motivationHalfway.
  ///
  /// In ar, this message translates to:
  /// **'ما شاء الله يا {userName}! تجاوزت منتصف الطريق. الجنة تناديك، بقي القليل!'**
  String motivationHalfway(Object userName);

  /// No description provided for @motivationAlmost.
  ///
  /// In ar, this message translates to:
  /// **'أنت على وشك الختام يا {userName}! يا له من إنجاز عظيم يفتخر به الملائكة.'**
  String motivationAlmost(Object userName);

  /// No description provided for @customizeInterface.
  ///
  /// In ar, this message translates to:
  /// **'خصص واجهتك النورانية'**
  String get customizeInterface;

  /// No description provided for @displayMode.
  ///
  /// In ar, this message translates to:
  /// **'نمط العرض'**
  String get displayMode;

  /// No description provided for @night.
  ///
  /// In ar, this message translates to:
  /// **'ليلي'**
  String get night;

  /// No description provided for @day.
  ///
  /// In ar, this message translates to:
  /// **'نهاري'**
  String get day;

  /// No description provided for @chooseBackground.
  ///
  /// In ar, this message translates to:
  /// **'اختر الخلفية'**
  String get chooseBackground;

  /// No description provided for @suggestedBackgrounds.
  ///
  /// In ar, this message translates to:
  /// **'خلفيات مقترحة'**
  String get suggestedBackgrounds;

  /// No description provided for @fromDevice.
  ///
  /// In ar, this message translates to:
  /// **'من جهازك'**
  String get fromDevice;

  /// No description provided for @primaryColor.
  ///
  /// In ar, this message translates to:
  /// **'اللون الأساسي للأزرار'**
  String get primaryColor;

  /// No description provided for @accentColor.
  ///
  /// In ar, this message translates to:
  /// **'لون التفاصيل والكتابة'**
  String get accentColor;

  /// No description provided for @livePreview.
  ///
  /// In ar, this message translates to:
  /// **'معاينة حية'**
  String get livePreview;

  /// No description provided for @primaryText.
  ///
  /// In ar, this message translates to:
  /// **'نص أساسي'**
  String get primaryText;

  /// No description provided for @secondaryText.
  ///
  /// In ar, this message translates to:
  /// **'نص ثانوي'**
  String get secondaryText;

  /// No description provided for @exampleButton.
  ///
  /// In ar, this message translates to:
  /// **'زر مثال'**
  String get exampleButton;

  /// No description provided for @startMyJourney.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ رحلتي الآن'**
  String get startMyJourney;

  /// No description provided for @chooseSuggestedBackground.
  ///
  /// In ar, this message translates to:
  /// **'اختر خلفية مقترحة'**
  String get chooseSuggestedBackground;

  /// No description provided for @close.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق'**
  String get close;

  /// No description provided for @nextPrayer.
  ///
  /// In ar, this message translates to:
  /// **'الصلاة القادمة'**
  String get nextPrayer;

  /// No description provided for @currentDay.
  ///
  /// In ar, this message translates to:
  /// **'اليوم الحالي'**
  String get currentDay;

  /// No description provided for @inJourney.
  ///
  /// In ar, this message translates to:
  /// **'في الرحلة'**
  String get inJourney;

  /// No description provided for @previousKhatmas.
  ///
  /// In ar, this message translates to:
  /// **'ختمات سابقة'**
  String get previousKhatmas;

  /// No description provided for @days.
  ///
  /// In ar, this message translates to:
  /// **'يوم'**
  String get days;

  /// No description provided for @prayerTimes.
  ///
  /// In ar, this message translates to:
  /// **'مواقيت الصلاة'**
  String get prayerTimes;

  /// No description provided for @startDailyWird.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ الورد اليومي'**
  String get startDailyWird;

  /// No description provided for @wirdReady.
  ///
  /// In ar, this message translates to:
  /// **'وردك القرآني جاهز، اضغط للبدء..'**
  String get wirdReady;

  /// No description provided for @calibrationTitle.
  ///
  /// In ar, this message translates to:
  /// **'المعايرة والاستعداد'**
  String get calibrationTitle;

  /// No description provided for @rakahLabel.
  ///
  /// In ar, this message translates to:
  /// **'الركعة'**
  String get rakahLabel;

  /// No description provided for @rakah1.
  ///
  /// In ar, this message translates to:
  /// **'الأولى'**
  String get rakah1;

  /// No description provided for @rakah2.
  ///
  /// In ar, this message translates to:
  /// **'الثانية'**
  String get rakah2;

  /// No description provided for @rakah3.
  ///
  /// In ar, this message translates to:
  /// **'الثالثة'**
  String get rakah3;

  /// No description provided for @rakah4.
  ///
  /// In ar, this message translates to:
  /// **'الرابعة'**
  String get rakah4;

  /// No description provided for @completeAyahVoice.
  ///
  /// In ar, this message translates to:
  /// **'أكمل الآية بصوتك...'**
  String get completeAyahVoice;

  /// No description provided for @waitingForCamera.
  ///
  /// In ar, this message translates to:
  /// **'بانتظار ظهورك أمام الكاميرا...'**
  String get waitingForCamera;

  /// No description provided for @tooClose.
  ///
  /// In ar, this message translates to:
  /// **'أنت قريب جداً! تراجع للخلف'**
  String get tooClose;

  /// No description provided for @tiltUp.
  ///
  /// In ar, this message translates to:
  /// **'ارفع وجه الهاتف للأعلى قليلاً'**
  String get tiltUp;

  /// No description provided for @tiltDown.
  ///
  /// In ar, this message translates to:
  /// **'أمل الهاتف للأسفل قليلاً'**
  String get tiltDown;

  /// No description provided for @perfectPosition.
  ///
  /// In ar, this message translates to:
  /// **'الوضعية ممتازة! كبّر للبدء'**
  String get perfectPosition;

  /// No description provided for @checkingPosition.
  ///
  /// In ar, this message translates to:
  /// **'جاري التحقق من الوضعية...'**
  String get checkingPosition;

  /// No description provided for @takbirPrompt.
  ///
  /// In ar, this message translates to:
  /// **'قل \'الله أكبر\' أو ارفع يديك للتكبير'**
  String get takbirPrompt;

  /// No description provided for @skip.
  ///
  /// In ar, this message translates to:
  /// **'تخطي'**
  String get skip;

  /// No description provided for @camera.
  ///
  /// In ar, this message translates to:
  /// **'الكاميرا'**
  String get camera;

  /// No description provided for @istiftahDua.
  ///
  /// In ar, this message translates to:
  /// **'دعاء الاستفتاح'**
  String get istiftahDua;

  /// No description provided for @fatiha.
  ///
  /// In ar, this message translates to:
  /// **'الفاتحة'**
  String get fatiha;

  /// No description provided for @amin.
  ///
  /// In ar, this message translates to:
  /// **'تأمين'**
  String get amin;

  /// No description provided for @rukuLabel.
  ///
  /// In ar, this message translates to:
  /// **'الركوع'**
  String get rukuLabel;

  /// No description provided for @risingLabel.
  ///
  /// In ar, this message translates to:
  /// **'الرفع'**
  String get risingLabel;

  /// No description provided for @sujud1Label.
  ///
  /// In ar, this message translates to:
  /// **'السجود الأول'**
  String get sujud1Label;

  /// No description provided for @sittingLabel.
  ///
  /// In ar, this message translates to:
  /// **'الجلسة'**
  String get sittingLabel;

  /// No description provided for @sujud2Label.
  ///
  /// In ar, this message translates to:
  /// **'السجود الثاني'**
  String get sujud2Label;

  /// No description provided for @tashahhudMiddle.
  ///
  /// In ar, this message translates to:
  /// **'التشهد الأوسط'**
  String get tashahhudMiddle;

  /// No description provided for @tashahhudFinal.
  ///
  /// In ar, this message translates to:
  /// **'التشهد الأخير'**
  String get tashahhudFinal;

  /// No description provided for @tasleemRight.
  ///
  /// In ar, this message translates to:
  /// **'التسليم يميناً'**
  String get tasleemRight;

  /// No description provided for @tasleemLeft.
  ///
  /// In ar, this message translates to:
  /// **'التسليم يساراً'**
  String get tasleemLeft;

  /// No description provided for @prayerStartConfirm.
  ///
  /// In ar, this message translates to:
  /// **'تقبل الله، لنبدأ الصلاة'**
  String get prayerStartConfirm;

  /// No description provided for @prayerFinished.
  ///
  /// In ar, this message translates to:
  /// **'تقبل الله طاعتكم، تم تسجيل صلاتكم بنجاح'**
  String get prayerFinished;

  /// No description provided for @anisPersonality.
  ///
  /// In ar, this message translates to:
  /// **'شخصية أنيس (صوته)'**
  String get anisPersonality;

  /// No description provided for @sage.
  ///
  /// In ar, this message translates to:
  /// **'الوقور'**
  String get sage;

  /// No description provided for @companion.
  ///
  /// In ar, this message translates to:
  /// **'الرفيق'**
  String get companion;

  /// No description provided for @motivator.
  ///
  /// In ar, this message translates to:
  /// **'المحفز'**
  String get motivator;

  /// No description provided for @peaceful.
  ///
  /// In ar, this message translates to:
  /// **'الهادئ'**
  String get peaceful;

  /// No description provided for @orator.
  ///
  /// In ar, this message translates to:
  /// **'الخطيب'**
  String get orator;

  /// No description provided for @mentor.
  ///
  /// In ar, this message translates to:
  /// **'الناصح'**
  String get mentor;

  /// No description provided for @tryVoice.
  ///
  /// In ar, this message translates to:
  /// **'تجربة الصوت'**
  String get tryVoice;

  /// No description provided for @selectLanguage.
  ///
  /// In ar, this message translates to:
  /// **'اختر اللغة'**
  String get selectLanguage;

  /// No description provided for @gender.
  ///
  /// In ar, this message translates to:
  /// **'الجنس'**
  String get gender;

  /// No description provided for @ageGroup.
  ///
  /// In ar, this message translates to:
  /// **'الفئة العمرية'**
  String get ageGroup;

  /// No description provided for @calibrationInstruction.
  ///
  /// In ar, this message translates to:
  /// **'من فضلك، اقرأ الآية لكي أتعرف على سرعة تلاوتك ونبرة صوتك.'**
  String get calibrationInstruction;

  /// No description provided for @calibrationSuccess.
  ///
  /// In ar, this message translates to:
  /// **'رائع! تم حفظ بصمتك الصوتية بنجاح. سأكون متناغماً معك في الصلاة.'**
  String get calibrationSuccess;

  /// No description provided for @goodMorning.
  ///
  /// In ar, this message translates to:
  /// **'صباح الخير'**
  String get goodMorning;

  /// No description provided for @goodDay.
  ///
  /// In ar, this message translates to:
  /// **'طاب يومك'**
  String get goodDay;

  /// No description provided for @goodEvening.
  ///
  /// In ar, this message translates to:
  /// **'مساء الخير'**
  String get goodEvening;

  /// No description provided for @anisIntro.
  ///
  /// In ar, this message translates to:
  /// **'أنا أنيس، رفيقك في هذه الرحلة المباركة.'**
  String get anisIntro;

  /// No description provided for @fajr.
  ///
  /// In ar, this message translates to:
  /// **'الفجر'**
  String get fajr;

  /// No description provided for @dhuhr.
  ///
  /// In ar, this message translates to:
  /// **'الظهر'**
  String get dhuhr;

  /// No description provided for @asr.
  ///
  /// In ar, this message translates to:
  /// **'العصر'**
  String get asr;

  /// No description provided for @maghrib.
  ///
  /// In ar, this message translates to:
  /// **'المغرب'**
  String get maghrib;

  /// No description provided for @isha.
  ///
  /// In ar, this message translates to:
  /// **'العشاء'**
  String get isha;

  /// No description provided for @startPrayerAction.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ صلاة {prayerName}'**
  String startPrayerAction(Object prayerName);

  /// No description provided for @wirdReadyForPrayer.
  ///
  /// In ar, this message translates to:
  /// **'وردك القرآني جاهز للصلاة..'**
  String get wirdReadyForPrayer;

  /// No description provided for @morningAdhkar.
  ///
  /// In ar, this message translates to:
  /// **'أذكار الصباح'**
  String get morningAdhkar;

  /// No description provided for @eveningAdhkar.
  ///
  /// In ar, this message translates to:
  /// **'أذكار المساء'**
  String get eveningAdhkar;

  /// No description provided for @afterPrayerAdhkar.
  ///
  /// In ar, this message translates to:
  /// **'أذكار بعد الصلاة'**
  String get afterPrayerAdhkar;

  /// No description provided for @propheticDuas.
  ///
  /// In ar, this message translates to:
  /// **'أدعية نبوية'**
  String get propheticDuas;

  /// No description provided for @quranicDuas.
  ///
  /// In ar, this message translates to:
  /// **'أدعية قرآنية'**
  String get quranicDuas;

  /// No description provided for @wakingUpAdhkar.
  ///
  /// In ar, this message translates to:
  /// **'أذكار الاستيقاظ'**
  String get wakingUpAdhkar;

  /// No description provided for @sleepingAdhkar.
  ///
  /// In ar, this message translates to:
  /// **'أذكار النوم'**
  String get sleepingAdhkar;

  /// No description provided for @travelAdhkar.
  ///
  /// In ar, this message translates to:
  /// **'أذكار السفر'**
  String get travelAdhkar;

  /// No description provided for @distressDuas.
  ///
  /// In ar, this message translates to:
  /// **'أدعية الكرب'**
  String get distressDuas;

  /// No description provided for @tasbeehTitle.
  ///
  /// In ar, this message translates to:
  /// **'التسبيح'**
  String get tasbeehTitle;

  /// No description provided for @targetLabel.
  ///
  /// In ar, this message translates to:
  /// **'الهدف'**
  String get targetLabel;

  /// No description provided for @cyclesLabel.
  ///
  /// In ar, this message translates to:
  /// **'الدورات'**
  String get cyclesLabel;

  /// No description provided for @selectDhikr.
  ///
  /// In ar, this message translates to:
  /// **'اختر الذكر'**
  String get selectDhikr;

  /// No description provided for @rakah.
  ///
  /// In ar, this message translates to:
  /// **'الركعة'**
  String get rakah;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'ar',
        'en',
        'es',
        'fr',
        'id',
        'ms',
        'tr',
        'ur'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'id':
      return AppLocalizationsId();
    case 'ms':
      return AppLocalizationsMs();
    case 'tr':
      return AppLocalizationsTr();
    case 'ur':
      return AppLocalizationsUr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
