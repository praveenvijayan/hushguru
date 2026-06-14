import 'package:speech_to_text/speech_to_text.dart';

class VoiceService {
  final SpeechToText _speech = SpeechToText();
  bool _initialized = false;

  Future<bool> initialize() async {
    if (!_initialized) {
      _initialized = await _speech.initialize(
        onError: (_) {},
        onStatus: (_) {},
      );
    }
    return _initialized;
  }

  Future<void> startListening({required void Function(String) onResult}) async {
    if (!_initialized) {
      final ok = await initialize();
      if (!ok) return;
    }
    await _speech.listen(
      onResult: (result) => onResult(result.recognizedWords),
      listenOptions: SpeechListenOptions(
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> stopListening() async {
    await _speech.stop();
  }
}
