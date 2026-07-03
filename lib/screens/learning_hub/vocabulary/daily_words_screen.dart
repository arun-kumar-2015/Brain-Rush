import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../services/audio_service.dart';

class DailyWordsScreen extends StatefulWidget {
  const DailyWordsScreen({super.key});

  @override
  State<DailyWordsScreen> createState() => _DailyWordsScreenState();
}

class _DailyWordsScreenState extends State<DailyWordsScreen> {
  final AudioService _audio = AudioService();
  final List<Map<String, String>> _words = [
    {
      'word': 'CURIOUS',
      'phonetic': '/ˈkjʊə.ri.əs/',
      'definition': 'Wanting to know or learn about something.',
      'example': 'The curious puppy wanted to explore the garden.',
      'emoji': '🐱'
    },
    {
      'word': 'GENEROUS',
      'phonetic': '/ˈdʒen.ər.əs/',
      'definition': 'Willing to give money, help, or kindness freely.',
      'example': 'She was very generous and shared all her toys with friends.',
      'emoji': '🎁'
    },
    {
      'word': 'VALIANT',
      'phonetic': '/ˈvæl.i.ənt/',
      'definition': 'Very brave and showing great courage.',
      'example': 'The valiant knight protected the castle from the dragon.',
      'emoji': '🛡️'
    },
    {
      'word': 'DILIGENT',
      'phonetic': '/ˈdɪl.ɪ.dʒənt/',
      'definition': 'Careful and using a lot of effort in work/studies.',
      'example': 'A diligent student reviews lessons every day.',
      'emoji': '✍️'
    },
    {
      'word': 'GIGANTIC',
      'phonetic': '/ˌdʒaɪˈɡæn.tɪk/',
      'definition': 'Extremely large in size or scale.',
      'example': 'They saw a gigantic whale swimming in the ocean.',
      'emoji': '🐳'
    },
  ];

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speakCurrentWord();
    });
  }

  void _speakCurrentWord() {
    final word = _words[_currentIndex]['word']!;
    final definition = _words[_currentIndex]['definition']!;
    _audio.speak('$word. Meaning: $definition');
  }

  void _nextWord() {
    if (_currentIndex < _words.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _speakCurrentWord();
    }
  }

  void _prevWord() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
      _speakCurrentWord();
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = _words[_currentIndex];
    return Scaffold(
      backgroundColor: const Color(0xFF0F0C29),
      appBar: AppBar(
        title: Text('Daily New Words', style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Word ${_currentIndex + 1} of ${_words.length}',
                style: GoogleFonts.nunito(color: Colors.white54, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              // Word card
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.teal.shade800, Colors.cyan.shade900],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.teal.shade400, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.teal.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(item['emoji']!, style: const TextStyle(fontSize: 80)),
                      const SizedBox(height: 20),
                      Text(
                        item['word']!,
                        style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        item['phonetic']!,
                        style: GoogleFonts.nunito(
                          color: Colors.white70,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      const Divider(color: Colors.white24, thickness: 1.5),
                      const SizedBox(height: 16),
                      Text(
                        'MEANING',
                        style: GoogleFonts.nunito(color: Colors.amberAccent, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item['definition']!,
                        style: GoogleFonts.nunito(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'EXAMPLE',
                        style: GoogleFonts.nunito(color: Colors.cyanAccent, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '"${item['example']!}"',
                        style: GoogleFonts.nunito(color: Colors.white70, fontSize: 15, fontStyle: FontStyle.italic),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // Play audio button
              ElevatedButton.icon(
                onPressed: _speakCurrentWord,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                icon: const Icon(Icons.volume_up, color: Colors.white, size: 28),
                label: Text('Listen and Speak', style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              // Pronunciation check button
              IconButton(
                icon: const Icon(Icons.mic, color: Colors.white),
                onPressed: () async {
                  final userInput = await showDialog<String>(
                    context: context,
                    builder: (context) {
                      String typed = '';
                      return AlertDialog(
                        title: const Text('Pronunciation Check'),
                        content: TextField(
                          onChanged: (v) => typed = v,
                          decoration: const InputDecoration(hintText: 'Type the word you heard'),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, null),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, typed),
                            child: const Text('Submit'),
                          ),
                        ],
                      );
                    },
                  );
                  if (userInput != null) {
                    final correct = userInput.trim().toLowerCase() == item['word']!.toLowerCase();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(correct ? 'Great! Correct pronunciation.' : 'Try again.')),
                    );
                  }
                },
              ),
              const SizedBox(height: 20),
              // Nav row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: _currentIndex > 0 ? _prevWord : null,
                    icon: const Icon(Icons.arrow_circle_left_rounded, size: 54, color: Colors.teal),
                    disabledColor: Colors.white12,
                  ),
                  IconButton(
                    onPressed: _currentIndex < _words.length - 1 ? _nextWord : null,
                    icon: const Icon(Icons.arrow_circle_right_rounded, size: 54, color: Colors.teal),
                    disabledColor: Colors.white12,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
