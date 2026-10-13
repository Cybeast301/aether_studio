import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedGalaxyLogo extends StatefulWidget {
  final double size;
  const AnimatedGalaxyLogo({Key? key, this.size = 140}) : super(key: key);

  @override
  State<AnimatedGalaxyLogo> createState() => _AnimatedGalaxyLogoState();
}

class _AnimatedGalaxyLogoState extends State<AnimatedGalaxyLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.size,
      width: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) {
          return CustomPaint(painter: GalaxyPainter(_controller.value));
        },
      ),
    );
  }
}

class GalaxyPainter extends CustomPainter {
  final double progress;
  GalaxyPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;

    // 🌌 Rotating Galaxy Glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.deepPurple.withOpacity(0.6),
          Colors.indigo.withOpacity(0.3),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(progress * 2 * pi);
    canvas.translate(-center.dx, -center.dy);
    canvas.drawCircle(center, radius, glowPaint);
    canvas.restore();

    // ✨ Glitter Particles
    final random = Random(42);
    final particlePaint = Paint()..color = Colors.white.withOpacity(0.8);

    for (int i = 0; i < 60; i++) {
      final angle = random.nextDouble() * 2 * pi + progress * 2 * pi;
      final distance = random.nextDouble() * radius;
      final dx = center.dx + cos(angle) * distance;
      final dy = center.dy + sin(angle) * distance;
      canvas.drawCircle(Offset(dx, dy), random.nextDouble() * 2, particlePaint);
    }

    // ⚔️ Sword Silhouette
    final swordPaint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(center.dx, center.dy - radius * 0.6);
    path.lineTo(center.dx + 6, center.dy + radius * 0.2);
    path.lineTo(center.dx - 6, center.dy + radius * 0.2);
    path.close();

    // Guard
    path.moveTo(center.dx - 25, center.dy + radius * 0.1);
    path.lineTo(center.dx + 25, center.dy + radius * 0.1);
    path.lineTo(center.dx + 25, center.dy + radius * 0.15);
    path.lineTo(center.dx - 25, center.dy + radius * 0.15);
    path.close();

    canvas.drawPath(path, swordPaint);

    // 💫 Breathing Glow
    final glowStrength = (sin(progress * 2 * pi) + 1) / 2;
    final breathingPaint = Paint()
      ..color = Colors.blueAccent.withOpacity(0.3 * glowStrength)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    canvas.drawCircle(center, radius * 0.7, breathingPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
