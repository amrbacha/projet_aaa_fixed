import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:projet_aaa_fixed/core/services/settings_service.dart';
import 'package:projet_aaa_fixed/models/settings_model.dart';

class AudioProvider with ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterTts _tts = FlutterTts();
  
  String _selectedQari = 'mishary';
  double _playbackRate = 1.0;
  bool _isSpeaking = false;

  String get selectedQari => _selectedQari;
  double get playbackRate => _playbackRate;

  AudioProvider() {
    _initAudio();
    _initTts();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage("ar-SA");
    await _tts.setSpeechRate(0.35); // سرعة وقورة هادئة
    await _tts.setPitch(0.85);

    _tts.setCompletionHandler(() {
      _isSpeaking = false;
    });
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
        options: {
          AVAudioSessionOptions.mixWithOthers,
          AVAudioSessionOptions.defaultToSpeaker,
        },
      ),
    ));

    final settings = await SettingsService.loadSettings();
    _selectedQari = settings.qari;
    notifyListeners();
  }

  /// تغيير القارئ وحفظ الإعدادات (مطلوبة لشاشات الإعدادات)
  Future<void> setQari(String qari) async {
    _selectedQari = qari;
    final currentSettings = await SettingsService.loadSettings();
    final newSettings = currentSettings.copyWith(qari: qari);
    await SettingsService.saveSettings(newSettings);
    notifyListeners();
  }

  /// تغيير سرعة التشغيل (مطلوبة لشاشة القراءة)
  Future<void> setPlaybackRate(double rate) async {
    _playbackRate = rate;
    await _audioPlayer.setPlaybackRate(rate);
    // سرعة الإمام TTS تظل هادئة ووقورة ولكن تتأثر قليلاً بنسبة مئوية
    await _tts.setSpeechRate((rate * 0.35).clamp(0.2, 0.5)); 
    notifyListeners();
  }

  /// دالة ذكية للانتظار حتى انتهاء الكلام تماماً (تستخدم في الصلاة)
  Future<void> speakActionAndWait(String text) async {
    await _audioPlayer.stop();
    await _tts.stop();
    
    Completer completer = Completer();
    _tts.setCompletionHandler(() {
      _isSpeaking = false;
      if (!completer.isCompleted) completer.complete();
    });

    _isSpeaking = true;
    await _tts.speak(text);
    
    return completer.future.timeout(const Duration(seconds: 15), onTimeout: () {
      if (!completer.isCompleted) completer.complete();
    });
  }

  Future<void> playVerse(int surahNumber, int ayahNumber) async {
    String s = surahNumber.toString().padLeft(3, '0');
    String a = ayahNumber.toString().padLeft(3, '0');
    
    final Map<String, String> qariMap = {
      'mishary': 'Alafasy_128kbps',
      'sudais': 'Abdurrahmaan_As-Sudais_192kbps',
      'husary': 'Husary_128kbps',
      'minshawi': 'Minshawy_Murattal_128kbps',
      'ghamdi': 'Ghamadi_40kbps',
      'basit': 'Abdul_Basit_Murattal_192kbps',
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

  Stream<void> get onPlayerComplete => _audioPlayer.onPlayerComplete;

  Future<void> stop() async {
    await _audioPlayer.stop();
    await _tts.stop();
  }

  // إضافة معالج الإكمال لـ TTS لضمان عدم حدوث تعارض في الشاشات الأخرى
  void setTtsCompletionHandler(VoidCallback callback) {
    _tts.setCompletionHandler(callback);
  }
}
