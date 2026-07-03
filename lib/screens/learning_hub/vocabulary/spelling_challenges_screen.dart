import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../services/audio_service.dart';

class SpellingChallengesScreen extends StatefulWidget {
  const SpellingChallengesScreen({super.key});

  @override
  State<SpellingChallengesScreen> createState() => _SpellingChallengesScreenState();
}

class _SpellingChallengesScreenState extends State<SpellingChallengesScreen> {
  final AudioService _audio = AudioService();

  final List<Map<String, String>> _challenges = [
    {'word': 'CAT', 'emoji': '🐱'},
    {'word': 'SUN', 'emoji': '☀️'},
    {'word': 'DOG', 'emoji': '🐶'},
    {'word': 'FISH', 'emoji': '🐟'},
    {'word': 'BIRD', 'emoji': '🐦'},
    {'word': 'FROG', 'emoji': '🐸'},
  ];

  int _currentIndex = 0;
  List<String> _scrambledLetters = [];
  List<String> _typedLetters = [];
  int _coins = 0;

  @override
  void initState() {
    super.initState();
    _loadChallenge();
  }

  void _loadChallenge() {
    final correctWord = _challenges[_currentIndex]['word']!;
    List<String> letters = correctWord.split('');
    // Add extra random letters to make it fun
    final alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('');
    while (letters.length < 8) {
      final randLetter = (alphabet..shuffle()).first;
      if (!letters.contains(randLetter)) {
        letters.add(randLetter);
      }
    }
    setState(() {
      _scrambledLetters = letters..shuffle();
      _typedLetters.clear();
    });
    _speakCurrentChallenge();
  }

  void _speakCurrentChallenge() {
    final correctWord = _challenges[_currentIndex]['word']!;
    _audio.speak('Spell the word: $correctWord');
  }

  void _onLetterTap(String letter) {
    setState(() {
      _typedLetters.add(letter);
    });

    final targetWord = _challenges[_currentIndex]['word']!;
    final typedString = _typedLetters.join('');

    if (typedString.length == targetWord.length) {
      if (typedString == targetWord) {
        // Correct spelling!
        setState(() {
          _coins += 20;
        });
        _audio.speak('Sensational! You spelled it right!');
        
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (_currentIndex < _challenges.length - 1) {
            setState(() {
              _currentIndex++;
            });
            _loadChallenge();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Completed all spelling challenges! Total Coins: $_coins', style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          }
        });
      } else {
        // Wrong spelling, shake or reset
        _audio.speak('Incorrect spelling. Let\'s try again!');
        Future.delayed(const Duration(milliseconds: 1000), () {
          setState(() {
            _typedLetters.clear();
          });
        });
      }
    }
  }

  void _clearTyped() {
    setState(() {
      _typedLetters.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final item = _challenges[_currentIndex];
    return Scaffold(
      backgroundColor: const Color(0xFF0F0C29),
      appBar: AppBar(
        title: Text('Spelling Challenges', style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              LinearProgressIndicator(
                value: (_currentIndex + 1) / _challenges.length,
                backgroundColor: Colors.white12,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.indigo),
              ),
              const SizedBox(height: 12),
              Text(
                'Challenge ${_currentIndex + 1} of ${_challenges.length}',
                style: GoogleFonts.nunito(color: Colors.white60, fontSize: 14),
              ),
              const Spacer(),
              // Big Emoji
              Text(item['emoji']!, style: const TextStyle(fontSize: 90)),
              const SizedBox(height: 12),
              IconButton(
                icon: const Icon(Icons.volume_up, size: 40, color: Colors.indigoAccent),
                onPressed: _speakCurrentChallenge,
              ),
              const Spacer(),
              // Spelled letters placeholder boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(item['word']!.length, (idx) {
                  final hasLetter = idx < _typedLetters.length;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    width: 50,
                    height: 54,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: hasLetter ? Colors.indigoAccent : Colors.white24,
                        width: 2.5,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      hasLetter ? _typedLetters[idx] : '',
                      style: GoogleFonts.nunito(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 40),
              // Scrambled letters choices
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: _scrambledLetters.map((letter) {
                  // Only count how many times this letter has been typed
                  final letterTypeCount = _typedLetters.where((l) => l == letter).length;
                  final totalScrambledCount = _scrambledLetters.where((l) => l == letter).length;
                  final isUsed = letterTypeCount >= totalScrambledCount;

                  return InkWell(
                    onTap: isUsed ? null : () => _onLetterTap(letter),
                    borderRadius: BorderRadius.circular(16),
                    child: Opacity(
                      opacity: isUsed ? 0.3 : 1.0,
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.indigo.shade800,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.indigo.shade400, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.indigo.withOpacity(0.4),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          letter,
                          style: GoogleFonts.nunito(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const Spacer(),
              // Clear button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _clearTyped,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: const Icon(Icons.backspace, color: Colors.white),
                  label: Text('Clear spelling', style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
