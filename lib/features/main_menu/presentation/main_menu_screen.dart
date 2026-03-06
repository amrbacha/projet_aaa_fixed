import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../widgets/islamic_background.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/theme_provider.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  String _userName = "";

  static const double _globalOpacity = 0.1;
  static const double _globalBorderOpacity = 0.2;

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final userData = await LocalStorageService.getUserData();
    if (mounted) {
      setState(() {
        _userName = userData['fullName'] ?? "";
      });
    }
  }

  Future<void> _showExitDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0D3B2E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('تأكيد الخروج', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: const Text('هل أنت متأكد أنك تريد الخروج من التطبيق؟', style: TextStyle(color: Colors.white70)),
          actions: <Widget>[
            TextButton(
              child: const Text('لا', style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('نعم', style: TextStyle(color: Color(0xFFF5A623))),
              onPressed: () {
                exit(0);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tt = theme.textTheme;

    return IslamicBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text("مساعد الصلاة", style: tt.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
          centerTitle: true,
          leading: IconButton(
            onPressed: () => context.push('/language'),
            icon: const Icon(Icons.person_outline, color: Colors.white, size: 28),
          ),
          actions: [
            IconButton(
              onPressed: () => _showExitDialog(context),
              icon: const Icon(Icons.exit_to_app, color: Colors.white, size: 28),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Text("السلام عليكم، $_userName", style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text("أهلاً بك في رحاب الطاعة. اختر وجهتك اليوم لترتقي سوياً في درجات الإيمان", 
                  style: tt.bodyMedium?.copyWith(color: Colors.white.withOpacity(0.9)), textAlign: TextAlign.center),
              const SizedBox(height: 24),
              _buildKhatmaCard(context, theme),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: Text("الخدمات والبرامج", style: tt.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.0,
                children: [
                  _buildServiceCard(context: context, theme: theme, title: "ختم القرآن بالصلاة", icon: Icons.mosque_outlined, onTap: () => context.push('/home')),
                  _buildServiceCard(context: context, theme: theme, title: "ختم القرآن بالقراءة", icon: Icons.book_outlined, onTap: () => context.push('/reading')),
                  _buildServiceCard(context: context, theme: theme, title: "حفظ القرآن الكريم", icon: Icons.school_outlined, onTap: () => context.push('/memorization')),
                  _buildServiceCard(context: context, theme: theme, title: "التفسير والتدبر", icon: Icons.lightbulb_outline, onTap: () => context.push('/tafseer')),
                  _buildServiceCard(context: context, theme: theme, title: "الأذكار والأدعية", icon: Icons.favorite_border, onTap: () => context.push('/adhkar')),
                  _buildServiceCard(context: context, theme: theme, title: "التسبيح", icon: Icons.all_inclusive, onTap: () => context.push('/tasbeeh')),
                  _buildServiceCard(context: context, theme: theme, title: "اتجاه القبلة", icon: Icons.explore_outlined, onTap: () => context.push('/qibla')),
                  _buildServiceCard(context: context, theme: theme, title: "أسماء الله الحسنى", icon: Icons.auto_awesome_outlined, onTap: () => context.push('/asma-allah')),
                ],
              ),
              const SizedBox(height: 24),
              _buildCertificateCard(context, theme),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKhatmaCard(BuildContext context, ThemeData theme) {
    final tt = theme.textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
       decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withOpacity(_globalOpacity),
        border: Border.all(color: Colors.white.withOpacity(_globalBorderOpacity)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("موصى به", style: tt.titleSmall?.copyWith(color: const Color(0xFFF5A623), fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text("رحلة الختمة المباركة", style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 6),
          Text("ابدأ رحلة الإيمان لختم القرآن الكريم تلاوةً أو في صلواتك اليومية.",
              style: tt.bodyMedium?.copyWith(color: Colors.white.withOpacity(0.85))),
        ],
      ),
    );
  }

  Widget _buildCertificateCard(BuildContext context, ThemeData theme) {
    final tt = theme.textTheme;
    return InkWell(
      onTap: () => context.push('/certificate-selector'),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color(0xFFF5A623).withOpacity(0.15),
          border: Border.all(color: const Color(0xFFF5A623).withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.workspace_premium, size: 48, color: Color(0xFFF5A623)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("شهادات الإنجاز والمكافأة", style: tt.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text("استعرض وثق نجاحاتك في رحلتك مع القرآن.", style: tt.bodySmall?.copyWith(color: Colors.white70)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard({
    required BuildContext context,
    required ThemeData theme,
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final tt = theme.textTheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white.withOpacity(_globalOpacity),
          border: Border.all(color: Colors.white.withOpacity(_globalBorderOpacity)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 36, color: const Color(0xFFF5A623)),
            const Spacer(),
            Text(title, style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.white, height: 1.2)),
            const SizedBox(height: 8),
            Text("ابدأ الآن", style: tt.bodySmall?.copyWith(color: Colors.white.withOpacity(0.7), fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
