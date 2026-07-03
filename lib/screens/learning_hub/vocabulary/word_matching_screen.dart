import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../services/audio_service.dart';

class WordMatchingScreen extends StatefulWidget {
  const WordMatchingScreen({super.key});

  @override
  State<WordMatchingScreen> createState() => _WordMatchingScreenState();
}

class _WordMatchingScreenState extends State<WordMatchingScreen> {
  final AudioService _audio = AudioService();

  final List<Map<String, String>> _pairs = [
    {'word': 'APPLE', 'match': '🍎'},
    {'word': 'DOG', 'match': '🐶'},
    {'word': 'SUN', 'match': '☀️'},
    {'word': 'CAT', 'match': '🐱'},
    {'word': 'FISH', 'match': '🐟'},
    {'word': 'BOOK', 'match': '📖'},
  ];

  List<String> _words = [];
  List<String> _matches = [];

  String? _selectedWord;
  String? _selectedMatch;
  Set<String> _matchedWords = {};
  int _coins = 0;

  @override
  void initState() {
    super.initState();
    _resetGame();
  }

  void _resetGame() {
    setState(() {
      _matchedWords.clear();
      _selectedWord = null;
      _selectedMatch = null;
      _words = _pairs.map((p) => p['word']!).toList()..shuffle();
      _matches = _pairs.map((p) => p['match']!).toList()..shuffle();
    });
    _audio.speak('Match the words to their pictures!');
  }

  void _onWordTap(String word) {
    if (_matchedWords.contains(word)) return;
    setState(() {
      _selectedWord = word;
    });
    _audio.speak(word);
    _checkMatch();
  }

  void _onMatchTap(String match) {
    // Find if match is already paired
    final wordForThisMatch = _pairs.firstWhere((p) => p['match'] == match)['word']!;
    if (_matchedWords.contains(wordForThisMatch)) return;
    setState(() {
      _selectedMatch = match;
    });
    _checkMatch();
  }

  void _checkMatch() {
    if (_selectedWord != null && _selectedMatch != null) {
      final pair = _pairs.firstWhere((p) => p['word'] == _selectedWord);
      if (pair['match'] == _selectedMatch) {
        // Correct pair!
        setState(() {
          _matchedWords.add(_selectedWord!);
          _selectedWord = null;
          _selectedMatch = null;
          _coins += 15;
        });
        _audio.speak('Good match!');
        if (_matchedWords.length == _pairs.length) {
          _audio.speak('Splendid! You matched all pairs!');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Well Done! All matches found! Earned $_coins coins!', style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Incorrect pair
        _audio.speak('Try another combination.');
        setState(() {
          _selectedWord = null;
          _selectedMatch = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0C29),
      appBar: AppBar(
        title: Text('Word Matching Game', style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Connect the words to the matching icons',
                style: GoogleFonts.nunito(color: Colors.white70, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Row(
                  children: [
                    // Words Column
                    Expanded(
                      child: ListView.builder(
                        itemCount: _words.length,
                        itemBuilder: (context, idx) {
                          final w = _words[idx];
                          final isMatched = _matchedWords.contains(w);
                          final isSelected = _selectedWord == w;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: InkWell(
                              onTap: () => _onWordTap(w),
                              borderRadius: BorderRadius.circular(16),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                height: 64,
                                decoration: BoxDecoration(
                                  color: isMatched
                                      ? Colors.green.withOpacity(0.2)
                                      : isSelected
                                          ? Colors.pink.withOpacity(0.3)
                                          : Colors.white.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isMatched
                                        ? Colors.green
                                        : isSelected
                                            ? Colors.pink
                                            : Colors.white30,
                                    width: 2,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  w,
                                  style: GoogleFonts.nunito(
                                    color: isMatched ? Colors.green : Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 24),
                    // Emojis Column
                    Expanded(
                      child: ListView.builder(
                        itemCount: _matches.length,
                        itemBuilder: (context, idx) {
                          final m = _matches[idx];
                          // Find associated word
                          final wordForMatch = _pairs.firstWhere((p) => p['match'] == m)['word']!;
                          final isMatched = _matchedWords.contains(wordForMatch);
                          final isSelected = _selectedMatch == m;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: InkWell(
                              onTap: () => _onMatchTap(m),
                              borderRadius: BorderRadius.circular(16),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                height: 64,
                                decoration: BoxDecoration(
                                  color: isMatched
                                      ? Colors.green.withOpacity(0.2)
                                      : isSelected
                                          ? Colors.pink.withOpacity(0.3)
                                          : Colors.white.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isMatched
                                        ? Colors.green
                                        : isSelected
                                            ? Colors.pink
                                            : Colors.white30,
                                    width: 2,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  m,
                                  style: const TextStyle(fontSize: 32),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (_matchedWords.length == _pairs.length)
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: _resetGame,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    label: Text('Play Again', style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
