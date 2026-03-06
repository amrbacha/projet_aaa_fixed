import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:projet_aaa/widgets/islamic_background.dart';
import '../data/models/asma_model.dart';
import '../data/asma_data.dart';

class AsmaAllahScreen extends StatelessWidget {
  const AsmaAllahScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final asmaList = rawAsmaAllah.map((e) => AsmaAllah.fromJson(e)).toList();

    return IslamicBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('أسماء الله الحسنى',
              style: GoogleFonts.amiri(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24)),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
            onPressed: () => context.pop(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.workspace_premium, color: Color(0xFFF5A623)),
              onPressed: () => context.push('/asma-quiz'),
            ),
          ],
        ),
        body: Column(
          children: [
            _buildNameOfTheDay(context, asmaList[0]),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('القائمة الكاملة', style: GoogleFonts.amiri(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton.icon(
                    icon: const Icon(Icons.play_circle_outline, color: Color(0xFFF5A623), size: 20),
                    onPressed: () => context.push('/asma-quiz'),
                    label: Text('ابدأ التحدي', style: GoogleFonts.amiri(color: const Color(0xFFF5A623))),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.0,
                ),
                itemCount: asmaList.length,
                itemBuilder: (context, index) {
                  final asma = asmaList[index];
                  return _buildAsmaCard(context, asma);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNameOfTheDay(BuildContext context, AsmaAllah asma) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFFC19A6B).withOpacity(0.3), Colors.transparent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: const Color(0xFFC19A6B).withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('اسم اليوم التدبري',
                    style: GoogleFonts.amiri(
                        color: const Color(0xFFF5A623),
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(asma.name,
                    style: GoogleFonts.amiri(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(asma.meaning,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.amiri(
                        color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF5A623),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
            ),
            onPressed: () => context.push('/asma-detail', extra: asma),
            child: Text('تدبر الآن',
                style: GoogleFonts.amiri(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildAsmaCard(BuildContext context, AsmaAllah asma) {
    return InkWell(
      onTap: () => context.push('/asma-detail', extra: asma),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Center(
          child: Text(
            asma.name,
            textAlign: TextAlign.center,
            style: GoogleFonts.amiri(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
