import 'package:flutter/material.dart';

class MetallicShine extends StatefulWidget {
  final Widget child;
  const MetallicShine({super.key, required this.child});

  @override
  State<MetallicShine> createState() => _MetallicShineState();
}

class _MetallicShineState extends State<MetallicShine>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) {
        return ShaderMask(
          shaderCallback: (rect) {
            return LinearGradient(
              begin: Alignment(-1 + 2 * _controller.value, -1),
              end: Alignment(1 + 2 * _controller.value, 1),
              colors: const [
                Colors.transparent,
                Colors.white24,
                Colors.transparent,
              ],
              stops: const [0.3, 0.5, 0.7],
            ).createShader(rect);
          },
          blendMode: BlendMode.lighten,
          child: child,
        );
      },
      child: widget.child,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
