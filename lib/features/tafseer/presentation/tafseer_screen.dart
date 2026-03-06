import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:projet_aaa/core/data/surah_names.dart';
import 'package:projet_aaa/widgets/islamic_background.dart';

class TafseerScreen extends StatefulWidget {
  const TafseerScreen({super.key});

  @override
  State<TafseerScreen> createState() => _TafseerScreenState();
}

class _TafseerScreenState extends State<TafseerScreen> {
  int? lastSurah;
  String? lastSurahName;

  @override
  void initState() {
    super.initState();
    _loadLastPosition();
  }

  Future<void> _loadLastPosition() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      lastSurah = prefs.getInt('last_tafseer_surah');
      lastSurahName = prefs.getString('last_tafseer_surah_name');
    });
  }

  @override
  Widget build(BuildContext context) {
    return IslamicBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('التفسير والتدبر', 
            style: GoogleFonts.amiri(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
            onPressed: () => context.pop(),
          ),
          actions: [
            IconButton(icon: const Icon(Icons.search, color: Colors.white), onPressed: () {}),
          ],
        ),
        body: Column(
          children: [
            _buildQuickAccessSection(context),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text('فهرس السور', 
                  style: GoogleFonts.amiri(color: const Color(0xFFC19A6B), fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: surahNames.length,
                itemBuilder: (context, index) {
                  return _buildSurahItem(context, index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessSection(BuildContext context) {
    return Container(
      height: 180,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(16),
        children: [
          _buildQuickCard(
            context,
            title: 'تدبر اليوم',
            subtitle: 'سورة الملك، آية ١٥',
            icon: Icons.auto_awesome,
            color: const Color(0xFFF5A623),
            onTap: () {
               // مثال: الانتقال لآية معينة لتدبر اليوم
               context.push('/surah-tafseer', extra: {
                'surahNumber': 67,
                'surahName': 'الملك',
              });
            }
          ),
          _buildQuickCard(
            context,
            title: 'آخر موضع',
            subtitle: lastSurahName != null ? 'سورة $lastSurahName' : 'لا يوجد سجل حالياً',
            icon: Icons.history,
            color: const Color(0xFF1ABC9C),
            onTap: lastSurah != null ? () {
               context.push('/surah-tafseer', extra: {
                'surahNumber': lastSurah,
                'surahName': lastSurahName,
              });
            } : null,
          ),
          _buildQuickCard(
            context,
            title: 'خواطري',
            subtitle: 'عرض الملاحظات',
            icon: Icons.edit_note,
            color: const Color(0xFFE74C3C),
            onTap: () {
               // سيتم بناء شاشة قائمة الخواطر لاحقاً
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('سيتم فتح سجل الخواطر قريباً')));
            }
          ),
        ],
      ),
    );
  }

  Widget _buildQuickCard(BuildContext context, {
    required String title, 
    required String subtitle, 
    required IconData icon, 
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(left: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 12),
            Text(title, style: GoogleFonts.amiri(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            Text(subtitle, style: GoogleFonts.amiri(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildSurahItem(BuildContext context, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: ListTile(
        onTap: () async {
          // حفظ الموضع الأخير
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('last_tafseer_surah', index + 1);
          await prefs.setString('last_tafseer_surah_name', surahNames[index]);
          
          if (!mounted) return;
          context.push('/surah-tafseer', extra: {
            'surahNumber': index + 1,
            'surahName': surahNames[index],
          });
        },
        leading: Container(
          width: 35,
          height: 35,
          decoration: BoxDecoration(
            color: const Color(0xFFC19A6B).withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFC19A6B).withOpacity(0.4)),
          ),
          child: Center(
            child: Text('${index + 1}', 
              style: GoogleFonts.notoSans(color: const Color(0xFFC19A6B), fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ),
        title: Text(surahNames[index], 
          style: GoogleFonts.amiri(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 14),
      ),
    );
  }
}
