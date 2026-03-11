import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:projet_aaa_fixed/widgets/islamic_background.dart';
import '../data/models/adhkar_model.dart';
import '../data/adhkar_data.dart';

class AdhkarScreen extends StatelessWidget {
  const AdhkarScreen({super.key});

  static const double _globalOpacity = 0.12;
  static const double _globalBorderOpacity = 0.25;

  @override
  Widget build(BuildContext context) {
    final categories = rawAthkarCategories.map((c) => AthkarCategory.fromJson(c)).toList();

    return IslamicBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('الأذكار والأدعية', 
            style: GoogleFonts.amiri(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
            onPressed: () => context.pop(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () {},
            ),
          ],
        ),
        body: Column(
          children: [
            _buildHeroSection(context),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.95,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return _buildCategoryCard(context, category);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5A623).withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF5A623).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: Color(0xFFF5A623), size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ذِكْرُ اليَوْمِ', 
                  style: GoogleFonts.amiri(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                Text('ألا بذكر الله تطمئن القلوب', 
                  style: GoogleFonts.amiri(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, AthkarCategory category) {
    bool isTargeted = category.id == 'targeted';
    return InkWell(
      onTap: () {
        context.push('/adhkar-session', extra: category);
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isTargeted ? const Color(0xFFF5A623).withOpacity(0.2) : Colors.white.withOpacity(_globalOpacity),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isTargeted ? const Color(0xFFF5A623).withOpacity(0.5) : Colors.white.withOpacity(_globalBorderOpacity)),
          boxShadow: isTargeted ? [BoxShadow(color: const Color(0xFFF5A623).withOpacity(0.1), blurRadius: 10)] : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_getIcon(category.icon), color: const Color(0xFFF5A623), size: 40),
            const SizedBox(height: 12),
            Text(
              category.title,
              textAlign: TextAlign.center,
              style: GoogleFonts.amiri(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
            const Spacer(),
            Text(
              isTargeted ? '١٤ دعاء هادف' : 'ابدأ الآن',
              style: GoogleFonts.amiri(color: isTargeted ? const Color(0xFFF5A623) : Colors.white70, fontSize: 12, fontWeight: isTargeted ? FontWeight.bold : FontWeight.normal),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'wb_sunny_outlined': return Icons.wb_sunny_outlined;
      case 'dark_mode_outlined': return Icons.dark_mode_outlined;
      case 'mosque_outlined': return Icons.mosque_outlined;
      case 'auto_stories_outlined': return Icons.auto_stories_outlined;
      case 'volunteer_activism_outlined': return Icons.volunteer_activism_outlined;
      case 'auto_awesome_motion_outlined': return Icons.auto_awesome_motion_outlined;
      default: return Icons.favorite_border;
    }
  }
}
