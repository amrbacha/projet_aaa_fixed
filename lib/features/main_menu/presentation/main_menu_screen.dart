import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../widgets/islamic_background.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/services/assistant_service.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  String _userName = "";
  final AssistantService _anis = AssistantService();
  bool _hasWelcomed = false;

  static const double _globalOpacity = 0.1;
  static const double _globalBorderOpacity = 0.2;

  @override
  void initState() {
    super.initState();
    _initializeMenu();
  }

  Future<void> _initializeMenu() async {
    final userData = await LocalStorageService.getUserData();
    if (mounted) {
      setState(() {
        _userName = userData['fullName'] ?? "";
      });
      
      // المبادرة بالترحيب الاجتماعي الذكي لمرة واحدة عند الدخول
      if (!_hasWelcomed && _userName.isNotEmpty) {
        _hasWelcomed = true;
        Future.delayed(const Duration(seconds: 1), () {
          _anis.welcomeUser(_userName);
        });
      }
    }
  }

  Future<void> _showExitDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0D3B2E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(l10n.confirmExit, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Text(l10n.exitMessage, style: const TextStyle(color: Colors.white70)),
          actions: <Widget>[
            TextButton(
              child: Text(l10n.no, style: const TextStyle(color: Colors.white)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(l10n.yes, style: const TextStyle(color: Color(0xFFF5A623))),
              onPressed: () => exit(0),
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
    final l10n = AppLocalizations.of(context);
    
    if (l10n == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return IslamicBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(l10n.appTitle, style: tt.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
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
              // عرض الترحيب النصي
              Text(l10n.greeting(_userName), style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(l10n.welcomeMessage, 
                  style: tt.bodyMedium?.copyWith(color: Colors.white.withOpacity(0.9)), textAlign: TextAlign.center),
              const SizedBox(height: 24),
              _buildKhatmaCard(context, theme, l10n),
              const SizedBox(height: 24),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(l10n.servicesTitle, style: tt.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
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
                  _buildServiceCard(context: context, theme: theme, title: l10n.prayerKhatma, icon: Icons.mosque_outlined, onTap: () => context.push('/home'), l10n: l10n),
                  _buildServiceCard(context: context, theme: theme, title: l10n.readingQuran, icon: Icons.book_outlined, onTap: () => context.push('/reading'), l10n: l10n),
                  _buildServiceCard(context: context, theme: theme, title: l10n.memorization, icon: Icons.school_outlined, onTap: () => context.push('/memorization'), l10n: l10n),
                  _buildServiceCard(context: context, theme: theme, title: l10n.tafseer, icon: Icons.lightbulb_outline, onTap: () => context.push('/tafseer'), l10n: l10n),
                  _buildServiceCard(context: context, theme: theme, title: l10n.adhkar, icon: Icons.favorite_border, onTap: () => context.push('/adhkar'), l10n: l10n),
                  _buildServiceCard(context: context, theme: theme, title: l10n.tasbeeh, icon: Icons.all_inclusive, onTap: () => context.push('/tasbeeh'), l10n: l10n),
                  _buildServiceCard(context: context, theme: theme, title: l10n.qiblaDirection, icon: Icons.explore_outlined, onTap: () => context.push('/qibla'), l10n: l10n),
                  _buildServiceCard(context: context, theme: theme, title: l10n.asmaAllah, icon: Icons.auto_awesome_outlined, onTap: () => context.push('/asma-allah'), l10n: l10n),
                ],
              ),
              const SizedBox(height: 24),
              _buildCertificateCard(context, theme, l10n),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKhatmaCard(BuildContext context, ThemeData theme, AppLocalizations l10n) {
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
          Text(l10n.recommended, style: tt.titleSmall?.copyWith(color: const Color(0xFFF5A623), fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(l10n.khatmaJourney, style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 6),
          Text(l10n.khatmaDesc,
              style: tt.bodyMedium?.copyWith(color: Colors.white.withOpacity(0.85))),
        ],
      ),
    );
  }

  Widget _buildCertificateCard(BuildContext context, ThemeData theme, AppLocalizations l10n) {
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
                  Text(l10n.certificatesTitle, style: tt.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(l10n.certificatesDesc, style: tt.bodySmall?.copyWith(color: Colors.white70)),
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
    required AppLocalizations l10n,
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
            Text(l10n.startNow, style: tt.bodySmall?.copyWith(color: Colors.white.withOpacity(0.7), fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
