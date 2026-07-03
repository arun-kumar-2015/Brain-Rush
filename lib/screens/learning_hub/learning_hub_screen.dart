import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import 'english/english_hub_screen.dart';
import 'reading/reading_hub_screen.dart';
import 'writing/writing_hub_screen.dart';
import 'vocabulary/vocabulary_hub_screen.dart';
import 'parent_dashboard_screen.dart';


class LearningHubScreen extends StatelessWidget {
  const LearningHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Hub', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'What do you want to learn today?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildCategoryCard(
              context,
              'English Basics',
              'Alphabets, Phonics, Grammar',
              Icons.abc,
              Colors.blue,
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EnglishHubScreen())),
            ),
            const SizedBox(height: 16),
            _buildCategoryCard(
              context,
              'Reading Skills',
              'Stories, Comprehension',
              Icons.menu_book,
              Colors.green,
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReadingHubScreen())),
            ),
            const SizedBox(height: 16),
            _buildCategoryCard(
              context,
              'Writing Skills',
              'Tracing, Sentences, Essays',
              Icons.edit,
              Colors.orange,
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WritingHubScreen())),
            ),
            const SizedBox(height: 16),
            _buildCategoryCard(
              context,
              'Vocabulary Builder',
              'Daily Words, Spelling, Matching',
              Icons.sort_by_alpha,
              Colors.purple,
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VocabularyHubScreen())),
            ),
            const SizedBox(height: 16),
            _buildCategoryCard(
              context,
              'Habits & Dashboard',
              'Track habits, view parent dashboard',
              Icons.track_changes,
              Colors.teal,
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ParentDashboardScreen())),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
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
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
