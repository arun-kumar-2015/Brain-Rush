import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

/// SpeechRecognitionService – simple wrapper around speech_to_text package.
/// Provides init, start listening, stop, and result callbacks. Stores last result.
class SpeechRecognitionService {
  static final SpeechRecognitionService _instance = SpeechRecognitionService._internal();
  factory SpeechRecognitionService() => _instance;
  SpeechRecognitionService._internal();

  final SpeechToText _stt = SpeechToText();
  bool _available = false;
  String _lastWords = '';
  void Function(String)? _onResult;

  bool get isAvailable => _available;
  bool get isListening => _stt.isListening;

  /// Initialize the plugin – must be called before any listening.
  Future<bool> init() async {
    _available = await _stt.initialize(
      onStatus: (status) {},
      onError: (msg) {},
    );
    return _available;
  }

  /// Start listening for speech. Returns true if listening started.
  Future<bool> startListening({
    void Function(String)? onResult,
    bool partialResults = true,
  }) async {
    if (!_available) await init();
    if (!_available) return false;
    _onResult = onResult;

    // Stop any existing session before starting a new one
    if (_stt.isListening) {
      await _stt.stop();
      await Future.delayed(const Duration(milliseconds: 200));
    }

    return await _stt.listen(
      onResult: (SpeechRecognitionResult result) {
        _lastWords = result.recognizedWords;
        if (_onResult != null) _onResult!(_lastWords);
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      partialResults: partialResults,
      localeId: 'en_US',
      onSoundLevelChange: (_) {},
    );
  }

  /// Stop listening.
  Future<void> stopListening() async {
    await _stt.stop();
  }

  /// Get the last recognized words.
  String get lastWords => _lastWords;

  /// Dispose resources.
  void dispose() {
    _stt.stop();
  }
}
