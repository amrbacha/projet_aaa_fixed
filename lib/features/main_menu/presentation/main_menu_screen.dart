
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../widgets/islamic_background.dart';
import '../../../core/services/local_storage_service.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    try {
      final data = await LocalStorageService.getUserData();
      if (mounted) {
        setState(() => _userName = (data['fullName'] ?? '').toString());
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return IslamicBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Text(
            'مساعد الصلاة',
            style: GoogleFonts.amiri(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 26,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () => context.push('/settings'),
              icon: const Icon(Icons.person_outline, color: Colors.white),
            ),
          ],
          leading: IconButton(
            onPressed: () => context.go('/language'),
            icon: const Icon(Icons.logout, color: Colors.white),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildWelcomeCard(),
                const SizedBox(height: 14),
                _buildPrimaryGrid(),
                const SizedBox(height: 14),
                _buildSecondaryGrid(),
                const SizedBox(height: 14),
                _buildBottomCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            _userName.isEmpty ? 'السلام عليكم' : 'السلام عليكم، $_userName',
            textAlign: TextAlign.right,
            style: GoogleFonts.amiri(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'رحلة الختمة المباركة تبدأ من القرآن، ثم الصلاة، ثم الفهم والذكر.',
            textAlign: TextAlign.right,
            style: GoogleFonts.amiri(
              color: Colors.white.withOpacity(0.85),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _sectionTitle('الخدمات والبرامج الأساسية'),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _menuCard(
                title: 'ختم القرآن بالقراءة',
                subtitle: 'ابدأ الآن',
                icon: Icons.menu_book_rounded,
                onTap: () => context.push('/reading'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _menuCard(
                title: 'ختم القرآن بالصلاة',
                subtitle: 'ابدأ الآن',
                icon: Icons.mosque_rounded,
                onTap: () => context.push('/home'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _menuCard(
                title: 'التفسير والتدبر',
                subtitle: 'ابدأ الآن',
                icon: Icons.lightbulb_outline_rounded,
                onTap: () => context.push('/tafseer'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _menuCard(
                title: 'حفظ القرآن الكريم',
                subtitle: 'ابدأ الآن',
                icon: Icons.school_outlined,
                onTap: () => context.push('/memorization'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSecondaryGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _sectionTitle('الخدمات المساندة'),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _menuCard(
                title: 'التسبيح',
                subtitle: 'ابدأ الآن',
                icon: Icons.all_inclusive_rounded,
                onTap: () => context.push('/tasbeeh'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _menuCard(
                title: 'الأذكار والأدعية',
                subtitle: 'ابدأ الآن',
                icon: Icons.favorite_border_rounded,
                onTap: () => context.push('/adhkar'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _menuCard(
                title: 'أسماء الله الحسنى',
                subtitle: 'ابدأ الآن',
                icon: Icons.auto_awesome_rounded,
                onTap: () => context.push('/asma-allah'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _menuCard(
                title: 'تعليم الصلاة',
                subtitle: 'ابدأ الآن',
                icon: Icons.menu_book_outlined,
                onTap: () => context.push('/prayer-learning'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _menuCard(
                title: 'اتجاه القبلة',
                subtitle: 'أداة مساندة',
                icon: Icons.explore_outlined,
                onTap: () => context.push('/qibla'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _menuCard(
                title: 'مساعد الصلاة التجريبي',
                subtitle: 'للاختبار فقط',
                icon: Icons.videocam_outlined,
                onTap: () => context.push('/prayer-coach-debug'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF6B3F14).withOpacity(0.70),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF5A623).withOpacity(0.35)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.workspace_premium_outlined, color: Color(0xFFF5A623), size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'شهادات الإنجاز والمكافأة',
                  textAlign: TextAlign.right,
                  style: GoogleFonts.amiri(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'استعرض إنجازاتك في رحلتك مع القرآن.',
                  textAlign: TextAlign.right,
                  style: GoogleFonts.amiri(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: () => context.push('/certificate-selector'),
            icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      textAlign: TextAlign.right,
      style: GoogleFonts.amiri(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _menuCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 158,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.10),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Icon(icon, color: const Color(0xFFF5A623), size: 34),
            ),
            const Spacer(),
            Text(
              title,
              textAlign: TextAlign.right,
              style: GoogleFonts.amiri(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.right,
              style: GoogleFonts.amiri(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
