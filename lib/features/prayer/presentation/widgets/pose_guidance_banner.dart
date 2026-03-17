import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PoseGuidanceBanner extends StatelessWidget {
  final String message;
  final bool success;

  const PoseGuidanceBanner({
    super.key,
    required this.message,
    this.success = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: success ? Colors.green.withOpacity(0.12) : Colors.black38,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: success
              ? Colors.greenAccent.withOpacity(0.35)
              : Colors.white10,
        ),
      ),
      child: Row(
        children: [
          Icon(
            success ? Icons.check_circle_outline : Icons.center_focus_strong,
            color: success ? Colors.greenAccent : const Color(0xFFF5A623),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              textAlign: TextAlign.right,
              style: GoogleFonts.amiri(
                color: Colors.white70,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
