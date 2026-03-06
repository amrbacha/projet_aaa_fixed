import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projet_aaa/core/services/quran_service.dart';
import 'package:projet_aaa/core/models/quran_data.dart';
import 'package:projet_aaa/widgets/islamic_background.dart';

class MemorizationDashboardScreen extends StatefulWidget {
  const MemorizationDashboardScreen({super.key});

  @override
  State<MemorizationDashboardScreen> createState() => _MemorizationDashboardScreenState();
}

class _MemorizationDashboardScreenState extends State<MemorizationDashboardScreen> {
  final QuranService _quranService = QuranService();
  List<Surah> _allSurahs = [];
  List<Surah> _filteredSurahs = [];
  bool _isLoading = true;
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  static const double _globalOpacity = 0.1;
  static const double _globalBorderOpacity = 0.2;

  @override
  void initState() {
    super.initState();
    _loadSurahs();
  }

  Future<void> _loadSurahs() async {
    try {
      final quran = await _quranService.getAllVerses(excludeFatiha: false);
      Map<int, Surah> surahMap = {};
      for (var v in quran) {
        if (!surahMap.containsKey(v.surahNumber)) {
          surahMap[v.surahNumber] = Surah(
            surahNumber: v.surahNumber,
            surahName: v.surahName,
            verses: [],
          );
        }
        surahMap[v.surahNumber]!.verses.add(v);
      }
      
      if (mounted) {
        setState(() {
          _allSurahs = surahMap.values.toList();
          _filteredSurahs = _allSurahs;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading surahs: $e");
    }
  }

  void _filterSurahs(String query) {
    setState(() {
      _searchQuery = query;
      _filteredSurahs = _allSurahs
          .where((s) => s.surahName.contains(query) || s.surahNumber.toString().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return IslamicBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text('حفظ القرآن الكريم', 
            style: GoogleFonts.amiri(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => context.go('/main-menu'),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.white),
              onPressed: () => context.push('/memorization-settings'),
            ),
          ],
        ),
        body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFF5A623)))
          : Column(
              children: [
                _buildSearchBar(),
                _buildProgressSummary(),
                Expanded(
                  child: _buildSurahList(),
                ),
              ],
            ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        onChanged: _filterSurahs,
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl, // تحديد اتجاه النص لليمين للغة العربية
        style: GoogleFonts.amiri(color: Colors.white, fontSize: 18),
        decoration: InputDecoration(
          hintText: 'ابحث عن سورة...',
          hintStyle: GoogleFonts.amiri(color: Colors.white.withOpacity(0.5), fontSize: 16),
          prefixIcon: const Icon(Icons.search, color: Colors.white70),
          filled: true,
          fillColor: Colors.white.withOpacity(_globalOpacity),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15), 
            borderSide: BorderSide(color: Colors.white.withOpacity(_globalBorderOpacity)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15), 
            borderSide: BorderSide(color: Colors.white.withOpacity(_globalBorderOpacity)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15), 
            borderSide: const BorderSide(color: Color(0xFFF5A623), width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressSummary() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(_globalOpacity),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(_globalBorderOpacity)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem("السور المحفوظة", "٠"),
          _buildStatItem("الآيات المحفوظة", "٠"),
          _buildStatItem("نسبة الإنجاز", "٠٪"),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.amiri(color: const Color(0xFFF5A623), fontSize: 22, fontWeight: FontWeight.bold)),
        Text(label, style: GoogleFonts.amiri(color: Colors.white70, fontSize: 14)),
      ],
    );
  }

  Widget _buildSurahList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredSurahs.length,
      itemBuilder: (context, index) {
        final surah = _filteredSurahs[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(_globalOpacity),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white.withOpacity(_globalBorderOpacity)),
          ),
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF5A623).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(_toArabicDigits(surah.surahNumber), style: const TextStyle(color: Color(0xFFF5A623), fontSize: 14, fontWeight: FontWeight.bold)),
            ),
            title: Text(surah.surahName, style: GoogleFonts.amiri(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            subtitle: Text('عدد آياتها: ${_toArabicDigits(surah.verses.length)}', style: GoogleFonts.amiri(color: Colors.white70, fontSize: 14)),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 16),
            onTap: () {
              context.push('/memorization-session', extra: surah);
            },
          ),
        );
      },
    );
  }

  String _toArabicDigits(int n) => n.toString().split('').map((c) => '٠١٢٣٤٥٦٧٨٩'[int.parse(c)]).join();
}
