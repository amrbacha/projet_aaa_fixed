import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

Future<void> validateQuranJson() async {
  try {
    print('Loading asset...');
    final s = await rootBundle.loadString('assets/quran/quran.json');
    print('Loaded. length=${s.length}');

    final obj = jsonDecode(s);
    final surates = obj['surates'] as List;

    print('OK ✅ meta=${obj["meta"] != null}, surates=${surates.length}');
  } catch (e, st) {
    print('JSON/ASSET ERROR ❌: $e');
    print(st);
  }
}