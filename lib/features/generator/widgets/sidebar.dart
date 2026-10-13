import 'dart:math';
import 'package:aether_studio/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../generator_page.dart';
import 'cinematic_presets_widget.dart';
import '../../auth/auth_service.dart';
import '../history_controller.dart';
import '../prompt_history_controller.dart';

//////////////////////////////////////////////////////////
// 🌌 RESPONSIVE GALAXY SIDEBAR
//////////////////////////////////////////////////////////

class Sidebar extends StatelessWidget {
  final AppPage currentPage;
  final ValueChanged<AppPage> onPageChanged;

  const Sidebar({
    super.key,
    required this.currentPage,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Stack(
      children: [
        const Positioned.fill(child: _CinematicGalaxyBackground()),
        LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;
            // On mobile drawer, w might be 260 — treat as full sidebar
            final effectiveW = isMobile ? 260.0 : w;
            final logoSize = (effectiveW * 0.35).clamp(50.0, 100.0);
            final fontSize = (effectiveW * 0.07).clamp(9.0, 16.0);
            final letterSpacing = (effectiveW * 0.022).clamp(3.0, 7.0);
            final compact = !isMobile && w < 180;

            return Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(color: Colors.white.withOpacity(0.05)),
                ),
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF060A14).withOpacity(0.7),
                    const Color(0xFF0F172A).withOpacity(0.5),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Safe area top padding on mobile ──────
                  if (isMobile)
                    SizedBox(height: MediaQuery.of(context).padding.top + 12),

                  // ── Logo + Theme Toggle ──────────────────
                  SizedBox(
                    height: isMobile ? 140 : (h * 0.22).clamp(100.0, 180.0),
                    child: Stack(
                      children: [
                        Center(
                          child: _LogoSection(
                            logoSize: logoSize,
                            fontSize: fontSize,
                            letterSpacing: letterSpacing,
                          ),
                        ),
                        Positioned(
                          top: 12,
                          right: 12,
                          child: const ThemeToggle(),
                        ),
                        // ✅ Close drawer button on mobile
                        if (isMobile)
                          Positioned(
                            top: 12,
                            left: 12,
                            child: GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.white.withOpacity(0.06),
                                ),
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 18,
                                  color: Colors.white.withOpacity(0.5),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 12 : effectiveW * 0.04,
                    ),
                    child: Column(
                      children: [
                        _NavItem(
                          icon: Icons.auto_awesome_outlined,
                          label: 'Generator',
                          selected: currentPage == AppPage.generator,
                          compact: compact,
                          onTap: () => onPageChanged(AppPage.generator),
                        ),
                        _NavItem(
                          icon: Icons.history_outlined,
                          label: 'History',
                          selected: currentPage == AppPage.history,
                          compact: compact,
                          onTap: () => onPageChanged(AppPage.history),
                        ),
                        _NavItem(
                          icon: Icons.crop_outlined,
                          label: 'Crop & Resize',
                          selected: currentPage == AppPage.cropResize,
                          compact: compact,
                          onTap: () => onPageChanged(AppPage.cropResize),
                        ),
                        _NavItem(
                          icon: Icons.hd_outlined,
                          label: 'Upscale',
                          selected: currentPage == AppPage.upscale,
                          compact: compact,
                          onTap: () => onPageChanged(AppPage.upscale),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: isMobile ? 16 : h * 0.025),

                  if (!compact)
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 20 : effectiveW * 0.08,
                      ),
                      child: Text(
                        'ADVANCED SETTINGS',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: isMobile
                              ? 9
                              : (effectiveW * 0.034).clamp(7.0, 10.0),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),

                  SizedBox(height: isMobile ? 10 : h * 0.015),

                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 12 : effectiveW * 0.04,
                      ),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.03),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.05),
                            ),
                          ),
                          child: compact
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Icon(
                                      Icons.movie_filter_outlined,
                                      color: Colors.white.withOpacity(0.2),
                                      size: 22,
                                    ),
                                  ),
                                )
                              : const CinematicPresetsWidget(),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: isMobile ? 12 : h * 0.02),

                  // ── Profile + Logout ──────────────────────
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      isMobile ? 12 : effectiveW * 0.04,
                      0,
                      isMobile ? 12 : effectiveW * 0.04,
                      isMobile
                          ? MediaQuery.of(context).padding.bottom + 16
                          : h * 0.02,
                    ),
                    child: _ProfileTile(compact: compact),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

//////////////////////////////////////////////////////////
// ⚛️ LOGO SECTION
//////////////////////////////////////////////////////////

class _LogoSection extends StatefulWidget {
  final double logoSize, fontSize, letterSpacing;
  const _LogoSection({
    required this.logoSize,
    required this.fontSize,
    required this.letterSpacing,
  });
  @override
  State<_LogoSection> createState() => _LogoSectionState();
}

class _LogoSectionState extends State<_LogoSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
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
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: widget.logoSize,
          width: widget.logoSize,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) =>
                CustomPaint(painter: _WormholePainter(_controller.value)),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'A E T H E R',
          style: TextStyle(
            color: Colors.white,
            fontSize: widget.fontSize,
            letterSpacing: widget.letterSpacing,
            fontWeight: FontWeight.w300,
            shadows: const [Shadow(color: Colors.purpleAccent, blurRadius: 20)],
          ),
        ),
      ],
    );
  }
}

class _WormholePainter extends CustomPainter {
  final double progress;
  _WormholePainter(this.progress);
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(
      center,
      size.width * 0.3,
      Paint()
        ..color = const Color(
          0xFF7C3AED,
        ).withOpacity(0.3 * (0.5 + 0.5 * sin(progress * 2 * pi)))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 25),
    );
    canvas.drawCircle(
      center,
      size.width * 0.15,
      Paint()
        ..shader =
            const RadialGradient(
              colors: [Colors.white, Color(0xFF7C3AED), Colors.transparent],
            ).createShader(
              Rect.fromCircle(center: center, radius: size.width * 0.2),
            ),
    );
    for (int i = 0; i < 8; i++) {
      final angle = (progress * 2 * pi) + (i * pi / 4);
      final orbitX = center.dx + cos(angle) * size.width * 0.35;
      final orbitY = center.dy + sin(angle) * size.height * 0.25;
      canvas.drawCircle(
        Offset(orbitX, orbitY),
        size.width * 0.03,
        Paint()..color = Colors.white.withOpacity(0.8),
      );
      canvas.drawCircle(
        Offset(orbitX, orbitY),
        size.width * 0.06,
        Paint()
          ..color = Colors.white.withOpacity(0.2)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

//////////////////////////////////////////////////////////
// 🌌 GALAXY BACKGROUND
//////////////////////////////////////////////////////////

class _CinematicGalaxyBackground extends StatefulWidget {
  const _CinematicGalaxyBackground();
  @override
  State<_CinematicGalaxyBackground> createState() =>
      _CinematicGalaxyBackgroundState();
}

class _CinematicGalaxyBackgroundState extends State<_CinematicGalaxyBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) =>
          CustomPaint(painter: _UniversePainter(_controller.value)),
    );
  }
}

class _UniversePainter extends CustomPainter {
  final double progress;
  _UniversePainter(this.progress);
  @override
  void paint(Canvas canvas, Size size) {
    final rand = Random(42);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF03050B),
    );
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..shader =
            RadialGradient(
              colors: [
                const Color(
                  0xFF3B0764,
                ).withOpacity(0.2 + (0.05 * sin(progress * 2 * pi))),
                const Color(0xFF1E1B4B).withOpacity(0.1),
                Colors.transparent,
              ],
            ).createShader(
              Rect.fromLTWH(
                -size.width * 0.2,
                0,
                size.width * 1.5,
                size.height,
              ),
            ),
    );
    for (int i = 0; i < 150; i++) {
      final x = rand.nextDouble() * size.width;
      final yInitial = rand.nextDouble() * size.height;
      final depth = rand.nextDouble();
      final y = (yInitial + (progress * (5 + depth * 20) * 10)) % size.height;
      final twinkle = (sin((progress * 2 * pi * 4) + (i * 2)) + 1) / 2;
      canvas.drawCircle(
        Offset(x, y),
        depth > 0.9 ? 1.5 : 0.8,
        Paint()
          ..color = Colors.white.withOpacity(
            depth > 0.9 ? 0.5 + 0.5 * twinkle : 0.1 + 0.3 * twinkle,
          ),
      );
    }
    final cometProgress = (progress * 8) % 1.0;
    if (cometProgress < 0.2) {
      final t = cometProgress / 0.2;
      final start = Offset(size.width * 1.2, size.height * 0.1);
      final end = Offset(-size.width * 0.2, size.height * 0.6);
      final pos = Offset(
        start.dx + (end.dx - start.dx) * t,
        start.dy + (end.dy - start.dy) * t,
      );
      canvas.drawLine(
        pos,
        Offset(pos.dx + 50, pos.dy - 15),
        Paint()
          ..shader = LinearGradient(
            colors: [Colors.white.withOpacity(0.8), Colors.transparent],
          ).createShader(Rect.fromCenter(center: pos, width: 60, height: 2))
          ..strokeWidth = 1.5,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

//////////////////////////////////////////////////////////
// 💎 NAV ITEM
//////////////////////////////////////////////////////////

class _NavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool selected, compact;
  final VoidCallback onTap;
  const _NavItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
    this.compact = false,
  });
  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool isHovered = false;
  @override
  Widget build(BuildContext context) {
    final active = widget.selected || isHovered;
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(vertical: 3),
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: active
                ? LinearGradient(
                    colors: [Colors.white.withOpacity(0.1), Colors.transparent],
                  )
                : null,
          ),
          child: widget.compact
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      widget.icon,
                      color: active
                          ? Colors.purpleAccent
                          : Colors.white.withOpacity(0.4),
                      size: 20,
                    ),
                  ),
                )
              : ListTile(
                  dense: true,
                  leading: Icon(
                    widget.icon,
                    color: active
                        ? Colors.purpleAccent
                        : Colors.white.withOpacity(0.4),
                    size: 20,
                  ),
                  title: Text(
                    widget.label,
                    style: TextStyle(
                      color: active
                          ? Colors.white
                          : Colors.white.withOpacity(0.4),
                      fontWeight: active ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

//////////////////////////////////////////////////////////
// 👤 PROFILE + LOGOUT TILE
//////////////////////////////////////////////////////////

class _ProfileTile extends StatefulWidget {
  final bool compact;
  const _ProfileTile({required this.compact});
  @override
  State<_ProfileTile> createState() => _ProfileTileState();
}

class _ProfileTileState extends State<_ProfileTile> {
  bool _hovered = false;

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0F0A1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.purple.withOpacity(0.3)),
        ),
        title: const Text(
          'Sign Out',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to sign out?',
          style: TextStyle(color: Colors.white.withOpacity(0.6)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.white.withOpacity(0.4)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7c3aed),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Sign Out',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<HistoryController>().clearLocal();
      PromptHistoryController.instance.clearLocal();
      await AuthService.instance.logout();
      Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.user;
    if (user == null) return const SizedBox.shrink();
    final initials = user.name.isNotEmpty
        ? user.name
              .trim()
              .split(' ')
              .map((e) => e[0])
              .take(2)
              .join()
              .toUpperCase()
        : '?';

    if (widget.compact) {
      return MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: () => _logout(context),
          child: Tooltip(
            message: '${user.name}\nSign Out',
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.purple.withOpacity(_hovered ? 0.25 : 0.12),
                border: Border.all(color: Colors.purple.withOpacity(0.3)),
              ),
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: _hovered
              ? Colors.white.withOpacity(0.05)
              : Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.purple.withOpacity(_hovered ? 0.3 : 0.12),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF7c3aed), Color(0xFF6366f1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.4),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    user.email,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.35),
                      fontSize: 11,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => _logout(context),
              child: Tooltip(
                message: 'Sign Out',
                child: Icon(
                  Icons.logout_rounded,
                  color: Colors.white.withOpacity(0.3),
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
