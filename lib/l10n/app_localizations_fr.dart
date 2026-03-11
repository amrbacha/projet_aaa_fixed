// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Assistant de Prière';

  @override
  String get welcomeMessage =>
      'Bienvenue dans le domaine de l\'obéissance. Choisissez votre destination aujourd\'hui pour vous élever ensemble dans les degrés de la foi';

  @override
  String get startPrayer => 'Commencer la prière maintenant';

  @override
  String get qiblaDirection => 'Direction de la Qibla';

  @override
  String get khatmaProgress => 'Progression de la Khatma';

  @override
  String get smartAssistant => 'Anis - Assistant Intelligent';

  @override
  String get settings => 'Paramètres Complets';

  @override
  String get readingQuran => 'Clôture du Coran par la lecture';

  @override
  String get prayerKhatma => 'Clôture du Coran par la prière';

  @override
  String get memorization => 'Mémorisation du Saint Coran';

  @override
  String get tafseer => 'Tafsir et Méditation';

  @override
  String get adhkar => 'Adhkar et Supplications';

  @override
  String get tasbeeh => 'Tasbeeh';

  @override
  String get asmaAllah => 'Les Noms d\'Allah';

  @override
  String get language => 'Langue';

  @override
  String get theme => 'Apparence';

  @override
  String get male => 'Homme';

  @override
  String get female => 'Femme';

  @override
  String get child => 'Enfant';

  @override
  String get young => 'Jeune';

  @override
  String get senior => 'Aîné';

  @override
  String get readingSpeed => 'Vitesse de lecture';

  @override
  String get slow => 'Calme';

  @override
  String get medium => 'Moyen';

  @override
  String get fast => 'Rapide';

  @override
  String get calibration => 'Calibrage de la voix';

  @override
  String get saveChanges => 'Enregistrer les modifications';

  @override
  String get prayerPosition => 'Position de prière';

  @override
  String get takbir => 'Takbirat al-Ihram';

  @override
  String get ruku => 'Ruku';

  @override
  String get sujud => 'Sujud';

  @override
  String get sitting => 'Assis';

  @override
  String get standing => 'Debout';

  @override
  String get nextStep => 'Passer';

  @override
  String get previousStep => 'Précédent';

  @override
  String get finish => 'Terminer';

  @override
  String greeting(Object userName) {
    return 'Assalamu alaykum, $userName';
  }

  @override
  String get servicesTitle => 'Services et Programmes';

  @override
  String get recommended => 'Recommandé';

  @override
  String get khatmaJourney => 'Voyage béni de la Khatma';

  @override
  String get khatmaDesc =>
      'Commencez le voyage de la foi pour terminer le Saint Coran par la récitation ou dans vos prières quotidiennes.';

  @override
  String get certificatesTitle => 'Certificats de réussite et de récompense';

  @override
  String get certificatesDesc =>
      'Consultez et documentez vos succès dans votre voyage avec le Coran.';

  @override
  String get startNow => 'Commencer maintenant';

  @override
  String get confirmExit => 'Confirmer la sortie';

  @override
  String get exitMessage => 'Êtes-vous sûr de vouloir quitter l\'application ?';

  @override
  String get no => 'Non';

  @override
  String get yes => 'Oui';

  @override
  String get cameraAnalysis => 'Analyse de posture (IA)';

  @override
  String get cameraFollowUp => 'Suivi et correction de la position';

  @override
  String get locationService => 'Service de localisation';

  @override
  String get locationDesc =>
      'Pour déterminer les heures de prière avec précision';

  @override
  String get updateNow => 'Mettre à jour maintenant';

  @override
  String get prayerSettings => 'Paramètres de prière et notifications';

  @override
  String get athanNotifications => 'Notifications de l\'Athan';

  @override
  String get prefAthanVoice => 'Voix de l\'Athan préférée';

  @override
  String get prePrayerReminder => 'Rappel avant la prière';

  @override
  String reminderTime(Object minutes) {
    return 'Rappel $minutes minutes avant';
  }

  @override
  String get calculationMethod => 'Méthode de calcul';

  @override
  String get khatmaSettings => 'Personnalisation et Khatma';

  @override
  String get darkMode => 'Mode sombre';

  @override
  String khatmaDuration(Object days) {
    return 'Durée de la Khatma : $days jours';
  }

  @override
  String get prefQari => 'Récitateur préféré';

  @override
  String get dataManagement => 'Gestion des données et de la progression';

  @override
  String get resetKhatma => 'Réinitialiser la progression de la Khatma';

  @override
  String get resetDailyPrayers => 'Réinitialiser les prières d\'aujourd\'hui';

  @override
  String get saveSuccess =>
      'Paramètres enregistrés et notifications mises à jour';

  @override
  String get locationUpdateSuccess =>
      'Emplacement et heures de prière mis à jour avec succès';

  @override
  String get locationUpdateError =>
      'Échec de la mise à jour de l\'emplacement, veuillez vérifier les autorisations';

  @override
  String get cancel => 'Annuler';

  @override
  String get confirm => 'Confirmer';

  @override
  String get confirmResetKhatma =>
      'Êtes-vous sûr de vouloir réinitialiser la progression de la Khatma et recommencer ?';

  @override
  String get confirmResetPrayers =>
      'Êtes-vous sûr de vouloir effacer les prières d\'aujourd\'hui et les refaire ?';

  @override
  String get resetKhatmaSuccess =>
      'Progression de la Khatma réinitialisée avec succès';

  @override
  String get resetPrayersSuccess =>
      'Prières d\'aujourd\'hui réinitialisées avec succès';

  @override
  String get fullName => 'Nom et prénom';

  @override
  String get jobTitle => 'Votre titre (par ex. Étudiant)';

  @override
  String get personalInfo => 'Faisons connaissance';

  @override
  String get calibrationPrompt =>
      'Souhaitez-vous lire un court verset une fois pour que l\'application puisse s\'adapter à votre vitesse de récitation ? (Facultatif)';

  @override
  String get dhikrOfDay => 'Dhikr du jour';

  @override
  String get peaceOfMind =>
      'N\'est-ce pas par l\'évocation d\'Allah que les cœurs se tranquillisent ?';

  @override
  String targetedDuaCount(Object count) {
    return '$count Duas ciblées';
  }

  @override
  String get fullList => 'Liste complète';

  @override
  String get startChallenge => 'Commencer le défi';

  @override
  String get asmaOfTheDay => 'Nom du jour pour la méditation';

  @override
  String get tadabburNow => 'Méditer maintenant';

  @override
  String get copied => 'Copié';

  @override
  String get remaining => 'Restant';

  @override
  String get target => 'Objectif';

  @override
  String get cycles => 'Cycles';

  @override
  String get vibration => 'Vibration';

  @override
  String get sound => 'Son';

  @override
  String get selectZikr => 'Sélectionner le Dhikr';

  @override
  String get setTarget => 'Définir l\'objectif';

  @override
  String get searchSurah => 'Rechercher une sourate...';

  @override
  String get savedSurahs => 'Sourates mémorisées';

  @override
  String get savedAyahs => 'Versets mémorisés';

  @override
  String get achievementRate => 'Taux de réussite';

  @override
  String verseCount(Object count) {
    return 'Versets : $count';
  }

  @override
  String ayahNumber(Object number) {
    return 'Verset $number';
  }

  @override
  String get clickForTadabbur => 'Cliquez pour la méditation et le Tafsir';

  @override
  String get tafseerTab => 'Tafsir';

  @override
  String get tadabburTab => 'Méditation';

  @override
  String get reflectionsTab => 'Mes réflexions';

  @override
  String get easyMeaning => 'Le sens simplifié';

  @override
  String get wordMeanings => 'Signification des mots';

  @override
  String get reflectiveQuestion => 'Question de méditation';

  @override
  String get practicalApplication => 'Application pratique';

  @override
  String get reflectionHint =>
      'Écrivez vos pensées et réflexions sur ce verset...';

  @override
  String get saveReflection => 'Enregistrer la réflexion';

  @override
  String get reflectionSaved => 'Réflexion enregistrée avec succès';

  @override
  String get meaningAndSignificance => 'Signification et portée';

  @override
  String get legalEvidence => 'Preuve légale';

  @override
  String get contemplativeNote => 'Note contemplative';

  @override
  String get traditionalSupplication => 'Supplication traditionnelle';

  @override
  String motivationStart(Object userName) {
    return 'Bienvenue $userName, aujourd\'hui commence un grand voyage avec le Coran. Commençons-nous par votre première lecture ?';
  }

  @override
  String motivationProgress(Object percent, Object userName) {
    return 'Excellent $userName, vous avez parcouru $percent% du voyage de la Khatma. Continuez, vous vous débrouillez très bien !';
  }

  @override
  String motivationHalfway(Object userName) {
    return 'Masha\'Allah $userName ! Vous avez dépassé la moitié du chemin. Le Paradis vous appelle, il reste peu de chemin !';
  }

  @override
  String motivationAlmost(Object userName) {
    return 'Vous êtes sur le point de terminer, $userName ! Quel grand accomplissement dont les anges sont fiers.';
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
  String get nextPrayer => 'Prochaine Prière';

  @override
  String get currentDay => 'Jour Actuel';

  @override
  String get inJourney => 'Dans le Voyage';

  @override
  String get previousKhatmas => 'Khatmas Précédentes';

  @override
  String get days => 'Jours';

  @override
  String get prayerTimes => 'Horaires de Prière';

  @override
  String get startDailyWird => 'Commencer le Wird Quotidien';

  @override
  String get wirdReady =>
      'Votre wird coranique est prêt, appuyez pour commencer..';

  @override
  String get calibrationTitle => 'Calibrage et Préparation';

  @override
  String get rakahLabel => 'Rakah';

  @override
  String get rakah1 => 'Première';

  @override
  String get rakah2 => 'Deuxième';

  @override
  String get rakah3 => 'Troisième';

  @override
  String get rakah4 => 'Quatrième';

  @override
  String get completeAyahVoice => 'Complétez le verset avec votre voix...';

  @override
  String get waitingForCamera =>
      'En attente de votre apparition devant la caméra...';

  @override
  String get tooClose => 'Vous êtes trop près ! Veuillez reculer';

  @override
  String get tiltUp => 'Inclinez le téléphone vers le haut';

  @override
  String get tiltDown => 'Inclinez le téléphone vers le bas';

  @override
  String get perfectPosition => 'Position parfaite ! Commencez par le Takbir';

  @override
  String get checkingPosition => 'Vérification de la position...';

  @override
  String get takbirPrompt =>
      'Dites \'Allahu Akbar\' ou levez les mains pour le Takbir';

  @override
  String get skip => 'Passer';

  @override
  String get camera => 'Caméra';

  @override
  String get istiftahDua => 'Doua d\'ouverture';

  @override
  String get fatiha => 'Al-Fatiha';

  @override
  String get amin => 'Amine';

  @override
  String get rukuLabel => 'Ruku';

  @override
  String get risingLabel => 'Relèvement';

  @override
  String get sujud1Label => 'Premier Sujud';

  @override
  String get sittingLabel => 'Assise';

  @override
  String get sujud2Label => 'Second Sujud';

  @override
  String get tashahhudMiddle => 'Tashahhud Moyen';

  @override
  String get tashahhudFinal => 'Tashahhud Final';

  @override
  String get tasleemRight => 'Taslim à droite';

  @override
  String get tasleemLeft => 'Taslim à gauche';

  @override
  String get prayerStartConfirm => 'Qu\'Allah accepte, commençons la prière';

  @override
  String get prayerFinished =>
      'Qu\'Allah accepte votre obéissance, votre prière a été enregistrée avec succès';

  @override
  String get anisPersonality => 'Personnalité d\'Anis (Sa voix)';

  @override
  String get sage => 'Sage';

  @override
  String get companion => 'Compagnon';

  @override
  String get motivator => 'Motivateur';

  @override
  String get peaceful => 'Paisible';

  @override
  String get orator => 'Orateur';

  @override
  String get mentor => 'Mentor';

  @override
  String get tryVoice => 'Essayer la voix';

  @override
  String get selectLanguage => 'Choisir la langue';

  @override
  String get gender => 'Genre';

  @override
  String get ageGroup => 'Tranche d\'âge';

  @override
  String get calibrationInstruction =>
      'Veuillez lire le verset afin que je puisse reconnaître votre vitesse de récitation et votre ton de voix.';

  @override
  String get calibrationSuccess =>
      'Génial ! Votre empreinte vocale a été enregistrée avec succès. Je serai en harmonie avec vous dans la prière.';

  @override
  String get goodMorning => 'Bonjour';

  @override
  String get goodDay => 'Bonne journée';

  @override
  String get goodEvening => 'Bonsoir';

  @override
  String get anisIntro => 'Je suis Anis, votre compagnon dans ce voyage béni.';

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
    return 'Commencer la prière de $prayerName';
  }

  @override
  String get wirdReadyForPrayer =>
      'Votre wird coranique est prêt pour la prière..';

  @override
  String get morningAdhkar => 'Adhkar du Matin';

  @override
  String get eveningAdhkar => 'Adhkar du Soir';

  @override
  String get afterPrayerAdhkar => 'Adhkar après la Prière';

  @override
  String get propheticDuas => 'Douas Prophétiques';

  @override
  String get quranicDuas => 'Douas Coraniques';

  @override
  String get wakingUpAdhkar => 'Adhkar du Réveil';

  @override
  String get sleepingAdhkar => 'Adhkar du Sommeil';

  @override
  String get travelAdhkar => 'Adhkar du Voyage';

  @override
  String get distressDuas => 'Douas de Détresse';

  @override
  String get tasbeehTitle => 'Tasbeeh';

  @override
  String get targetLabel => 'Objectif';

  @override
  String get cyclesLabel => 'Cycles';

  @override
  String get selectDhikr => 'Sélectionner le Dhikr';

  @override
  String get rakah => 'Rakah';
}
