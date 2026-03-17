import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  final String title;
  final String message;
  final double score;

  const InfoCard({
    super.key,
    required this.title,
    required this.message,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (score * 100).round();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.62),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFF5A623),
          width: 1.2,
        ),
      ),
      child: Column(
        children: [
          Text(
            'حالة المطابقة: $title',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: score.clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFFF5A623),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'جودة المطابقة: $percent%',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }
}