import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'daily_words_screen.dart';
import 'word_matching_screen.dart';
import 'spelling_challenges_screen.dart';
import 'pronunciation_mock_screen.dart';


class VocabularyHubScreen extends StatelessWidget {
  const VocabularyHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0C29),
      appBar: AppBar(
        title: Text('Vocabulary Builder', style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildVocabItem(context, 'Daily New Words', Icons.calendar_today, Colors.teal, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const DailyWordsScreen()));
          }),
          const SizedBox(height: 12),
          _buildVocabItem(context, 'Word Matching Game', Icons.extension, Colors.pink, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const WordMatchingScreen()));
          }),
          const SizedBox(height: 12),
          _buildVocabItem(context, 'Spelling Challenges', Icons.spellcheck, Colors.indigo, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SpellingChallengesScreen()));
          }),
          const SizedBox(height: 12),
          _buildVocabItem(context, 'Pronunciation Practice', Icons.record_voice_over, Colors.orange, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const PronunciationMockScreen()));
          }),
        ],
      ),
    );
  }

  Widget _buildVocabItem(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(backgroundColor: color.withOpacity(0.2), child: Icon(icon, color: color)),
      title: Text(title, style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
      trailing: const Icon(Icons.play_circle_fill, color: Colors.indigoAccent),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.white12)),
      tileColor: Colors.white.withOpacity(0.05),
    );
  }
}
