import 'package:shared_preferences/shared_preferences.dart';

class Badge {
  final String id;
  final String title;
  final String description;
  final String icon;
  final int goal;

  Badge({required this.id, required this.title, required this.description, required this.icon, required this.goal});
}

class AchievementService {
  static final List<Badge> availableBadges = [
    Badge(id: 'first_prayer', title: 'بداية النور', description: 'أتممت أول صلاة ذكية بنجاح', icon: '🌟', goal: 1),
    Badge(id: 'quran_reader', title: 'القارئ المثابر', description: 'قرأت أكثر من 100 آية في الختمة', icon: '📖', goal: 100),
    Badge(id: 'asma_expert', title: 'العارف بالرحمن', description: 'أتممت 10 تحديات في أسماء الله', icon: '💎', goal: 10),
    Badge(id: 'constant_dhikr', title: 'الذاكر', description: 'أتممت أذكار الصباح والمساء لـ 3 أيام متتالية', icon: '📿', goal: 3),
  ];

  static Future<void> incrementProgress(String badgeId) async {
    final prefs = await SharedPreferences.getInstance();
    int current = prefs.getInt('progress_$badgeId') ?? 0;
    await prefs.setInt('progress_$badgeId', current + 1);
  }

  static Future<bool> isBadgeUnlocked(String badgeId) async {
    final prefs = await SharedPreferences.getInstance();
    int current = prefs.getInt('progress_$badgeId') ?? 0;
    final badge = availableBadges.firstWhere((b) => b.id == badgeId);
    return current >= badge.goal;
  }

  static Future<double> getBadgeProgress(String badgeId) async {
    final prefs = await SharedPreferences.getInstance();
    int current = prefs.getInt('progress_$badgeId') ?? 0;
    final badge = availableBadges.firstWhere((b) => b.id == badgeId);
    return (current / badge.goal).clamp(0.0, 1.0);
  }
}
