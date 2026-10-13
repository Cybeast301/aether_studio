import 'dart:math';
import 'package:flutter/material.dart';

class _LogoSection extends StatefulWidget {
  const _LogoSection();

  @override
  State<_LogoSection> createState() => _LogoSectionState();
}

class _LogoSectionState extends State<_LogoSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Faster duration for more "energy" in the sword
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 140, // Taller to fit the blade
          width: 100,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) =>
                CustomPaint(painter: _CelestialBladePainter(_controller.value)),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "A E T H E R",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            letterSpacing: 10,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(color: Colors.purpleAccent, blurRadius: 15),
              Shadow(color: Colors.blueAccent, blurRadius: 30),
            ],
          ),
        ),
      ],
    );
  }
}

class _CelestialBladePainter extends CustomPainter {
  final double progress;
  _CelestialBladePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final rand = Random(88); // Static seed for internal stars

    // 1. 🗡️ Define the Sword Path
    final Path bladePath = Path();
    // Blade Tip
    bladePath.moveTo(size.width * 0.5, size.height * 0.1);
    // Left Edge
    bladePath.lineTo(size.width * 0.35, size.height * 0.65);
    // Left Guard
    bladePath.lineTo(size.width * 0.2, size.height * 0.65);
    bladePath.lineTo(size.width * 0.2, size.height * 0.7);
    bladePath.lineTo(size.width * 0.45, size.height * 0.7);
    // Hilt/Handle
    bladePath.lineTo(size.width * 0.45, size.height * 0.9);
    bladePath.lineTo(size.width * 0.55, size.height * 0.9);
    bladePath.lineTo(size.width * 0.55, size.height * 0.7);
    // Right Guard
    bladePath.lineTo(size.width * 0.8, size.height * 0.7);
    bladePath.lineTo(size.width * 0.8, size.height * 0.65);
    bladePath.lineTo(size.width * 0.65, size.height * 0.65);
    // Right Edge
    bladePath.lineTo(size.width * 0.5, size.height * 0.1);
    bladePath.close();

    // 2. ✨ Draw External Aura (Glow)
    final auraPaint = Paint()
      ..color = Colors.purpleAccent.withOpacity(
        0.3 * (0.7 + 0.3 * sin(progress * 2 * pi)),
      )
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
    canvas.drawPath(bladePath, auraPaint);

    // 3. 🌌 Fill Blade with Universe (Clipping)
    canvas.save();
    canvas.clipPath(bladePath);

    // Blade Background (Deep Void)
    canvas.drawPaint(Paint()..color = const Color(0xFF0F172A));

    // Internal Nebula Flow
    final nebulaPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.blue.withOpacity(0.4),
          Colors.purpleAccent.withOpacity(0.4),
          Colors.transparent,
        ],
        stops: [(progress - 0.2) % 1.0, progress % 1.0, (progress + 0.2) % 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPaint(nebulaPaint);

    // Internal Shining Stars
    for (int i = 0; i < 30; i++) {
      final starX = rand.nextDouble() * size.width;
      final starY =
          (rand.nextDouble() * size.height + (progress * 50)) % size.height;
      final starTwinkle = (sin((progress * 2 * pi * 3) + i) + 1) / 2;

      canvas.drawCircle(
        Offset(starX, starY),
        1.2,
        Paint()..color = Colors.white.withOpacity(0.3 + 0.7 * starTwinkle),
      );
    }
    canvas.restore();

    // 4. ⚡ Blade Outline & Shine
    final outlinePaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawPath(bladePath, outlinePaint);

    // Central Core Shine (The bright spot at the guard)
    final coreGlow = Paint()
      ..color = Colors.white
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.68),
      4,
      coreGlow,
    );

    // Orbital Ring around the hilt (like your image)
    final ringPaint = Paint()
      ..color = Colors.blueAccent.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.68),
        width: 60,
        height: 15,
      ),
      ringPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
