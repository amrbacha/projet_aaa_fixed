import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/local_storage_service.dart';
import '../../../models/service_model.dart';

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
    if (!mounted) return;
    setState(() {
      user = u;
      lang = l;
    });
  }

  void _updateTime() {
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
    return "${date.year}/${date.month}/${date.day}";
  }

  String _formatTime(DateTime date) {
    return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}";
  }

  List<ServiceModel> services(BuildContext context) => [
        ServiceModel(
          title: 'ختم القرآن في الصلاة',
          description: 'برنامج مخصص لختم القرآن الكريم كاملاً خلال صلواتك المفروضة في شهر واحد.',
          icon: Icons.menu_book,
          color: Colors.green.shade100,
          onTap: () => context.push('/home'),
        ),
        ServiceModel(
          title: 'ختم القرآن بالقراءة',
          description: 'حدد وردك اليومي واقرأ المصحف الشريف مباشرة.',
          icon: Icons.auto_stories,
          color: Colors.blue.shade100,
          onTap: () => context.push('/reading'),
        ),
        ServiceModel(
          title: 'حفظ القرآن الكريم',
          description: 'خطة منهجية لحفظ السور والآيات مع مراجعة دورية.',
          icon: Icons.school,
          color: Colors.orange.shade100,
          onTap: () => context.push('/memorization'),
        ),
        ServiceModel(
          title: 'التفسير والتدبر',
          description: 'تعلم معاني الآيات وتدبر كلام الله مع نخبة من المفسرين.',
          icon: Icons.lightbulb,
          color: Colors.purple.shade100,
          onTap: () => context.push('/tafseer'),
        ),
        ServiceModel(
          title: 'الأذكار والأدعية',
          description: 'أذكار الصباح والمساء، وأدعية من الكتاب والسنة لكل حال.',
          icon: Icons.spa,
          color: Colors.teal.shade100,
          onTap: () => context.push('/adhkar'),
        ),
        ServiceModel(
          title: 'أتعلم صلاتي',
          description: 'تعليم شامل للوضوء ومبادئ الصلاة وخطواتها، مناسب للمبتدئ والطفل.',
          icon: Icons.self_improvement_rounded,
          color: const Color(0xFFFFE4B8),
          onTap: () => context.push('/prayer-learning'),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final name = user['fullName']?.isNotEmpty == true ? user['fullName'] : 'أحمد بن محمد';
    final greeting = _getGreeting();
    final serviceItems = services(context);

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
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                    const SizedBox(height: 8),
                    Text(
                      '$currentDate  •  $currentTime',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'موصى به',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () => context.push('/prayer-learning'),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cs.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFF5A623).withOpacity(0.35)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'أتعلم صلاتي',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'صفحة تعليمية جديدة تضم الوضوء ومبادئ الصلاة وتعليمها خطوة بخطوة للكبار والأطفال.',
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
              ),
              const SizedBox(height: 20),
              const Text(
                'الخدمات والبرامج',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.9,
                ),
                itemCount: serviceItems.length,
                itemBuilder: (context, index) {
                  final service = serviceItems[index];
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
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: TextButton(
                              onPressed: service.onTap,
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
              Center(
                child: Text(
                  'اجعل صلاتك خاشعة متصلة بكلام الله، وكل خطوة في التعلم تقربك أكثر من الإتقان.',
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
