import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:projet_aaa/core/models/quran_data.dart';
import 'package:projet_aaa/core/services/quran_service.dart';
import 'package:projet_aaa/widgets/islamic_background.dart';

class SurahTafseerScreen extends StatefulWidget {
  final int surahNumber;
  final String surahName;

  const SurahTafseerScreen({
    super.key,
    required this.surahNumber,
    required this.surahName,
  });

  @override
  State<SurahTafseerScreen> createState() => _SurahTafseerScreenState();
}

class _SurahTafseerScreenState extends State<SurahTafseerScreen> {
  List<Ayah>? verses;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVerses();
  }

  Future<void> _loadVerses() async {
    // جلب بيانات القرآن والبحث عن السورة المطلوبة
    final quran = await QuranService().getAllVerses(excludeFatiha: false);
    final surahVerses = quran.where((a) => a.surahNumber == widget.surahNumber).toList();
    
    if (mounted) {
      setState(() {
        verses = surahVerses;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return IslamicBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(widget.surahName, 
            style: GoogleFonts.amiri(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
            onPressed: () => context.pop(),
          ),
        ),
        body: isLoading 
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFC19A6B)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: verses?.length ?? 0,
              itemBuilder: (context, index) {
                final ayah = verses![index];
                return _buildAyahCard(context, ayah);
              },
            ),
      ),
    );
  }

  Widget _buildAyahCard(BuildContext context, Ayah ayah) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: ListTile(
        onTap: () {
          context.push('/ayah-tadabbur', extra: ayah);
        },
        title: Text(
          ayah.text,
          textAlign: TextAlign.right,
          style: GoogleFonts.amiri(
            color: Colors.white,
            fontSize: 20,
            height: 1.8,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFC19A6B).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text('آية ${ayah.ayahNumber}', 
                  style: GoogleFonts.notoSans(color: const Color(0xFFC19A6B), fontSize: 10)),
              ),
              const Spacer(),
              Text('انقر للتدبر والتفسير', 
                style: GoogleFonts.amiri(color: Colors.white38, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
