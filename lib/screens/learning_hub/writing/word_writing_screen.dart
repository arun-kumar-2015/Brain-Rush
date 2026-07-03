import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../services/audio_service.dart';

class WordWritingScreen extends StatefulWidget {
  const WordWritingScreen({super.key});

  @override
  State<WordWritingScreen> createState() => _WordWritingScreenState();
}

class _WordWritingScreenState extends State<WordWritingScreen> {
  final AudioService _audio = AudioService();
  final List<Map<String, String>> _words = [
    {'word': 'CAT', 'emoji': '🐱', 'hint': 'A small furry pet that meows.'},
    {'word': 'DOG', 'emoji': '🐶', 'hint': 'Man\'s best friend that barks.'},
    {'word': 'SUN', 'emoji': '☀️', 'hint': 'The big hot star in the sky.'},
    {'word': 'FISH', 'emoji': '🐟', 'hint': 'It swims in the water.'},
    {'word': 'BIRD', 'emoji': '🐦', 'hint': 'It has wings and can fly.'},
    {'word': 'TREE', 'emoji': '🌳', 'hint': 'A tall plant with green leaves.'},
    {'word': 'BOOK', 'emoji': '📖', 'hint': 'You read pages of stories in this.'},
    {'word': 'FROG', 'emoji': '🐸', 'hint': 'A green animal that jumps.'},
    {'word': 'MILK', 'emoji': '🥛', 'hint': 'A white healthy drink.'},
    {'word': 'BALL', 'emoji': '⚽', 'hint': 'You kick it or throw it in games.'},
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
      _speakCurrentWord();
    });
  }

  void _speakCurrentWord() {
    _audio.speakWord(_words[_currentIndex]['word']!);
  }

  void _checkWord() {
    final userInput = _controller.text.trim().toUpperCase();
    final correctWord = _words[_currentIndex]['word']!;
    setState(() {
      _isChecked = true;
      _isCorrect = userInput == correctWord;
      if (_isCorrect) {
        _coins += 10;
        _audio.speak('Correct! Good job!');
      } else {
        _audio.speak('Try again, you can do it!');
      }
    });
  }

  void _nextWord() {
    if (_currentIndex < _words.length - 1) {
      setState(() {
        _currentIndex++;
        _controller.clear();
        _isChecked = false;
      });
      _speakCurrentWord();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Awesome! You earned $_coins coins in total!',
              style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = _words[_currentIndex];
    return Scaffold(
      backgroundColor: const Color(0xFF0F0C29),
      appBar: AppBar(
        title: Text('Word Writing', style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
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
            children: [
              // Progress indicator
              LinearProgressIndicator(
                value: (_currentIndex + 1) / _words.length,
                backgroundColor: Colors.white12,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
              const SizedBox(height: 12),
              Text(
                'Word ${_currentIndex + 1} of ${_words.length}',
                style: GoogleFonts.nunito(color: Colors.white60, fontSize: 14),
              ),
              const SizedBox(height: 30),
              // Big Emoji Display
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.blue.withOpacity(0.4), width: 3),
                ),
                alignment: Alignment.center,
                child: Text(
                  item['emoji']!,
                  style: const TextStyle(fontSize: 70),
                ),
              ),
              const SizedBox(height: 20),
              // Word pronunciation button
              ElevatedButton.icon(
                onPressed: _speakCurrentWord,
                icon: const Icon(Icons.volume_up, color: Colors.white),
                label: Text('Listen to Word', style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
              const SizedBox(height: 24),
              // Hint
              Text(
                'Hint: ${item['hint']!}',
                style: GoogleFonts.nunito(color: Colors.white70, fontSize: 16, fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              // TextField
              TextField(
                controller: _controller,
                style: GoogleFonts.nunito(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 3),
                textAlign: TextAlign.center,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: 'WRITE HERE',
                  hintStyle: GoogleFonts.nunito(color: Colors.white24, fontSize: 22),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: Colors.white30, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                ),
              ),
              const SizedBox(height: 30),
              // Check / Next buttons
              if (!_isChecked)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _checkWord,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: Text('Check Answer', style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                )
              else ...[
                // Feedback icon/text
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isCorrect ? Icons.check_circle : Icons.cancel,
                      color: _isCorrect ? Colors.green : Colors.red,
                      size: 36,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _isCorrect ? 'Correct! +10 Coins' : 'Incorrect. The word was: ${item['word']}',
                      style: GoogleFonts.nunito(
                        color: _isCorrect ? Colors.green : Colors.red,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _nextWord,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: Text(
                      _currentIndex < _words.length - 1 ? 'Next Word' : 'Finish',
                      style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
