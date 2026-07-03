import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/story_model.dart';
import '../../../services/audio_service.dart';
import '../../../services/story_service.dart';

class ComprehensionQuizScreen extends StatefulWidget {
  final Story story;
  const ComprehensionQuizScreen({super.key, required this.story});

  @override
  State<ComprehensionQuizScreen> createState() => _ComprehensionQuizScreenState();
}

class _ComprehensionQuizScreenState extends State<ComprehensionQuizScreen> {
  final AudioService _audio = AudioService();
  final StoryService _storyService = StoryService();

  int _currentQuestionIdx = 0;
  int? _selectedAnswerIdx;
  int _score = 0;
  bool _quizFinished = false;

  int _coinsEarned = 0;
  String _badgeName = 'Bronze Reader';

  void _answerQuestion(int idx) {
    if (_selectedAnswerIdx != null) return; // already answered this question

    final correctIdx = widget.story.quizQuestions[_currentQuestionIdx]['correctOptionIndex'] as int;
    setState(() {
      _selectedAnswerIdx = idx;
      if (idx == correctIdx) {
        _score++;
        _audio.speak('Superb!');
      } else {
        _audio.speak('Oh, that was close.');
      }
    });

    // Automatically transition after 1.5 seconds
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      if (_currentQuestionIdx < widget.story.quizQuestions.length - 1) {
        setState(() {
          _currentQuestionIdx++;
          _selectedAnswerIdx = null;
        });
      } else {
        _calculateRewards();
      }
    });
  }

  void _calculateRewards() async {
    final totalQ = widget.story.quizQuestions.length;
    final pct = _score / totalQ;

    int coins = 0;
    String badge = 'Bronze Reader';

    if (pct == 1.0) {
      coins = 50;
      badge = 'Gold Reader 🏆';
    } else if (pct >= 0.6) {
      coins = 30;
      badge = 'Silver Reader 🥈';
    } else {
      coins = 10;
      badge = 'Bronze Reader 🥉';
    }

    await _storyService.addCoins(coins);
    await _storyService.updateStreak();

    setState(() {
      _coinsEarned = coins;
      _badgeName = badge;
      _quizFinished = true;
    });

    _audio.speak('Congratulations! You got $_score out of $totalQ correct. You earned $coins coins and a $_badgeName badge!');
  }

  @override
  Widget build(BuildContext context) {
    final totalQ = widget.story.quizQuestions.length;

    if (_quizFinished) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F0C29),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🎉', style: TextStyle(fontSize: 80)),
                  const SizedBox(height: 20),
                  Text(
                    'Quiz Completed!',
                    style: GoogleFonts.nunito(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Your Score: $_score / $totalQ',
                    style: GoogleFonts.nunito(color: Colors.white70, fontSize: 20),
                  ),
                  const SizedBox(height: 40),
                  // Rewards card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white24, width: 2),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.monetization_on, color: Colors.amber, size: 30),
                            const SizedBox(width: 8),
                            Text(
                              '+$_coinsEarned Coins',
                              style: GoogleFonts.nunito(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.shield, color: Colors.indigoAccent, size: 30),
                            const SizedBox(width: 8),
                            Text(
                              'Badge: $_badgeName',
                              style: GoogleFonts.nunito(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 50),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      onPressed: () {
                        Navigator.pop(context); // returns to story library list
                      },
                      child: Text(
                        'Back to Library',
                        style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      );
    }

    final q = widget.story.quizQuestions[_currentQuestionIdx];
    final correctIdx = q['correctOptionIndex'] as int;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0C29),
      appBar: AppBar(
        title: Text('Story Quiz', style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(), // hide back button to force quiz completion
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Question ${_currentQuestionIdx + 1} of $totalQ',
                style: GoogleFonts.nunito(color: Colors.white54, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              // Question text
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  q['question'] as String,
                  style: GoogleFonts.nunito(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 30),
              // Options list
              Expanded(
                child: ListView.builder(
                  itemCount: (q['options'] as List).length,
                  itemBuilder: (context, idx) {
                    final optionText = q['options'][idx] as String;
                    final isAnswered = _selectedAnswerIdx != null;
                    final isThisOptionSelected = _selectedAnswerIdx == idx;
                    final isCorrectOption = idx == correctIdx;

                    Color cardColor = Colors.white.withOpacity(0.05);
                    Color borderColor = Colors.white12;

                    if (isAnswered) {
                      if (isCorrectOption) {
                        cardColor = Colors.green.withOpacity(0.2);
                        borderColor = Colors.green;
                      } else if (isThisOptionSelected) {
                        cardColor = Colors.red.withOpacity(0.2);
                        borderColor = Colors.red;
                      }
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: InkWell(
                        onTap: () => _answerQuestion(idx),
                        borderRadius: BorderRadius.circular(20),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: borderColor, width: 2),
                          ),
                          child: Row(
                            children: [
                              Text(
                                '${String.fromCharCode(65 + idx)}.',
                                style: GoogleFonts.nunito(color: Colors.amberAccent, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  optionText,
                                  style: GoogleFonts.nunito(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                              if (isAnswered && isCorrectOption)
                                const Icon(Icons.check_circle, color: Colors.green)
                              else if (isAnswered && isThisOptionSelected && !isCorrectOption)
                                const Icon(Icons.cancel, color: Colors.red),
                            ],
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
      ),
    );
  }
}
