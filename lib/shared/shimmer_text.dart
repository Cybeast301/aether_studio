import 'package:flutter/material.dart';

class ShimmerText extends StatefulWidget {
  final String text;

  const ShimmerText({super.key, required this.text});

  @override
  State<ShimmerText> createState() => _ShimmerTextState();
}

class _ShimmerTextState extends State<ShimmerText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(-1 + _controller.value * 2, 0),
              end: Alignment(1 + _controller.value * 2, 0),
              colors: const [Colors.white70, Colors.white, Colors.white70],
            ).createShader(bounds);
          },
          child: Text(
            widget.text,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w300,
              letterSpacing: 8,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
