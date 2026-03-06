class QuranProgress {
  final int totalPages;          // إجمالي صفحات المصحف (ثابت = 604)
  final int pagesReadToday;      // الصفحات المقروءة اليوم
  final int targetPagesPerDay;   // الصفحات المستهدفة لليوم (يتم حسابها بناءً على مدة الختمة)
  final int currentPage;         // آخر صفحة تمت قراءتها (للعرض)
  final DateTime lastUpdate;     // تاريخ آخر تحديث

  QuranProgress({
    required this.totalPages,
    required this.pagesReadToday,
    required this.targetPagesPerDay,
    required this.currentPage,
    required this.lastUpdate,
  });

  // دالة لحساب النسبة المئوية للتقدم اليومي
  double get progressPercentage {
    if (targetPagesPerDay == 0) return 0;
    return pagesReadToday / targetPagesPerDay;
  }

  // يمكن إضافة دوال أخرى مثل إعادة تعيين التقدم في بداية يوم جديد
}