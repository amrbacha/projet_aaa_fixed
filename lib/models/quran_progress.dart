class QuranProgress {
  final int totalPages;
  final int pagesReadToday;
  final int targetPagesPerDay;
  final int currentPage;
  final DateTime lastUpdate;

  QuranProgress({
    required this.totalPages,
    required this.pagesReadToday,
    required this.targetPagesPerDay,
    required this.currentPage,
    required this.lastUpdate,
  });

  double get progressPercentage {
    if (targetPagesPerDay == 0) return 0;
    return pagesReadToday / targetPagesPerDay;
  }
}