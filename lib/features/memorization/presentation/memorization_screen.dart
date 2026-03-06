import 'package:flutter/material.dart';
import 'package:projet_aaa/core/data/surah_names.dart';
import 'package:projet_aaa/widgets/islamic_background.dart';

class MemorizationScreen extends StatelessWidget {
  const MemorizationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return IslamicBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('حفظ القرآن الكريم', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: ListView.builder(
          itemCount: surahNames.length,
          itemBuilder: (context, index) {
            return Card(
              color: Colors.white.withOpacity(0.1),
              margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
              child: ListTile(
                title: Text(
                  surahNames[index],
                  style: const TextStyle(color: Colors.white),
                ),
                leading: CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                onTap: () {
                  // TODO: Navigate to the memorization detail screen for this Surah
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
