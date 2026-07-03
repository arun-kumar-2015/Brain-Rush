import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

class PronunciationMockScreen extends StatefulWidget {
  const PronunciationMockScreen({super.key});

  @override
  State<PronunciationMockScreen> createState() => _PronunciationMockScreenState();
}

class _PronunciationMockScreenState extends State<PronunciationMockScreen> {
  final FlutterTts _tts = FlutterTts();
  final SpeechToText _stt = SpeechToText();
  bool _listening = false;
  bool _sttAvailable = false;
  String _spoken = '';
  int _currentIndex = 0;
  int _score = 0;

  final List<Map<String, String>> _phrases = [
    {'word': 'Apple', 'hint': 'A red fruit'},
    {'word': 'Banana', 'hint': 'A yellow fruit'},
    {'word': 'Elephant', 'hint': 'A big grey animal'},
    {'word': 'Beautiful', 'hint': 'Very pretty'},
    {'word': 'Butterfly', 'hint': 'A flying insect with colorful wings'},
    {'word': 'Dinosaur', 'hint': 'An ancient reptile'},
    {'word': 'Chocolate', 'hint': 'A sweet brown treat'},
    {'word': 'Umbrella', 'hint': 'Keeps you dry in rain'},
  ];

  @override
  void initState() {
    super.initState();
    _initStt();
    _configureTts();
  }

  Future<void> _configureTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.4);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
  }

  Future<void> _initStt() async {
    _sttAvailable = await _stt.initialize(
      onStatus: (status) {
        if (status == 'notListening' && mounted) {
          setState(() => _listening = false);
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() => _listening = false);
        }
      },
    );
  }

  Future<void> _playTarget() async {
    await _tts.speak(_phrases[_currentIndex]['word']!);
  }

  Future<void> _startListening() async {
    if (!_sttAvailable) {
      await _initStt();
    }
    if (!_sttAvailable) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Speech recognition not available. Check microphone permissions.')),
        );
      }
      return;
    }

    setState(() {
      _listening = true;
      _spoken = '';
    });

    await _stt.listen(
      onResult: (SpeechRecognitionResult result) {
        if (mounted) {
          setState(() {
            _spoken = result.recognizedWords;
          });
        }
      },
      listenFor: const Duration(seconds: 10),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      localeId: 'en_US',
    );
  }

  Future<void> _stopListening() async {
    await _stt.stop();
    setState(() => _listening = false);
  }

  bool get _isMatch =>
      _spoken.trim().toLowerCase() == _phrases[_currentIndex]['word']!.toLowerCase();

  void _nextWord() {
    if (_isMatch) _score++;
    if (_currentIndex < _phrases.length - 1) {
      setState(() {
        _currentIndex++;
        _spoken = '';
      });
    } else {
      // Show completion dialog
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF1A1540),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Practice Complete! 🎉', style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Text(
            'You got $_score out of ${_phrases.length} words correct!',
            style: GoogleFonts.nunito(color: Colors.white70, fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                setState(() {
                  _currentIndex = 0;
                  _spoken = '';
                  _score = 0;
                });
              },
              child: Text('Try Again', style: GoogleFonts.nunito(color: Colors.amber)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: Text('Done', style: GoogleFonts.nunito(color: Colors.greenAccent)),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    _tts.stop();
    _stt.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final phrase = _phrases[_currentIndex];
    return Scaffold(
      backgroundColor: const Color(0xFF0F0C29),
      appBar: AppBar(
        title: Text('Pronunciation Practice', style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Progress indicator
            Text(
              'Word ${_currentIndex + 1} of ${_phrases.length}',
              style: GoogleFonts.nunito(color: Colors.white54, fontSize: 14),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: (_currentIndex + 1) / _phrases.length,
                backgroundColor: Colors.white12,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 30),

            // Word card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF3F51B5)]),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.indigo.withOpacity(0.4), blurRadius: 16, spreadRadius: 2),
                ],
              ),
              child: Column(
                children: [
                  Text('Say this word:', style: GoogleFonts.nunito(color: Colors.white70, fontSize: 16)),
                  const SizedBox(height: 12),
                  Text(
                    phrase['word']!,
                    style: GoogleFonts.nunito(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: 2),
                  ),
                  const SizedBox(height: 8),
                  Text('💡 ${phrase['hint']!}', style: GoogleFonts.nunito(color: Colors.white60, fontSize: 14, fontStyle: FontStyle.italic)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Listen button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.volume_up, size: 24),
                label: Text('Listen to Pronunciation', style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _playTarget,
              ),
            ),
            const SizedBox(height: 16),

            // Record button
            GestureDetector(
              onTap: _listening ? _stopListening : _startListening,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _listening ? Colors.red : Colors.green,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (_listening ? Colors.red : Colors.green).withOpacity(0.5),
                      blurRadius: _listening ? 20 : 10,
                      spreadRadius: _listening ? 4 : 1,
                    ),
                  ],
                ),
                child: Icon(
                  _listening ? Icons.stop : Icons.mic,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _listening ? '🔴 Listening... speak now!' : 'Tap to record',
              style: GoogleFonts.nunito(color: _listening ? Colors.redAccent : Colors.white54, fontSize: 14),
            ),
            const SizedBox(height: 24),

            // Result area
            if (_spoken.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _isMatch ? Colors.green.withOpacity(0.15) : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _isMatch ? Colors.greenAccent : Colors.redAccent, width: 1.5),
                ),
                child: Column(
                  children: [
                    Text('You said:', style: GoogleFonts.nunito(color: Colors.white54, fontSize: 14)),
                    const SizedBox(height: 8),
                    Text(
                      _spoken,
                      style: GoogleFonts.nunito(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _isMatch ? '✅ Perfect pronunciation!' : '❌ Try again! Listen carefully.',
                      style: GoogleFonts.nunito(
                        color: _isMatch ? Colors.greenAccent : Colors.redAccent,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _nextWord,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    _currentIndex < _phrases.length - 1 ? 'Next Word →' : 'Finish',
                    style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
