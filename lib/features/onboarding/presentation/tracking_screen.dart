import 'package:flutter/material.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../core/services/prayer_times_service.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  DateTime now = DateTime.now();
  Map<String, String> user = {};

  // بيانات مؤقتة للقرآن
  final int totalQuranPages = 604;
  int pagesReadToday = 0;
  int targetPagesPerDay = 20;
  int currentPage = 1;

  // أوقات الصلاة (مثال)
  Map<String, String> prayerTimes = {};
  bool isLoadingPrayerTimes = true;

  @override
  void initState() {
    super.initState();
    _initializeProgress();
    _loadUserData();
    _updateTime();
    _fetchPrayerTimes(); // استدعاء جديد
  }

  Future<void> _loadUserData() async {
    final u = await LocalStorageService.getUserData();
    if (mounted) {
      setState(() {
        user = u;
      });
    }
  }

  void _initializeProgress() {
    // Here you would load progress, for now it's just initialized with default values
  }

  Future<void> _fetchPrayerTimes() async {
    final position = await PrayerTimesService.getCurrentLocation();
    if (position != null) {
      final times = await PrayerTimesService.fetchPrayerTimes(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      if (times != null && mounted) {
        setState(() {
          prayerTimes = times;
          isLoadingPrayerTimes = false;
        });
        return;
      }
    }
    // إذا فشل الجلب، استخدم القيم الافتراضية
    if (mounted) {
      setState(() {
        prayerTimes = {
          'الفجر': '05:34',
          'الظهر': '12:35',
          'العصر': '15:52',
          'المغرب': '18:19',
          'العشاء': '19:49',
        };
        isLoadingPrayerTimes = false;
      });
    }
  }

  void _updateTime() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          now = DateTime.now();
        });
        _updateTime();
      }
    });
  }

  String get nextPrayer {
    // منطق مبسط: نعتبر الفجر هو التالي إذا كان الوقت قبل الفجر
    // يمكن تحسينه لاحقاً
    return 'الفجر';
  }

  String get nextPrayerTime {
    return prayerTimes[nextPrayer] ?? '05:34';
  }

  double get progressPercentage {
    if (targetPagesPerDay == 0) return 0;
    return pagesReadToday / targetPagesPerDay;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/islamic_decoration_9.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: colorScheme.primary,
          title: const Text(
            'مساعد الصلاة',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                // TODO: الانتقال إلى شاشة الإعدادات
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await LocalStorageService.logout();
                if (!context.mounted) return;
                Navigator.of(context).pushReplacementNamed('/language');
              },
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // اسم المستخدم
                Text(
                  'مرحباً، ${user['fullName'] ?? 'مستخدم'}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),

                // الوقت والتاريخ
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${now.year}/${now.month}/${now.day}',
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // الصلاة القادمة
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'الصلاة القادمة',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                          Text(
                            nextPrayerTime,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        nextPrayer,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // تقدم الختمة
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('تقدم الختمة', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('${(progressPercentage * 100).toInt()}%'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: progressPercentage,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('صفحة $pagesReadToday / $targetPagesPerDay لليوم'),
                          Text('إجمالي الختمة: $totalQuranPages'),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'وصلت إلى صفحة $currentPage من $targetPagesPerDay',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // مواقيت الصلاة
                const Text('مواقيت الصلاة', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Expanded(
                  child: isLoadingPrayerTimes
                      ? const Center(child: CircularProgressIndicator())
                      : GridView.count(
                          crossAxisCount: 3,
                          childAspectRatio: 1.5,
                          children: prayerTimes.entries.map((entry) {
                            return Container(
                              margin: const EdgeInsets.all(4),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.85),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Text(entry.value, style: const TextStyle(fontSize: 16)),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                ),
                const SizedBox(height: 10),

                // زر بدء الورد
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: الانتقال إلى شاشة الصلاة
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('سيتم الانتقال إلى شاشة الصلاة قريباً')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text('ابدأ وردك الآن'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}