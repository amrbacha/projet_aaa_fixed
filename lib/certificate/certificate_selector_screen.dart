import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/islamic_background.dart';

class CertificateType {
  final String title;
  final String description;
  final IconData icon;
  final String id;

  CertificateType({required this.title, required this.description, required this.icon, required this.id});
}

class CertificateSelectorScreen extends StatelessWidget {
  const CertificateSelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<CertificateType> types = [
      CertificateType(id: 'prayer_khatma', title: 'شهادة الختمة بالصلاة', description: 'لإتمام ختم القرآن الكريم كاملاً في الصلوات', icon: Icons.mosque_outlined),
      CertificateType(id: 'reading_khatma', title: 'شهادة الختمة بالقراءة', description: 'لإتمام تلاوة القرآن الكريم كاملاً', icon: Icons.menu_book_outlined),
      CertificateType(id: 'quran_memorization', title: 'شهادة حفظ القرآن', description: 'لإتمام حفظ كتاب الله عز وجل', icon: Icons.school_outlined),
      CertificateType(id: 'surah_memorization', title: 'شهادة حفظ سورة', description: 'لإتمام حفظ سورة معينة من القرآن', icon: Icons.star_border),
      CertificateType(id: 'general_achievements', title: 'شهادة الإنجاز العامة', description: 'إحصائيات عامة لجميع ختماتك وإنجازاتك', icon: Icons.workspace_premium),
    ];

    return IslamicBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
          centerTitle: true,
          title: const Text('اختر نوع الشهادة', style: TextStyle(fontWeight: FontWeight.bold)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => context.go('/main-menu'), // العودة للصفحة الرئيسية
          ),
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: types.length,
          itemBuilder: (context, index) {
            final type = types[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              color: Colors.white.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Colors.white24), // تم إصلاح الخطأ هنا باستخدام side بدلاً من border
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: const Color(0xFFF5A623).withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                  child: Icon(type.icon, color: const Color(0xFFF5A623), size: 32),
                ),
                title: Text(type.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                subtitle: Text(type.description, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 16),
                onTap: () {
                  context.push('/certificate-viewer', extra: type.id);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
