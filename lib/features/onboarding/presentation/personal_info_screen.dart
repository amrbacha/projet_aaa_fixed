import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
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
  String _gender = 'ذكر';
  String _ageGroup = 'شاب';
  String _readingSpeed = 'متوسط'; // الخيار الجديد للسرعة اليدوية

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
        _gender = data['gender'] ?? 'ذكر';
        _ageGroup = data['ageGroup'] ?? 'شاب';
        _readingSpeed = data['readingSpeed'] ?? 'متوسط';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return IslamicBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => context.pop(),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const Icon(Icons.mosque, size: 60, color: Colors.white),
              const SizedBox(height: 16),
              Text('مساعد الصلاة', 
                style: GoogleFonts.amiri(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 28)),
              const SizedBox(height: 32),
              
              _buildFormContainer(),
              
              const SizedBox(height: 32),
              _buildSubmitButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormContainer() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Text('لنتعرف عليك', 
                style: GoogleFonts.amiri(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold))),
              const SizedBox(height: 24),
              
              _buildSectionTitle('الجنس'),
              Row(
                children: [
                  Expanded(child: _buildChoiceChip('ذكر', Icons.male, _gender == 'ذكر', () => setState(() => _gender = 'ذكر'))),
                  const SizedBox(width: 12),
                  Expanded(child: _buildChoiceChip('أنثى', Icons.female, _gender == 'أنثى', () => setState(() => _gender = 'أنثى'))),
                ],
              ),
              
              const SizedBox(height: 20),
              _buildSectionTitle('الفئة العمرية'),
              Row(
                children: [
                  Expanded(child: _buildChoiceChip('طفل', null, _ageGroup == 'طفل', () => setState(() => _ageGroup = 'طفل'))),
                  const SizedBox(width: 8),
                  Expanded(child: _buildChoiceChip('شاب', null, _ageGroup == 'شاب', () => setState(() => _ageGroup = 'شاب'))),
                  const SizedBox(width: 8),
                  Expanded(child: _buildChoiceChip('كبير', null, _ageGroup == 'كبير', () => setState(() => _ageGroup = 'كبير'))),
                ],
              ),

              const SizedBox(height: 20),
              _buildSectionTitle('سرعة قراءتك المعتادة (يدوياً)'),
              Row(
                children: [
                  Expanded(child: _buildChoiceChip('هادئ', null, _readingSpeed == 'هادئ', () => setState(() => _readingSpeed = 'هادئ'))),
                  const SizedBox(width: 8),
                  Expanded(child: _buildChoiceChip('متوسط', null, _readingSpeed == 'متوسط', () => setState(() => _readingSpeed = 'متوسط'))),
                  const SizedBox(width: 8),
                  Expanded(child: _buildChoiceChip('سريع', null, _readingSpeed == 'سريع', () => setState(() => _readingSpeed = 'سريع'))),
                ],
              ),
              
              const SizedBox(height: 20),
              _buildTextField('الاسم الكامل', _nameController),
              const SizedBox(height: 16),
              _buildTextField('صفتك (مثلاً: طالب علم)', _jobController),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(title, style: GoogleFonts.amiri(color: Colors.white70, fontSize: 16)),
    );
  }

  Widget _buildChoiceChip(String label, IconData? icon, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF5A623).withOpacity(0.8) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? const Color(0xFFF5A623) : Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) Icon(icon, color: Colors.white, size: 16),
            if (icon != null) const SizedBox(width: 4),
            Text(label, style: GoogleFonts.amiri(color: Colors.white, fontSize: 14, fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller) {
    return TextField(
      controller: controller,
      textAlign: TextAlign.right,
      textDirection: TextDirection.rtl,
      style: GoogleFonts.amiri(color: Colors.white, fontSize: 16),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.amiri(color: Colors.white.withOpacity(0.3), fontSize: 14),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withOpacity(0.2))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFF5A623))),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFFF5A623),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: () async {
          if (_nameController.text.isNotEmpty) {
            await LocalStorageService.saveUserData(
              fullName: _nameController.text,
              jobTitle: _jobController.text,
              gender: _gender,
              ageGroup: _ageGroup,
              readingSpeed: _readingSpeed, // حفظ السرعة اليدوية كبديل
            );
            if (mounted) {
               // إذا أراد المستخدم، نعرض له شاشة المعايرة الصوتية كخطوة اختيارية
               _showCalibrationDialog();
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الرجاء إدخال الاسم')));
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('استمرار', 
              style: GoogleFonts.amiri(color: const Color(0xFF0D3B2E), fontWeight: FontWeight.bold, fontSize: 20)),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios, color: Color(0xFF0D3B2E), size: 18),
          ],
        ),
      ),
    );
  }

  void _showCalibrationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0D3B2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("تحسين دقة الاستجابة", textAlign: TextAlign.center, style: GoogleFonts.amiri(color: const Color(0xFFF5A623))),
        content: Text(
          "هل ترغب في قراءة آية قصيرة لمرة واحدة فقط لكي يضبط التطبيق نفسه على سرعة تلاوتك؟ (اختياري)",
          textAlign: TextAlign.center,
          style: GoogleFonts.amiri(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => context.push('/theme-customization'),
            child: Text("تخطي الآن", style: GoogleFonts.amiri(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF5A623)),
            onPressed: () {
              context.pop();
              // هنا سيتم فتح شاشة المعايرة الصوتية
              context.push('/voice-calibration'); 
            },
            child: Text("ابدأ المعايرة", style: GoogleFonts.amiri(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}
