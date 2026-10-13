import 'dart:math';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;
  final bool isDataReady;
  const SplashScreen({
    super.key,
    required this.onComplete,
    this.isDataReady = false,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _bgCtrl;
  late AnimationController _iconCtrl;
  late AnimationController _textCtrl;
  late AnimationController _shimmerCtrl;
  late AnimationController _fadeCtrl;

  late Animation<double> _textOpacity;
  late Animation<double> _textScale;
  late Animation<double> _subtitleOpacity;
  late Animation<double> _fadeOut;
  late Animation<double> _glowPulse;

  late List<_FloatingIcon> _icons;
  final _random = Random();

  bool _animDone = false;

  void _tryNavigate() {
    if (_animDone && widget.isDataReady && mounted) {
      widget.onComplete();
    }
  }

  @override
  void didUpdateWidget(SplashScreen old) {
    super.didUpdateWidget(old);
    if (!old.isDataReady && widget.isDataReady) {
      _tryNavigate();
    }
  }

  @override
  void initState() {
    super.initState();

    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _iconCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    )..forward();

    _textCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _textOpacity = CurvedAnimation(
      parent: _textCtrl,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );
    _textScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _textCtrl,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );
    _subtitleOpacity = CurvedAnimation(
      parent: _textCtrl,
      curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
    );
    _glowPulse = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _shimmerCtrl, curve: Curves.easeInOut));
    _fadeOut = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);

    _icons = List.generate(
      18,
      (i) => _FloatingIcon(
        icon: _aiIcons[i % _aiIcons.length],
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: 18.0 + _random.nextDouble() * 28,
        speed: 0.3 + _random.nextDouble() * 0.7,
        phase: _random.nextDouble() * 2 * pi,
        opacity: 0.15 + _random.nextDouble() * 0.5,
        color: _iconColors[_random.nextInt(_iconColors.length)],
      ),
    );

    // Start text reveal at 0.8s
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _textCtrl.forward();
    });

    // At 3.8s — animation is "done", try to fade + navigate
    Future.delayed(const Duration(milliseconds: 3800), () {
      if (!mounted) return;
      if (widget.isDataReady) {
        // Data already loaded — fade out and go
        _fadeCtrl.forward().then((_) {
          if (mounted) {
            setState(() => _animDone = true);
            widget.onComplete();
          }
        });
      } else {
        // Data still loading — mark anim done, keep splash visible
        setState(() => _animDone = true);
        // _tryNavigate will be called via didUpdateWidget when data finishes
      }
    });
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _iconCtrl.dispose();
    _textCtrl.dispose();
    _shimmerCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  static const List<IconData> _aiIcons = [
    Icons.image_outlined,
    Icons.auto_awesome,
    Icons.memory_outlined,
    Icons.camera_outlined,
    Icons.photo_filter_outlined,
    Icons.psychology_outlined,
    Icons.hub_outlined,
    Icons.blur_on,
    Icons.palette_outlined,
    Icons.device_hub_outlined,
    Icons.grid_view_outlined,
    Icons.diamond_outlined,
    Icons.tune_outlined,
    Icons.lens_outlined,
    Icons.scatter_plot_outlined,
    Icons.grain,
    Icons.tv_outlined,
    Icons.monitor_outlined,
  ];

  static const List<Color> _iconColors = [
    Color(0xFF6366F1),
    Color(0xFF7C3AED),
    Color(0xFF3B82F6),
    Color(0xFFA855F7),
    Color(0xFF06B6D4),
    Color(0xFF8B5CF6),
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: _fadeOut,
      builder: (context, child) =>
          Opacity(opacity: 1.0 - _fadeOut.value, child: child),
      child: Scaffold(
        backgroundColor: const Color(0xFF020818),
        body: Stack(
          children: [
            // 🌌 Space background
            AnimatedBuilder(
              animation: _bgCtrl,
              builder: (_, __) => CustomPaint(
                size: size,
                painter: _SpacePainter(_bgCtrl.value),
              ),
            ),

            // 🔮 Nebula orbs
            AnimatedBuilder(
              animation: _bgCtrl,
              builder: (_, __) {
                final pulse = sin(_bgCtrl.value * 2 * pi);
                return Stack(
                  children: [
                    Positioned(
                      left: -100,
                      top: size.height * 0.2,
                      child: _NebulaOrb(
                        color: const Color(0xFF6366F1),
                        size: 400,
                        opacity: 0.12 + 0.04 * pulse,
                      ),
                    ),
                    Positioned(
                      right: -80,
                      bottom: size.height * 0.15,
                      child: _NebulaOrb(
                        color: const Color(0xFF7C3AED),
                        size: 350,
                        opacity: 0.10 + 0.04 * pulse,
                      ),
                    ),
                    Positioned(
                      top: -60,
                      left: size.width * 0.3,
                      child: _NebulaOrb(
                        color: const Color(0xFF3B82F6),
                        size: 300,
                        opacity: 0.08 + 0.03 * pulse,
                      ),
                    ),
                  ],
                );
              },
            ),

            // 💫 Floating icons
            AnimatedBuilder(
              animation: Listenable.merge([_iconCtrl, _bgCtrl]),
              builder: (_, __) {
                final t = _iconCtrl.value;
                final iconOpacity = t < 0.3
                    ? t / 0.3
                    : t > 0.8
                    ? (1.0 - t) / 0.2
                    : 1.0;
                return Stack(
                  children: _icons.map((icon) {
                    final floatY =
                        sin(_bgCtrl.value * 2 * pi * icon.speed + icon.phase) *
                        30;
                    final floatX =
                        cos(_bgCtrl.value * pi * icon.speed + icon.phase) * 15;
                    return Positioned(
                      left: icon.x * size.width + floatX,
                      top: icon.y * size.height + floatY,
                      child: Opacity(
                        opacity: (icon.opacity * iconOpacity).clamp(0.0, 1.0),
                        child: _GlowIcon(
                          icon: icon.icon,
                          size: icon.size,
                          color: icon.color,
                          glowIntensity: _glowPulse.value,
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),

            // 🔗 Connection lines
            AnimatedBuilder(
              animation: _iconCtrl,
              builder: (_, __) {
                final t = _iconCtrl.value;
                final opacity =
                    (t < 0.4
                            ? t / 0.4
                            : t > 0.75
                            ? (1 - t) / 0.25
                            : 1.0)
                        .clamp(0.0, 1.0);
                return CustomPaint(
                  size: size,
                  painter: _ConnectionPainter(_icons, opacity, size),
                );
              },
            ),

            // ✨ AETHER text
            Center(
              child: AnimatedBuilder(
                animation: Listenable.merge([
                  _textCtrl,
                  _shimmerCtrl,
                  _glowPulse,
                ]),
                builder: (_, __) => Opacity(
                  opacity: _textOpacity.value,
                  child: Transform.scale(
                    scale: _textScale.value,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) {
                            final shimmer = _shimmerCtrl.value;
                            return LinearGradient(
                              begin: Alignment(-1.5 + shimmer * 3, 0),
                              end: Alignment(-0.5 + shimmer * 3, 0),
                              colors: const [
                                Color(0xFF6366F1),
                                Color(0xFFFFFFFF),
                                Color(0xFFA855F7),
                                Color(0xFF3B82F6),
                                Color(0xFF6366F1),
                              ],
                              stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
                            ).createShader(bounds);
                          },
                          child: const Text(
                            'AETHER',
                            style: TextStyle(
                              fontSize: 72,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 20,
                              height: 1,
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        Container(
                          width: 200,
                          height: 1.5,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                const Color(
                                  0xFF6366F1,
                                ).withOpacity(_glowPulse.value),
                                const Color(
                                  0xFFA855F7,
                                ).withOpacity(_glowPulse.value),
                                Colors.transparent,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF6366F1,
                                ).withOpacity(0.6 * _glowPulse.value),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        Opacity(
                          opacity: _subtitleOpacity.value,
                          child: const Text(
                            'S T U D I O',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w300,
                              color: Color(0xFF818CF8),
                              letterSpacing: 12,
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        Opacity(
                          opacity: _subtitleOpacity.value,
                          child: _PulsingDots(
                            waitingForData: _animDone && !widget.isDataReady,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
/// PAINTERS & WIDGETS
//////////////////////////////////////////////////////////////

class _NebulaOrb extends StatelessWidget {
  final Color color;
  final double size;
  final double opacity;
  const _NebulaOrb({
    required this.color,
    required this.size,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(
        colors: [color.withOpacity(opacity), Colors.transparent],
      ),
    ),
  );
}

class _SpacePainter extends CustomPainter {
  final double progress;
  _SpacePainter(this.progress);

  static final _stars = List.generate(220, (i) {
    final rand = Random(i * 7 + 13);
    return (
      x: rand.nextDouble(),
      y: rand.nextDouble(),
      size: rand.nextDouble() * 1.8 + 0.3,
      speed: rand.nextDouble() * 0.3 + 0.05,
      phase: rand.nextDouble() * 2 * pi,
      bright: rand.nextDouble() > 0.85,
    );
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF020818),
    );

    for (final s in _stars) {
      final y =
          (s.y * size.height + progress * s.speed * size.height * 0.3) %
          size.height;
      final twinkle = (sin(progress * 4 * pi + s.phase) + 1) / 2;
      final opacity = s.bright ? 0.5 + 0.5 * twinkle : 0.1 + 0.25 * twinkle;
      canvas.drawCircle(
        Offset(s.x * size.width, y),
        s.bright ? s.size * 1.4 : s.size,
        Paint()..color = Colors.white.withOpacity(opacity),
      );
      if (s.bright && twinkle > 0.7) {
        final f = s.size * 4 * twinkle;
        final p = Paint()
          ..color = Colors.white.withOpacity(0.15 * twinkle)
          ..strokeWidth = 0.8;
        canvas.drawLine(
          Offset(s.x * size.width - f, y),
          Offset(s.x * size.width + f, y),
          p,
        );
        canvas.drawLine(
          Offset(s.x * size.width, y - f),
          Offset(s.x * size.width, y + f),
          p,
        );
      }
    }

    // Shooting star
    final st = (progress * 5) % 1.0;
    if (st < 0.18) {
      final t = st / 0.18;
      final sx = size.width * 0.8 - t * size.width * 0.7;
      final sy = size.height * 0.1 + t * size.height * 0.25;
      canvas.drawLine(
        Offset(sx, sy),
        Offset(sx + 60, sy - 18),
        Paint()
          ..shader = LinearGradient(
            colors: [Colors.white.withOpacity(0.9), Colors.transparent],
          ).createShader(Rect.fromLTWH(sx, sy - 10, 70, 20))
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_SpacePainter old) => true;
}

class _ConnectionPainter extends CustomPainter {
  final List<_FloatingIcon> icons;
  final double opacity;
  final Size screenSize;
  _ConnectionPainter(this.icons, this.opacity, this.screenSize);

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0) return;
    final paint = Paint()
      ..strokeWidth = 0.6
      ..style = PaintingStyle.stroke;
    for (int i = 0; i < icons.length; i++) {
      for (int j = i + 1; j < icons.length; j++) {
        final a = Offset(
          icons[i].x * screenSize.width,
          icons[i].y * screenSize.height,
        );
        final b = Offset(
          icons[j].x * screenSize.width,
          icons[j].y * screenSize.height,
        );
        final dist = (a - b).distance;
        if (dist < 180) {
          paint.color = const Color(
            0xFF6366F1,
          ).withOpacity((1 - dist / 180) * 0.25 * opacity);
          canvas.drawLine(a, b, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(_ConnectionPainter old) => old.opacity != opacity;
}

class _GlowIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color color;
  final double glowIntensity;
  const _GlowIcon({
    required this.icon,
    required this.size,
    required this.color,
    required this.glowIntensity,
  });

  @override
  Widget build(BuildContext context) => Stack(
    alignment: Alignment.center,
    children: [
      Container(
        width: size * 2,
        height: size * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withOpacity(0.15 * glowIntensity),
              Colors.transparent,
            ],
          ),
        ),
      ),
      Icon(icon, size: size, color: color),
    ],
  );
}

class _PulsingDots extends StatefulWidget {
  final bool waitingForData;
  const _PulsingDots({this.waitingForData = false});

  @override
  State<_PulsingDots> createState() => _PulsingDotsState();
}

class _PulsingDotsState extends State<_PulsingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void didUpdateWidget(_PulsingDots old) {
    super.didUpdateWidget(old);
    if (widget.waitingForData != old.waitingForData) {
      _ctrl.duration = Duration(
        milliseconds: widget.waitingForData ? 400 : 900,
      );
      _ctrl.repeat();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          final t = ((_ctrl.value - i / 3) % 1.0);
          final scale = 0.5 + 0.5 * sin(t * pi);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Transform.scale(
              scale: scale,
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF6366F1).withOpacity(0.4 + 0.6 * scale),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(0.4 * scale),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _FloatingIcon {
  final IconData icon;
  final double x, y, size, speed, phase, opacity;
  final Color color;
  _FloatingIcon({
    required this.icon,
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.phase,
    required this.opacity,
    required this.color,
  });
}
