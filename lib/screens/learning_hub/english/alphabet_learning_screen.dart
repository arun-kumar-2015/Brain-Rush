import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../services/audio_service.dart';

// ── Complete alphabet data ──────────────────────────────────────────────────
class _LetterData {
  final String letter;
  final String word;
  final String emoji;
  final String phonics;
  final Color color;
  const _LetterData(this.letter, this.word, this.emoji, this.phonics, this.color);
}

const List<_LetterData> _alphabetData = [
  _LetterData('A', 'Apple',    '🍎', '/æ/ as in Apple',       Color(0xFFE53935)),
  _LetterData('B', 'Ball',     '⚽', '/b/ as in Ball',        Color(0xFF1E88E5)),
  _LetterData('C', 'Cat',      '🐱', '/k/ as in Cat',         Color(0xFFFF8F00)),
  _LetterData('D', 'Dog',      '🐶', '/d/ as in Dog',         Color(0xFF6D4C41)),
  _LetterData('E', 'Elephant', '🐘', '/ɛ/ as in Elephant',    Color(0xFF8E24AA)),
  _LetterData('F', 'Fish',     '🐟', '/f/ as in Fish',        Color(0xFF00ACC1)),
  _LetterData('G', 'Grapes',   '🍇', '/g/ as in Grapes',      Color(0xFF7B1FA2)),
  _LetterData('H', 'Hat',      '🎩', '/h/ as in Hat',         Color(0xFF00897B)),
  _LetterData('I', 'Igloo',    '🏔️', '/ɪ/ as in Igloo',       Color(0xFF039BE5)),
  _LetterData('J', 'Jug',      '🫙', '/dʒ/ as in Jug',        Color(0xFFF4511E)),
  _LetterData('K', 'Kite',     '🪁', '/k/ as in Kite',        Color(0xFF43A047)),
  _LetterData('L', 'Lion',     '🦁', '/l/ as in Lion',        Color(0xFFFFB300)),
  _LetterData('M', 'Monkey',   '🐒', '/m/ as in Monkey',      Color(0xFF795548)),
  _LetterData('N', 'Nest',     '🪺', '/n/ as in Nest',        Color(0xFF546E7A)),
  _LetterData('O', 'Orange',   '🍊', '/ɒ/ as in Orange',      Color(0xFFEF6C00)),
  _LetterData('P', 'Parrot',   '🦜', '/p/ as in Parrot',      Color(0xFF2E7D32)),
  _LetterData('Q', 'Queen',    '👑', '/kw/ as in Queen',      Color(0xFFAD1457)),
  _LetterData('R', 'Rabbit',   '🐇', '/r/ as in Rabbit',      Color(0xFFE91E63)),
  _LetterData('S', 'Sun',      '☀️', '/s/ as in Sun',          Color(0xFFF9A825)),
  _LetterData('T', 'Tiger',    '🐯', '/t/ as in Tiger',       Color(0xFFFF6F00)),
  _LetterData('U', 'Umbrella', '☂️', '/ʌ/ as in Umbrella',    Color(0xFF1565C0)),
  _LetterData('V', 'Violin',   '🎻', '/v/ as in Violin',      Color(0xFF558B2F)),
  _LetterData('W', 'Whale',    '🐋', '/w/ as in Whale',       Color(0xFF00838F)),
  _LetterData('X', 'X-ray',   '🔬', '/ks/ as in X-ray',      Color(0xFF4527A0)),
  _LetterData('Y', 'Yak',      '🐃', '/j/ as in Yak',         Color(0xFF6A1B9A)),
  _LetterData('Z', 'Zebra',    '🦓', '/z/ as in Zebra',       Color(0xFF37474F)),
];

class AlphabetLearningScreen extends StatefulWidget {
  const AlphabetLearningScreen({super.key});

  @override
  State<AlphabetLearningScreen> createState() => _AlphabetLearningScreenState();
}

class _AlphabetLearningScreenState extends State<AlphabetLearningScreen>
    with TickerProviderStateMixin {
  final AudioService _audio = AudioService();
  int _currentIndex = 0;
  bool _isSpeaking = false;
  bool _showAll = false;
  int _speakToken = 0;

  _LetterData get _current => _alphabetData[_currentIndex];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speakLetter();
    });
  }

  Future<void> _speakLetter() async {
    final myToken = ++_speakToken;
    setState(() => _isSpeaking = true);
    await _audio.speakLetter(_current.letter);
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted || _speakToken != myToken) return;
    await _audio.speakWord(_current.word);
    if (mounted && _speakToken == myToken) {
      setState(() => _isSpeaking = false);
    }
  }

  Future<void> _speakPhonics() async {
    final myToken = ++_speakToken;
    setState(() => _isSpeaking = true);
    await _audio.speakPhonics(_current.letter);
    if (mounted && _speakToken == myToken) {
      setState(() => _isSpeaking = false);
    }
  }

  void _navigate(int delta) {
    final next = _currentIndex + delta;
    if (next >= 0 && next < _alphabetData.length) {
      _audio.stop();
      setState(() {
        _currentIndex = next;
      });
      _speakLetter();
    }
  }

  @override
  void dispose() {
    _speakToken = -1; // invalidate any active speak operations
    _audio.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0C29),
      body: SafeArea(
        child: _showAll ? _buildGridView() : _buildDetailView(),
      ),
    );
  }

  // ── Detail card view ───────────────────────────────────────────────────────
  Widget _buildDetailView() {
    final data = _current;
    return Column(
      children: [
        // AppBar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              ),
              Expanded(
                child: Text('Alphabet Learning',
                    style: GoogleFonts.nunito(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800)),
              ),
              IconButton(
                onPressed: () => setState(() => _showAll = true),
                icon: const Icon(Icons.grid_view_rounded, color: Colors.white70),
              ),
            ],
          ),
        ),
        // Progress bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${_currentIndex + 1} / 26',
                      style: GoogleFonts.nunito(color: Colors.white54, fontSize: 13)),
                  Text('${((_currentIndex + 1) / 26 * 100).round()}%',
                      style: GoogleFonts.nunito(color: Colors.white54, fontSize: 13)),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (_currentIndex + 1) / 26,
                  backgroundColor: Colors.white12,
                  valueColor: AlwaysStoppedAnimation<Color>(data.color),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Main letter card
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                // Big letter display
                Expanded(
                  flex: 3,
                  child: GestureDetector(
                    onTap: _speakLetter,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            data.color.withOpacity(0.8),
                            data.color.withOpacity(0.3),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: data.color.withOpacity(0.5),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Background emoji
                          Positioned(
                            right: 20,
                            bottom: 20,
                            child: Text(data.emoji,
                                style: const TextStyle(fontSize: 80))
                                .animate(key: ValueKey(_currentIndex))
                                .fadeIn(duration: 400.ms)
                                .slideX(begin: 0.3),
                          ),
                          // Letter
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                data.letter,
                                style: GoogleFonts.nunito(
                                  fontSize: 120,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  height: 1,
                                ),
                              ).animate(key: ValueKey(_currentIndex))
                                  .fadeIn(duration: 300.ms)
                                  .scale(begin: const Offset(0.7, 0.7)),
                              Text(
                                data.letter.toLowerCase(),
                                style: GoogleFonts.nunito(
                                  fontSize: 60,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white70,
                                  height: 1,
                                ),
                              ),
                            ],
                          ),
                          // Speak hint
                          Positioned(
                            top: 16,
                            right: 16,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: _isSpeaking
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation(Colors.white),
                                        ),
                                      )
                                    : const Icon(Icons.volume_up_rounded,
                                        color: Colors.white, size: 24),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Word card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    children: [
                      Text(data.emoji, style: const TextStyle(fontSize: 40)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(data.word,
                                style: GoogleFonts.nunito(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800)),
                            Text(data.phonics,
                                style: GoogleFonts.nunito(
                                    color: Colors.white54, fontSize: 14)),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _audio.speakWord(data.word),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: data.color.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.volume_up_rounded,
                              color: data.color, size: 22),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: _ActionBtn(
                        icon: Icons.abc,
                        label: 'Say Letter',
                        color: data.color,
                        onTap: _speakLetter,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ActionBtn(
                        icon: Icons.spatial_audio_off_rounded,
                        label: 'Phonics',
                        color: const Color(0xFF9C27B0),
                        onTap: _speakPhonics,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Navigation
                Row(
                  children: [
                    _NavBtn(
                      icon: Icons.arrow_back_ios_new,
                      label: 'Prev',
                      enabled: _currentIndex > 0,
                      onTap: () => _navigate(-1),
                    ),
                    const Spacer(),
                    // Dot indicators (show 5 around current)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(5, (i) {
                        final dotIndex = (_currentIndex - 2 + i).clamp(0, 25);
                        final isActive = dotIndex == _currentIndex;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: isActive ? 20 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isActive ? data.color : Colors.white24,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                    const Spacer(),
                    _NavBtn(
                      icon: Icons.arrow_forward_ios,
                      label: 'Next',
                      enabled: _currentIndex < 25,
                      onTap: () => _navigate(1),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Grid overview view ─────────────────────────────────────────────────────
  Widget _buildGridView() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              IconButton(
                onPressed: () => setState(() => _showAll = false),
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              ),
              Text('All 26 Letters',
                  style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800)),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 0.85,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            itemCount: 26,
            itemBuilder: (ctx, i) {
              final d = _alphabetData[i];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _currentIndex = i;
                    _showAll = false;
                  });
                  _audio.speakLetter(d.letter);
                },
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [d.color.withOpacity(0.7), d.color.withOpacity(0.3)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: _currentIndex == i ? Colors.white : Colors.transparent,
                        width: 2),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(d.letter,
                          style: GoogleFonts.nunito(
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              color: Colors.white)),
                      Text(d.emoji, style: const TextStyle(fontSize: 22)),
                      Text(d.word,
                          style: GoogleFonts.nunito(
                              fontSize: 10,
                              color: Colors.white70,
                              fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: (i * 30).ms, duration: 400.ms).scale(
                  begin: const Offset(0.8, 0.8));
            },
          ),
        ),
      ],
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(label,
                style: GoogleFonts.nunito(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onTap;
  const _NavBtn({required this.icon, required this.label, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: enabled ? Colors.white12 : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            if (label == 'Prev') Icon(icon, color: enabled ? Colors.white : Colors.white30, size: 16),
            if (label == 'Prev') const SizedBox(width: 6),
            Text(label, style: GoogleFonts.nunito(color: enabled ? Colors.white : Colors.white30, fontWeight: FontWeight.w700)),
            if (label == 'Next') const SizedBox(width: 6),
            if (label == 'Next') Icon(icon, color: enabled ? Colors.white : Colors.white30, size: 16),
          ],
        ),
      ),
    );
  }
}
