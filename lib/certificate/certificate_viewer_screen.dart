import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:projet_aaa_fixed/core/services/local_storage_service.dart';
import 'package:google_fonts/google_fonts.dart';

class CertificateViewerScreen extends StatefulWidget {
  final String certificateId;
  final String? surahName;

  const CertificateViewerScreen({
    super.key,
    required this.certificateId,
    this.surahName,
  });

  @override
  State<CertificateViewerScreen> createState() => _CertificateViewerScreenState();
}

class _CertificateViewerScreenState extends State<CertificateViewerScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();
  String _userName = 'طالب العلم';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final name = await LocalStorageService().getUserName();
    if (name != null && name.isNotEmpty) {
      if (mounted) {
        setState(() {
          _userName = name;
        });
      }
    }
  }

  Future<void> _shareCertificate() async {
    final directory = await getApplicationDocumentsDirectory();
    final String fileName = 'certificate_${widget.certificateId}.png';
    final String path = '${directory.path}/$fileName';

    await _screenshotController.captureAndSave(directory.path, fileName: fileName);

    await Share.shareXFiles([XFile(path)], text: 'الحمد لله، أتممت وردي في تطبيق أنيس!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('شهادة إتمام'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareCertificate,
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Screenshot(
                controller: _screenshotController,
                child: Container(
                  width: 350,
                  height: 500,
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFD4AF37), width: 10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.stars, color: Color(0xFFD4AF37), size: 80),
                      const SizedBox(height: 20),
                      Text(
                        'شهادة تقدير',
                        style: GoogleFonts.amiri(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2D5A27),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Text(
                        'نـشهد بـأن المستـخدم',
                        style: GoogleFonts.amiri(fontSize: 18),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _userName,
                        style: GoogleFonts.amiri(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        widget.surahName != null
                            ? 'قد أتم حفظ سورة ${widget.surahName} بنجاح'
                            : 'قد أتم الورد اليومي بنجاح',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.amiri(fontSize: 20),
                      ),
                      const SizedBox(height: 40),
                      const Divider(color: Color(0xFFD4AF37)),
                      const SizedBox(height: 10),
                      Text(
                        'تطبيق أنيس - رفيقك في دروب الطاعة',
                        style: GoogleFonts.amiri(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _shareCertificate,
                icon: const Icon(Icons.download),
                label: const Text('حفظ ومشاركة الشهادة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D5A27),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
