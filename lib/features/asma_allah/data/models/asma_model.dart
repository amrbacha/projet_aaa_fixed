class AsmaAllah {
  final int id;
  final String name;
  final String meaning;
  final String evidence; // الدليل من القرآن أو السنة
  final String supplication; // دعاء بهذا الاسم
  final String reflection; // لفتة تدبرية

  AsmaAllah({
    required this.id,
    required this.name,
    required this.meaning,
    required this.evidence,
    required this.supplication,
    required this.reflection,
  });

  factory AsmaAllah.fromJson(Map<String, dynamic> json) => AsmaAllah(
        id: json['id'],
        name: json['name'],
        meaning: json['meaning'],
        evidence: json['evidence'],
        supplication: json['supplication'],
        reflection: json['reflection'],
      );
}
