import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'letter_tracing_screen.dart';
import 'word_writing_screen.dart';
import 'sentence_writing_screen.dart';
import 'creative_writing_screen.dart';

class WritingHubScreen extends StatelessWidget {
  const WritingHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0C29),
      appBar: AppBar(
        title: Text('Writing Skills', style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          _buildWritingCard(context, 'Letter Tracing', Icons.draw, Colors.red, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const LetterTracingScreen()));
          }),
          _buildWritingCard(context, 'Word Writing', Icons.edit, Colors.blue, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const WordWritingScreen()));
          }),
          _buildWritingCard(context, 'Sentence Writing', Icons.short_text, Colors.green, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SentenceWritingScreen()));
          }),
          _buildWritingCard(context, 'Creative Writing', Icons.mic, Colors.orange, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const CreativeWritingScreen()));
          }),
        ],
      ),
    );
  }

  Widget _buildWritingCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.4), width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
