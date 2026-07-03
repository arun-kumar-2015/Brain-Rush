import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';
import '../widgets/game_card.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.userModel;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => auth.logout(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundImage: user?.photoUrl != '' ? NetworkImage(user!.photoUrl) : null,
                      child: user?.photoUrl == '' ? const Icon(Icons.person, size: 40) : null,
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, ${user?.name ?? "User"}!',
                            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Total Score: ${user?.totalScore ?? 0}',
                            style: const TextStyle(color: Colors.white70, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: -0.2),
              
              const SizedBox(height: 30),
              
              Text(
                'Challenges',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              
              const SizedBox(height: 20),
              
              // Games List
              Column(
                children: [
                  _buildGameListItem(
                    context,
                    AppConstants.memoryGame,
                    Icons.grid_view_rounded,
                    Colors.orange,
                    '/memory',
                  ),
                  const SizedBox(height: 12),
                  _buildGameListItem(
                    context,
                    AppConstants.mathGame,
                    Icons.functions_rounded,
                    Colors.green,
                    '/math',
                  ),
                  const SizedBox(height: 12),
                  _buildGameListItem(
                    context,
                    AppConstants.patternGame,
                    Icons.auto_awesome_motion_rounded,
                    Colors.purple,
                    '/pattern',
                  ),
                  const SizedBox(height: 12),
                  _buildGameListItem(
                    context,
                    AppConstants.reactionGame,
                    Icons.timer_rounded,
                    Colors.redAccent,
                    '/reaction',
                  ),
                ],
              ).animate().fadeIn(delay: 200.ms),
              
              const SizedBox(height: 30),
              
              // Bottom Navigation Buttons
              Row(
                children: [
                  Expanded(
                    child: _buildNavButton(
                      context,
                      'Leaderboard',
                      Icons.leaderboard,
                      Colors.blueGrey,
                      () => Navigator.pushNamed(context, '/leaderboard'),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _buildNavButton(
                      context,
                      'Progress',
                      Icons.insights,
                      Colors.teal,
                      () => Navigator.pushNamed(context, '/progress'),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 400.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameListItem(BuildContext context, String title, IconData icon, Color color, String route) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Tap to play challenge',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
