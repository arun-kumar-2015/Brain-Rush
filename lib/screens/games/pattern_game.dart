import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../utils/difficulty_manager.dart';
import '../../utils/theme.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PatternGame extends StatefulWidget {
  const PatternGame({super.key});

  @override
  State<PatternGame> createState() => _PatternGameState();
}

class _PatternGameState extends State<PatternGame> {
  final _firestoreService = FirestoreService();
  int level = 1;
  int score = 0;
  List<int> sequence = [];
  List<int> userSequence = [];
  bool isShowingSequence = false;
  int currentShowingIndex = -1;
  
  final List<Color> colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
  ];

  @override
  void initState() {
    super.initState();
    _startNewLevel();
  }

  void _startNewLevel() {
    int length = DifficultyManager.getPatternLength(level);
    sequence = List.generate(length, (_) => Random().nextInt(4));
    userSequence = [];
    _showSequence();
  }

  Future<void> _showSequence() async {
    setState(() {
      isShowingSequence = true;
      userSequence = [];
    });

    for (int i = 0; i < sequence.length; i++) {
      if (!mounted) return;
      setState(() {
        currentShowingIndex = i;
      });
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      setState(() {
        currentShowingIndex = -1;
      });
      await Future.delayed(const Duration(milliseconds: 200));
    }

    if (mounted) {
      setState(() {
        isShowingSequence = false;
      });
    }
  }

  void _onColorTap(int index) {
    if (isShowingSequence) return;

    setState(() {
      userSequence.add(index);
    });

    if (userSequence[userSequence.length - 1] != sequence[userSequence.length - 1]) {
      _showGameOver();
    } else if (userSequence.length == sequence.length) {
      setState(() {
        score += level * 10;
        level++;
      });
      Future.delayed(const Duration(milliseconds: 500), _startNewLevel);
    }
  }

  void _showGameOver() {
    // Save score
    final uid = Provider.of<AuthProvider>(context, listen: false).userModel?.uid;
    if (uid != null) {
      _firestoreService.updateUserScore(uid, 'Pattern Game', score);
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Game Over'),
        content: Text('You missed the pattern!\nFinal Score: $score'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Exit'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                level = 1;
                score = 0;
                _startNewLevel();
              });
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pattern Game')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Score: $score', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                Text('Level: $level', style: const TextStyle(fontSize: 20)),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: AspectRatio(
              aspectRatio: 1,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                ),
                itemCount: 4,
                itemBuilder: (context, index) {
                  bool isHighlight = currentShowingIndex != -1 && sequence[currentShowingIndex] == index;
                  return GestureDetector(
                    onTap: () => _onColorTap(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isHighlight ? colors[index] : colors[index].withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isHighlight ? Colors.white : Colors.transparent,
                          width: 4,
                        ),
                        boxShadow: isHighlight
                            ? [BoxShadow(color: colors[index], blurRadius: 20, spreadRadius: 5)]
                            : [],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Text(
            isShowingSequence ? 'Watch Carefully...' : 'Repeat the Pattern!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isShowingSequence ? Colors.orange : Colors.green,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
