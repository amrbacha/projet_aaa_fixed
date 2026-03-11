// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Asistente de Oración';

  @override
  String get welcomeMessage => 'Bienvenido a un bendito viaje espiritual';

  @override
  String get startPrayer => 'Comenzar la oración ahora';

  @override
  String get qiblaDirection => 'Dirección de la Qibla';

  @override
  String get khatmaProgress => 'Progreso de Khatma';

  @override
  String get smartAssistant => 'Anis - Asistente Inteligente';

  @override
  String get settings => 'Ajustes Integrales';

  @override
  String get readingQuran => 'Lectura del Corán';

  @override
  String get prayerKhatma => 'Khatma por Oración';

  @override
  String get memorization => 'Memorización del Corán';

  @override
  String get tafseer => 'Tafsir y Reflexión';

  @override
  String get adhkar => 'Adhkar y Súplicas';

  @override
  String get tasbeeh => 'Tasbeeh Electrónico';

  @override
  String get asmaAllah => 'Nombres de Allah';

  @override
  String get language => 'Idioma';

  @override
  String get theme => 'Apariencia';

  @override
  String get male => 'Masculino';

  @override
  String get female => 'Femenino';

  @override
  String get child => 'Niño';

  @override
  String get young => 'Joven';

  @override
  String get senior => 'Mayor';

  @override
  String get readingSpeed => 'Velocidad de lectura';

  @override
  String get slow => 'Lento';

  @override
  String get medium => 'Medio';

  @override
  String get fast => 'Rápido';

  @override
  String get calibration => 'Calibración de voz';

  @override
  String get saveChanges => 'Guardar todos los cambios';

  @override
  String get prayerPosition => 'Posición de oración';

  @override
  String get takbir => 'Takbirat al-Ihram';

  @override
  String get ruku => 'Ruku';

  @override
  String get sujud => 'Sujud';

  @override
  String get sitting => 'Sentado';

  @override
  String get standing => 'De pie';

  @override
  String get nextStep => 'Saltar';

  @override
  String get previousStep => 'Anterior';

  @override
  String get finish => 'Terminar';

  @override
  String greeting(Object userName) {
    return 'La paz sea con usted, $userName';
  }

  @override
  String get servicesTitle => 'Servicios y Programas';

  @override
  String get recommended => 'Recomendado';

  @override
  String get khatmaJourney => 'Viaje Bendito de Khatma';

  @override
  String get khatmaDesc =>
      'Comienza el viaje de fe para completar el Sagrado Corán mediante la recitación o en tus oraciones diarias.';

  @override
  String get certificatesTitle => 'Certificados de Logros y Recompensas';

  @override
  String get certificatesDesc =>
      'Revisa y documenta tus éxitos en tu viaje con el Corán.';

  @override
  String get startNow => 'Empezar ahora';

  @override
  String get confirmExit => 'Confirmar salida';

  @override
  String get exitMessage => '¿Está seguro de que desea salir de la aplicación?';

  @override
  String get no => 'No';

  @override
  String get yes => 'Sí';

  @override
  String get cameraAnalysis => 'Análisis de postura (IA)';

  @override
  String get cameraFollowUp => 'Seguimiento y corrección';

  @override
  String get locationService => 'Servicio de ubicación';

  @override
  String get locationDesc =>
      'Para determinar los tiempos de oración con precisión';

  @override
  String get updateNow => 'Actualizar ahora';

  @override
  String get prayerSettings => 'Ajustes de oración y notificaciones';

  @override
  String get athanNotifications => 'Notificaciones de Athan';

  @override
  String get prefAthanVoice => 'Voz de Athan preferida';

  @override
  String get prePrayerReminder => 'Recordatorio antes de la oración';

  @override
  String reminderTime(Object minutes) {
    return 'Recordatorio $minutes minutos antes';
  }

  @override
  String get calculationMethod => 'Método de cálculo';

  @override
  String get khatmaSettings => 'Personalización y Khatma';

  @override
  String get darkMode => 'Modo oscuro';

  @override
  String khatmaDuration(Object days) {
    return 'Duración de Khatma: $days días';
  }

  @override
  String get prefQari => 'Recitador preferido';

  @override
  String get dataManagement => 'Gestión de datos y progreso';

  @override
  String get resetKhatma => 'Reiniciar progreso de Khatma';

  @override
  String get resetDailyPrayers => 'Reiniciar oraciones de hoy';

  @override
  String get saveSuccess => 'Ajustes guardados y notificaciones actualizadas';

  @override
  String get locationUpdateSuccess =>
      'Ubicación y tiempos de oración actualizados con éxito';

  @override
  String get locationUpdateError =>
      'Error al actualizar la ubicación, verifique los permisos';

  @override
  String get cancel => 'Cancelar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get confirmResetKhatma =>
      '¿Está seguro de que desea reiniciar el progreso de Khatma?';

  @override
  String get confirmResetPrayers =>
      '¿Está seguro de que desea borrar las oraciones de hoy?';

  @override
  String get resetKhatmaSuccess => 'Progreso de Khatma reiniciado con éxito';

  @override
  String get resetPrayersSuccess => 'Oraciones de hoy reiniciadas con éxito';

  @override
  String get fullName => 'Nombre completo';

  @override
  String get jobTitle => 'Su título (por ej. Estudiante)';

  @override
  String get personalInfo => 'Conozcámonos';

  @override
  String get calibrationPrompt =>
      '¿Le gustaría leer un verso corto una vez para que la aplicación pueda ajustarse a su velocidad de recitación? (Opcional)';

  @override
  String get dhikrOfDay => 'Dhikr del día';

  @override
  String get peaceOfMind =>
      '¿No es con el recuerdo de Allah que los corazones se tranquilizan?';

  @override
  String targetedDuaCount(Object count) {
    return '$count Duas dirigidas';
  }

  @override
  String get fullList => 'Lista completa';

  @override
  String get startChallenge => 'Comenzar desafío';

  @override
  String get asmaOfTheDay => 'Nombre del día para la reflexión';

  @override
  String get tadabburNow => 'Reflexionar ahora';

  @override
  String get copied => 'Copiado';

  @override
  String get remaining => 'Restante';

  @override
  String get target => 'Objetivo';

  @override
  String get cycles => 'Ciclos';

  @override
  String get vibration => 'Vibración';

  @override
  String get sound => 'Sonido';

  @override
  String get selectZikr => 'Seleccionar Dhikr';

  @override
  String get setTarget => 'Establecer objetivo';

  @override
  String get searchSurah => 'Buscar Sura...';

  @override
  String get savedSurahs => 'Suras guardadas';

  @override
  String get savedAyahs => 'Ayas guardadas';

  @override
  String get achievementRate => 'Tasa de logros';

  @override
  String verseCount(Object count) {
    return 'Versos: $count';
  }

  @override
  String ayahNumber(Object number) {
    return 'Aya $number';
  }

  @override
  String get clickForTadabbur => 'Haga clic para Reflexión y Tafsir';

  @override
  String get tafseerTab => 'Tafsir';

  @override
  String get tadabburTab => 'Reflexión';

  @override
  String get reflectionsTab => 'Mis reflexiones';

  @override
  String get easyMeaning => 'El significado simplificado';

  @override
  String get wordMeanings => 'Significado de las palabras';

  @override
  String get reflectiveQuestion => 'Pregunta de reflexión';

  @override
  String get practicalApplication => 'Aplicación práctica';

  @override
  String get reflectionHint =>
      'Escriba sus pensamientos y reflexiones sobre este verso...';

  @override
  String get saveReflection => 'Guardar reflexión';

  @override
  String get reflectionSaved => 'Reflexión guardada con éxito';

  @override
  String get meaningAndSignificance => 'Significado y alcance';

  @override
  String get legalEvidence => 'Prueba legal';

  @override
  String get contemplativeNote => 'Nota contemplativa';

  @override
  String get traditionalSupplication => 'Súplica tradicional';

  @override
  String motivationStart(Object userName) {
    return 'Bienvenido $userName, hoy comienza un gran viaje con el Corán. ¿Comenzamos con su primera lectura?';
  }

  @override
  String motivationProgress(Object percent, Object userName) {
    return 'Excelente $userName, ha completado el $percent% del viaje de la Khatma. ¡Siga así, lo está haciendo muy bien!';
  }

  @override
  String motivationHalfway(Object userName) {
    return '¡Masha\'Allah $userName! Ha superado la mitad del camino. ¡El Paraíso le llama, queda poco!';
  }

  @override
  String motivationAlmost(Object userName) {
    return '¡Está a punto de terminar, $userName! Qué gran logro del que los ángeles se enorgullecen.';
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
  String get nextPrayer => 'Próxima Oración';

  @override
  String get currentDay => 'Día Actual';

  @override
  String get inJourney => 'En el Viaje';

  @override
  String get previousKhatmas => 'Khatmas Anteriores';

  @override
  String get days => 'Días';

  @override
  String get prayerTimes => 'Horarios de Oración';

  @override
  String get startDailyWird => 'Iniciar Wird Diario';

  @override
  String get wirdReady => 'Su wird coránico está listo, toque para comenzar..';

  @override
  String get calibrationTitle => 'Calibración y Preparación';

  @override
  String get rakahLabel => 'Raka';

  @override
  String get rakah1 => 'Primera';

  @override
  String get rakah2 => 'Segunda';

  @override
  String get rakah3 => 'Tercera';

  @override
  String get rakah4 => 'Cuarta';

  @override
  String get completeAyahVoice => 'Complete el verso con su voz...';

  @override
  String get waitingForCamera =>
      'Esperando a que aparezca frente a la cámara...';

  @override
  String get tooClose => '¡Está demasiado cerca! Por favor, retroceda';

  @override
  String get tiltUp => 'Incline el teléfono ligeramente hacia arriba';

  @override
  String get tiltDown => 'Incline el teléfono ligeramente hacia abajo';

  @override
  String get perfectPosition => '¡Posición perfecta! Comience con el Takbir';

  @override
  String get checkingPosition => 'Verificando posición...';

  @override
  String get takbirPrompt =>
      'Diga \'Allahu Akbar\' o levante las manos para el Takbir';

  @override
  String get skip => 'Saltar';

  @override
  String get camera => 'Cámara';

  @override
  String get istiftahDua => 'Súplica de apertura';

  @override
  String get fatiha => 'Al-Fatiha';

  @override
  String get amin => 'Amén';

  @override
  String get rukuLabel => 'Ruku';

  @override
  String get risingLabel => 'Levantamiento';

  @override
  String get sujud1Label => 'Primer Sujud';

  @override
  String get sittingLabel => 'Sentado';

  @override
  String get sujud2Label => 'Segundo Sujud';

  @override
  String get tashahhudMiddle => 'Tashahhud Medio';

  @override
  String get tashahhudFinal => 'Tashahhud Final';

  @override
  String get tasleemRight => 'Taslim a la derecha';

  @override
  String get tasleemLeft => 'Taslim a la izquierda';

  @override
  String get prayerStartConfirm => 'Que Allah acepte, comencemos la oración';

  @override
  String get prayerFinished =>
      'Que Allah acepte su obediencia, su oración ha sido registrada con éxito';

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
