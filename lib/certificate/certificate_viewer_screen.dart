import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:projet_aaa/core/services/local_storage_service.dart';
import '../widgets/islamic_background.dart';

class CertificateViewerScreen extends StatefulWidget {
  final String certificateId;
  final String? surahName;
  const CertificateViewerScreen({super.key, required this.certificateId, this.surahName});

  @override
  State<CertificateViewerScreen> createState() => _CertificateViewerScreenState();
}

class _CertificateViewerScreenState extends State<CertificateViewerScreen> {
  String _userName = "";
  String _jobTitle = "";
  bool _isLoading = true;
  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final userData = await LocalStorageService.getUserData();
    if (mounted) {
      setState(() {
        _userName = userData['fullName'] ?? "المستخدم المبارك";
        _jobTitle = userData['jobTitle'] ?? "";
        _isLoading = false;
      });
    }
  }

  String _formatSurahName(String? name) {
    if (name == null || name.isEmpty) return "";
    if (name.trim().startsWith("سورة")) return name.trim();
    return "سورة ${name.trim()}";
  }

  String _getCertificateTitle() {
    switch (widget.certificateId) {
      case 'prayer_khatma': return 'شهادة إتمام الختمة بالصلاة';
      case 'reading_khatma': return 'شهادة إتمام الختمة بالقراءة';
      case 'quran_memorization': return 'شهادة حفظ القرآن الكريم كاملاً';
      case 'surah_memorization': return 'شهادة ${_formatSurahName(widget.surahName)}';
      case 'asma_quiz_perfection': return 'شهادة براعة في علم الأسماء الحسنى';
      default: return 'شهادة إنجاز ومباركة';
    }
  }

  String _getCertificateBody() {
    switch (widget.certificateId) {
      case 'prayer_khatma': return 'بفضل الله ومنّته، نُشهد بفخر واعتزاز أن حامل هذه الشهادة قد أتم رحلة الختمة المباركة في صلواته اليومية بكل خشوع واجتهاد، سائلين الله له الثبات والقبول. نحن فخورون جداً بهذا الإنجاز الروحاني العظيم الذي يرفع الدرجات في الدنيا والآخرة.';
      case 'reading_khatma': return 'بكل فخر واعتزاز، نُبارك لحامل هذه الشهادة إتمام تلاوة كتاب الله عز وجل كاملاً، مجتهداً في تدبر آياته متمسكاً بنوره، جعله الله لك شفيعاً يوم القيامة. أنت اليوم قدوة يُحتذى بها ومفخرة لأمتنا في حب القرآن الكريم.';
      case 'quran_memorization': return 'هنيئاً لك هذا الإنجاز العظيم! بكل فخر نُبارك لك حفظ كتاب الله في صدرك، فمن حفظ القرآن فقد حاز على شرف لا يدانيه شرف، جعله الله نوراً في قلبك وحجة لك. نفتخر بك كحافظ لكتاب الله وتاج وقار لوالديك.';
      case 'surah_memorization': return 'نفتخر بك وبمثابرتك العالية! نُبارك لك بكل اعتزاز إتمام حفظ ${_formatSurahName(widget.surahName)}، ونسأل الله أن يجعل كل آية حفظتها رفعة لك في الدرجات ونوراً لك في حياتك. استمر في طريق النور، فأنت اليوم بطل من أبطال القرآن الكريم.';
      case 'asma_quiz_perfection': return 'هنيئاً لك هذا العلم الشريف! بكل فخر نُبارك لك حصولك على الدرجة الكاملة في تحدي أسماء الله الحسنى، مما يدل على عمق فهمك وتعلقك بصفات خالقك. جعل الله هذا العلم نوراً لك في الدنيا والآخرة ورفعة لمقامك العالي.';
      default: return 'تقديراً وافتخاراً بالجهود العظيمة والمثابرة في التقرب إلى الله عز وجل عبر برامج تطبيق مساعد الصلاة، جعلها الله في ميزان حسناتك ورفعة لمقامك العالي. نحن نفخر بكل خطوة تخطوها نحو الجنة.';
    }
  }

  Future<void> _saveAndShare(bool shareOnly) async {
    try {
      final Uint8List? image = await _screenshotController.capture();
      if (image == null) return;

      final directory = await getApplicationDocumentsDirectory();
      final imagePath = await File('${directory.path}/certificate.png').create();
      await imagePath.writeAsBytes(image);

      if (shareOnly) {
        await Share.shareXFiles([XFile(imagePath.path)], text: 'الحمد لله، بكل فخر واعتزاز حصلت على ${_getCertificateTitle()} من تطبيق مساعد الصلاة');
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم حفظ الشهادة بنجاح في ذاكرة الجهاز')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ أثناء المعالجة: $e')),
        );
      }
    }
  }

  void _handleBackNavigation() {
    if (widget.certificateId == 'surah_memorization' || widget.certificateId == 'quran_memorization') {
      context.go('/memorization');
    } else if (widget.certificateId == 'asma_quiz_perfection') {
      context.go('/asma-allah');
    } else {
      context.go('/main-menu');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const IslamicBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent, 
          body: Center(child: CircularProgressIndicator(color: Colors.white))
        )
      );
    }

    return IslamicBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
          centerTitle: true,
          title: Text('معاينة الشهادة', style: GoogleFonts.amiri(fontWeight: FontWeight.bold, fontSize: 24)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: _handleBackNavigation,
          ),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            children: [
              Screenshot(
                controller: _screenshotController,
                child: _buildCertificateUI(),
              ),
              const SizedBox(height: 25),
              _buildActionButtons(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCertificateUI() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 500),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF0),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFC19A6B), width: 10),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Center(
              child: Opacity(opacity: 0.05, child: Icon(Icons.mosque, size: 250, color: const Color(0xFF1B5E20)))
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 25.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFB71C1C).withOpacity(0.4), width: 2),
                    color: const Color(0xFFB71C1C).withOpacity(0.05),
                  ),
                  child: const Icon(Icons.workspace_premium, color: Color(0xFFB71C1C), size: 45),
                ),
                const SizedBox(height: 10),
                
                Text('شهادة إنجاز ومباركـة', 
                  style: GoogleFonts.amiri(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF1B5E20))
                ),
                const SizedBox(height: 4),
                Container(width: 120, height: 2, color: const Color(0xFFC19A6B)),
                const SizedBox(height: 15),
                
                Text('نحن في تطبيق مساعد الصلاة نمنح هذه الشهادة بكل فخر لـ:', 
                  style: GoogleFonts.amiri(fontSize: 14, color: Colors.black54, fontStyle: FontStyle.italic)
                ),
                const SizedBox(height: 6),
                Text(_userName, 
                  textAlign: TextAlign.center,
                  style: GoogleFonts.amiri(fontSize: 30, fontWeight: FontWeight.bold, color: const Color(0xFFB71C1C))
                ),
                if (_jobTitle.isNotEmpty)
                  Text('($_jobTitle)', style: GoogleFonts.amiri(fontSize: 13, color: Colors.black45)),
                
                const SizedBox(height: 20),
                Text(_getCertificateTitle(), 
                  textAlign: TextAlign.center,
                  style: GoogleFonts.amiri(fontSize: 19, fontWeight: FontWeight.bold, color: const Color(0xFF1B5E20), decoration: TextDecoration.underline, decorationColor: const Color(0xFFC19A6B))
                ),
                const SizedBox(height: 12),
                
                Text(_getCertificateBody(), 
                  textAlign: TextAlign.center, 
                  style: GoogleFonts.amiri(fontSize: 15, height: 1.5, color: Colors.black87, fontWeight: FontWeight.w500)
                ),
                
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('تاريخ الصدور:', style: GoogleFonts.amiri(fontSize: 10, color: Colors.black45)),
                        Text(DateFormat('yyyy-MM-dd').format(DateTime.now()), 
                          style: GoogleFonts.notoSans(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text('الختم الرسمي', style: GoogleFonts.amiri(fontSize: 10, color: Colors.black45)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle, 
                            border: Border.all(color: const Color(0xFFC19A6B), width: 2),
                            color: Colors.white,
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 3)]
                          ),
                          child: const Icon(Icons.verified, color: Color(0xFF1B5E20), size: 32),
                        ),
                        const SizedBox(height: 2),
                        Text('مساعد الصلاة', style: GoogleFonts.amiri(fontSize: 9, color: const Color(0xFF1B5E20), fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(child: _buildButton(icon: Icons.download_done_rounded, label: 'حفظ الشهادة', onTap: () => _saveAndShare(false))),
        const SizedBox(width: 10),
        Expanded(child: _buildButton(icon: Icons.share_rounded, label: 'مشاركة الفرحة', onTap: () => _saveAndShare(true))),
        const SizedBox(width: 10),
        Expanded(child: _buildButton(icon: Icons.print_rounded, label: 'طباعة فورية', onTap: () {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('جاري تهيئة الطابعة اللاسلكية...')));
        })),
      ],
    );
  }

  Widget _buildButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12), 
          borderRadius: BorderRadius.circular(15), 
          border: Border.all(color: Colors.white.withOpacity(0.2)),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFFF5A623), size: 26),
            const SizedBox(height: 6),
            Text(label, style: GoogleFonts.amiri(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
