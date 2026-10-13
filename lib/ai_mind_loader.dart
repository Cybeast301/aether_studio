import 'dart:math';
import 'package:flutter/material.dart';

/// Drop-in replacement for the loading panel.
/// Usage: just show this widget when isGenerating == true
class AiMindLoader extends StatefulWidget {
  const AiMindLoader({super.key});

  @override
  State<AiMindLoader> createState() => _AiMindLoaderState();
}

class _AiMindLoaderState extends State<AiMindLoader>
    with TickerProviderStateMixin {
  late AnimationController _starCtrl;
  late AnimationController _robotCtrl;
  late AnimationController _gear1Ctrl;
  late AnimationController _gear2Ctrl;
  late AnimationController _antennaCtrl;
  late AnimationController _textCtrl;
  late AnimationController _eyeCtrl;
  late List<_Star> _stars;

  @override
  void initState() {
    super.initState();

    _starCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _robotCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _gear1Ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _gear2Ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: false);
    _antennaCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _textCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _eyeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );

    _stars = List.generate(60, (_) => _Star());

    // auto blink eyes
    _scheduleBlink();
  }

  void _scheduleBlink() async {
    if (!mounted) return;
    await Future.delayed(Duration(milliseconds: 2000 + Random().nextInt(3000)));
    if (!mounted) return;
    await _eyeCtrl.forward();
    await _eyeCtrl.reverse();
    _scheduleBlink();
  }

  @override
  void dispose() {
    _starCtrl.dispose();
    _robotCtrl.dispose();
    _gear1Ctrl.dispose();
    _gear2Ctrl.dispose();
    _antennaCtrl.dispose();
    _textCtrl.dispose();
    _eyeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF020818), Color(0xFF041230), Color(0xFF060820)],
        ),
        border: Border.all(color: const Color(0xFF3B4FE8).withOpacity(0.2)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // ⭐ Starfield
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _starCtrl,
              builder: (_, __) =>
                  CustomPaint(painter: _StarPainter(_stars, _starCtrl.value)),
            ),
          ),

          // 🔵 Bottom ground glow
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 120,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Color(0xFF0A1628), Colors.transparent],
                ),
              ),
            ),
          ),

          // 🤖 Robot + thought bubble
          Center(
            child: AnimatedBuilder(
              animation: Listenable.merge([
                _robotCtrl,
                _gear1Ctrl,
                _gear2Ctrl,
                _antennaCtrl,
                _eyeCtrl,
              ]),
              builder: (_, __) => CustomPaint(
                size: const Size(340, 320),
                painter: _RobotPainter(
                  float: _robotCtrl.value,
                  gear1: _gear1Ctrl.value,
                  gear2: _gear2Ctrl.value,
                  antenna: _antennaCtrl.value,
                  blink: _eyeCtrl.value,
                ),
              ),
            ),
          ),

          // 📝 Animated text + progress
          Positioned(
            bottom: 28,
            left: 0,
            right: 0,
            child: Column(
              children: [
                AnimatedBuilder(
                  animation: _textCtrl,
                  builder: (_, __) {
                    final dots = '.' * ((_textCtrl.value * 4).toInt() % 4);
                    return Text(
                      'Crafting your masterpiece$dots',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF818CF8),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.1,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                // Glowing progress bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 60),
                  child: AnimatedBuilder(
                    animation: _textCtrl,
                    builder: (_, __) => Container(
                      height: 3,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: const Color(0xFF3B4FE8).withOpacity(0.2),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: _textCtrl.value,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF3B4FE8),
                                Color(0xFF818CF8),
                                Color(0xFF7C3AED),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6366F1).withOpacity(0.8),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
/// 🤖 ROBOT PAINTER
//////////////////////////////////////////////////////////////

class _RobotPainter extends CustomPainter {
  final double float, gear1, gear2, antenna, blink;

  _RobotPainter({
    required this.float,
    required this.gear1,
    required this.gear2,
    required this.antenna,
    required this.blink,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2 + 10 - 12 * sin(float * pi); // floating effect

    // ── Colors ──
    const bodyColor = Color(0xFF1E3A5F);
    const bodyHighlight = Color(0xFF2A5080);
    const metalLight = Color(0xFF4A7AB5);
    const glowBlue = Color(0xFF60A5FA);
    const screenGreen = Color(0xFF34D399);

    Paint metalPaint(Color c) => Paint()..color = c;

    // ── Shadow ──
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 115), width: 120, height: 18),
      Paint()..color = Colors.black.withOpacity(0.3 + 0.1 * sin(float * pi)),
    );

    // ── TRACKS / BASE ──
    _drawTrack(
      canvas,
      Offset(cx - 42, cy + 100),
      metalPaint(const Color(0xFF0F2744)),
    );
    _drawTrack(
      canvas,
      Offset(cx + 42, cy + 100),
      metalPaint(const Color(0xFF0F2744)),
    );

    // ── BODY ──
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy + 50), width: 100, height: 80),
      const Radius.circular(12),
    );
    canvas.drawRRect(
      bodyRect,
      Paint()
        ..shader =
            LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [bodyHighlight, bodyColor, const Color(0xFF0F2744)],
            ).createShader(
              Rect.fromCenter(
                center: Offset(cx, cy + 50),
                width: 100,
                height: 80,
              ),
            ),
    );

    // body panel lines
    canvas.drawLine(
      Offset(cx - 30, cy + 30),
      Offset(cx - 30, cy + 90),
      Paint()
        ..color = metalLight.withOpacity(0.3)
        ..strokeWidth = 1,
    );
    canvas.drawLine(
      Offset(cx + 30, cy + 30),
      Offset(cx + 30, cy + 90),
      Paint()
        ..color = metalLight.withOpacity(0.3)
        ..strokeWidth = 1,
    );

    // ── CHEST SCREEN ──
    final screenRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy + 52), width: 52, height: 36),
      const Radius.circular(6),
    );
    canvas.drawRRect(screenRect, Paint()..color = const Color(0xFF071A35));
    canvas.drawRRect(
      screenRect,
      Paint()
        ..color = screenGreen.withOpacity(0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Screen content — binary lines
    for (int i = 0; i < 4; i++) {
      final y = cy + 38.0 + i * 8;
      final w = 20.0 + (gear1 * 20 + i * 7) % 28;
      canvas.drawLine(
        Offset(cx - 18, y),
        Offset(cx - 18 + w, y),
        Paint()
          ..color = screenGreen.withOpacity(0.6)
          ..strokeWidth = 1.5,
      );
    }

    // ── ARMS ──
    // Left arm — slightly raised as if thinking
    _drawArm(
      canvas,
      cx - 50,
      cy + 40,
      -0.3 - 0.1 * sin(float * pi),
      metalPaint(bodyColor),
      metalLight,
    );
    // Right arm — resting on chin (thinking pose)
    _drawArmThinking(
      canvas,
      cx + 50,
      cy + 40,
      metalPaint(bodyColor),
      metalLight,
      float,
    );

    // ── NECK ──
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy - 2), width: 22, height: 16),
        const Radius.circular(4),
      ),
      metalPaint(const Color(0xFF0F2744)),
    );

    // ── HEAD ──
    final headRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy - 32), width: 88, height: 66),
      const Radius.circular(14),
    );
    canvas.drawRRect(
      headRect,
      Paint()
        ..shader =
            LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [bodyHighlight, bodyColor],
            ).createShader(
              Rect.fromCenter(
                center: Offset(cx, cy - 32),
                width: 88,
                height: 66,
              ),
            ),
    );

    // head edge highlight
    canvas.drawRRect(
      headRect,
      Paint()
        ..color = metalLight.withOpacity(0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // ── EYES (binocular style like WALL-E) ──
    _drawEye(canvas, Offset(cx - 20, cy - 32), blink, glowBlue);
    _drawEye(canvas, Offset(cx + 20, cy - 32), blink, glowBlue);

    // Eye bridge
    canvas.drawLine(
      Offset(cx - 8, cy - 32),
      Offset(cx + 8, cy - 32),
      Paint()
        ..color = metalLight.withOpacity(0.5)
        ..strokeWidth = 3,
    );

    // ── ANTENNA ──
    final antY = cy - 68 - 4 * antenna;
    canvas.drawLine(
      Offset(cx, cy - 65),
      Offset(cx, antY),
      Paint()
        ..color = metalLight
        ..strokeWidth = 2,
    );
    // Blinking antenna tip
    canvas.drawCircle(
      Offset(cx, antY - 5),
      5,
      Paint()
        ..color = glowBlue.withOpacity(0.4 + 0.6 * antenna)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawCircle(
      Offset(cx, antY - 5),
      3,
      Paint()..color = Color.lerp(glowBlue, Colors.white, antenna)!,
    );

    // ── THOUGHT BUBBLE ──
    _drawThoughtBubble(canvas, Offset(cx + 55, cy - 70), gear1, gear2);
  }

  void _drawEye(Canvas canvas, Offset center, double blink, Color glow) {
    // Outer lens
    canvas.drawCircle(center, 16, Paint()..color = const Color(0xFF071A35));
    canvas.drawCircle(
      center,
      16,
      Paint()
        ..color = glow.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(1.0, 1.0 - blink);
    canvas.translate(-center.dx, -center.dy);

    // Inner lens
    canvas.drawCircle(
      center,
      11,
      Paint()
        ..shader = RadialGradient(
          colors: [glow.withOpacity(0.9), const Color(0xFF1E3A5F)],
        ).createShader(Rect.fromCircle(center: center, radius: 11)),
    );

    // Pupil
    canvas.drawCircle(center, 6, Paint()..color = const Color(0xFF020818));

    // Glint
    canvas.drawCircle(
      Offset(center.dx - 4, center.dy - 4),
      2.5,
      Paint()..color = Colors.white.withOpacity(0.9),
    );
    canvas.restore();
  }

  void _drawTrack(Canvas canvas, Offset center, Paint paint) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: 55, height: 22),
        const Radius.circular(11),
      ),
      paint,
    );
    // Track wheels
    for (int i = -1; i <= 1; i++) {
      canvas.drawCircle(
        Offset(center.dx + i * 18, center.dy),
        9,
        Paint()..color = const Color(0xFF1E3A5F),
      );
      canvas.drawCircle(
        Offset(center.dx + i * 18, center.dy),
        5,
        Paint()..color = const Color(0xFF2A5080),
      );
    }
  }

  void _drawArm(
    Canvas canvas,
    double x,
    double y,
    double angle,
    Paint fill,
    Color highlight,
  ) {
    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(angle);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-10, 0, 20, 45),
        const Radius.circular(8),
      ),
      fill,
    );
    canvas.restore();
  }

  void _drawArmThinking(
    Canvas canvas,
    double x,
    double y,
    Paint fill,
    Color highlight,
    double float,
  ) {
    // Right arm bent up to chin
    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(0.5);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-10, 0, 20, 38),
        const Radius.circular(8),
      ),
      fill,
    );
    canvas.restore();
  }

  void _drawThoughtBubble(
    Canvas canvas,
    Offset origin,
    double gear1,
    double gear2,
  ) {
    // Small bubble dots leading to main bubble
    for (int i = 0; i < 3; i++) {
      canvas.drawCircle(
        Offset(origin.dx - 10 + i * 8, origin.dy + 20 - i * 10),
        2.0 + i * 1.5,
        Paint()..color = Colors.white.withOpacity(0.3),
      );
    }

    // Main thought bubble
    canvas.drawCircle(
      origin,
      38,
      Paint()
        ..color = const Color(0xFF0F2744).withOpacity(0.85)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
    canvas.drawCircle(
      origin,
      38,
      Paint()
        ..color = const Color(0xFF3B4FE8).withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // ── Gear 1 (large) ──
    canvas.save();
    canvas.translate(origin.dx - 8, origin.dy);
    canvas.rotate(gear1 * 2 * pi);
    _drawGear(canvas, 16, 8, const Color(0xFF818CF8));
    canvas.restore();

    // ── Gear 2 (small, counter-rotate) ──
    canvas.save();
    canvas.translate(origin.dx + 14, origin.dy - 10);
    canvas.rotate(-gear2 * 2 * pi);
    _drawGear(canvas, 10, 6, const Color(0xFF60A5FA));
    canvas.restore();
  }

  void _drawGear(Canvas canvas, double radius, int teeth, Color color) {
    final path = Path();
    final toothH = radius * 0.35;
    final toothW = (2 * pi * radius / teeth) * 0.35;

    for (int i = 0; i < teeth; i++) {
      final a1 = (i / teeth) * 2 * pi - toothW / radius;
      final a2 = (i / teeth) * 2 * pi + toothW / radius;
      final a3 = ((i + 0.5) / teeth) * 2 * pi - toothW / radius;
      final a4 = ((i + 0.5) / teeth) * 2 * pi + toothW / radius;

      if (i == 0) {
        path.moveTo(cos(a1) * radius, sin(a1) * radius);
      } else {
        path.lineTo(cos(a1) * radius, sin(a1) * radius);
      }
      path.lineTo(cos(a2) * (radius + toothH), sin(a2) * (radius + toothH));
      path.lineTo(cos(a3) * (radius + toothH), sin(a3) * (radius + toothH));
      path.lineTo(cos(a4) * radius, sin(a4) * radius);
    }
    path.close();

    canvas.drawPath(path, Paint()..color = color.withOpacity(0.85));
    canvas.drawCircle(
      Offset.zero,
      radius * 0.4,
      Paint()..color = const Color(0xFF071A35),
    );
  }

  @override
  bool shouldRepaint(covariant _RobotPainter old) => true;
}

//////////////////////////////////////////////////////////////
/// ⭐ STARFIELD
//////////////////////////////////////////////////////////////

class _Star {
  final double x = Random().nextDouble();
  final double y = Random().nextDouble() * 0.7; // top 70% of screen
  final double size = Random().nextDouble() * 2 + 0.5;
  final double phase = Random().nextDouble() * 2 * pi;
}

class _StarPainter extends CustomPainter {
  final List<_Star> stars;
  final double t;
  _StarPainter(this.stars, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in stars) {
      final opacity = 0.4 + 0.6 * sin(t * pi + s.phase);
      canvas.drawCircle(
        Offset(s.x * size.width, s.y * size.height),
        s.size,
        Paint()..color = Colors.white.withOpacity(opacity * 0.8),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StarPainter old) => old.t != t;
}
