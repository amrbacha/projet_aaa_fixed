import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:projet_aaa/core/services/settings_service.dart';
import 'package:projet_aaa/models/settings_model.dart';

class AudioProvider with ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterTts _tts = FlutterTts();
  
  String _selectedQari = 'mishary';
  double _playbackRate = 1.0;

  String get selectedQari => _selectedQari;
  double get playbackRate => _playbackRate;

  AudioProvider() {
    _initAudio();
    _initTts();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage("ar-SA");
    
    // سرعة وقورة جداً للإمام (أبطأ لتكون كالصلاة)
    await _tts.setSpeechRate(0.3); 
    
    // ضبط النبرة لتكون غليظة وذكورية (0.7 إلى 0.8)
    await _tts.setPitch(0.8);

    try {
      List<dynamic> voices = await _tts.getVoices;
      for (var voice in voices) {
        String name = voice["name"].toString().toLowerCase();
        String locale = voice["locale"].toString().toLowerCase();
        
        // البحث عن أفضل صوت ذكر عربي (خاصة أصوات جوجل الاحترافية)
        if (locale.contains("ar") && 
           (name.contains("male") || name.contains("low") || name.contains("sha") || name.contains("fallback"))) {
          await _tts.setVoice({"name": voice["name"], "locale": voice["locale"]});
          debugPrint("Imam Voice Selected: ${voice["name"]}");
          break;
        }
      }
    } catch (e) {
      debugPrint("TTS Voice Selection Error: $e");
    }
  }

  Future<void> _initAudio() async {
    await AudioPlayer.global.setAudioContext(AudioContext(
      android: const AudioContextAndroid(
        isSpeakerphoneOn: true,
        contentType: AndroidContentType.music,
        usageType: AndroidUsageType.media,
        audioFocus: AndroidAudioFocus.gain,
      ),
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.playback,
        options: const {
          AVAudioSessionOptions.mixWithOthers,
          AVAudioSessionOptions.defaultToSpeaker,
        },
      ),
    ));

    final settings = await SettingsService.loadSettings();
    _selectedQari = settings.qari;
    notifyListeners();
  }

  Future<void> setQari(String qari) async {
    _selectedQari = qari;
    final currentSettings = await SettingsService.loadSettings();
    final newSettings = currentSettings.copyWith(qari: qari);
    await SettingsService.saveSettings(newSettings);
    notifyListeners();
  }

  Future<void> setPlaybackRate(double rate) async {
    _playbackRate = rate;
    await _audioPlayer.setPlaybackRate(rate);
    // سرعة الإمام TTS تظل هادئة ووقورة
    await _tts.setSpeechRate((rate * 0.3).clamp(0.2, 0.4)); 
    notifyListeners();
  }

  Stream<void> get onPlayerComplete => _audioPlayer.onPlayerComplete;

  Future<void> playVerse(int surahNumber, int ayahNumber) async {
    String s = surahNumber.toString().padLeft(3, '0');
    String a = ayahNumber.toString().padLeft(3, '0');
    
    final Map<String, String> qariMap = {
      'mishary': 'Alafasy_128kbps',
      'sudais': 'Abdurrahmaan_As-Sudais_192kbps',
      'ghamdi': 'Ghamadi_40kbps',
      'basit': 'Abdul_Basit_Murattal_192kbps',
      'husary': 'Husary_128kbps',
      'minshawi': 'Minshawy_Murattal_128kbps',
      'muaiqly': 'Maher_AlMuaiqly_64kbps',
      'tablawi': 'Mohammad_al_Tablaway_128kbps',
      'shuraim': 'Saood_ash-Shuraym_128kbps',
    };

    String qariPath = qariMap[_selectedQari] ?? 'Alafasy_128kbps';
    String url = "https://everyayah.com/data/$qariPath/$s$a.mp3";

    await _audioPlayer.stop();
    await _tts.stop();
    await _audioPlayer.play(UrlSource(url));
    await _audioPlayer.setPlaybackRate(_playbackRate);
  }

  Future<void> speakAction(String text) async {
    await _audioPlayer.stop();
    await _tts.stop();
    await _tts.speak(text);
  }

  void setTtsCompletionHandler(VoidCallback callback) {
    _tts.setCompletionHandler(callback);
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
    await _tts.stop();
  }
}
