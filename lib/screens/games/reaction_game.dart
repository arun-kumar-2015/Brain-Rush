import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../utils/theme.dart';

enum GameState { waiting, ready, result, tooEarly }

class ReactionGame extends StatefulWidget {
  const ReactionGame({super.key});

  @override
  State<ReactionGame> createState() => _ReactionGameState();
}

class _ReactionGameState extends State<ReactionGame> {
  final _firestoreService = FirestoreService();
  GameState _state = GameState.waiting;
  Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  int _reactionTime = 0;

  void _start() {
    setState(() {
      _state = GameState.waiting;
    });
    
    int delay = Random().nextInt(3000) + 2000; // 2-5 seconds
    _timer = Timer(Duration(milliseconds: delay), () {
      setState(() {
        _state = GameState.ready;
        _stopwatch.reset();
        _stopwatch.start();
      });
    });
  }

  void _onTap() {
    if (_state == GameState.waiting) {
      _timer?.cancel();
      setState(() {
        _state = GameState.tooEarly;
      });
    } else if (_state == GameState.ready) {
      _stopwatch.stop();
      setState(() {
        _reactionTime = _stopwatch.elapsedMilliseconds;
        _state = GameState.result;
      });

      // Save score
      final uid = Provider.of<AuthProvider>(context, listen: false).userModel?.uid;
      if (uid != null) {
        // We track reaction time. In the UI we show best as min.
        _firestoreService.updateUserScore(uid, 'Reaction Test', _reactionTime);
      }
    } else {
      _start();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    String text;
    IconData icon;

    switch (_state) {
      case GameState.waiting:
        bgColor = Colors.red;
        text = 'Wait for Green...';
        icon = Icons.hourglass_empty;
        break;
      case GameState.ready:
        bgColor = Colors.green;
        text = 'TAP NOW!';
        icon = Icons.touch_app;
        break;
      case GameState.result:
        bgColor = AppTheme.primaryColor;
        text = '${_reactionTime}ms';
        icon = Icons.speed;
        break;
      case GameState.tooEarly:
        bgColor = Colors.orange;
        text = 'Too Early! Tap to restart.';
        icon = Icons.warning_amber;
        break;
    }

    return Scaffold(
      backgroundColor: bgColor,
      body: GestureDetector(
        onTap: _onTap,
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 100, color: Colors.white),
              const SizedBox(height: 20),
              Text(
                text,
                style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              if (_state == GameState.result || _state == GameState.tooEarly)
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: const Text('Tap anywhere to try again', style: TextStyle(color: Colors.white70, fontSize: 18)),
                ),
              if (_state == GameState.result)
                 Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Back to Menu'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
