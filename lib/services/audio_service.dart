import 'dart:io';
import 'package:flutter_tts/flutter_tts.dart';

/// AudioService — singleton TTS wrapper for BrainRush.
/// Handles letter pronunciation, phonics sounds, word reading,
/// and story read-aloud with configurable speed.
class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;
  double _speechRate = 0.45; // slightly slower for children

  // ── Phonics descriptions for all 26 letters ──────────────────────────────
  static const Map<String, String> phonicsDescriptions = {
    'A': 'The letter A. Phonics sound: ah. As in Apple.',
    'B': 'The letter B. Phonics sound: buh. As in Ball.',
    'C': 'The letter C. Phonics sound: kuh. As in Cat.',
    'D': 'The letter D. Phonics sound: duh. As in Dog.',
    'E': 'The letter E. Phonics sound: eh. As in Elephant.',
    'F': 'The letter F. Phonics sound: fff. As in Fish.',
    'G': 'The letter G. Phonics sound: guh. As in Grapes.',
    'H': 'The letter H. Phonics sound: huh. As in Hat.',
    'I': 'The letter I. Phonics sound: ih. As in Igloo.',
    'J': 'The letter J. Phonics sound: juh. As in Jug.',
    'K': 'The letter K. Phonics sound: kuh. As in Kite.',
    'L': 'The letter L. Phonics sound: lll. As in Lion.',
    'M': 'The letter M. Phonics sound: mmm. As in Monkey.',
    'N': 'The letter N. Phonics sound: nnn. As in Nest.',
    'O': 'The letter O. Phonics sound: oh. As in Orange.',
    'P': 'The letter P. Phonics sound: puh. As in Parrot.',
    'Q': 'The letter Q. Phonics sound: kwuh. As in Queen.',
    'R': 'The letter R. Phonics sound: rrr. As in Rabbit.',
    'S': 'The letter S. Phonics sound: sss. As in Sun.',
    'T': 'The letter T. Phonics sound: tuh. As in Tiger.',
    'U': 'The letter U. Phonics sound: uh. As in Umbrella.',
    'V': 'The letter V. Phonics sound: vvv. As in Violin.',
    'W': 'The letter W. Phonics sound: wuh. As in Whale.',
    'X': 'The letter X. Phonics sound: ex. As in X-ray.',
    'Y': 'The letter Y. Phonics sound: yuh. As in Yak.',
    'Z': 'The letter Z. Phonics sound: zzz. As in Zebra.',
  };

  Future<void> _ensureInit() async {
    if (_initialized) return;
    try {
      await _tts.setLanguage('en-US');
    } catch (e) {
      print('TTS setLanguage error: $e');
    }
    try {
      await _tts.setPitch(1.1); // slightly higher for child-friendly voice
    } catch (e) {
      print('TTS setPitch error: $e');
    }
    try {
      await _tts.setSpeechRate(_speechRate);
    } catch (e) {
      print('TTS setSpeechRate error: $e');
    }
    try {
      await _tts.setVolume(1.0);
    } catch (e) {
      print('TTS setVolume error: $e');
    }
    try {
      if (Platform.isAndroid) {
        await _tts.setQueueMode(1); // flush + speak
      }
    } catch (e) {
      print('TTS setQueueMode error: $e');
    }
    _initialized = true;
  }

  /// Speak any arbitrary text.
  Future<void> speak(String text) async {
    await _ensureInit();
    await _tts.stop();
    await _tts.speak(text);
  }

  /// Pronounce a single alphabet letter clearly.
  Future<void> speakLetter(String letter) async {
    await speak('The letter $letter');
  }

  /// Read the phonics description for a letter.
  Future<void> speakPhonics(String letter) async {
    final desc = phonicsDescriptions[letter.toUpperCase()] ??
        'Phonics for $letter';
    await speak(desc);
  }

  /// Pronounce a word clearly for the child.
  Future<void> speakWord(String word) async {
    await speak(word);
  }

  /// Read an entire sentence aloud.
  Future<void> speakSentence(String sentence) async {
    await speak(sentence);
  }

  /// Stop any ongoing speech.
  Future<void> stop() async {
    await _tts.stop();
  }

  /// Set speech rate: 0.0 (very slow) to 1.0 (fast). Default 0.45.
  Future<void> setSpeechRate(double rate) async {
    _speechRate = rate;
    await _ensureInit();
    await _tts.setSpeechRate(rate);
  }

  double get speechRate => _speechRate;

  /// Register a callback for when speech completes.
  void onComplete(void Function() callback) {
    _tts.setCompletionHandler(callback);
  }

  /// Register a callback for when speech starts.
  void onStart(void Function() callback) {
    _tts.setStartHandler(callback);
  }

  void dispose() {
    _tts.stop();
  }
}
