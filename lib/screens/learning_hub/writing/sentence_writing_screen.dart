import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../services/audio_service.dart';

class SentenceWritingScreen extends StatefulWidget {
  const SentenceWritingScreen({super.key});

  @override
  State<SentenceWritingScreen> createState() => _SentenceWritingScreenState();
}

class _SentenceWritingScreenState extends State<SentenceWritingScreen> {
  final AudioService _audio = AudioService();
  final List<String> _sentences = [
    'THE CAT IS ON THE MAT.',
    'THE SUN IS SHINING BRIGHT.',
    'I LOVE TO READ GOOD BOOKS.',
    'A FISH LIVES IN THE WATER.',
    'THE LITTLE BIRD CAN FLY HIGH.',
  ];

  int _currentIndex = 0;
  final TextEditingController _controller = TextEditingController();
  bool _isChecked = false;
  bool _isCorrect = false;
  int _coins = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speakCurrentSentence();
    });
  }

  void _speakCurrentSentence() {
    _audio.speakSentence(_sentences[_currentIndex]);
  }

  void _checkSentence() {
    // Normalise spaces and punctuation for comparison
    final userInput = _controller.text.trim().replaceAll(RegExp(r'\s+'), ' ').toUpperCase();
    final correctSentence = _sentences[_currentIndex].toUpperCase();
    setState(() {
      _isChecked = true;
      _isCorrect = userInput == correctSentence;
      if (_isCorrect) {
        _coins += 20;
        _audio.speak('Amazing! That is correct!');
      } else {
        _audio.speak('Almost there, double check spelling and punctuation!');
      }
    });
  }

  void _nextSentence() {
    if (_currentIndex < _sentences.length - 1) {
      setState(() {
        _currentIndex++;
        _controller.clear();
        _isChecked = false;
      });
      _speakCurrentSentence();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Great! Completed all sentences! Earned $_coins coins.',
              style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sentence = _sentences[_currentIndex];
    return Scaffold(
      backgroundColor: const Color(0xFF0F0C29),
      appBar: AppBar(
        title: Text('Sentence Writing', style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const Icon(Icons.monetization_on, color: Colors.amber, size: 24),
                const SizedBox(width: 4),
                Text('$_coins', style: GoogleFonts.nunito(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              LinearProgressIndicator(
                value: (_currentIndex + 1) / _sentences.length,
                backgroundColor: Colors.white12,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
              ),
              const SizedBox(height: 12),
              Text(
                'Sentence ${_currentIndex + 1} of ${_sentences.length}',
                style: GoogleFonts.nunito(color: Colors.white60, fontSize: 14),
              ),
              const SizedBox(height: 30),
              // Target sentence card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white12, width: 2),
                ),
                child: Column(
                  children: [
                    Text(
                      'Copy this sentence:',
                      style: GoogleFonts.nunito(color: Colors.white54, fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      sentence,
                      style: GoogleFonts.nunito(
                        color: Colors.yellowAccent,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _speakCurrentSentence,
                      icon: const Icon(Icons.volume_up, color: Colors.white),
                      label: Text('Hear Sentence', style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              // Input field
              TextField(
                controller: _controller,
                maxLines: 3,
                style: GoogleFonts.nunito(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: 'TYPE THE SENTENCE EXACTLY',
                  hintStyle: GoogleFonts.nunito(color: Colors.white24, fontSize: 18),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: Colors.white30, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: Colors.green, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                ),
              ),
              const SizedBox(height: 30),
              // Action button
              if (!_isChecked)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _checkSentence,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: Text('Check Sentence', style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                )
              else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isCorrect ? Icons.check_circle : Icons.cancel,
                      color: _isCorrect ? Colors.green : Colors.red,
                      size: 32,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _isCorrect ? 'Correct! +20 Coins' : 'Spelling mismatch. Try matching letter by letter.',
                        style: GoogleFonts.nunito(
                          color: _isCorrect ? Colors.green : Colors.red,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _nextSentence,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: Text(
                      _currentIndex < _sentences.length - 1 ? 'Next Sentence' : 'Finish',
                      style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
