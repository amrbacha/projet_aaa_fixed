class AthkarCategory {
  final String id;
  final String title;
  final String icon;
  final int order;

  AthkarCategory({
    required this.id,
    required this.title,
    required this.icon,
    this.order = 0,
  });

  factory AthkarCategory.fromJson(Map<String, dynamic> json) => AthkarCategory(
        id: json['id'],
        title: json['title'],
        icon: json['icon'],
        order: json['order'] ?? 0,
      );
}

class AthkarItem {
  final String id;
  final String categoryId;
  final String text;
  final int repeat;
  final String? reference;
  final String? benefit;

  AthkarItem({
    required this.id,
    required this.categoryId,
    required this.text,
    this.repeat = 1,
    this.reference,
    this.benefit,
  });

  factory AthkarItem.fromJson(Map<String, dynamic> json) => AthkarItem(
        id: json['id'],
        categoryId: json['categoryId'],
        text: json['text'],
        repeat: json['repeat'] ?? 1,
        reference: json['reference'],
        benefit: json['benefit'],
      );
}
