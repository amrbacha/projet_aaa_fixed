// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Prayer Assistant';

  @override
  String get welcomeMessage =>
      'Welcome to the realm of obedience. Choose your destination today to rise together in the degrees of faith';

  @override
  String get startPrayer => 'Start Prayer Now';

  @override
  String get qiblaDirection => 'Qibla Direction';

  @override
  String get khatmaProgress => 'Khatma Progress';

  @override
  String get smartAssistant => 'Anis - Smart Assistant';

  @override
  String get settings => 'Comprehensive Settings';

  @override
  String get readingQuran => 'Quran Completion by Reading';

  @override
  String get prayerKhatma => 'Quran Completion by Prayer';

  @override
  String get memorization => 'Holy Quran Memorization';

  @override
  String get tafseer => 'Tafseer and Reflection';

  @override
  String get adhkar => 'Adhkar and Supplications';

  @override
  String get tasbeeh => 'Tasbeeh';

  @override
  String get asmaAllah => 'Names of Allah';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Appearance';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get child => 'Child';

  @override
  String get young => 'Young';

  @override
  String get senior => 'Senior';

  @override
  String get readingSpeed => 'Reading Speed';

  @override
  String get slow => 'Slow';

  @override
  String get medium => 'Medium';

  @override
  String get fast => 'Fast';

  @override
  String get calibration => 'Voice Calibration';

  @override
  String get saveChanges => 'Save All Changes';

  @override
  String get prayerPosition => 'Prayer Position';

  @override
  String get takbir => 'Takbirat al-Ihram';

  @override
  String get ruku => 'Ruku';

  @override
  String get sujud => 'Sujud';

  @override
  String get sitting => 'Sitting';

  @override
  String get standing => 'Standing';

  @override
  String get nextStep => 'Skip';

  @override
  String get previousStep => 'Previous';

  @override
  String get finish => 'Finish';

  @override
  String greeting(Object userName) {
    return 'Peace be upon you, $userName';
  }

  @override
  String get servicesTitle => 'Services and Programs';

  @override
  String get recommended => 'Recommended';

  @override
  String get khatmaJourney => 'Blessed Khatma Journey';

  @override
  String get khatmaDesc =>
      'Start the journey of faith to complete the Holy Quran by recitation or in your daily prayers.';

  @override
  String get certificatesTitle => 'Achievement and Reward Certificates';

  @override
  String get certificatesDesc =>
      'Review and document your successes in your journey with the Quran.';

  @override
  String get startNow => 'Start Now';

  @override
  String get confirmExit => 'Confirm Exit';

  @override
  String get exitMessage => 'Are you sure you want to exit the application?';

  @override
  String get no => 'No';

  @override
  String get yes => 'Yes';

  @override
  String get cameraAnalysis => 'Body Pose Analysis (AI)';

  @override
  String get cameraFollowUp => 'Follow-up and position correction';

  @override
  String get locationService => 'Location Service';

  @override
  String get locationDesc => 'To determine prayer times accurately';

  @override
  String get updateNow => 'Update Now';

  @override
  String get prayerSettings => 'Prayer Settings and Notifications';

  @override
  String get athanNotifications => 'Athan Notifications';

  @override
  String get prefAthanVoice => 'Preferred Athan Voice';

  @override
  String get prePrayerReminder => 'Pre-prayer Reminder';

  @override
  String reminderTime(Object minutes) {
    return 'Reminder $minutes minutes before';
  }

  @override
  String get calculationMethod => 'Calculation Method';

  @override
  String get khatmaSettings => 'Customization and Khatma';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String khatmaDuration(Object days) {
    return 'Khatma Duration: $days days';
  }

  @override
  String get prefQari => 'Preferred Reciter';

  @override
  String get dataManagement => 'Data and Progress Management';

  @override
  String get resetKhatma => 'Reset Khatma Progress';

  @override
  String get resetDailyPrayers => 'Reset Today\'s Prayers';

  @override
  String get saveSuccess => 'Settings saved and notifications updated';

  @override
  String get locationUpdateSuccess =>
      'Location and prayer times updated successfully';

  @override
  String get locationUpdateError =>
      'Failed to update location, please check permissions';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get confirmResetKhatma =>
      'Are you sure you want to reset the Khatma progress and start over?';

  @override
  String get confirmResetPrayers =>
      'Are you sure you want to clear today\'s prayers and redo them?';

  @override
  String get resetKhatmaSuccess => 'Khatma reset successfully';

  @override
  String get resetPrayersSuccess => 'Today\'s prayers reset successfully';

  @override
  String get fullName => 'Full Name';

  @override
  String get jobTitle => 'Your Title (e.g., Student)';

  @override
  String get personalInfo => 'Let\'s get to know you';

  @override
  String get calibrationPrompt =>
      'Would you like to read a short verse once so the app can adjust to your recitation speed? (Optional)';

  @override
  String get dhikrOfDay => 'Dhikr of the Day';

  @override
  String get peaceOfMind =>
      'Unquestionably, by the remembrance of Allah hearts are assured';

  @override
  String targetedDuaCount(Object count) {
    return '$count Targeted Duas';
  }

  @override
  String get fullList => 'Full List';

  @override
  String get startChallenge => 'Start Challenge';

  @override
  String get asmaOfTheDay => 'Name of the Day for Reflection';

  @override
  String get tadabburNow => 'Reflect Now';

  @override
  String get copied => 'Copied';

  @override
  String get remaining => 'Remaining';

  @override
  String get target => 'Target';

  @override
  String get cycles => 'Cycles';

  @override
  String get vibration => 'Vibration';

  @override
  String get sound => 'Sound';

  @override
  String get selectZikr => 'Select Dhikr';

  @override
  String get setTarget => 'Set Target';

  @override
  String get searchSurah => 'Search for Surah...';

  @override
  String get savedSurahs => 'Saved Surahs';

  @override
  String get savedAyahs => 'Saved Ayahs';

  @override
  String get achievementRate => 'Achievement Rate';

  @override
  String verseCount(Object count) {
    return 'Verses: $count';
  }

  @override
  String ayahNumber(Object number) {
    return 'Ayah $number';
  }

  @override
  String get clickForTadabbur => 'Click for Reflection and Tafseer';

  @override
  String get tafseerTab => 'Tafseer';

  @override
  String get tadabburTab => 'Reflection';

  @override
  String get reflectionsTab => 'My Reflections';

  @override
  String get easyMeaning => 'Simplified Meaning';

  @override
  String get wordMeanings => 'Word Meanings';

  @override
  String get reflectiveQuestion => 'Reflective Question';

  @override
  String get practicalApplication => 'Practical Application';

  @override
  String get reflectionHint =>
      'Write your thoughts and reflections on this verse...';

  @override
  String get saveReflection => 'Save Reflection';

  @override
  String get reflectionSaved => 'Reflection saved successfully';

  @override
  String get meaningAndSignificance => 'Meaning and Significance';

  @override
  String get legalEvidence => 'Legal Evidence';

  @override
  String get contemplativeNote => 'Contemplative Note';

  @override
  String get traditionalSupplication => 'Traditional Supplication';

  @override
  String motivationStart(Object userName) {
    return 'Welcome $userName, today begins a great journey with the Quran. Shall we start with your first reading?';
  }

  @override
  String motivationProgress(Object percent, Object userName) {
    return 'Great $userName, you have completed $percent% of the Khatma journey. Keep going, you\'re doing very well!';
  }

  @override
  String motivationHalfway(Object userName) {
    return 'Masha\'Allah $userName! You\'ve passed the halfway point. Paradise is calling you, just a little further!';
  }

  @override
  String motivationAlmost(Object userName) {
    return 'You are almost finished, $userName! What a great achievement that the angels are proud of.';
  }

  @override
  String get customizeInterface => 'Customize Your Luminous Interface';

  @override
  String get displayMode => 'Display Mode';

  @override
  String get night => 'Night';

  @override
  String get day => 'Day';

  @override
  String get chooseBackground => 'Choose Background';

  @override
  String get suggestedBackgrounds => 'Suggested Backgrounds';

  @override
  String get fromDevice => 'From Your Device';

  @override
  String get primaryColor => 'Primary Button Color';

  @override
  String get accentColor => 'Accent & Text Color';

  @override
  String get livePreview => 'Live Preview';

  @override
  String get primaryText => 'Primary Text';

  @override
  String get secondaryText => 'Secondary Text';

  @override
  String get exampleButton => 'Example Button';

  @override
  String get startMyJourney => 'Start My Journey Now';

  @override
  String get chooseSuggestedBackground => 'Choose a Suggested Background';

  @override
  String get close => 'Close';

  @override
  String get nextPrayer => 'Next Prayer';

  @override
  String get currentDay => 'Current Day';

  @override
  String get inJourney => 'In Journey';

  @override
  String get previousKhatmas => 'Previous Khatmas';

  @override
  String get days => 'Days';

  @override
  String get prayerTimes => 'Prayer Times';

  @override
  String get startDailyWird => 'Start Daily Wird';

  @override
  String get wirdReady => 'Your Quranic wird is ready, tap to start..';

  @override
  String get calibrationTitle => 'Calibration and Preparation';

  @override
  String get rakahLabel => 'Rakah';

  @override
  String get rakah1 => 'First';

  @override
  String get rakah2 => 'Second';

  @override
  String get rakah3 => 'Third';

  @override
  String get rakah4 => 'Fourth';

  @override
  String get completeAyahVoice => 'Complete the verse with your voice...';

  @override
  String get waitingForCamera =>
      'Waiting for you to appear in front of the camera...';

  @override
  String get tooClose => 'You are too close! Please step back';

  @override
  String get tiltUp => 'Tilt the phone face up slightly';

  @override
  String get tiltDown => 'Tilt the phone face down slightly';

  @override
  String get perfectPosition => 'Perfect position! Start by saying Takbir';

  @override
  String get checkingPosition => 'Checking position...';

  @override
  String get takbirPrompt =>
      'Say \'Allahu Akbar\' or raise your hands for Takbir';

  @override
  String get skip => 'Skip';

  @override
  String get camera => 'Camera';

  @override
  String get istiftahDua => 'Opening Supplication';

  @override
  String get fatiha => 'Al-Fatiha';

  @override
  String get amin => 'Ameen';

  @override
  String get rukuLabel => 'Ruku';

  @override
  String get risingLabel => 'Rising';

  @override
  String get sujud1Label => 'First Sujud';

  @override
  String get sittingLabel => 'Sitting';

  @override
  String get sujud2Label => 'Second Sujud';

  @override
  String get tashahhudMiddle => 'Middle Tashahhud';

  @override
  String get tashahhudFinal => 'Final Tashahhud';

  @override
  String get tasleemRight => 'Tasleem Right';

  @override
  String get tasleemLeft => 'Tasleem Left';

  @override
  String get prayerStartConfirm => 'May Allah accept, let\'s start prayer';

  @override
  String get prayerFinished =>
      'May Allah accept your obedience, your prayer has been recorded successfully';

  @override
  String get anisPersonality => 'Anis Personality (Voice)';

  @override
  String get sage => 'Sage';

  @override
  String get companion => 'Companion';

  @override
  String get motivator => 'Motivator';

  @override
  String get peaceful => 'Peaceful';

  @override
  String get orator => 'Orator';

  @override
  String get mentor => 'Mentor';

  @override
  String get tryVoice => 'Try Voice';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get gender => 'Gender';

  @override
  String get ageGroup => 'Age Group';

  @override
  String get calibrationInstruction =>
      'Please read the verse so I can recognize your recitation speed and tone of voice.';

  @override
  String get calibrationSuccess =>
      'Great! Your voiceprint has been saved successfully. I will be in harmony with you in prayer.';

  @override
  String get goodMorning => 'Good morning';

  @override
  String get goodDay => 'Good day';

  @override
  String get goodEvening => 'Good evening';

  @override
  String get anisIntro => 'I am Anis, your companion on this blessed journey.';

  @override
  String get fajr => 'Fajr';

  @override
  String get dhuhr => 'Dhuhr';

  @override
  String get asr => 'Asr';

  @override
  String get maghrib => 'Maghrib';

  @override
  String get isha => 'Isha';

  @override
  String startPrayerAction(Object prayerName) {
    return 'Start $prayerName Prayer';
  }

  @override
  String get wirdReadyForPrayer => 'Your Quranic wird is ready for prayer..';

  @override
  String get morningAdhkar => 'Morning Adhkar';

  @override
  String get eveningAdhkar => 'Evening Adhkar';

  @override
  String get afterPrayerAdhkar => 'After Prayer Adhkar';

  @override
  String get propheticDuas => 'Prophetic Supplications';

  @override
  String get quranicDuas => 'Quranic Supplications';

  @override
  String get wakingUpAdhkar => 'Waking Up Adhkar';

  @override
  String get sleepingAdhkar => 'Sleeping Adhkar';

  @override
  String get travelAdhkar => 'Travel Adhkar';

  @override
  String get distressDuas => 'Distress Supplications';

  @override
  String get tasbeehTitle => 'Tasbeeh';

  @override
  String get targetLabel => 'Target';

  @override
  String get cyclesLabel => 'Cycles';

  @override
  String get selectDhikr => 'Select Dhikr';

  @override
  String get rakah => 'Rakah';
}
