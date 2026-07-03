import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/story_model.dart';
import '../../../services/audio_service.dart';
import '../../../services/story_service.dart';
import 'comprehension_quiz_screen.dart';

class StoryReaderScreen extends StatefulWidget {
  final Story story;
  const StoryReaderScreen({super.key, required this.story});

  @override
  State<StoryReaderScreen> createState() => _StoryReaderScreenState();
}

class _StoryReaderScreenState extends State<StoryReaderScreen> {
  final AudioService _audio = AudioService();
  final StoryService _storyService = StoryService();

  int _currentSentenceIndex = 0;
  bool _isPlaying = false;
  double _fontSize = 20.0;
  double _speechRate = 0.45;
  bool _isDarkMode = true;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _speechRate = _audio.speechRate;
    _loadProgress();
    _setupAudioCallbacks();
  }

  void _setupAudioCallbacks() {
    _audio.onComplete(() {
      if (mounted && _isPlaying) {
        _onSentenceFinished();
      }
    });
  }

  Future<void> _loadProgress() async {
    final index = await _storyService.getProgress(widget.story.id);
    if (mounted && index > 0 && index < widget.story.sentences.length) {
      setState(() {
        _currentSentenceIndex = index;
      });
      _scrollToCurrent();
      // Prompt user to continue
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showContinuePrompt(index);
      });
    }
  }

  void _showContinuePrompt(int index) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Continue reading from sentence ${index + 1}?', style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
        action: SnackBarAction(
          label: 'Yes',
          textColor: Colors.yellowAccent,
          onPressed: () {
            setState(() {
              _currentSentenceIndex = index;
            });
            _scrollToCurrent();
          },
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void _scrollToCurrent() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _currentSentenceIndex * 90.0, // estimate sentence card height
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _startReading() async {
    if (_currentSentenceIndex >= widget.story.sentences.length) {
      setState(() {
        _currentSentenceIndex = 0;
      });
    }
    setState(() {
      _isPlaying = true;
    });
    _readActiveSentence();
  }

  Future<void> _readActiveSentence() async {
    if (!mounted || !_isPlaying) return;
    _scrollToCurrent();
    final text = widget.story.sentences[_currentSentenceIndex];
    await _audio.speakSentence(text);
    _storyService.saveProgress(widget.story.id, _currentSentenceIndex);
  }

  void _onSentenceFinished() {
    if (_currentSentenceIndex < widget.story.sentences.length - 1) {
      setState(() {
        _currentSentenceIndex++;
      });
      _readActiveSentence();
    } else {
      // Completed story
      setState(() {
        _isPlaying = false;
      });
      _storyService.saveProgress(widget.story.id, 0); // reset progress on finish
      _showQuizOption();
    }
  }

  void _pauseReading() {
    _audio.stop();
    setState(() {
      _isPlaying = false;
    });
  }

  void _stopReading() {
    _audio.stop();
    setState(() {
      _isPlaying = false;
      _currentSentenceIndex = 0;
    });
    _scrollToCurrent();
  }

  void _selectSentence(int idx) {
    setState(() {
      _currentSentenceIndex = idx;
    });
    if (_isPlaying) {
      _readActiveSentence();
    } else {
      _scrollToCurrent();
    }
  }

  void _showQuizOption() {
    _audio.speak('You have finished the story! Let\'s take a short quiz.');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1B4B),
        title: Text(
          'Congratulations! 🎉',
          style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: Text(
          'You finished reading "${widget.story.title}". Ready for a fun comprehension quiz?',
          style: GoogleFonts.nunito(color: Colors.white70),
          textAlign: TextAlign.center,
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              ),
              onPressed: () {
                Navigator.pop(ctx); // Close dialog
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ComprehensionQuizScreen(story: widget.story),
                  ),
                );
              },
              child: Text(
                'Start Quiz',
                style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _audio.stop();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _isDarkMode ? const Color(0xFF0F0C29) : Colors.amber.shade50;
    final textColor = _isDarkMode ? Colors.white : Colors.brown.shade900;
    final cardBgColor = _isDarkMode ? Colors.white.withOpacity(0.06) : Colors.white;
    final activeCardBgColor = _isDarkMode ? Colors.green.withOpacity(0.2) : Colors.green.withOpacity(0.15);
    final activeBorderColor = _isDarkMode ? Colors.greenAccent : Colors.green;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(widget.story.title, style: GoogleFonts.nunito(fontWeight: FontWeight.bold, color: textColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(_isDarkMode ? Icons.wb_sunny : Icons.mode_night, color: textColor),
            onPressed: () => setState(() => _isDarkMode = !_isDarkMode),
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Settings controls panel
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cardBgColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: _isDarkMode ? Colors.white12 : Colors.black12),
              ),
              child: Column(
                children: [
                  // Text Size slider
                  Row(
                    children: [
                      Icon(Icons.format_size, color: textColor, size: 20),
                      const SizedBox(width: 8),
                      Text('Text Size', style: GoogleFonts.nunito(color: textColor, fontSize: 13)),
                      Expanded(
                        child: Slider(
                          value: _fontSize,
                          min: 16.0,
                          max: 32.0,
                          activeColor: Colors.green,
                          inactiveColor: Colors.white24,
                          onChanged: (val) => setState(() => _fontSize = val),
                        ),
                      ),
                      Text('${_fontSize.round()}px', style: GoogleFonts.nunito(color: textColor, fontSize: 12)),
                    ],
                  ),
                  // Speech Speed slider
                  Row(
                    children: [
                      Icon(Icons.speed, color: textColor, size: 20),
                      const SizedBox(width: 8),
                      Text('Read Speed', style: GoogleFonts.nunito(color: textColor, fontSize: 13)),
                      Expanded(
                        child: Slider(
                          value: _speechRate,
                          min: 0.2,
                          max: 0.8,
                          activeColor: Colors.indigoAccent,
                          inactiveColor: Colors.white24,
                          onChanged: (val) {
                            setState(() => _speechRate = val);
                            _audio.setSpeechRate(val);
                          },
                        ),
                      ),
                      Text('${(_speechRate * 2).toStringAsFixed(1)}x', style: GoogleFonts.nunito(color: textColor, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            // Story Content View
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: widget.story.sentences.length,
                itemBuilder: (context, idx) {
                  final sentence = widget.story.sentences[idx];
                  final isActive = idx == _currentSentenceIndex;

                  return GestureDetector(
                    onTap: () => _selectSentence(idx),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isActive ? activeCardBgColor : cardBgColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isActive ? activeBorderColor : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        sentence,
                        style: GoogleFonts.nunito(
                          color: isActive
                              ? (_isDarkMode ? Colors.yellowAccent : Colors.green.shade900)
                              : textColor.withOpacity(0.7),
                          fontSize: _fontSize,
                          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                          height: 1.4,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Playback controls footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBgColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(Icons.stop, color: textColor, size: 32),
                    onPressed: _stopReading,
                  ),
                  GestureDetector(
                    onTap: _isPlaying ? _pauseReading : _startReading,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.quiz, color: textColor, size: 32),
                    onPressed: () {
                      _audio.stop();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ComprehensionQuizScreen(story: widget.story),
                        ),
                      );
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
