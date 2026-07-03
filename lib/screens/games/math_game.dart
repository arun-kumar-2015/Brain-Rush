import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../utils/difficulty_manager.dart';
import '../../utils/theme.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MathGame extends StatefulWidget {
  const MathGame({super.key});

  @override
  State<MathGame> createState() => _MathGameState();
}

class _MathGameState extends State<MathGame> {
  final _firestoreService = FirestoreService();
  int level = 1;
  int score = 0;
  late int num1;
  late int num2;
  late String operator;
  late int correctAnswer;
  List<int> options = [];
  int timeLeft = 10;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _generateQuestion();
  }

  void _generateQuestion() {
    final rand = Random();
    final operators = DifficultyManager.getMathOperators(level);
    operator = operators[rand.nextInt(operators.length)];
    
    int range = DifficultyManager.getMathRange(level);
    num1 = rand.nextInt(range) + 1;
    num2 = rand.nextInt(range) + 1;

    switch (operator) {
      case '+':
        correctAnswer = num1 + num2;
        break;
      case '-':
        if (num1 < num2) {
          int temp = num1;
          num1 = num2;
          num2 = temp;
        }
        correctAnswer = num1 - num2;
        break;
      case '*':
        num1 = rand.nextInt(level + 5) + 1;
        num2 = rand.nextInt(level + 5) + 1;
        correctAnswer = num1 * num2;
        break;
      default:
        correctAnswer = num1 + num2;
    }

    options = [correctAnswer];
    while (options.length < 4) {
      int wrong = correctAnswer + rand.nextInt(20) - 10;
      if (!options.contains(wrong) && wrong >= 0) {
        options.add(wrong);
      }
    }
    options.shuffle();
    
    timeLeft = 10;
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (timeLeft > 0) {
          timeLeft--;
        } else {
          _onTimeUp();
        }
      });
    });
  }

  void _onTimeUp() {
    _timer?.cancel();
    _saveAndShowGameOver('Time Up!');
  }

  void _onAnswer(int answer) {
    if (answer == correctAnswer) {
      setState(() {
        score += 10;
        if (score % 50 == 0) level++;
        _generateQuestion();
      });
    } else {
      _timer?.cancel();
      _saveAndShowGameOver('Wrong Answer!');
    }
  }

  void _saveAndShowGameOver(String message) {
    // Save score
    final uid = Provider.of<AuthProvider>(context, listen: false).userModel?.uid;
    if (uid != null) {
      _firestoreService.updateUserScore(uid, 'Math Speed', score);
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(message),
        content: Text('Final Score: $score'),
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
                score = 0;
                level = 1;
                _generateQuestion();
              });
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Math Speed')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Score: $score', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                CircularProgressIndicator(
                  value: timeLeft / 10,
                  color: timeLeft < 4 ? Colors.red : AppTheme.primaryColor,
                ),
              ],
            ),
            Expanded(
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '$num1 $operator $num2 = ?',
                    style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
                  ),
                ),
              ).animate(key: ValueKey(num1 + num2)).scale().fadeIn(),
            ),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              childAspectRatio: 2,
              children: options.map((opt) {
                return ElevatedButton(
                  onPressed: () => _onAnswer(opt),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primaryColor,
                    side: const BorderSide(color: AppTheme.primaryColor, width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text('$opt', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                );
              }).toList(),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
