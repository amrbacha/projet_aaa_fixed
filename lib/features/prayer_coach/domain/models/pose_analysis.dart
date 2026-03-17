class PoseAnalysis {
  final String title;
  final String message;
  final double score;
  final bool noseVisible;
  final bool shouldersVisible;
  final bool hipsVisible;
  final bool kneesVisible;
  final bool anklesVisible;

  const PoseAnalysis({
    required this.title,
    required this.message,
    required this.score,
    required this.noseVisible,
    required this.shouldersVisible,
    required this.hipsVisible,
    required this.kneesVisible,
    required this.anklesVisible,
  });
}