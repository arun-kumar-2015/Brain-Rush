import 'package:flutter/material.dart';
import 'alphabet_learning_screen.dart';
import 'phonics_practice_screen.dart';

class EnglishHubScreen extends StatelessWidget {
  const EnglishHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('English Basics')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildItem(context, 'Alphabet (A-Z)', Icons.sort_by_alpha, Colors.blue, () {
             Navigator.push(context, MaterialPageRoute(builder: (_) => const AlphabetLearningScreen()));
          }),
          const SizedBox(height: 12),
          _buildItem(context, 'Phonics & Sounds', Icons.record_voice_over, Colors.orange, () {
             Navigator.push(context, MaterialPageRoute(builder: (_) => const PhonicsPracticeScreen()));
          }),
          const SizedBox(height: 12),
          _buildItem(context, 'Pronunciation Check (Mock)', Icons.mic, Colors.red, () {
             // Mock
             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mock: Say "Apple"')));
          }),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(backgroundColor: color.withOpacity(0.2), child: Icon(icon, color: color)),
      title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.play_circle_fill, color: Colors.grey),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade300)),
      tileColor: Colors.white,
    );
  }
}
