import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:projet_aaa_fixed/core/data/surah_names.dart';
import 'package:projet_aaa_fixed/widgets/islamic_background.dart';
import 'package:projet_aaa_fixed/core/services/assistant_service.dart';

class TafseerScreen extends StatefulWidget {
  const TafseerScreen({super.key});

  @override
  State<TafseerScreen> createState() => _TafseerScreenState();
}

class _TafseerScreenState extends State<TafseerScreen> {
  int? lastSurah;
  String? lastSurahName;
  final AssistantService _anis = AssistantService();
  String _searchQuery = "";
  bool _isSearching = false;

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
        appBar: _buildAppBar(),
        body: Column(
          children: [
            if (!_isSearching) _buildHeroSection(),
            _buildSectionHeader(),
            Expanded(child: _buildSurahList()),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFFF5A623),
          child: const Icon(Icons.lightbulb_outline, color: Colors.black),
          onPressed: () => _anis.speak("هنا يمكنك الإبحار في معاني القرآن وكتابة خواطرك الإيمانية."),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.black26,
      elevation: 0,
      centerTitle: true,
      title: _isSearching 
        ? TextField(
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(hintText: "ابحث عن سورة...", hintStyle: TextStyle(color: Colors.white54), border: InputBorder.none),
            onChanged: (v) => setState(() => _searchQuery = v),
          )
        : Text('التفسير والتدبر', style: GoogleFonts.amiri(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
      leading: IconButton(
        icon: Icon(_isSearching ? Icons.close : Icons.arrow_back_ios, color: Colors.white70),
        onPressed: () {
          if (_isSearching) setState(() { _isSearching = false; _searchQuery = ""; });
          else context.pop();
        },
      ),
      actions: [
        IconButton(
          icon: Icon(_isSearching ? Icons.check : Icons.search, color: const Color(0xFFF5A623)),
          onPressed: () => setState(() => _isSearching = !_isSearching),
        ),
      ],
    );
  }

  Widget _buildHeroSection() {
    return SizedBox(
      height: 200,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        children: [
          _buildHeroCard(
            title: 'تدبر اليوم',
            subtitle: 'سورة الملك، آية ١٥',
            icon: Icons.auto_awesome,
            colors: [const Color(0xFFF5A623), const Color(0xFFD48106)],
            onTap: () => context.push('/surah-tafseer', extra: {'surahNumber': 67, 'surahName': 'الملك'}),
          ),
          _buildHeroCard(
            title: 'آخر موضع',
            subtitle: lastSurahName != null ? 'سورة $lastSurahName' : 'ابدأ القراءة الآن',
            icon: Icons.history_toggle_off,
            colors: [const Color(0xFF1ABC9C), const Color(0xFF16A085)],
            onTap: lastSurah != null ? () => context.push('/surah-tafseer', extra: {'surahNumber': lastSurah, 'surahName': lastSurahName}) : null,
          ),
          _buildHeroCard(
            title: 'خواطري',
            subtitle: 'سجل تأملاتك',
            icon: Icons.edit_note_rounded,
            colors: [const Color(0xFFE74C3C), const Color(0xFFC0392B)],
            onTap: () => _anis.speak("سجل الخواطر سيتاح قريباً في التحديث القادم."),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard({required String title, required String subtitle, required IconData icon, required List<Color> colors, VoidCallback? onTap}) {
    return Container(
      width: 170,
      margin: const EdgeInsets.only(left: 15),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(25),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colors[0].withOpacity(0.7),
                    colors[1].withOpacity(0.4),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
                boxShadow: [BoxShadow(color: colors[0].withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 6))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(icon, color: Colors.white, size: 35),
                  const Spacer(),
                  Text(title, style: GoogleFonts.amiri(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                  Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('فهرس السور', style: GoogleFonts.amiri(color: const Color(0xFFF5A623), fontSize: 20, fontWeight: FontWeight.bold)),
          const Icon(Icons.sort_rounded, color: Colors.white38, size: 20),
        ],
      ),
    );
  }

  Widget _buildSurahList() {
    final filteredSurahs = surahNames.where((name) => name.contains(_searchQuery)).toList();
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: filteredSurahs.length,
      itemBuilder: (context, index) {
        final actualIndex = surahNames.indexOf(filteredSurahs[index]);
        return _buildSurahItem(actualIndex, filteredSurahs[index]);
      },
    );
  }

  Widget _buildSurahItem(int index, String name) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setInt('last_tafseer_surah', index + 1);
                await prefs.setString('last_tafseer_surah_name', name);
                if (mounted) context.push('/surah-tafseer', extra: {'surahNumber': index + 1, 'surahName': name});
              },
              leading: Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  image: const DecorationImage(image: AssetImage('assets/images/surah_frame.png'), opacity: 0.5),
                  color: Colors.white.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text('${index + 1}', style: GoogleFonts.notoSans(color: const Color(0xFFF5A623), fontSize: 14, fontWeight: FontWeight.bold)),
                ),
              ),
              title: Text(name, style: GoogleFonts.amiri(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
              subtitle: Text("سورة ${index % 2 == 0 ? 'مكية' : 'مدنية'} • ٧ آيات", style: const TextStyle(color: Colors.white38, fontSize: 11)),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white12, size: 16),
            ),
          ),
        ),
      ),
    );
  }
}
