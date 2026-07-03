import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  void _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      // The decision of where to go next is handled in main.dart
      // This is just a visual delay
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.primaryColor, AppTheme.darkBackgroundColor],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.secondaryColor.withOpacity(0.5),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: const Icon(
                Icons.psychology,
                size: 80,
                color: AppTheme.primaryColor,
              ),
            ).animate()
             .scale(duration: 600.ms, curve: Curves.easeOutBack)
             .then()
             .shake(duration: 500.ms),
            
            const SizedBox(height: 30),
            
            Text(
              AppConstants.appName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.5),
            
            const SizedBox(height: 10),
            
            const Text(
              'CHALLENGE YOUR MIND',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                letterSpacing: 4,
              ),
            ).animate().fadeIn(delay: 800.ms),
            
            const SizedBox(height: 100),
            
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
            ).animate().fadeIn(delay: 1200.ms),
          ],
        ),
      ),
    );
  }
}
