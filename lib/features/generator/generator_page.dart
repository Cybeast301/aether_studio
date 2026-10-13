import 'dart:math';
import 'package:aether_studio/ai_mind_loader.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../shared/glass_container.dart';
import 'generator_controller.dart';
import 'history_page.dart';
import 'widgets/sidebar.dart';
import 'widgets/prompt_input.dart';
import 'widgets/style_selector.dart';
import 'widgets/aspect_ratio_selector.dart';
import 'widgets/generate_button.dart';
import 'widgets/preview_panel.dart';
import 'widgets/animated_title.dart';
import 'ai_assistant_widget.dart';
import 'ai_assistant_controller.dart';
import 'crop_resize_page.dart';
import 'upscale_page.dart';

enum AppPage { generator, history, cropResize, upscale }

class GeneratorPage extends StatefulWidget {
  const GeneratorPage({super.key});
  @override
  State<GeneratorPage> createState() => _GeneratorPageState();
}

class _GeneratorPageState extends State<GeneratorPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _bgCtrl;
  AppPage _currentPage = AppPage.generator;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: isDark
          ? const Color(0xFF020818)
          : const Color(0xFFF1F5FF),

      // ── Mobile drawer ─────────────────────────────────────
      drawer: isMobile
          ? Drawer(
              backgroundColor: Colors.transparent,
              width: 260,
              child: Sidebar(
                currentPage: _currentPage,
                onPageChanged: (p) {
                  setState(() => _currentPage = p);
                  Navigator.of(context).pop();
                },
              ),
            )
          : null,

      body: Stack(
        children: [
          // 🌌 Adaptive animated background
          AnimatedBuilder(
            animation: _bgCtrl,
            builder: (_, __) => Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(
                    -0.3 + 0.2 * sin(_bgCtrl.value * 2 * pi),
                    -0.6,
                  ),
                  radius: 1.6,
                  colors: isDark
                      ? const [
                          Color(0xFF041230),
                          Color(0xFF020818),
                          Color(0xFF060820),
                        ]
                      : const [
                          Color(0xFFEEF2FF),
                          Color(0xFFF1F5FF),
                          Color(0xFFE8EDFF),
                        ],
                ),
              ),
            ),
          ),

          // 🔮 Particle Orb
          Positioned(
            top: -80,
            right: 60,
            width: isMobile ? 200 : 400,
            height: isMobile ? 200 : 400,
            child: _ParticleOrb(isDark: isDark),
          ),

          // ✨ Floating dots
          Positioned.fill(child: _ParticleField(isDark: isDark)),

          // 🧠 Main UI
          if (isMobile)
            // ── Mobile: full width + top app bar ────────────
            Column(
              children: [
                _MobileAppBar(
                  currentPage: _currentPage,
                  isDark: isDark,
                  onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _buildPage(),
                  ),
                ),
              ],
            )
          else
            // ── Desktop: sidebar + content ───────────────────
            Row(
              children: [
                SizedBox(
                  width: AppConstants.sidebarWidth,
                  child: Sidebar(
                    currentPage: _currentPage,
                    onPageChanged: (p) => setState(() => _currentPage = p),
                  ),
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _buildPage(),
                  ),
                ),
              ],
            ),

          // 🤖 Aiko
          const Positioned.fill(child: AiAssistantWidget()),
        ],
      ),
    );
  }

  Widget _buildPage() {
    switch (_currentPage) {
      case AppPage.generator:
        return _GeneratorContent(key: const ValueKey('generator'));
      case AppPage.history:
        return const HistoryPage(key: ValueKey('history'));
      case AppPage.cropResize:
        return const CropResizePage(key: ValueKey('cropResize'));
      case AppPage.upscale:
        return const UpscalePage(key: ValueKey('upscale'));
    }
  }
}

//////////////////////////////////////////////////////////////
/// 📱 MOBILE APP BAR
//////////////////////////////////////////////////////////////

class _MobileAppBar extends StatelessWidget {
  final AppPage currentPage;
  final bool isDark;
  final VoidCallback onMenuTap;

  const _MobileAppBar({
    required this.currentPage,
    required this.isDark,
    required this.onMenuTap,
  });

  String get _title {
    switch (currentPage) {
      case AppPage.generator:
        return 'Generator';
      case AppPage.history:
        return 'History';
      case AppPage.cropResize:
        return 'Crop & Resize';
      case AppPage.upscale:
        return 'Upscale';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF04020F).withOpacity(0.9)
            : Colors.white.withOpacity(0.85),
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : const Color(0xFF6366F1).withOpacity(0.12),
          ),
        ),
      ),
      child: Row(
        children: [
          // Hamburger menu
          GestureDetector(
            onTap: onMenuTap,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: isDark
                    ? Colors.white.withOpacity(0.06)
                    : Colors.black.withOpacity(0.05),
              ),
              child: Icon(
                Icons.rocket_launch_rounded,
                size: 20,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Logo
          ShaderMask(
            shaderCallback: (b) => const LinearGradient(
              colors: [Color(0xFFc084fc), Color(0xFF818cf8)],
            ).createShader(b),
            child: const Text(
              'AETHER',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
                color: Colors.white,
              ),
            ),
          ),

          const Spacer(),

          // Current page title
          Text(
            _title,
            style: TextStyle(
              color: isDark
                  ? Colors.white.withOpacity(0.5)
                  : Colors.black.withOpacity(0.4),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
/// 🖼 GENERATOR CONTENT
//////////////////////////////////////////////////////////////

class _GeneratorContent extends StatelessWidget {
  const _GeneratorContent({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<GeneratorController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = MediaQuery.of(context).size.width < 768;
    final padding = isMobile ? 16.0 : AppConstants.paddingLg.toDouble();

    return Padding(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AnimatedTitle(),
          SizedBox(height: isMobile ? 12 : AppConstants.paddingLg.toDouble()),

          // ✅ Input panel
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF3B4FE8).withOpacity(0.18)
                    : const Color(0xFF6366F1).withOpacity(0.15),
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        Colors.white.withOpacity(0.04),
                        const Color(0xFF3B4FE8).withOpacity(0.04),
                      ]
                    : [
                        Colors.white.withOpacity(0.9),
                        const Color(0xFFEEF2FF).withOpacity(0.8),
                      ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(
                    0xFF4F46E5,
                  ).withOpacity(isDark ? 0.08 : 0.06),
                  blurRadius: 30,
                ),
              ],
            ),
            padding: EdgeInsets.all(
              isMobile ? 12 : AppConstants.paddingLg.toDouble(),
            ),
            child: Column(
              children: [
                const PromptInput(),
                SizedBox(
                  height: isMobile ? 10 : AppConstants.padding.toDouble(),
                ),

                // ── Mobile: stack vertically, Desktop: row ──
                if (isMobile)
                  Column(
                    children: [
                      const StyleSelector(),
                      const SizedBox(height: 10),
                      const AspectRatioSelector(),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: GenerateButton(onPressed: () => ctrl.generate()),
                      ),
                    ],
                  )
                else
                  Row(
                    children: [
                      const Expanded(child: StyleSelector()),
                      const SizedBox(width: AppConstants.padding),
                      const Expanded(child: AspectRatioSelector()),
                      const SizedBox(width: AppConstants.padding),
                      GenerateButton(onPressed: () => ctrl.generate()),
                    ],
                  ),
              ],
            ),
          ),

          SizedBox(height: isMobile ? 12 : AppConstants.paddingLg.toDouble()),

          // Preview OR Robot loading
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: ctrl.isGenerating
                  ? const AiMindLoader(key: ValueKey('loader'))
                  : const PreviewPanel(key: ValueKey('preview')),
            ),
          ),
        ],
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
/// 🔮 PARTICLE ORB — theme aware
//////////////////////////////////////////////////////////////

class _ParticleOrb extends StatefulWidget {
  final bool isDark;
  const _ParticleOrb({required this.isDark});
  @override
  State<_ParticleOrb> createState() => _ParticleOrbState();
}

class _ParticleOrbState extends State<_ParticleOrb>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late List<_OrbParticle> _particles;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();
    _particles = List.generate(300, (_) => _OrbParticle());
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
      builder: (_, __) => CustomPaint(
        painter: _OrbPainter(_particles, _ctrl.value, widget.isDark),
      ),
    );
  }
}

class _OrbParticle {
  final double theta = Random().nextDouble() * 2 * pi;
  final double phi = acos(2 * Random().nextDouble() - 1);
  final double radius = 90.0 + Random().nextDouble() * 55;
  final double size = Random().nextDouble() * 2.2 + 0.3;
  final double speed = Random().nextDouble() * 0.4 + 0.1;
  final double colorT = Random().nextDouble();
}

class _OrbPainter extends CustomPainter {
  final List<_OrbParticle> particles;
  final double progress;
  final bool isDark;
  _OrbPainter(this.particles, this.progress, this.isDark);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final t = progress * 2 * pi;

    for (final p in particles) {
      final angle = p.theta + t * p.speed;
      final x = cx + sin(p.phi) * cos(angle) * p.radius;
      final y = cy + sin(p.phi) * sin(angle) * p.radius * 0.4;
      final depth = (cos(p.phi) + 1) / 2;
      final opacity = (depth * (isDark ? 0.65 : 0.2) + (isDark ? 0.1 : 0.03))
          .clamp(0.0, 1.0);
      final drawSize = p.size * (0.4 + depth * 0.9);
      final color = Color.lerp(
        const Color(0xFF3B4FE8),
        const Color(0xFF7C3AED),
        p.colorT,
      )!.withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), drawSize, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(covariant _OrbPainter old) =>
      old.progress != progress || old.isDark != isDark;
}

//////////////////////////////////////////////////////////////
/// ✨ FLOATING PARTICLE FIELD — theme aware
//////////////////////////////////////////////////////////////

class _ParticleField extends StatefulWidget {
  final bool isDark;
  const _ParticleField({required this.isDark});
  @override
  State<_ParticleField> createState() => _ParticleFieldState();
}

class _ParticleFieldState extends State<_ParticleField>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  final particles = List.generate(30, (_) => _Particle());

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat();
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
      builder: (_, __) => CustomPaint(
        painter: _ParticlePainter(particles, _ctrl.value, widget.isDark),
      ),
    );
  }
}

class _Particle {
  final double x = Random().nextDouble();
  final double y = Random().nextDouble();
  final double size = Random().nextDouble() * 1.5 + 0.5;
  final double speed = Random().nextDouble() * 0.5 + 0.3;
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  final bool isDark;
  _ParticlePainter(this.particles, this.progress, this.isDark);

  @override
  void paint(Canvas canvas, Size size) {
    for (var p in particles) {
      final dy = (p.y * size.height + progress * 55 * p.speed) % size.height;
      canvas.drawCircle(
        Offset(p.x * size.width, dy),
        p.size,
        Paint()
          ..color = const Color(0xFF6366F1).withOpacity(isDark ? 0.2 : 0.07),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter old) =>
      old.progress != progress || old.isDark != isDark;
}

//////////////////////////////////////////////////////////////
/// 🚧 COMING SOON
//////////////////////////////////////////////////////////////

// ignore: unused_element
class _ComingSoon extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  const _ComingSoon({
    super.key,
    required this.label,
    required this.icon,
    this.subtitle = 'Coming soon',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF6366F1).withOpacity(0.1),
              border: Border.all(
                color: const Color(0xFF6366F1).withOpacity(0.2),
              ),
            ),
            child: Icon(
              icon,
              size: 48,
              color: const Color(0xFF818CF8).withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white70 : const Color(0xFF1E1B4B),
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: isDark
                  ? Colors.white.withOpacity(0.3)
                  : Colors.black.withOpacity(0.4),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF6366F1).withOpacity(0.3),
              ),
              color: const Color(0xFF6366F1).withOpacity(0.08),
            ),
            child: const Text(
              '🚀 Coming Soon',
              style: TextStyle(
                color: Color(0xFF818CF8),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
