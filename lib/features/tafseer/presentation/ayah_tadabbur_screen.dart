import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:projet_aaa_fixed/core/models/quran_data.dart';
import 'package:projet_aaa_fixed/widgets/islamic_background.dart';
import 'package:projet_aaa_fixed/core/services/assistant_service.dart';
import 'package:projet_aaa_fixed/core/services/tafseer_service.dart';

class AyahTadabburScreen extends StatefulWidget {
  final Ayah ayah;
  const AyahTadabburScreen({super.key, required this.ayah});

  @override
  State<AyahTadabburScreen> createState() => _AyahTadabburScreenState();
}

class _AyahTadabburScreenState extends State<AyahTadabburScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _reflectionController = TextEditingController();
  final AssistantService _anis = AssistantService();
  final TafseerService _tafseerService = TafseerService();

  Map<String, dynamic>? _tafseerData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadTafseer();
  }

  Future<void> _loadTafseer() async {
    setState(() => _isLoading = true);
    final data = await _tafseerService.getTafseer(widget.ayah.surahNumber, widget.ayah.ayahNumber);
    if (mounted) {
      setState(() {
        _tafseerData = data;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _reflectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IslamicBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('${widget.ayah.surahName} - آية ${widget.ayah.ayahNumber}', 
            style: GoogleFonts.amiri(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
          centerTitle: true,
          backgroundColor: Colors.black26,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
            onPressed: () => context.pop(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Color(0xFFF5A623)),
              onPressed: _loadTafseer,
            )
          ],
        ),
        body: Column(
          children: [
            _buildAyahHeader(),
            _buildTabBar(),
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFF5A623)))
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTafseerTab(),
                      _buildTadabburTab(),
                      _buildMyReflectionTab(),
                    ],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAyahHeader() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: const Color(0xFFF5A623).withOpacity(0.5), width: 1.5),
        boxShadow: [BoxShadow(color: const Color(0xFFF5A623).withOpacity(0.1), blurRadius: 20)],
      ),
      child: Text(
        widget.ayah.text,
        textAlign: TextAlign.center,
        style: GoogleFonts.amiri(
          color: Colors.white,
          fontSize: 26,
          height: 1.8,
          fontWeight: FontWeight.bold,
          shadows: [const Shadow(color: Colors.black, blurRadius: 2, offset: const Offset(1, 1))]
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      indicatorColor: const Color(0xFFF5A623),
      labelColor: const Color(0xFFF5A623),
      unselectedLabelColor: Colors.white60,
      labelStyle: GoogleFonts.amiri(fontSize: 18, fontWeight: FontWeight.bold),
      tabs: const [
        Tab(text: 'التفسير المنضبط'),
        Tab(text: 'هدايات إيمانية'),
        Tab(text: 'تدبراتي'),
      ],
    );
  }

  Widget _buildTafseerTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            _tafseerData?['source'] ?? 'تفسير معتمد', 
            _tafseerData?['text'] ?? 'جاري جلب النص المعتمد...', 
            Icons.menu_book
          ),
          const SizedBox(height: 15),
          Text(
            "تنبيه: هذا التفسير منقول عن مجمع الملك فهد لطباعة المصحف الشريف لضمان السلامة الفقهية.",
            textAlign: TextAlign.center,
            style: GoogleFonts.amiri(color: Colors.white38, fontSize: 13, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildTadabburTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildTadabburCard(
            'من هدايات الآية (بالاستناد لأقوال السلف)', 
            _tafseerData?['guidance'] ?? 'تأمل في عظمة الله وحكمته في هذه الآية.', 
            Icons.auto_awesome
          ),
          const SizedBox(height: 15),
          _buildTadabburCard(
            'التوجيه العملي', 
            'العمل بالقرآن هو ثمرة العلم، فاحرص على امتثال أمر الله واجتناب نهيه في ضوء فهم هذه الآية.', 
            Icons.favorite_border
          ),
        ],
      ),
    );
  }

  Widget _buildMyReflectionTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white10)),
              child: TextField(
                controller: _reflectionController,
                maxLines: null,
                style: GoogleFonts.amiri(color: Colors.white, fontSize: 18),
                decoration: InputDecoration(
                  hintText: 'اكتب ما فتح الله به عليك من تأملات في ضوء التفسير الصحيح المذكور في التاب الأول...',
                  hintStyle: GoogleFonts.amiri(color: Colors.white38),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF5A623), minimumSize: const Size(double.infinity, 55), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
            onPressed: () {
              _anis.speak("تم حفظ تدبرك، جعله الله في ميزان حسناتك.");
            },
            icon: const Icon(Icons.save, color: Colors.black),
            label: Text('حفظ في سجلي الإيماني', style: GoogleFonts.amiri(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String content, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, color: const Color(0xFFF5A623), size: 22), const SizedBox(width: 12), Expanded(child: Text(title, style: GoogleFonts.amiri(color: const Color(0xFFF5A623), fontSize: 18, fontWeight: FontWeight.bold)))]),
          const SizedBox(height: 12),
          Text(content, style: GoogleFonts.amiri(color: Colors.white, fontSize: 19, height: 1.7)),
        ],
      ),
    );
  }

  Widget _buildTadabburCard(String title, String content, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white10)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFF5A623), size: 26),
          const SizedBox(width: 15),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: GoogleFonts.amiri(color: const Color(0xFFF5A623), fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 8), Text(content, style: GoogleFonts.amiri(color: Colors.white, fontSize: 17, height: 1.5))])),
        ],
      ),
    );
  }
}
