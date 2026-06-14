import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _tts = FlutterTts();

  Future<void> init() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(0.9);
    await _tts.setPitch(0.9);
  }

  Future<void> speak(String text) => _tts.speak(text);

  Future<void> stop() => _tts.stop();
}
