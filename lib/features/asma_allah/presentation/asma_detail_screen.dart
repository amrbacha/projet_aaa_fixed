import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:projet_aaa_fixed/widgets/islamic_background.dart';
import '../data/models/asma_model.dart';

class AsmaDetailScreen extends StatelessWidget {
  final AsmaAllah asma;
  const AsmaDetailScreen({super.key, required this.asma});

  @override
  Widget build(BuildContext context) {
    return IslamicBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(asma.name,
              style: GoogleFonts.amiri(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 28)),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
            onPressed: () => context.pop(),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              _buildBigNameCard(),
              const SizedBox(height: 24),
              _buildInfoSection('المعنى والدلالة', asma.meaning, Icons.info_outline),
              const SizedBox(height: 16),
              _buildInfoSection('الدليل الشرعي', asma.evidence, Icons.menu_book),
              const SizedBox(height: 16),
              _buildInfoSection('لفتة تدبرية', asma.reflection, Icons.lightbulb_outline),
              const SizedBox(height: 16),
              _buildSupplicationSection(asma.supplication),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBigNameCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFC19A6B).withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFC19A6B).withOpacity(0.1),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Center(
        child: Text(
          asma.name,
          style: GoogleFonts.amiri(
            color: Colors.white,
            fontSize: 64,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, String content, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFF5A623), size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.amiri(
                        color: const Color(0xFFF5A623),
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(content,
                    style: GoogleFonts.amiri(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                        height: 1.6)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupplicationSection(String supplication) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF1ABC9C).withOpacity(0.2), Colors.transparent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1ABC9C).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.volunteer_activism_outlined, color: Color(0xFF1ABC9C)),
              const SizedBox(width: 12),
              Text('دعاء مأثور',
                  style: GoogleFonts.amiri(
                      color: const Color(0xFF1ABC9C),
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Text(supplication,
              textAlign: TextAlign.center,
              style: GoogleFonts.amiri(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  height: 1.5)),
        ],
      ),
    );
  }
}
