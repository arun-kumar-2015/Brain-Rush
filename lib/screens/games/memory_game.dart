import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../utils/difficulty_manager.dart';
import '../../utils/theme.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MemoryGame extends StatefulWidget {
  const MemoryGame({super.key});

  @override
  State<MemoryGame> createState() => _MemoryGameState();
}

class _MemoryGameState extends State<MemoryGame> {
  final _firestoreService = FirestoreService();
  int level = 1;
  int score = 0;
  List<int> cardValues = [];
  List<bool> cardFlipped = [];
  List<bool> cardMatched = [];
  int? firstFlippedIndex;
  bool isProcessing = false;
  late int gridSize;
  late Timer _timer;
  int _secondsElapsed = 0;

  @override
  void initState() {
    super.initState();
    _startNewLevel();
  }

  void _startNewLevel() {
    gridSize = DifficultyManager.getMemoryGridSize(level);
    int totalCards = gridSize * gridSize;
    List<int> values = [];
    for (int i = 0; i < totalCards ~/ 2; i++) {
      values.add(i);
      values.add(i);
    }
    values.shuffle();
    
    setState(() {
      cardValues = values;
      cardFlipped = List.filled(totalCards, false);
      cardMatched = List.filled(totalCards, false);
      firstFlippedIndex = null;
      isProcessing = false;
      _secondsElapsed = 0;
    });
    
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsElapsed++;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _onCardTap(int index) {
    if (isProcessing || cardFlipped[index] || cardMatched[index]) return;

    setState(() {
      cardFlipped[index] = true;
    });

    if (firstFlippedIndex == null) {
      firstFlippedIndex = index;
    } else {
      isProcessing = true;
      if (cardValues[firstFlippedIndex!] == cardValues[index]) {
        // Match!
        setState(() {
          cardMatched[firstFlippedIndex!] = true;
          cardMatched[index] = true;
          score += 10 * level;
          firstFlippedIndex = null;
          isProcessing = false;
        });
        
        if (cardMatched.every((m) => m)) {
          _onLevelComplete();
        }
      } else {
        // No match
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) {
            setState(() {
              cardFlipped[firstFlippedIndex!] = false;
              cardFlipped[index] = false;
              firstFlippedIndex = null;
              isProcessing = false;
            });
          }
        });
      }
    }
  }

  void _onLevelComplete() {
    _timer.cancel();

    // Save score
    final uid = Provider.of<AuthProvider>(context, listen: false).userModel?.uid;
    if (uid != null) {
      _firestoreService.updateUserScore(uid, 'Memory Game', score);
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Level Complete!'),
        content: Text('Score: $score\nTime: $_secondsElapsed seconds'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                level++;
                _startNewLevel();
              });
            },
            child: const Text('Next Level'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory Game'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text('Level: $level', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Score: $score', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text('Time: $_secondsElapsed s', style: const TextStyle(fontSize: 20)),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: gridSize,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: cardValues.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _onCardTap(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        color: cardFlipped[index] || cardMatched[index] ? AppTheme.primaryColor : Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: cardFlipped[index] || cardMatched[index]
                            ? Text(
                                '${cardValues[index]}',
                                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                              ).animate().scale()
                            : const Icon(Icons.help_outline, color: Colors.white54, size: 30),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
