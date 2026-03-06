class ServiceModel {
  final String title;
  final String description;
  final String imagePath; // يمكن استخدام IconData بدلاً من ذلك
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  ServiceModel({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.onTap,
  });
}