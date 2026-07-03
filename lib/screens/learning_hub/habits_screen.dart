import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  final List<Map<String, dynamic>> _habits = [
    {'name': 'Brush Teeth', 'icon': Icons.clean_hands, 'color': Colors.cyan, 'key': 'habit_brush'},
    {'name': 'Read a Book', 'icon': Icons.menu_book, 'color': Colors.amber, 'key': 'habit_read'},
    {'name': 'Drink Water', 'icon': Icons.water_drop, 'color': Colors.blueAccent, 'key': 'habit_water'},
    {'name': 'Exercise', 'icon': Icons.directions_run, 'color': Colors.greenAccent, 'key': 'habit_exercise'},
    {'name': 'Eat Vegetables', 'icon': Icons.eco, 'color': Colors.lightGreen, 'key': 'habit_veggies'},
    {'name': 'Sleep Early', 'icon': Icons.bedtime, 'color': Colors.deepPurple, 'key': 'habit_sleep'},
  ];

  final Map<String, bool> _completed = {};

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    setState(() {
      for (var h in _habits) {
        _completed[h['key']] = prefs.getBool('${h['key']}_$today') ?? false;
      }
    });
  }

  Future<void> _toggleHabit(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final newVal = !(_completed[key] ?? false);
    await prefs.setBool('${key}_$today', newVal);
    setState(() {
      _completed[key] = newVal;
    });
  }

  int get _completedCount => _completed.values.where((v) => v).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0C29),
      appBar: AppBar(
        title: Text('My Daily Habits', style: GoogleFonts.nunito(fontWeight: FontWeight.bold, fontSize: 22)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Progress header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple.shade800, Colors.indigo.shade700],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.purple.withOpacity(0.3), blurRadius: 12, spreadRadius: 2),
                ],
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CircularProgressIndicator(
                          value: _habits.isEmpty ? 0 : _completedCount / _habits.length,
                          strokeWidth: 6,
                          backgroundColor: Colors.white24,
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                        ),
                        Center(
                          child: Text(
                            '$_completedCount/${_habits.length}',
                            style: GoogleFonts.nunito(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Today's Progress", style: GoogleFonts.nunito(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(
                          _completedCount == _habits.length
                              ? 'All done! Great job! 🎉'
                              : '${_habits.length - _completedCount} habits remaining',
                          style: GoogleFonts.nunito(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Habits list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              itemCount: _habits.length,
              itemBuilder: (context, index) {
                final habit = _habits[index];
                final done = _completed[habit['key']] ?? false;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      color: done ? (habit['color'] as Color).withOpacity(0.15) : Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: done ? (habit['color'] as Color) : Colors.white12,
                        width: 1.5,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      leading: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: (habit['color'] as Color).withOpacity(done ? 0.3 : 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(habit['icon'] as IconData, color: habit['color'] as Color, size: 28),
                      ),
                      title: Text(
                        habit['name'] as String,
                        style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          decoration: done ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      trailing: GestureDetector(
                        onTap: () => _toggleHabit(habit['key'] as String),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: done ? Colors.greenAccent : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: done ? Colors.greenAccent : Colors.white30, width: 2),
                          ),
                          child: done
                              ? const Icon(Icons.check, color: Colors.black, size: 22)
                              : const SizedBox.shrink(),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
