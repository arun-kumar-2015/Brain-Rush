import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ParentDashboardScreen extends StatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
  int _totalHabitsCompleted = 0;
  int _totalGamesPlayed = 0;
  int _readingStreak = 0;
  int _wordsLearned = 0;
  double _screenTimeMinutes = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);

    // Count habits completed today
    int habitsCount = 0;
    final habitKeys = ['habit_brush', 'habit_read', 'habit_water', 'habit_exercise', 'habit_veggies', 'habit_sleep'];
    for (var key in habitKeys) {
      if (prefs.getBool('${key}_$today') ?? false) habitsCount++;
    }

    setState(() {
      _totalHabitsCompleted = habitsCount;
      _totalGamesPlayed = prefs.getInt('total_games_played') ?? 0;
      _readingStreak = prefs.getInt('reading_streak') ?? 0;
      _wordsLearned = prefs.getInt('words_learned') ?? 0;
      _screenTimeMinutes = prefs.getDouble('screen_time_today') ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0C29),
      appBar: AppBar(
        title: Text('Parent Dashboard', style: GoogleFonts.nunito(fontWeight: FontWeight.bold, fontSize: 22)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            onPressed: _loadStats,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepPurple.shade700, Colors.indigo.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.deepPurple.withOpacity(0.4), blurRadius: 16, spreadRadius: 2),
                ],
              ),
              child: Column(
                children: [
                  const Icon(Icons.family_restroom, color: Colors.white, size: 48),
                  const SizedBox(height: 12),
                  Text("Child's Activity Summary", style: GoogleFonts.nunito(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Today\'s Overview', style: GoogleFonts.nunito(color: Colors.white60, fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Stats grid
            Text('Activity Stats', style: GoogleFonts.nunito(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.3,
              children: [
                _statCard('Habits Done', '$_totalHabitsCompleted/6', Icons.check_circle, Colors.greenAccent),
                _statCard('Games Played', '$_totalGamesPlayed', Icons.gamepad, Colors.orangeAccent),
                _statCard('Reading Streak', '$_readingStreak days', Icons.local_fire_department, Colors.redAccent),
                _statCard('Words Learned', '$_wordsLearned', Icons.abc, Colors.cyanAccent),
              ],
            ),
            const SizedBox(height: 28),

            // Screen time card
            Text('Screen Time', style: GoogleFonts.nunito(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.timer, color: Colors.blueAccent, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${_screenTimeMinutes.toInt()} minutes today', style: GoogleFonts.nunito(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: (_screenTimeMinutes / 120).clamp(0.0, 1.0),
                            backgroundColor: Colors.white12,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _screenTimeMinutes > 90 ? Colors.redAccent : Colors.greenAccent,
                            ),
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _screenTimeMinutes > 90 ? 'Consider a break!' : 'Within healthy limits',
                          style: GoogleFonts.nunito(
                            color: _screenTimeMinutes > 90 ? Colors.redAccent : Colors.greenAccent,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Tips
            Text('Parenting Tips', style: GoogleFonts.nunito(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _tipCard('🎯 Encourage your child to complete all daily habits for a streak bonus!'),
            const SizedBox(height: 10),
            _tipCard('📚 Reading together for 15 minutes daily improves vocabulary significantly.'),
            const SizedBox(height: 10),
            _tipCard('⏰ Set consistent screen time limits to promote healthy device usage.'),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.nunito(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title, style: GoogleFonts.nunito(color: Colors.white60, fontSize: 12), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _tipCard(String tip) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withOpacity(0.2)),
      ),
      child: Text(tip, style: GoogleFonts.nunito(color: Colors.white70, fontSize: 14)),
    );
  }
}
