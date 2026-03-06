import 'package:go_router/go_router.dart';
import 'package:projet_aaa/certificate/certificate_selector_screen.dart';
import 'package:projet_aaa/certificate/certificate_viewer_screen.dart';
import 'package:projet_aaa/core/models/quran_data.dart';
import 'package:projet_aaa/features/adhkar/data/models/adhkar_model.dart';
import 'package:projet_aaa/features/adhkar/presentation/adhkar_screen.dart';
import 'package:projet_aaa/features/adhkar/presentation/adhkar_session_screen.dart';
import 'package:projet_aaa/features/main_menu/presentation/main_menu_screen.dart';
import 'package:projet_aaa/features/memorization/presentation/memorization_dashboard_screen.dart';
import 'package:projet_aaa/features/memorization/presentation/memorization_session_screen.dart';
import 'package:projet_aaa/features/memorization/presentation/memorization_settings_screen.dart';
import 'package:projet_aaa/features/qibla/presentation/qibla_screen.dart';
import 'package:projet_aaa/features/reading/presentation/reading_dashboard_screen.dart';
import 'package:projet_aaa/features/reading/presentation/reading_screen.dart';
import 'package:projet_aaa/features/reading/presentation/reading_settings_screen.dart';
import 'package:projet_aaa/features/tafseer/presentation/tafseer_screen.dart';
import 'package:projet_aaa/features/tafseer/presentation/surah_tafseer_screen.dart';
import 'package:projet_aaa/features/tafseer/presentation/ayah_tadabbur_screen.dart';
import 'package:projet_aaa/features/tasbeeh/presentation/tasbeeh_screen.dart';
import 'package:projet_aaa/features/asma_allah/presentation/asma_allah_screen.dart';
import 'package:projet_aaa/features/asma_allah/presentation/asma_detail_screen.dart';
import 'package:projet_aaa/features/asma_allah/presentation/asma_quiz_screen.dart';
import 'package:projet_aaa/features/asma_allah/data/models/asma_model.dart';
import 'package:projet_aaa/features/search/presentation/global_search_screen.dart';
import 'package:projet_aaa/features/onboarding/presentation/splash_screen.dart';
import 'package:projet_aaa/features/onboarding/presentation/voice_calibration_screen.dart';
import '../features/onboarding/presentation/language_screen.dart';
import '../features/onboarding/presentation/personal_info_screen.dart';
import '../features/onboarding/presentation/theme_customization_screen.dart';
import '../features/tracking/presentation/tracking_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/prayer/presentation/prayer_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/language',
        name: 'language',
        builder: (context, state) => const LanguageScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => PersonalInfoScreen(
          selectedLang: state.extra as String? ?? 'ar',
        ),
      ),
      GoRoute(
        path: '/voice-calibration',
        name: 'voice-calibration',
        builder: (context, state) => const VoiceCalibrationScreen(),
      ),
      GoRoute(
        path: '/theme-customization',
        name: 'theme-customization',
        builder: (context, state) => const ThemeCustomizationScreen(),
      ),
      GoRoute(
        path: '/main-menu',
        name: 'main-menu',
        builder: (context, state) => const MainMenuScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const TrackingScreen(),
      ),
      GoRoute(
        path: '/reading',
        name: 'reading',
        builder: (context, state) => const ReadingDashboardScreen(),
      ),
      GoRoute(
        path: '/reading-player',
        name: 'reading-player',
        builder: (context, state) => const ReadingScreen(),
      ),
      GoRoute(
        path: '/reading-settings',
        name: 'reading-settings',
        builder: (context, state) => const ReadingSettingsScreen(),
      ),
      GoRoute(
        path: '/memorization',
        name: 'memorization',
        builder: (context, state) => const MemorizationDashboardScreen(),
      ),
      GoRoute(
        path: '/memorization-session',
        name: 'memorization-session',
        builder: (context, state) => MemorizationSessionScreen(
          surah: state.extra as Surah,
        ),
      ),
      GoRoute(
        path: '/memorization-settings',
        name: 'memorization-settings',
        builder: (context, state) => const MemorizationSettingsScreen(),
      ),
      GoRoute(
        path: '/tasbeeh',
        name: 'tasbeeh',
        builder: (context, state) => const TasbeehScreen(),
      ),
      GoRoute(
        path: '/adhkar',
        name: 'adhkar',
        builder: (context, state) => const AdhkarScreen(),
      ),
      GoRoute(
        path: '/adhkar-session',
        name: 'adhkar-session',
        builder: (context, state) => AdhkarSessionScreen(
          category: state.extra as AthkarCategory,
        ),
      ),
      GoRoute(
        path: '/tafseer',
        name: 'tafseer',
        builder: (context, state) => const TafseerScreen(),
      ),
      GoRoute(
        path: '/surah-tafseer',
        name: 'surah-tafseer',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return SurahTafseerScreen(
            surahNumber: extra['surahNumber'],
            surahName: extra['surahName'],
          );
        },
      ),
      GoRoute(
        path: '/ayah-tadabbur',
        name: 'ayah-tadabbur',
        builder: (context, state) => AyahTadabburScreen(
          ayah: state.extra as Ayah,
        ),
      ),
      GoRoute(
        path: '/asma-allah',
        name: 'asma-allah',
        builder: (context, state) => const AsmaAllahScreen(),
      ),
      GoRoute(
        path: '/asma-detail',
        name: 'asma-detail',
        builder: (context, state) => AsmaDetailScreen(
          asma: state.extra as AsmaAllah,
        ),
      ),
      GoRoute(
        path: '/asma-quiz',
        name: 'asma-quiz',
        builder: (context, state) => const AsmaQuizScreen(),
      ),
      GoRoute(
        path: '/search',
        name: 'search',
        builder: (context, state) => const GlobalSearchScreen(),
      ),
      GoRoute(
        path: '/qibla',
        name: 'qibla',
        builder: (context, state) => const QiblaScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/certificate-selector',
        name: 'certificate-selector',
        builder: (context, state) => const CertificateSelectorScreen(),
      ),
      GoRoute(
        path: '/certificate-viewer',
        name: 'certificate-viewer',
        builder: (context, state) {
          if (state.extra is Map<String, dynamic>) {
            final data = state.extra as Map<String, dynamic>;
            return CertificateViewerScreen(
              certificateId: data['certificateId'] ?? 'general',
              surahName: data['surahName'],
            );
          }
          return CertificateViewerScreen(
            certificateId: state.extra as String? ?? 'general',
          );
        },
      ),
       GoRoute(
        path: '/prayer',
        name: 'prayer',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          final prayerName = extra['prayerName'] as String;
          final wird = extra['wird'] as List<Ayah>;
          return PrayerScreen(
            prayerName: prayerName,
            wird: wird,
          );
        },
      ),
    ],
  );
}
