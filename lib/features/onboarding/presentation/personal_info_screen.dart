import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/islamic_background.dart';
import '../../../core/services/local_storage_service.dart';

class PersonalInfoScreen extends StatefulWidget {
  final String selectedLang;
  const PersonalInfoScreen({super.key, required this.selectedLang});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _nameController = TextEditingController();
  final _jobController = TextEditingController();
  String _gender = 'male'; 
  String _ageGroup = 'young';
  String _readingSpeed = 'medium';

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  Future<void> _loadExistingData() async {
    final data = await LocalStorageService.getUserData();
    if (data['fullName'] != null && data['fullName']!.isNotEmpty) {
      setState(() {
        _nameController.text = data['fullName']!;
        _jobController.text = data['jobTitle']!;
        _gender = data['gender'] ?? 'male';
        _ageGroup = data['ageGroup'] ?? 'young';
        _readingSpeed = data['readingSpeed'] ?? 'medium';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return IslamicBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
            onPressed: () => context.pop(),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const Icon(Icons.person_pin, size: 70, color: Color(0xFFF5A623)),
              const SizedBox(height: 16),
              Text(l10n.personalInfo, 
                style: GoogleFonts.amiri(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 28)),
              const SizedBox(height: 32),
              
              _buildFormContainer(l10n),
              
              const SizedBox(height: 32),
              _buildSubmitButton(l10n),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormContainer(AppLocalizations l10n) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(l10n.gender),
              Row(
                children: [
                  Expanded(child: _buildChoiceChip(l10n.male, Icons.male, _gender == 'male', () => setState(() => _gender = 'male'))),
                  const SizedBox(width: 12),
                  Expanded(child: _buildChoiceChip(l10n.female, Icons.female, _gender == 'female', () => setState(() => _gender = 'female'))),
                ],
              ),
              
              const SizedBox(height: 24),
              _buildSectionTitle(l10n.ageGroup),
              Row(
                children: [
                  Expanded(child: _buildChoiceChip(l10n.child, null, _ageGroup == 'child', () => setState(() => _ageGroup = 'child'))),
                  const SizedBox(width: 8),
                  Expanded(child: _buildChoiceChip(l10n.young, null, _ageGroup == 'young', () => setState(() => _ageGroup = 'young'))),
                  const SizedBox(width: 8),
                  Expanded(child: _buildChoiceChip(l10n.senior, null, _ageGroup == 'senior', () => setState(() => _ageGroup = 'senior'))),
                ],
              ),

              const SizedBox(height: 24),
              _buildSectionTitle(l10n.readingSpeed),
              Row(
                children: [
                  Expanded(child: _buildChoiceChip(l10n.slow, null, _readingSpeed == 'slow', () => setState(() => _readingSpeed = 'slow'))),
                  const SizedBox(width: 8),
                  Expanded(child: _buildChoiceChip(l10n.medium, null, _readingSpeed == 'medium', () => setState(() => _readingSpeed = 'medium'))),
                  const SizedBox(width: 8),
                  Expanded(child: _buildChoiceChip(l10n.fast, null, _readingSpeed == 'fast', () => setState(() => _readingSpeed = 'fast'))),
                ],
              ),
              
              const SizedBox(height: 24),
              _buildTextField(l10n.fullName, _nameController),
              const SizedBox(height: 16),
              _buildTextField(l10n.jobTitle, _jobController),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Text(title, style: GoogleFonts.amiri(color: const Color(0xFFF5A623), fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildChoiceChip(String label, IconData? icon, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF5A623).withOpacity(0.9) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: selected ? Colors.white : Colors.white.withOpacity(0.1)),
          boxShadow: selected ? [BoxShadow(color: const Color(0xFFF5A623).withOpacity(0.3), blurRadius: 8)] : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) Icon(icon, color: selected ? const Color(0xFF0D3B2E) : Colors.white70, size: 18),
            if (icon != null) const SizedBox(width: 6),
            Text(label, style: GoogleFonts.amiri(color: selected ? const Color(0xFF0D3B2E) : Colors.white, fontSize: 14, fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller) {
    return TextField(
      controller: controller,
      textAlign: TextAlign.start,
      style: GoogleFonts.amiri(color: Colors.white, fontSize: 16),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.amiri(color: Colors.white.withOpacity(0.3), fontSize: 14),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFFF5A623), width: 1.5)),
      ),
    );
  }

  Widget _buildSubmitButton(AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFFF5A623),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 5,
        ),
        onPressed: () async {
          if (_nameController.text.isNotEmpty) {
            await LocalStorageService.saveUserData(
              fullName: _nameController.text,
              jobTitle: _jobController.text,
              gender: _gender,
              ageGroup: _ageGroup,
              readingSpeed: _readingSpeed,
            );
            if (mounted) _showCalibrationDialog(l10n);
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(l10n.finish, style: GoogleFonts.amiri(color: const Color(0xFF0D3B2E), fontWeight: FontWeight.bold, fontSize: 22)),
            const SizedBox(width: 10),
            const Icon(Icons.arrow_forward_ios, color: Color(0xFF0D3B2E), size: 20),
          ],
        ),
      ),
    );
  }

  void _showCalibrationDialog(AppLocalizations l10n) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0D3B2E),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: const Color(0xFFF5A623).withOpacity(0.3)),
          borderRadius: BorderRadius.circular(25),
        ),
        title: const Icon(Icons.mic_none, color: Color(0xFFF5A623), size: 50),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.calibration, style: GoogleFonts.amiri(color: const Color(0xFFF5A623), fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Text(
              l10n.calibrationPrompt,
              textAlign: TextAlign.center,
              style: GoogleFonts.amiri(color: Colors.white, fontSize: 18, height: 1.5),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () => context.push('/theme-customization'),
            child: Text(l10n.nextStep, style: GoogleFonts.amiri(color: Colors.white54, fontSize: 16)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF5A623),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            onPressed: () {
              context.pop();
              context.push('/voice-calibration'); 
            },
            child: Text(l10n.startNow, style: GoogleFonts.amiri(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
