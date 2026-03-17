import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../widgets/islamic_background.dart';
import '../data/prayer_learning_content.dart';

class PrayerLearningScreen extends StatefulWidget {
  const PrayerLearningScreen({super.key});

  @override
  State<PrayerLearningScreen> createState() => _PrayerLearningScreenState();
}

class _PrayerLearningScreenState extends State<PrayerLearningScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final section = PrayerLearningContent.sections[_selectedIndex];

    return IslamicBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.black26,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'أتعلم صلاتي',
            style: GoogleFonts.amiri(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              _buildHeroBanner(),
              const SizedBox(height: 10),
              _buildSectionsSelector(),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildSectionOverview(section),
                    const SizedBox(height: 16),
                    ...section.lessons.map(_buildLessonCard),
                    const SizedBox(height: 16),
                    _buildFutureLinkCard(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF0F3D35), Color(0xCC1A6B5D)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5A623).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.school_rounded, color: Color(0xFFF5A623), size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'المعلم الإسلامي المتكامل',
                      textAlign: TextAlign.right,
                      style: GoogleFonts.amiri(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'تعليم الوضوء والصلاة خطوة بخطوة، للمبتدئ والطفل والمسلم الجديد، مع تمهيد للربط بالمساعد الذكي لاحقًا.',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        height: 1.55,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.end,
            children: const [
              _HeroChip(label: 'وضوء'),
              _HeroChip(label: 'صلاة خطوة بخطوة'),
              _HeroChip(label: 'للأطفال'),
              _HeroChip(label: 'أخطاء شائعة'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionsSelector() {
    return SizedBox(
      height: 56,
      child: ListView.separated(
        reverse: true,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: PrayerLearningContent.sections.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final item = PrayerLearningContent.sections[index];
          final selected = index == _selectedIndex;
          return InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => setState(() => _selectedIndex = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: selected ? item.accent.withOpacity(0.18) : Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: selected ? item.accent : Colors.white12),
              ),
              child: Row(
                children: [
                  Icon(item.icon, color: selected ? item.accent : Colors.white70, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    item.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionOverview(PrayerLearningSection section) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: section.accent.withOpacity(0.18),
                child: Icon(section.icon, color: section.accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      section.title,
                      textAlign: TextAlign.right,
                      style: GoogleFonts.amiri(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      section.subtitle,
                      textAlign: TextAlign.right,
                      style: TextStyle(color: Colors.white.withOpacity(0.72), height: 1.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              'هذا القسم مصمم ليكون مناسبًا للعربية الآن، وقابلًا للتوسعة مستقبلاً لكل اللغات داخل التطبيق العالمي.',
              textAlign: TextAlign.right,
              style: TextStyle(color: Colors.white.withOpacity(0.82), height: 1.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonCard(PrayerLearningLesson lesson) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
        iconColor: const Color(0xFFF5A623),
        collapsedIconColor: Colors.white70,
        title: Text(
          lesson.title,
          textAlign: TextAlign.right,
          style: GoogleFonts.amiri(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            lesson.summary,
            textAlign: TextAlign.right,
            style: TextStyle(color: Colors.white.withOpacity(0.72), height: 1.5),
          ),
        ),
        children: [
          _LessonBlock(title: 'الخطوات', items: lesson.steps, color: const Color(0xFFF5A623)),
          const SizedBox(height: 12),
          _LessonBlock(title: 'نصائح', items: lesson.tips, color: const Color(0xFF27C2A0)),
          const SizedBox(height: 12),
          _LessonBlock(title: 'أخطاء شائعة', items: lesson.mistakes, color: const Color(0xFFFF7B7B)),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF2C3250).withOpacity(0.55),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'نسخة مبسطة للأطفال',
                  textAlign: TextAlign.right,
                  style: TextStyle(color: Color(0xFF59C3FF), fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  lesson.childFriendly,
                  textAlign: TextAlign.right,
                  style: const TextStyle(color: Colors.white, height: 1.7),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.push('/prayer-coach-debug'),
                  icon: const Icon(Icons.videocam_rounded, color: Color(0xFFF5A623)),
                  label: const Text('جرّب مع المساعد الذكي'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFFF5A623)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFutureLinkCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF5A623), Color(0xFFCC8A00)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'اقتراح التطوير القادم',
            style: GoogleFonts.amiri(
              color: Colors.black,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'بعد اعتماد هذه الصفحة، يمكن ربط كل درس بصوت ونطق وصور تعليمية، ثم ربطه تلقائيًا بـ prayer coach حتى يصبح التطبيق معلمًا إسلاميًا عالميًا متكاملًا.',
            textAlign: TextAlign.right,
            style: TextStyle(color: Colors.black87, height: 1.6),
          ),
        ],
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  final String label;

  const _HeroChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
    );
  }
}

class _LessonBlock extends StatelessWidget {
  final String title;
  final List<String> items;
  final Color color;

  const _LessonBlock({
    required this.title,
    required this.items,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            title,
            textAlign: TextAlign.right,
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 10),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      item,
                      textAlign: TextAlign.right,
                      style: const TextStyle(color: Colors.white, height: 1.6),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.circle, size: 8, color: color),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
