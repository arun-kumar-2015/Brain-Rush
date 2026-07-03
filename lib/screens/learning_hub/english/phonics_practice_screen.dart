import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../services/audio_service.dart';

class _PhonicData {
  final String letter;
  final String word;
  final String emoji;
  final String sound;    // phonics symbol
  final String example;  // "The 'a' in Apple sounds like 'aah'"
  final Color color;
  const _PhonicData(this.letter, this.word, this.emoji, this.sound, this.example, this.color);
}

const List<_PhonicData> _phonicsData = [
  _PhonicData('A', 'Apple',    '🍎', 'æ',  '"a" sounds like AAH',     Color(0xFFE53935)),
  _PhonicData('B', 'Ball',     '⚽', 'b',  '"b" sounds like BUH',     Color(0xFF1E88E5)),
  _PhonicData('C', 'Cat',      '🐱', 'k',  '"c" sounds like KUH',     Color(0xFFFF8F00)),
  _PhonicData('D', 'Dog',      '🐶', 'd',  '"d" sounds like DUH',     Color(0xFF6D4C41)),
  _PhonicData('E', 'Elephant', '🐘', 'ɛ',  '"e" sounds like EH',      Color(0xFF8E24AA)),
  _PhonicData('F', 'Fish',     '🐟', 'f',  '"f" sounds like FFF',     Color(0xFF00ACC1)),
  _PhonicData('G', 'Grapes',   '🍇', 'g',  '"g" sounds like GUH',     Color(0xFF7B1FA2)),
  _PhonicData('H', 'Hat',      '🎩', 'h',  '"h" sounds like HUH',     Color(0xFF00897B)),
  _PhonicData('I', 'Igloo',    '🏔️', 'ɪ',  '"i" sounds like IH',      Color(0xFF039BE5)),
  _PhonicData('J', 'Jug',      '🫙', 'dʒ', '"j" sounds like JUH',     Color(0xFFF4511E)),
  _PhonicData('K', 'Kite',     '🪁', 'k',  '"k" sounds like KUH',     Color(0xFF43A047)),
  _PhonicData('L', 'Lion',     '🦁', 'l',  '"l" sounds like LLL',     Color(0xFFFFB300)),
  _PhonicData('M', 'Monkey',   '🐒', 'm',  '"m" sounds like MMM',     Color(0xFF795548)),
  _PhonicData('N', 'Nest',     '🪺', 'n',  '"n" sounds like NNN',     Color(0xFF546E7A)),
  _PhonicData('O', 'Orange',   '🍊', 'ɒ',  '"o" sounds like OH',      Color(0xFFEF6C00)),
  _PhonicData('P', 'Parrot',   '🦜', 'p',  '"p" sounds like PUH',     Color(0xFF2E7D32)),
  _PhonicData('Q', 'Queen',    '👑', 'kw', '"q" sounds like KWUH',    Color(0xFFAD1457)),
  _PhonicData('R', 'Rabbit',   '🐇', 'r',  '"r" sounds like RRR',     Color(0xFFE91E63)),
  _PhonicData('S', 'Sun',      '☀️', 's',  '"s" sounds like SSS',     Color(0xFFF9A825)),
  _PhonicData('T', 'Tiger',    '🐯', 't',  '"t" sounds like TUH',     Color(0xFFFF6F00)),
  _PhonicData('U', 'Umbrella', '☂️', 'ʌ',  '"u" sounds like UH',      Color(0xFF1565C0)),
  _PhonicData('V', 'Violin',   '🎻', 'v',  '"v" sounds like VVV',     Color(0xFF558B2F)),
  _PhonicData('W', 'Whale',    '🐋', 'w',  '"w" sounds like WUH',     Color(0xFF00838F)),
  _PhonicData('X', 'X-ray',   '🔬', 'ks', '"x" sounds like EKS',     Color(0xFF4527A0)),
  _PhonicData('Y', 'Yak',      '🐃', 'j',  '"y" sounds like YUH',     Color(0xFF6A1B9A)),
  _PhonicData('Z', 'Zebra',    '🦓', 'z',  '"z" sounds like ZZZ',     Color(0xFF37474F)),
];

class PhonicsPracticeScreen extends StatefulWidget {
  const PhonicsPracticeScreen({super.key});

  @override
  State<PhonicsPracticeScreen> createState() => _PhonicsPracticeScreenState();
}

class _PhonicsPracticeScreenState extends State<PhonicsPracticeScreen> {
  final AudioService _audio = AudioService();
  int? _activeLetter;

  Future<void> _playPhonics(int index) async {
    setState(() => _activeLetter = index);
    final d = _phonicsData[index];
    await _audio.speakPhonics(d.letter);
    await Future.delayed(const Duration(milliseconds: 600));
    await _audio.speakWord(d.word);
    if (mounted) setState(() => _activeLetter = null);
  }

  @override
  void dispose() {
    _audio.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0C29),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                  ),
                  const SizedBox(width: 4),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Phonics Practice',
                          style: GoogleFonts.nunito(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800)),
                      Text('Tap a card to hear the sound!',
                          style: GoogleFonts.nunito(
                              color: Colors.white54, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            // Info banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7B1FA2), Color(0xFF9C27B0)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.spatial_audio_rounded, color: Colors.white),
                    const SizedBox(width: 10),
                    Text('Phonics = the sounds letters make in words',
                        style: GoogleFonts.nunito(
                            color: Colors.white, fontSize: 13)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.1,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                ),
                itemCount: _phonicsData.length,
                itemBuilder: (ctx, i) => _PhonicCard(
                  data: _phonicsData[i],
                  isActive: _activeLetter == i,
                  onTap: () => _playPhonics(i),
                ).animate().fadeIn(delay: (i * 25).ms, duration: 400.ms)
                  .slideY(begin: 0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhonicCard extends StatelessWidget {
  final _PhonicData data;
  final bool isActive;
  final VoidCallback onTap;
  const _PhonicCard({required this.data, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isActive
                ? [data.color, data.color.withOpacity(0.6)]
                : [data.color.withOpacity(0.15), data.color.withOpacity(0.05)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isActive ? data.color : data.color.withOpacity(0.4),
              width: isActive ? 2.5 : 1.5),
          boxShadow: isActive
              ? [BoxShadow(color: data.color.withOpacity(0.5), blurRadius: 16, spreadRadius: 2)]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Letter + phonics symbol
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(data.letter,
                    style: GoogleFonts.nunito(
                        fontSize: 52,
                        fontWeight: FontWeight.w900,
                        color: isActive ? Colors.white : data.color,
                        height: 1)),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10, left: 4),
                  child: Text('/${data.sound}/',
                      style: GoogleFonts.nunito(
                          fontSize: 16,
                          color: isActive ? Colors.white70 : Colors.white54,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            // Emoji
            Text(data.emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 4),
            // Word
            Text(data.word,
                style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isActive ? Colors.white : Colors.white70)),
            // Example sound description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(data.example,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                      fontSize: 11,
                      color: isActive ? Colors.white60 : Colors.white38)),
            ),
            // Speaker icon
            Icon(
              isActive ? Icons.hearing_rounded : Icons.volume_up_rounded,
              color: isActive ? Colors.white : data.color,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
