import 'package:flutter/material.dart';

class LandmarkStatusCard extends StatelessWidget {
  final bool noseVisible;
  final bool shouldersVisible;
  final bool hipsVisible;
  final bool kneesVisible;
  final bool anklesVisible;

  const LandmarkStatusCard({
    super.key,
    required this.noseVisible,
    required this.shouldersVisible,
    required this.hipsVisible,
    required this.kneesVisible,
    required this.anklesVisible,
  });

  Widget _item(String label, bool ok) {
    return Row(
      children: [
        Icon(
          ok ? Icons.check_circle : Icons.cancel,
          color: ok ? Colors.greenAccent : Colors.redAccent,
          size: 18,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.62),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF5A623),
          width: 1.0,
        ),
      ),
      child: Column(
        children: [
          const Text(
            'حالة النقاط الملتقطة',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          _item('الرأس / الأنف', noseVisible),
          const SizedBox(height: 6),
          _item('الكتفان', shouldersVisible),
          const SizedBox(height: 6),
          _item('الورك', hipsVisible),
          const SizedBox(height: 6),
          _item('الركبتان', kneesVisible),
          const SizedBox(height: 6),
          _item('الكاحلان', anklesVisible),
        ],
      ),
    );
  }
}