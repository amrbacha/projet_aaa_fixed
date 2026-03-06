import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:projet_aaa/core/models/quran_data.dart';
import 'package:projet_aaa/widgets/islamic_background.dart';

class AyahTadabburScreen extends StatefulWidget {
  final Ayah ayah;
  const AyahTadabburScreen({super.key, required this.ayah});

  @override
  State<AyahTadabburScreen> createState() => _AyahTadabburScreenState();
}

class _AyahTadabburScreenState extends State<AyahTadabburScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _reflectionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
          title: Text('${widget.ayah.surahName} (${widget.ayah.ayahNumber})', 
            style: GoogleFonts.amiri(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
            onPressed: () => context.pop(),
          ),
        ),
        body: Column(
          children: [
            _buildAyahDisplay(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
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

  Widget _buildAyahDisplay() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: const Color(0xFFC19A6B).withOpacity(0.3)),
      ),
      child: Center(
        child: Text(
          widget.ayah.text,
          textAlign: TextAlign.center,
          style: GoogleFonts.amiri(
            color: Colors.white,
            fontSize: 24,
            height: 1.8,
            fontWeight: FontWeight.w500,
          ),
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
      labelStyle: GoogleFonts.amiri(fontSize: 16, fontWeight: FontWeight.bold),
      tabs: const [
        Tab(text: 'التفسير'),
        Tab(text: 'التدبر'),
        Tab(text: 'خواطري'),
      ],
    );
  }

  Widget _buildTafseerTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoSection('المعنى الميسر', 'سيتم ربط بيانات التفسير الكاملة هنا قريباً. هذا النص هو نموذج توضيحي لمعنى الآية الكريمة وفهم مقاصدها الشرعية لتعميق الإيمان.'),
          const SizedBox(height: 20),
          _buildInfoSection('معاني الكلمات', '• الكلمة الأولى: معناها اللغوي\n• الكلمة الثانية: الدلالة السياقية'),
        ],
      ),
    );
  }

  Widget _buildTadabburTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildActionCard(
            title: 'سؤال تأملي',
            content: 'ما هو الأثر الذي تتركه هذه الآية في قلبك عند قراءتها بتدبر؟',
            icon: Icons.lightbulb_outline,
          ),
          const SizedBox(height: 16),
          _buildActionCard(
            title: 'تطبيق عملي',
            content: 'حاول اليوم أن تطبق معنى هذه الآية في تعاملك مع أهلك وزملائك.',
            icon: Icons.volunteer_activism_outlined,
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
            child: TextField(
              controller: _reflectionController,
              maxLines: 10,
              style: GoogleFonts.amiri(color: Colors.white, fontSize: 18),
              decoration: InputDecoration(
                hintText: 'اكتب خواطرك وتأملاتك حول هذه الآية...',
                hintStyle: GoogleFonts.amiri(color: Colors.white38),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC19A6B),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حفظ الخاطرة بنجاح')));
              },
              child: Text('حفظ التأمل', style: GoogleFonts.amiri(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.amiri(color: const Color(0xFFC19A6B), fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(content, style: GoogleFonts.amiri(color: Colors.white.withOpacity(0.85), fontSize: 16, height: 1.6)),
      ],
    );
  }

  Widget _buildActionCard({required String title, required String content, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFF5A623), size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.amiri(color: const Color(0xFFF5A623), fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(content, style: GoogleFonts.amiri(color: Colors.white70, fontSize: 15, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
