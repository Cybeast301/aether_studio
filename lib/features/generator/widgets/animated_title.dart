import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_controller.dart';

class AnimatedTitle extends StatefulWidget {
  const AnimatedTitle({super.key});

  @override
  State<AnimatedTitle> createState() => _AnimatedTitleState();
}

class _AnimatedTitleState extends State<AnimatedTitle>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeController>().isDark;
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedBuilder(
          animation: _ctrl,
          builder: (context, _) {
            final t = _ctrl.value;
            return ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: isDark
                    ? const [
                        Color(0xFF6366F1),
                        Colors.white,
                        Color(0xFFA855F7),
                        Colors.white,
                        Color(0xFF6366F1),
                      ]
                    : const [
                        Color(0xFF4F46E5),
                        Color(0xFF7C3AED),
                        Color(0xFF4338CA),
                        Color(0xFF7C3AED),
                        Color(0xFF4F46E5),
                      ],
                stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                begin: Alignment(-2 + t * 4, 0),
                end: Alignment(-1 + t * 4, 0),
                tileMode: TileMode.mirror,
              ).createShader(bounds),
              child: Text(
                isMobile
                    ? 'Create Something\nAmazing'
                    : 'Create Something Amazing',
                style: TextStyle(
                  // ✅ Smaller on mobile
                  fontSize: isMobile ? 22 : 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 6),

        _AnimatedSubtitle(isDark: isDark, isMobile: isMobile),
      ],
    );
  }
}

class _AnimatedSubtitle extends StatefulWidget {
  final bool isDark;
  final bool isMobile;
  const _AnimatedSubtitle({required this.isDark, required this.isMobile});

  @override
  State<_AnimatedSubtitle> createState() => _AnimatedSubtitleState();
}

class _AnimatedSubtitleState extends State<_AnimatedSubtitle>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;

  static const _full = 'Describe your vision and let AI bring it to life';
  static const _short = 'Let AI bring your vision to life';

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = widget.isMobile ? _short : _full;
    return AnimatedBuilder(
      animation: _fadeAnim,
      builder: (_, __) {
        final charsToShow = (_fadeAnim.value * text.length).round();
        return Text(
          text.substring(0, charsToShow),
          style: TextStyle(
            color: widget.isDark
                ? Colors.white.withOpacity(0.4)
                : Colors.black.withOpacity(0.5),
            // ✅ Smaller on mobile
            fontSize: widget.isMobile ? 12 : 14,
          ),
        );
      },
    );
  }
}
