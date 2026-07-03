import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/games/memory_game.dart';
import 'screens/games/math_game.dart';
import 'screens/games/pattern_game.dart';
import 'screens/games/reaction_game.dart';
import 'screens/splash_screen.dart';
import 'screens/leaderboard_screen.dart';
import 'screens/progress_screen.dart';
import 'utils/theme.dart';
import 'utils/constants.dart';
import 'firebase_options.dart'; // Import the generated options

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Now using the actual generated options from your project!
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase initialization error: $e");
  }

  runApp(const BrainRushApp());
}

class BrainRushApp extends StatelessWidget {
  const BrainRushApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            home: FutureBuilder(
              future: Future.delayed(const Duration(seconds: 3)),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SplashScreen();
                }
                return auth.userModel != null ? const MainNavigationScreen() : const AuthScreen();
              },
            ),
            routes: {
              '/memory': (context) => const MemoryGame(),
              '/math': (context) => const MathGame(),
              '/pattern': (context) => const PatternGame(),
              '/reaction': (context) => const ReactionGame(),
              '/leaderboard': (context) => const LeaderboardScreen(),
              '/progress': (context) => const ProgressScreen(),
            },
          );
        },
      ),
    );
  }
}
