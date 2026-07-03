import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../services/speech_recognition_service.dart';
import '../../../services/audio_service.dart';

class CreativeWritingScreen extends StatefulWidget {
  const CreativeWritingScreen({super.key});

  @override
  State<CreativeWritingScreen> createState() => _CreativeWritingScreenState();
}

class _CreativeWritingScreenState extends State<CreativeWritingScreen> {
  final SpeechRecognitionService _stt = SpeechRecognitionService();
  final AudioService _audio = AudioService();

  final List<Map<String, String>> _topics = [
    {
      'topic': 'MY FAVORITE ANIMAL',
      'hint': 'What animal is it? Why do you like it? What color is it?'
    },
    {
      'topic': 'MY HERO',
      'hint': 'Who is your hero? Is it mom, dad, or a superhero? What do they do?'
    },
    {
      'topic': 'A FUN DAY',
      'hint': 'Describe a fun day you had. Where did you go? What did you play?'
    },
  ];

  int _currentIndex = 0;
  final TextEditingController _controller = TextEditingController();
  bool _isListening = false;
  int _coinsEarned = 0;
  bool _submitted = false;
  int _wordsCount = 0;

  @override
  void initState() {
    super.initState();
    _stt.init();
  }

  void _toggleListening() async {
    if (_isListening) {
      await _stt.stopListening();
      setState(() => _isListening = false);
    } else {
      // Initialize STT first
      await _stt.init();

      setState(() => _isListening = true);

      // Wait a moment before starting to listen (avoid TTS conflict)
      await Future.delayed(const Duration(milliseconds: 300));

      final started = await _stt.startListening(
        onResult: (text) {
          if (mounted) {
            setState(() {
              _controller.text = text;
              _controller.selection = TextSelection.fromPosition(
                TextPosition(offset: _controller.text.length),
              );
            });
          }
        },
        partialResults: true,
      );
      if (!started) {
        if (mounted) {
          setState(() => _isListening = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Speech recognition not available. Please check microphone permissions and try typing!'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  void _submitText() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      _audio.speak('Please write or speak something first!');
      return;
    }
    final words = text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    setState(() {
      _wordsCount = words.length;
      _coinsEarned = (_wordsCount * 5).clamp(10, 100);
      _submitted = true;
    });
    _audio.speak('Great job! You wrote $_wordsCount words and earned $_coinsEarned coins!');
  }

  void _nextTopic() {
    if (_currentIndex < _topics.length - 1) {
      setState(() {
        _currentIndex++;
        _controller.clear();
        _submitted = false;
        _coinsEarned = 0;
        _wordsCount = 0;
      });
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = _topics[_currentIndex];
    return Scaffold(
      backgroundColor: const Color(0xFF0F0C29),
      appBar: AppBar(
        title: Text('Creative Voice Writing', style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Topic ${_currentIndex + 1} of ${_topics.length}',
                style: GoogleFonts.nunito(color: Colors.white54, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              // Topic card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8E24AA), Color(0xFFE91E63)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      item['topic']!,
                      style: GoogleFonts.nunito(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      item['hint']!,
                      style: GoogleFonts.nunito(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              // Input area
              TextField(
                controller: _controller,
                maxLines: 6,
                style: GoogleFonts.nunito(color: Colors.white, fontSize: 18),
                decoration: InputDecoration(
                  hintText: 'Type your story here, or tap the microphone to speak your thoughts aloud!',
                  hintStyle: GoogleFonts.nunito(color: Colors.white30, fontSize: 16),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: Colors.white30, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: Colors.purple, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                ),
              ),
              const SizedBox(height: 20),
              // Mic button & Speak option
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _toggleListening,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: _isListening ? Colors.red : Colors.purple,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (_isListening ? Colors.red : Colors.purple).withOpacity(0.5),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        _isListening ? Icons.mic : Icons.mic_none,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                _isListening ? 'Listening... speak clearly!' : 'Tap mic to use voice input',
                style: GoogleFonts.nunito(color: Colors.white54, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              // Action buttons
              if (!_submitted)
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _submitText,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: Text('Submit Writing', style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                )
              else ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Fantastic Writing!',
                        style: GoogleFonts.nunito(color: Colors.green, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'You wrote $_wordsCount words and earned $_coinsEarned Coins! 🪙',
                        style: GoogleFonts.nunito(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _nextTopic,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: Text(
                      _currentIndex < _topics.length - 1 ? 'Next Topic' : 'Done',
                      style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
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
