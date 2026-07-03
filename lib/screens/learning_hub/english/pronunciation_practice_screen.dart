import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../services/audio_service.dart';
import '../../../services/speech_recognition_service.dart';

/// Simple pronunciation practice widget.
/// Children see a word + speak button → app records speech → compares
/// with expected word (case‑insensitive) and shows feedback.
class PronunciationPracticeScreen extends StatefulWidget {
  final String word; // word to practice, e.g., "Apple"
  const PronunciationPracticeScreen({Key? key, required this.word}) : super(key: key);

  @override
  State<PronunciationPracticeScreen> createState() => _PronunciationPracticeScreenState();
}

class _PronunciationPracticeScreenState extends State<PronunciationPracticeScreen> {
  final AudioService _audio = AudioService();
  final SpeechRecognitionService _stt = SpeechRecognitionService();
  String _feedback = '';
  bool _listening = false;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _initStt();
  }

  Future<void> _initStt() async {
    final ok = await _stt.init();
    setState(() => _ready = ok);
  }

  Future<void> _listenAndCompare() async {
    if (!_ready) return;
    setState(() => _listening = true);
    await _stt.startListening(onResult: (spoken) {
      final expected = widget.word.toLowerCase();
      final said = spoken.toLowerCase().trim();
      if (said == expected) {
        _feedback = 'Excellent 🎉';
      } else if (expected.contains(said) || said.contains(expected)) {
        _feedback = 'Good Job 👍';
      } else {
        _feedback = 'Try Again 🙈';
      }
      // Store score locally – simple counter in SharedPreferences
      _storeScore(said == expected ? 2 : (said.isNotEmpty ? 1 : 0));
      setState(() => _listening = false);
    }, partialResults: false);
  }

  Future<void> _storeScore(int points) async {
    // In a real app you might use a more sophisticated model.
    // Here we just increment a counter persisted via SharedPreferences.
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt('pronunciation_score') ?? 0;
    await prefs.setInt('pronunciation_score', current + points);
  }

  @override
  void dispose() {
    _stt.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Pronunciation Practice'),
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(widget.word,
                style: GoogleFonts.nunito(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              icon: Icon(_listening ? Icons.mic : Icons.mic_none, color: Colors.white),
              label: Text(_listening ? 'Listening…' : 'Tap to Speak',
              onPressed: _listening ? null : _listenAndCompare,
            ),
            const SizedBox(height: 30),
            if (_feedback.isNotEmpty)
              Text(_feedback,
                  style: GoogleFonts.nunito(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: _feedback.contains('Excellent')
                          ? Colors.greenAccent
                          : _feedback.contains('Good')
                              ? Colors.orangeAccent
                              : Colors.redAccent)),
            const Spacer(),
            // Replay the word button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              icon: const Icon(Icons.volume_up, color: Colors.white),
              label: const Text('Hear Word', style: TextStyle(color: Colors.white)),
              onPressed: () => _audio.speakWord(widget.word),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
