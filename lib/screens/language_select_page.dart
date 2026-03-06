import 'package:flutter/material.dart';

class LanguageSelectPage extends StatelessWidget {
  const LanguageSelectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'هذه صفحة البداية الأصلية',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
