import 'dart:convert';
import 'package:http/http.dart' as http;

class TafseerService {
  static final TafseerService _instance = TafseerService._internal();
  factory TafseerService() => _instance;
  TafseerService._internal();

  final Map<String, Map<String, dynamic>> _cache = {};

  /// جلب التفسير الميسر (باللغة العربية حصراً لضمان الدقة)
  Future<Map<String, dynamic>> getTafseer(int surah, int ayah) async {
    final key = '$surah:$ayah';
    if (_cache.containsKey(key)) return _cache[key]!;

    try {
      // استخدام معرف التفسير الميسر (16) أو التفسير الوسيط لضمان العربية
      final response = await http.get(
        Uri.parse('https://api.quran.com/api/v4/tafsirs/16/by_ayah/$surah:$ayah'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final tafseerText = data['tafsir']['text']
            .replaceAll(RegExp(r'<[^>]*>|&nbsp;'), '') 
            .trim();
        
        final result = {
          'text': tafseerText,
          'source': 'التفسير الميسر - مجمع الملك فهد لطباعة المصحف الشريف',
          'guidance': await _getRealGuidance(surah, ayah),
        };
        
        _cache[key] = result;
        return result;
      }
    } catch (e) {
      return _getFallbackTafseer(surah, ayah);
    }
    return _getFallbackTafseer(surah, ayah);
  }

  /// جلب الهدايات الحقيقية المرتبطة بالآية من مصدر موثوق
  Future<String> _getRealGuidance(int surah, int ayah) async {
    // محاولة جلب "المختصر في التفسير" الذي يحتوي على هدايات الآيات
    try {
      final response = await http.get(
        Uri.parse('https://api.quran.com/api/v4/tafsirs/171/by_ayah/$surah:$ayah'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String fullText = data['tafsir']['text'];
        // استخلاص جزء الهدايات عادة ما يبدأ بكلمة "من فوائد الآيات"
        if (fullText.contains("من فوائد")) {
          return fullText.substring(fullText.indexOf("من فوائد")).replaceAll(RegExp(r'<[^>]*>'), '').trim();
        }
        return fullText.replaceAll(RegExp(r'<[^>]*>'), '').trim();
      }
    } catch (_) {}
    
    return "تأمل في أوامر الله ونواهيه في هذه الآية، واحرص على تطبيقها في حياتك اليومية.";
  }

  Map<String, dynamic> _getFallbackTafseer(int surah, int ayah) {
    return {
      'text': "يرجى الاتصال بالإنترنت لجلب التفسير الميسر المعتمد بالعربية.",
      'source': 'تنبيه شرعي',
      'guidance': 'التدبر يقتضي فهم المعنى من مصادره الموثوقة.'
    };
  }
}
