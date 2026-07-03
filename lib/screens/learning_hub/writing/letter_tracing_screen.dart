import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LetterTracingScreen extends StatefulWidget {
  const LetterTracingScreen({super.key});

  @override
  State<LetterTracingScreen> createState() => _LetterTracingScreenState();
}

class _LetterTracingScreenState extends State<LetterTracingScreen> {
  final List<String> _letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('');
  int _currentLetterIdx = 0;
  List<Offset?> _points = [];
  Color _penColor = Colors.orange;
  double _penWidth = 22.0;
  final GlobalKey _canvasKey = GlobalKey();
  bool _showSuccess = false;

  void _nextLetter() {
    if (_currentLetterIdx < _letters.length - 1) {
      setState(() {
        _currentLetterIdx++;
        _points.clear();
        _showSuccess = false;
      });
    }
  }

  void _prevLetter() {
    if (_currentLetterIdx > 0) {
      setState(() {
        _currentLetterIdx--;
        _points.clear();
        _showSuccess = false;
      });
    }
  }

  void _checkCompletion() {
    // Simple heuristic: if enough points drawn, consider it traced
    final validPoints = _points.where((p) => p != null).length;
    if (validPoints > 50 && !_showSuccess) {
      setState(() => _showSuccess = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final letter = _letters[_currentLetterIdx];
    return Scaffold(
      backgroundColor: const Color(0xFF0F0C29),
      appBar: AppBar(
        title: Text('Letter Tracing', style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Letter selector row
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, color: Colors.white, size: 36),
                    onPressed: _prevLetter,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Trace: $letter',
                      style: GoogleFonts.nunito(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, color: Colors.white, size: 36),
                    onPressed: _nextLetter,
                  ),
                ],
              ),
            ),
            // Success message
            if (_showSuccess)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Great tracing! 🎉',
                  style: GoogleFonts.nunito(color: Colors.greenAccent, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            // Canvas Area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  key: _canvasKey,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white24, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final canvasSize = Size(constraints.maxWidth, constraints.maxHeight);
                        return Stack(
                          children: [
                            // Background letter outline
                            Positioned.fill(
                              child: CustomPaint(
                                painter: LetterBackgroundPainter(letter: letter),
                              ),
                            ),
                            // Drawing layer - uses GestureDetector on this specific widget
                            Positioned.fill(
                              child: GestureDetector(
                                onPanStart: (details) {
                                  final localPos = details.localPosition;
                                  // Check if within letter bounds
                                  final letterPath = _getLetterBoundsPath(letter, canvasSize);
                                  if (letterPath.contains(localPos)) {
                                    setState(() {
                                      _points.add(localPos);
                                    });
                                  }
                                },
                                onPanUpdate: (details) {
                                  final localPos = details.localPosition;
                                  final letterPath = _getLetterBoundsPath(letter, canvasSize);
                                  if (letterPath.contains(localPos)) {
                                    setState(() {
                                      _points.add(localPos);
                                    });
                                  }
                                },
                                onPanEnd: (details) {
                                  setState(() {
                                    _points.add(null); // break the line
                                  });
                                  _checkCompletion();
                                },
                                child: CustomPaint(
                                  size: canvasSize,
                                  painter: TracingFillPainter(
                                    points: _points,
                                    color: _penColor,
                                    width: _penWidth,
                                    letter: letter,
                                    canvasSize: canvasSize,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            // Tools row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Pen colors
                  Row(
                    children: [Colors.orange, Colors.red, Colors.green, Colors.blue, Colors.purple].map((c) {
                      final isSelected = _penColor == c;
                      return GestureDetector(
                        onTap: () => setState(() => _penColor = c),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          width: isSelected ? 36 : 28,
                          height: isSelected ? 36 : 28,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? Colors.white : Colors.transparent,
                              width: 2.5,
                            ),
                            boxShadow: isSelected
                                ? [BoxShadow(color: c.withOpacity(0.6), blurRadius: 8, spreadRadius: 1)]
                                : [],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  // Clear button
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    icon: const Icon(Icons.refresh),
                    label: Text('Reset', style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
                    onPressed: () {
                      setState(() {
                        _points.clear();
                        _showSuccess = false;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Returns a path that covers the letter's bounding area for hit-testing.
  Path _getLetterBoundsPath(String letter, Size size) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: letter,
        style: GoogleFonts.nunito(
          fontSize: 240,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    final offset = Offset(
      (size.width - textPainter.width) / 2,
      (size.height - textPainter.height) / 2,
    );
    // Use the bounding rectangle expanded a bit for easier tracing
    return Path()..addRect(
      Rect.fromLTWH(
        offset.dx - 10,
        offset.dy - 10,
        textPainter.width + 20,
        textPainter.height + 20,
      ),
    );
  }
}

/// Paints the user's tracing strokes, clipped to the letter shape so the
/// color "fills" the letter as they trace over it.
class TracingFillPainter extends CustomPainter {
  final List<Offset?> points;
  final Color color;
  final double width;
  final String letter;
  final Size canvasSize;

  TracingFillPainter({
    required this.points,
    required this.color,
    required this.width,
    required this.letter,
    required this.canvasSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    // Create the letter text paragraph to get its path for clipping
    final textPainter = TextPainter(
      text: TextSpan(
        text: letter,
        style: GoogleFonts.nunito(
          fontSize: 240,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    final offset = Offset(
      (size.width - textPainter.width) / 2,
      (size.height - textPainter.height) / 2,
    );

    // We clip the drawing strokes to the letter's bounding rectangle
    // For a more precise clip, we'd need the actual glyph path, but
    // the visual effect of thick strokes within the bounds works well
    final letterRect = Rect.fromLTWH(
      offset.dx,
      offset.dy,
      textPainter.width,
      textPainter.height,
    );

    canvas.save();
    canvas.clipRect(letterRect);

    // Draw the fill strokes
    final paint = Paint()
      ..color = color.withOpacity(0.7)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = width
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }

    // Also draw circles at each point for a "fill" effect
    final fillPaint = Paint()
      ..color = color.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    for (final point in points) {
      if (point != null) {
        canvas.drawCircle(point, width / 2.5, fillPaint);
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant TracingFillPainter oldDelegate) => true;
}

/// Draws the background letter outline and guide lines
class LetterBackgroundPainter extends CustomPainter {
  final String letter;

  const LetterBackgroundPainter({required this.letter});

  @override
  void paint(Canvas canvas, Size size) {
    // Draw guide lines
    final dashPaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    double midY = size.height / 2;
    for (double i = 0; i < size.width; i += 15) {
      canvas.drawLine(Offset(i, midY), Offset(i + 8, midY), dashPaint);
    }
    canvas.drawLine(Offset(0, midY - 120), Offset(size.width, midY - 120), dashPaint);
    canvas.drawLine(Offset(0, midY + 120), Offset(size.width, midY + 120), dashPaint);

    // Draw the letter outline (dotted/light appearance)
    final textPainter = TextPainter(
      text: TextSpan(
        text: letter,
        style: GoogleFonts.nunito(
          fontSize: 240,
          fontWeight: FontWeight.w900,
          foreground: Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3
            ..color = Colors.white.withOpacity(0.25),
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    final offset = Offset(
      (size.width - textPainter.width) / 2,
      (size.height - textPainter.height) / 2,
    );
    textPainter.paint(canvas, offset);

    // Draw a very faint filled version as guide
    final fillTextPainter = TextPainter(
      text: TextSpan(
        text: letter,
        style: GoogleFonts.nunito(
          fontSize: 240,
          fontWeight: FontWeight.w900,
          color: Colors.white.withOpacity(0.06),
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    fillTextPainter.layout();
    fillTextPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant LetterBackgroundPainter oldDelegate) =>
      oldDelegate.letter != letter;
}
