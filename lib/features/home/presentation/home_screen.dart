import 'package:flutter/material.dart';
import '../../../core/services/local_storage_service.dart';
import '../../onboarding/presentation/language_screen.dart';
import '../../../models/service_model.dart'; // تأكد من المسار الصحيح

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, String> user = {};
  String lang = 'ar';
  String currentDate = '';
  String currentTime = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _updateTime();
  }

  Future<void> _loadUserData() async {
    final u = await LocalStorageService.getUserData();
    final l = await LocalStorageService.getLanguage();
    setState(() {
      user = u;
      lang = l;
    });
  }

  void _updateTime() {
    // تحديث الوقت كل ثانية
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        final now = DateTime.now();
        setState(() {
          currentDate = _formatDate(now);
          currentTime = _formatTime(now);
        });
        _updateTime();
      }
    });
  }

  String _formatDate(DateTime date) {
    // يمكن تخصيص الصيغة حسب اللغة
    return "${date.year}/${date.month}/${date.day}";
  }

  String _formatTime(DateTime date) {
    return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}";
  }

  // قائمة الخدمات
  List<ServiceModel> get services => [
        ServiceModel(
          title: 'ختم القرآن في الصلاة',
          description: 'برنامج مخصص لختم القرآن الكريم كاملاً خلال صلواتك المفروضة في شهر واحد.',
          icon: Icons.menu_book,
          color: Colors.green.shade100,
        ),
        ServiceModel(
          title: 'ختم القرآن بالقراءة',
          description: 'حدد وردك اليومي واقرأ المصحف الشريف مباشرة.',
          icon: Icons.auto_stories,
          color: Colors.blue.shade100,
        ),
        ServiceModel(
          title: 'حفظ القرآن الكريم',
          description: 'خطة منهجية لحفظ السور والآيات مع مراجعة دورية.',
          icon: Icons.school,
          color: Colors.orange.shade100,
        ),
        ServiceModel(
          title: 'التفسير والتدبر',
          description: 'تعلم معاني الآيات وتدبر كلام الله مع نخبة من المفسرين.',
          icon: Icons.lightbulb,
          color: Colors.purple.shade100,
        ),
        ServiceModel(
          title: 'الأذكار والأدعية',
          description: 'أذكار الصباح والمساء، وأدعية من الكتاب والسنة لكل حال.',
          icon: Icons.spa,
          color: Colors.teal.shade100,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final name = user['fullName']?.isNotEmpty == true ? user['fullName'] : 'أحمد بن محمد';
    final greeting = _getGreeting();

    return Scaffold(
      backgroundColor: const Color(0xFFF5FBF7),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: cs.primary,
        title: Text(
          'مساعد الصلاة',
          style: TextStyle(color: cs.primary, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: انتقل إلى شاشة الإعدادات
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // بطاقة الترحيب
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [cs.primary.withOpacity(0.2), cs.primary.withOpacity(0.05)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'السلام عليكم، $name',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      greeting,
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // قسم "موصى به"
              const Text(
                'موصى به',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'رحلة الختمة المباركة',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'رحلة 30 يوماً لختم القرآن في صلواتك، تقدمك محفوظ ومقسم بذكاء.',
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Icon(Icons.arrow_forward, color: cs.primary),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // عنوان الخدمات
              const Text(
                'الخدمات والبرامج',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // قائمة الخدمات (Grid)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.9,
                ),
                itemCount: services.length,
                itemBuilder: (context, index) {
                  final service = services[index];
                  return GestureDetector(
                    onTap: service.onTap,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: service.color,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(service.icon, size: 32, color: cs.primary),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                service.title,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                service.description,
                                style: const TextStyle(fontSize: 11),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'ابدأ الآن',
                                style: TextStyle(fontSize: 12, color: cs.primary),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // اقتباس سفلي
              Center(
                child: Text(
                  'اجعل صلاتك خاشعة متصلة بكلام الله، كل سجدة خطوة نحو الجنة.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'صباح الخير';
    if (hour < 17) return 'مساء الخير';
    return 'مساء النور';
  }
}