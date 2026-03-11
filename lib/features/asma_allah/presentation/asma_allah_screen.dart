import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:projet_aaa_fixed/widgets/islamic_background.dart';
import 'package:projet_aaa_fixed/core/services/assistant_service.dart';
import '../data/models/asma_model.dart';
import '../data/asma_data.dart';

class AsmaAllahScreen extends StatelessWidget {
  const AsmaAllahScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final asmaList = rawAsmaAllah.map((e) => AsmaAllah.fromJson(e)).toList();
    final AssistantService anis = AssistantService();

    return IslamicBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.black45,
          elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white70), onPressed: () => context.pop()),
          title: Text('أسماء الله الحسنى', style: GoogleFonts.amiri(color: const Color(0xFFF5A623), fontWeight: FontWeight.bold, fontSize: 24)),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.emoji_events_outlined, color: Color(0xFFF5A623)),
              onPressed: () => context.push('/asma-quiz'),
            ),
          ],
        ),
        body: Column(
          children: [
            _buildNameOfTheDay(context, asmaList[0], anis),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('القائمة الكاملة', style: GoogleFonts.amiri(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  _buildQuizButton(context),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 1.1,
                ),
                itemCount: asmaList.length,
                itemBuilder: (context, index) {
                  final asma = asmaList[index];
                  return _buildAsmaCard(context, asma, anis);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizButton(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/asma-quiz'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(color: const Color(0xFFF5A623).withOpacity(0.15), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFF5A623).withOpacity(0.5))),
        child: Row(
          children: [
            const Icon(Icons.psychology, color: Color(0xFFF5A623), size: 18),
            const SizedBox(width: 8),
            Text('ابدأ التحدي', style: GoogleFonts.amiri(color: const Color(0xFFF5A623), fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildNameOfTheDay(BuildContext context, AsmaAllah asma, AssistantService anis) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFF5A623).withOpacity(0.4)),
        boxShadow: [BoxShadow(color: const Color(0xFFF5A623).withOpacity(0.1), blurRadius: 20, spreadRadius: 5)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('اسم اليوم التدبري', style: GoogleFonts.amiri(color: const Color(0xFFF5A623), fontSize: 14)),
                  const SizedBox(height: 5),
                  Text(asma.name, style: GoogleFonts.amiri(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.volume_up, color: Color(0xFFF5A623), size: 30),
                onPressed: () => anis.speak("${asma.name}. ${asma.meaning}"),
              ),
            ],
          ),
          const Divider(color: Colors.white10, height: 30),
          Text(asma.meaning, textAlign: TextAlign.center, style: GoogleFonts.amiri(color: Colors.white70, fontSize: 16, height: 1.5)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF5A623),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: () => context.push('/asma-detail', extra: asma),
              icon: const Icon(Icons.auto_awesome, color: Colors.black, size: 20),
              label: Text('تدبر وفهم عميق', style: GoogleFonts.amiri(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAsmaCard(BuildContext context, AsmaAllah asma, AssistantService anis) {
    return InkWell(
      onTap: () => context.push('/asma-detail', extra: asma),
      onLongPress: () => anis.speak(asma.name),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black45,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(top: 5, right: 5, child: Icon(Icons.star, color: Colors.white.withOpacity(0.05), size: 15)),
            Text(
              asma.name,
              textAlign: TextAlign.center,
              style: GoogleFonts.amiri(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                shadows: [const Shadow(color: Colors.black45, blurRadius: 5)],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
