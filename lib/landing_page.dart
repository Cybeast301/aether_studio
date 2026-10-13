import 'dart:math';
import 'package:flutter/material.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});
  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with TickerProviderStateMixin {
  late AnimationController _portalCtrl,
      _portalCtrl2,
      _pulseCtrl,
      _gradientCtrl,
      _floatCtrl,
      _revealCtrl;
  final List<_Particle> _particles = [];
  final Random _rng = Random();

  final List<String> _words = [
    'Anything.',
    'Art.',
    'Magic.',
    'Worlds.',
    'Dreams.',
    'Beauty.',
  ];
  int _wordIdx = 0;
  String _displayWord = '';
  int _imagesCount = 0;

  @override
  void initState() {
    super.initState();
    _portalCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
    _portalCtrl2 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _gradientCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
    _revealCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    for (int i = 0; i < 35; i++) _particles.add(_Particle(rng: _rng));
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _revealCtrl.forward();
    });
    _startTypewriter();
    _startCounter();
  }

  void _startTypewriter() async {
    await Future.delayed(const Duration(milliseconds: 900));
    while (mounted) {
      final word = _words[_wordIdx % _words.length];
      for (int i = 0; i <= word.length; i++) {
        if (!mounted) return;
        setState(() => _displayWord = word.substring(0, i));
        await Future.delayed(const Duration(milliseconds: 85));
      }
      await Future.delayed(const Duration(milliseconds: 1600));
      for (int i = word.length; i >= 0; i--) {
        if (!mounted) return;
        setState(() => _displayWord = word.substring(0, i));
        await Future.delayed(const Duration(milliseconds: 50));
      }
      await Future.delayed(const Duration(milliseconds: 320));
      _wordIdx++;
    }
  }

  void _startCounter() async {
    await Future.delayed(const Duration(milliseconds: 1800));
    for (int i = 0; i <= 1247; i += 13) {
      if (!mounted) return;
      setState(() => _imagesCount = i);
      await Future.delayed(const Duration(milliseconds: 16));
    }
    if (mounted) setState(() => _imagesCount = 1247);
  }

  @override
  void dispose() {
    _portalCtrl.dispose();
    _portalCtrl2.dispose();
    _pulseCtrl.dispose();
    _gradientCtrl.dispose();
    _floatCtrl.dispose();
    _revealCtrl.dispose();
    super.dispose();
  }

  void _goToAuth() => Navigator.of(context).pushNamed('/auth');

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    return Scaffold(
      backgroundColor: const Color(0xFF04020F),
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _StarfieldPainter())),
          Positioned(
            left: -180,
            top: 80,
            child: _NebulaBlob(
              color: const Color(0xFF6366f1),
              size: 550,
              opacity: 0.055,
            ),
          ),
          Positioned(
            right: -150,
            bottom: 300,
            child: _NebulaBlob(
              color: const Color(0xFF7c3aed),
              size: 480,
              opacity: 0.05,
            ),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                isMobile ? _buildMobileNav() : _buildNav(),
                _buildHero(context),
                _buildMockup(),
                _buildLiveCount(),
                _buildStats(isMobile),
                _buildFeatures(isMobile),
                _buildAikoSection(isMobile),
                _buildTechStrip(isMobile),
                _buildCTA(isMobile),
                _buildFooter(isMobile),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── MOBILE NAV ───────────────────────────────────────────
  Widget _buildMobileNav() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF04020F).withOpacity(0.88),
        border: Border(
          bottom: BorderSide(color: Colors.purple.withOpacity(0.14)),
        ),
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (_, __) => Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [Color(0xFFc084fc), Color(0xFF4a148c)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purpleAccent.withOpacity(
                          0.3 + 0.45 * _pulseCtrl.value,
                        ),
                        blurRadius: 10 + 12 * _pulseCtrl.value,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ShaderMask(
                  shaderCallback: (b) => const LinearGradient(
                    colors: [
                      Color(0xFFc084fc),
                      Color(0xFF818cf8),
                      Color(0xFFc084fc),
                    ],
                  ).createShader(b),
                  child: const Text(
                    'AETHER',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          _GhostBtn(label: 'Sign In', onTap: _goToAuth),
          const SizedBox(width: 8),
          _PrimaryBtn(label: 'Get Started', onTap: _goToAuth),
        ],
      ),
    );
  }

  // ── DESKTOP NAV ──────────────────────────────────────────
  Widget _buildNav() {
    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 52),
      decoration: BoxDecoration(
        color: const Color(0xFF04020F).withOpacity(0.88),
        border: Border(
          bottom: BorderSide(color: Colors.purple.withOpacity(0.14)),
        ),
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (_, __) => Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [Color(0xFFc084fc), Color(0xFF4a148c)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purpleAccent.withOpacity(
                          0.3 + 0.45 * _pulseCtrl.value,
                        ),
                        blurRadius: 14 + 16 * _pulseCtrl.value,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                ShaderMask(
                  shaderCallback: (b) => const LinearGradient(
                    colors: [
                      Color(0xFFc084fc),
                      Color(0xFF818cf8),
                      Color(0xFFc084fc),
                    ],
                  ).createShader(b),
                  child: const Text(
                    'AETHER',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 5,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          ...['Features', 'Aiko AI', 'Get Started'].map(
            (t) => Padding(
              padding: const EdgeInsets.only(left: 32),
              child: _NavLink(label: t, onTap: () {}),
            ),
          ),
          const SizedBox(width: 24),
          _GhostBtn(label: 'Sign In', onTap: _goToAuth),
          const SizedBox(width: 10),
          _PrimaryBtn(label: 'Get Started →', onTap: _goToAuth),
        ],
      ),
    );
  }

  // ── HERO ─────────────────────────────────────────────────
  Widget _buildHero(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final navH = isMobile ? 56.0 : 68.0;
    final h = MediaQuery.of(context).size.height - navH;
    final heroFontSize = isMobile ? 48.0 : 84.0;
    final subtitleFontSize = isMobile ? 14.0 : 17.0;

    return SizedBox(
      height: h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: Listenable.merge([
                _portalCtrl,
                _portalCtrl2,
                _pulseCtrl,
              ]),
              builder: (_, __) => CustomPaint(
                painter: _PortalPainter(
                  r1: _portalCtrl.value,
                  r2: _portalCtrl2.value,
                  pulse: _pulseCtrl.value,
                  particles: _particles,
                  rng: _rng,
                ),
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _revealCtrl,
            builder: (_, __) {
              final t = Curves.easeOutCubic.transform(_revealCtrl.value);
              return LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 24 : 0,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _FSlide(
                            delay: 0.0,
                            t: t,
                            child: _Badge(pulseCtrl: _pulseCtrl),
                          ),
                          const SizedBox(height: 28),
                          _FSlide(
                            delay: 0.05,
                            t: t,
                            child: AnimatedBuilder(
                              animation: _gradientCtrl,
                              builder: (_, __) => ShaderMask(
                                shaderCallback: (b) => LinearGradient(
                                  colors: const [
                                    Color(0xFFc084fc),
                                    Color(0xFF818cf8),
                                    Color(0xFFec4899),
                                    Color(0xFF7c3aed),
                                  ],
                                  begin: Alignment(
                                    -1 + _gradientCtrl.value * 2,
                                    0,
                                  ),
                                  end: Alignment(
                                    1 + _gradientCtrl.value * 2,
                                    0,
                                  ),
                                  tileMode: TileMode.mirror,
                                ).createShader(b),
                                child: Text(
                                  'Create',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: heroFontSize,
                                    fontWeight: FontWeight.w900,
                                    height: 1.0,
                                    letterSpacing: isMobile ? -1 : -3,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          _FSlide(
                            delay: 0.1,
                            t: t,
                            child: SizedBox(
                              height: isMobile ? 55 : 90,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    _displayWord,
                                    style: TextStyle(
                                      fontSize: heroFontSize,
                                      fontWeight: FontWeight.w900,
                                      height: 1.0,
                                      letterSpacing: isMobile ? -1 : -3,
                                      color: Colors.white,
                                    ),
                                  ),
                                  _BlinkCursor(height: isMobile ? 48 : 80),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          _FSlide(
                            delay: 0.18,
                            t: t,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: isMobile ? 8 : 60,
                              ),
                              child: Text(
                                isMobile
                                    ? 'Generate stunning images and let Aiko guide your creativity.'
                                    : 'Aether Studio is your AI-powered creative universe.\nGenerate stunning images, enhance prompts, and let Aiko guide your creativity.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: subtitleFontSize,
                                  color: Colors.white.withOpacity(0.42),
                                  height: 1.75,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 36),
                          _FSlide(
                            delay: 0.25,
                            t: t,
                            child: isMobile
                                // ── Mobile: stack buttons vertically ──
                                ? Column(
                                    children: [
                                      _HeroBtn(
                                        label: '✦  Start Creating Free',
                                        primary: true,
                                        onTap: _goToAuth,
                                      ),
                                      const SizedBox(height: 12),
                                      _HeroBtn(
                                        label: 'Explore Features →',
                                        primary: false,
                                        onTap: () {},
                                      ),
                                    ],
                                  )
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _HeroBtn(
                                        label: '✦  Start Creating Free',
                                        primary: true,
                                        onTap: _goToAuth,
                                      ),
                                      const SizedBox(width: 14),
                                      _HeroBtn(
                                        label: 'Explore Features →',
                                        primary: false,
                                        onTap: () {},
                                      ),
                                    ],
                                  ),
                          ),
                          const SizedBox(height: 36),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── MOCKUP ───────────────────────────────────────────────
  Widget _buildMockup() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 768;
          return Center(
            child: AnimatedBuilder(
              animation: _floatCtrl,
              builder: (_, child) => Transform.translate(
                offset: Offset(0, -5 + 10 * _floatCtrl.value),
                child: child,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: constraints.maxWidth - (isMobile ? 32 : 96),
                ),
                child: const _AppMockup(),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── LIVE COUNT ───────────────────────────────────────────
  Widget _buildLiveCount() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF7c3aed).withOpacity(0.12),
            const Color(0xFF6366f1).withOpacity(0.08),
            const Color(0xFF7c3aed).withOpacity(0.12),
          ],
        ),
        border: Border.symmetric(
          horizontal: BorderSide(color: Colors.purple.withOpacity(0.18)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _LiveDot(),
          const SizedBox(width: 12),
          Flexible(
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$_imagesCount',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFc084fc),
                    ),
                  ),
                  TextSpan(
                    text: '  images generated today  ·  Join the creators',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.45),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── STATS ────────────────────────────────────────────────
  Widget _buildStats(bool isMobile) {
    final stats = [
      ('9', 'AI Art Styles'),
      ('6', 'Director Modes'),
      ('40+', 'Knowledge Entries'),
      ('∞', 'Creative Possibilities'),
    ];
    return Container(
      padding: EdgeInsets.symmetric(vertical: isMobile ? 32 : 52),
      decoration: BoxDecoration(
        color: const Color(0xFF080514).withOpacity(0.6),
        border: Border.symmetric(
          horizontal: BorderSide(color: Colors.purple.withOpacity(0.12)),
        ),
      ),
      child: isMobile
          // ── Mobile: 2x2 grid ──
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 2.0,
                children: stats.map((s) => _Stat(n: s.$1, l: s.$2)).toList(),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _Stat(n: '9', l: 'AI Art Styles'),
                _SDivider(),
                _Stat(n: '6', l: 'Director Modes'),
                _SDivider(),
                _Stat(n: '40+', l: 'Knowledge Entries'),
                _SDivider(),
                _Stat(n: '∞', l: 'Creative Possibilities'),
              ],
            ),
    );
  }

  // ── FEATURES ─────────────────────────────────────────────
  Widget _buildFeatures(bool isMobile) {
    const feats = [
      (
        '🖼️',
        'AI Image Generation',
        'Generate stunning images from text using Cloudflare AI — Photorealistic, Anime, Digital Art across 9 styles.',
      ),
      (
        '🎬',
        'Director Mode',
        'Channel Nolan, Kubrick, Ghibli, Villeneuve. Inject legendary cinematic style into every generation instantly.',
      ),
      (
        '✨',
        'Prompt Helper',
        'Aiko transforms your simple ideas into rich, detailed prompts that produce breathtaking results every time.',
      ),
      (
        '🔍',
        'Image Analyzer',
        'Aiko analyzes your creations with Gemini Vision — style, mood, lighting and composition feedback.',
      ),
      (
        '⬆️',
        'AI Upscaling',
        'Scale images up to 4× with professional AI upscaling. Perfect for wallpapers and high-res exports.',
      ),
      (
        '✂️',
        'Crop & Resize',
        'Pro crop tools with real drag handles, preset ratios and background removal via Remove.bg.',
      ),
      (
        '🕐',
        'Generation History',
        'Every creation saved to Supabase cloud. Browse, revisit and regenerate from your personal gallery.',
      ),
      (
        '🧠',
        'RAG Knowledge Base',
        'Aiko draws from 40+ art knowledge entries — lighting, colour theory, composition — for expert advice.',
      ),
      (
        '🌙',
        'Dark & Light Themes',
        'Switch between deep space dark mode and clean light mode. Your canvas, your aesthetic.',
      ),
    ];
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 52,
        vertical: isMobile ? 52 : 90,
      ),
      child: Column(
        children: [
          _SectionHeader(
            label: 'EVERYTHING YOU NEED',
            title: 'Built for Creators,\nPowered by AI',
            center: true,
          ),
          SizedBox(height: isMobile ? 32 : 56),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile ? 1 : 3,
              crossAxisSpacing: 18,
              mainAxisSpacing: 18,
              childAspectRatio: isMobile ? 2.5 : 1.55,
            ),
            itemCount: feats.length,
            itemBuilder: (_, i) => _FeatCard(
              icon: feats[i].$1,
              title: feats[i].$2,
              desc: feats[i].$3,
              index: i,
            ),
          ),
        ],
      ),
    );
  }

  // ── AIKO SECTION ─────────────────────────────────────────
  Widget _buildAikoSection(bool isMobile) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          label: 'MEET YOUR AI COMPANION',
          title: 'Aiko —\nYour Creative Soul',
          center: isMobile,
          gradientTitle: true,
        ),
        const SizedBox(height: 18),
        Text(
          'Aiko is your always-on AI creative assistant. She chats, improves prompts, analyzes images, and brings expert art knowledge to every session.',
          textAlign: isMobile ? TextAlign.center : TextAlign.left,
          style: TextStyle(
            fontSize: 15,
            color: Colors.white.withOpacity(0.45),
            height: 1.85,
          ),
        ),
        const SizedBox(height: 28),
        ...[
          ('⚡', 'Groq Llama 3.3', 'Lightning-fast sub-second responses'),
          ('👁️', 'Gemini Vision', 'Deep image understanding & feedback'),
          (
            '🔒',
            'Firebase Personality',
            "Aiko's unique character, always consistent",
          ),
          (
            '📚',
            '40+ Art Knowledge Entries',
            'Expert lighting, colour theory & composition',
          ),
        ].map(
          (f) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _AikoFeat(icon: f.$1, title: f.$2, desc: f.$3),
          ),
        ),
      ],
    );

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 52,
        vertical: isMobile ? 52 : 90,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            const Color(0xFF7c3aed).withOpacity(0.04),
            Colors.transparent,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: isMobile
          // ── Mobile: stack vertically ──
          ? Column(
              children: [
                SizedBox(
                  height: 260,
                  child: AnimatedBuilder(
                    animation: Listenable.merge([
                      _portalCtrl,
                      _pulseCtrl,
                      _floatCtrl,
                    ]),
                    builder: (_, __) => CustomPaint(
                      size: const Size(double.infinity, 260),
                      painter: _AikoPainter(
                        spin: _portalCtrl.value,
                        pulse: _pulseCtrl.value,
                        float: _floatCtrl.value,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                content,
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 420,
                    child: AnimatedBuilder(
                      animation: Listenable.merge([
                        _portalCtrl,
                        _pulseCtrl,
                        _floatCtrl,
                      ]),
                      builder: (_, __) => Stack(
                        alignment: Alignment.center,
                        children: [
                          CustomPaint(
                            size: const Size(double.infinity, 420),
                            painter: _AikoPainter(
                              spin: _portalCtrl.value,
                              pulse: _pulseCtrl.value,
                              float: _floatCtrl.value,
                            ),
                          ),
                          Positioned(
                            top: 36,
                            right: 16,
                            child: Transform.translate(
                              offset: Offset(0, -7 * _floatCtrl.value),
                              child: _ChatBubble(
                                text:
                                    'Try "golden hour rim lighting" for dramatic portraits ✨',
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 44,
                            left: 12,
                            child: Transform.translate(
                              offset: Offset(0, 7 * _floatCtrl.value),
                              child: _ChatBubble(
                                text:
                                    'Beautiful atmospheric perspective in this piece! 🎨',
                              ),
                            ),
                          ),
                          Positioned(
                            top: 150,
                            left: 0,
                            child: Transform.translate(
                              offset: Offset(0, -4 * _floatCtrl.value),
                              child: _ChatBubble(
                                text: 'Shall I improve your prompt? ✦',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 72),
                Expanded(child: content),
              ],
            ),
    );
  }

  // ── TECH STRIP ───────────────────────────────────────────
  Widget _buildTechStrip(bool isMobile) {
    final techs = [
      ('☁️', 'Cloudflare AI'),
      ('⚡', 'Groq'),
      ('💎', 'Gemini Vision'),
      ('🔥', 'Firebase'),
      ('🗄️', 'Supabase'),
      ('🎯', 'Flutter'),
    ];
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 52,
        vertical: 10,
      ),
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 24 : 36,
        horizontal: isMobile ? 20 : 52,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF7c3aed).withOpacity(0.1),
            const Color(0xFF6366f1).withOpacity(0.06),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.purple.withOpacity(0.18)),
      ),
      child: isMobile
          ? Wrap(
              spacing: 16,
              runSpacing: 14,
              alignment: WrapAlignment.center,
              children: techs
                  .map(
                    (t) => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(t.$1, style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 7),
                        Text(
                          t.$2,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList(),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: techs
                  .map(
                    (t) => Row(
                      children: [
                        Text(t.$1, style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 9),
                        Text(
                          t.$2,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ),
    );
  }

  // ── CTA ──────────────────────────────────────────────────
  Widget _buildCTA(bool isMobile) {
    return AnimatedBuilder(
      animation: _pulseCtrl,
      builder: (_, __) => Container(
        margin: EdgeInsets.symmetric(
          horizontal: isMobile ? 16 : 52,
          vertical: 40,
        ),
        padding: EdgeInsets.symmetric(
          vertical: isMobile ? 40 : 64,
          horizontal: isMobile ? 24 : 52,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            colors: [
              const Color(0xFF7c3aed).withOpacity(0.16),
              const Color(0xFF6366f1).withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: Colors.purple.withOpacity(0.22 + 0.08 * _pulseCtrl.value),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(
                0xFF7c3aed,
              ).withOpacity(0.08 + 0.06 * _pulseCtrl.value),
              blurRadius: 60,
              spreadRadius: -10,
            ),
          ],
        ),
        child: Column(
          children: [
            ShaderMask(
              shaderCallback: (b) => const LinearGradient(
                colors: [Color(0xFFc084fc), Color(0xFF818cf8)],
              ).createShader(b),
              child: Text(
                'Ready to Create?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isMobile ? 36 : 52,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.5,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Join thousands of creators building their imagination with Aether.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                color: Colors.white.withOpacity(0.42),
              ),
            ),
            const SizedBox(height: 36),
            _HeroBtn(
              label: '✦  Start Creating Free',
              primary: true,
              onTap: _goToAuth,
            ),
          ],
        ),
      ),
    );
  }

  // ── FOOTER ───────────────────────────────────────────────
  Widget _buildFooter(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 36 : 52,
        horizontal: isMobile ? 24 : 52,
      ),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.purple.withOpacity(0.13))),
      ),
      child: Column(
        children: [
          ShaderMask(
            shaderCallback: (b) => const LinearGradient(
              colors: [Color(0xFFa855f7), Color(0xFF6366f1)],
            ).createShader(b),
            child: const Text(
              'AETHER',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: 6,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            isMobile
                ? 'Built with ✦ by Yash Pandey'
                : 'Built with ✦ by Yash Pandey  ·  Cloudflare AI, Groq, Gemini, Firebase & Supabase',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.38),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '© 2026 Aether Studio. All rights reserved.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.18),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────────────

class _FSlide extends StatelessWidget {
  final double delay, t;
  final Widget child;
  const _FSlide({required this.delay, required this.t, required this.child});
  @override
  Widget build(BuildContext context) {
    final v = ((t - delay) / (1 - delay)).clamp(0.0, 1.0);
    final curved = Curves.easeOutCubic.transform(v);
    return Opacity(
      opacity: curved,
      child: Transform.translate(
        offset: Offset(0, 28 * (1 - curved)),
        child: child,
      ),
    );
  }
}

class _NebulaBlob extends StatelessWidget {
  final Color color;
  final double size, opacity;
  const _NebulaBlob({
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

class _LiveDot extends StatefulWidget {
  @override
  State<_LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<_LiveDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    builder: (_, __) => Container(
      width: 9,
      height: 9,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF22c55e),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF22c55e).withOpacity(0.6 + 0.4 * _c.value),
            blurRadius: 6 + 6 * _c.value,
          ),
        ],
      ),
    ),
  );
}

class _BlinkCursor extends StatefulWidget {
  final double height;
  const _BlinkCursor({this.height = 80});
  @override
  State<_BlinkCursor> createState() => _BlinkCursorState();
}

class _BlinkCursorState extends State<_BlinkCursor>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    builder: (_, __) => Opacity(
      opacity: _c.value > 0.5 ? 1.0 : 0.0,
      child: Container(
        width: 4,
        height: widget.height,
        margin: const EdgeInsets.only(left: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFc084fc),
          borderRadius: BorderRadius.circular(2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFc084fc).withOpacity(0.85),
              blurRadius: 10,
            ),
          ],
        ),
      ),
    ),
  );
}

class _Badge extends StatelessWidget {
  final AnimationController pulseCtrl;
  const _Badge({required this.pulseCtrl});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
    decoration: BoxDecoration(
      color: Colors.purple.withOpacity(0.13),
      borderRadius: BorderRadius.circular(100),
      border: Border.all(color: Colors.purple.withOpacity(0.28)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: pulseCtrl,
          builder: (_, __) => Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFc084fc),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFc084fc).withOpacity(0.8),
                  blurRadius: 4 + 5 * pulseCtrl.value,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          'POWERED BY AI  ·  FREE TO USE',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
            color: Color(0xFFc084fc),
          ),
        ),
      ],
    ),
  );
}

class _SectionHeader extends StatelessWidget {
  final String label, title;
  final bool center, gradientTitle;
  const _SectionHeader({
    required this.label,
    required this.title,
    this.center = false,
    this.gradientTitle = false,
  });
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final titleSize = isMobile ? 32.0 : 48.0;
    return Column(
      crossAxisAlignment: center
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          textAlign: center ? TextAlign.center : TextAlign.left,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 4,
            color: Color(0xFFc084fc),
          ),
        ),
        const SizedBox(height: 14),
        gradientTitle
            ? RichText(
                textAlign: center ? TextAlign.center : TextAlign.left,
                text: TextSpan(
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                    letterSpacing: -1.5,
                  ),
                  children: [
                    TextSpan(
                      text: title.split('\n').first + '\n',
                      style: const TextStyle(color: Colors.white),
                    ),
                    TextSpan(
                      text: title.split('\n').last,
                      style: const TextStyle(color: Color(0xFFc084fc)),
                    ),
                  ],
                ),
              )
            : Text(
                title,
                textAlign: center ? TextAlign.center : TextAlign.left,
                style: TextStyle(
                  fontSize: titleSize,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                  letterSpacing: -1.5,
                  color: Colors.white,
                ),
              ),
      ],
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final String text;
  const _ChatBubble({required this.text});
  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(maxWidth: 195),
    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
    decoration: BoxDecoration(
      color: const Color(0xFF080514).withOpacity(0.93),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.purple.withOpacity(0.28)),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 18),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'AIKO',
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
            color: Color(0xFFc084fc),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.82),
            height: 1.5,
          ),
        ),
      ],
    ),
  );
}

class _AikoFeat extends StatefulWidget {
  final String icon, title, desc;
  const _AikoFeat({
    required this.icon,
    required this.title,
    required this.desc,
  });
  @override
  State<_AikoFeat> createState() => _AikoFeatState();
}

class _AikoFeatState extends State<_AikoFeat> {
  bool _hov = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => _hov = true),
    onExit: (_) => setState(() => _hov = false),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _hov
            ? Colors.purple.withOpacity(0.1)
            : Colors.purple.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _hov
              ? Colors.purple.withOpacity(0.32)
              : Colors.purple.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Text(widget.icon, style: const TextStyle(fontSize: 19)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  widget.desc,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

// ── BUTTONS ───────────────────────────────────────────────────
class _NavLink extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _NavLink({required this.label, required this.onTap});
  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hov = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => _hov = true),
    onExit: (_) => setState(() => _hov = false),
    child: GestureDetector(
      onTap: widget.onTap,
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 150),
        style: TextStyle(
          color: _hov ? Colors.white : Colors.white.withOpacity(0.45),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        child: Text(widget.label),
      ),
    ),
  );
}

class _GhostBtn extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _GhostBtn({required this.label, required this.onTap});
  @override
  State<_GhostBtn> createState() => _GhostBtnState();
}

class _GhostBtnState extends State<_GhostBtn> {
  bool _hov = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => _hov = true),
    onExit: (_) => setState(() => _hov = false),
    child: GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: _hov ? Colors.purple.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _hov
                ? Colors.purple.withOpacity(0.55)
                : Colors.purple.withOpacity(0.28),
          ),
        ),
        child: Text(
          widget.label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ),
  );
}

class _PrimaryBtn extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _PrimaryBtn({required this.label, required this.onTap});
  @override
  State<_PrimaryBtn> createState() => _PrimaryBtnState();
}

class _PrimaryBtnState extends State<_PrimaryBtn> {
  bool _hov = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => _hov = true),
    onExit: (_) => setState(() => _hov = false),
    child: GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        transform: Matrix4.translationValues(0, _hov ? -1 : 0, 0),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF7c3aed), Color(0xFF6366f1)],
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7c3aed).withOpacity(_hov ? 0.65 : 0.35),
              blurRadius: _hov ? 28 : 16,
            ),
          ],
        ),
        child: Text(
          widget.label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ),
  );
}

class _HeroBtn extends StatefulWidget {
  final String label;
  final bool primary;
  final VoidCallback onTap;
  const _HeroBtn({
    required this.label,
    required this.primary,
    required this.onTap,
  });
  @override
  State<_HeroBtn> createState() => _HeroBtnState();
}

class _HeroBtnState extends State<_HeroBtn> {
  bool _hov = false;
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    return MouseRegion(
      onEnter: (_) => setState(() => _hov = true),
      onExit: (_) => setState(() => _hov = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.translationValues(0, _hov ? -3 : 0, 0),
          // ── Full width on mobile ──
          width: isMobile ? double.infinity : null,
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 24 : 28,
            vertical: isMobile ? 14 : 16,
          ),
          decoration: BoxDecoration(
            gradient: widget.primary
                ? const LinearGradient(
                    colors: [Color(0xFF7c3aed), Color(0xFF6366f1)],
                  )
                : null,
            border: widget.primary
                ? null
                : Border.all(color: Colors.purple.withOpacity(0.35)),
            borderRadius: BorderRadius.circular(14),
            boxShadow: widget.primary
                ? [
                    BoxShadow(
                      color: const Color(
                        0xFF7c3aed,
                      ).withOpacity(_hov ? 0.72 : 0.42),
                      blurRadius: _hov ? 44 : 24,
                      spreadRadius: -4,
                    ),
                  ]
                : [],
            color: widget.primary
                ? null
                : (_hov ? Colors.purple.withOpacity(0.08) : Colors.transparent),
          ),
          child: Text(
            widget.label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

// ── FEATURE CARD ──────────────────────────────────────────────
class _FeatCard extends StatefulWidget {
  final String icon, title, desc;
  final int index;
  const _FeatCard({
    required this.icon,
    required this.title,
    required this.desc,
    required this.index,
  });
  @override
  State<_FeatCard> createState() => _FeatCardState();
}

class _FeatCardState extends State<_FeatCard> {
  bool _hov = false;
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    return MouseRegion(
      onEnter: (_) => setState(() => _hov = true),
      onExit: (_) => setState(() => _hov = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        transform: Matrix4.translationValues(0, _hov ? -6 : 0, 0),
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        decoration: BoxDecoration(
          color: const Color(0xFF080514).withOpacity(0.72),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _hov
                ? Colors.purple.withOpacity(0.42)
                : Colors.purple.withOpacity(0.13),
          ),
          boxShadow: _hov
              ? [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.12),
                    blurRadius: 36,
                  ),
                ]
              : [],
          gradient: _hov
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.purple.withOpacity(0.06), Colors.transparent],
                )
              : null,
        ),
        child: isMobile
            ? Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(
                        color: Colors.purple.withOpacity(0.22),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        widget.icon,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.desc,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.4),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(
                        color: Colors.purple.withOpacity(0.22),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        widget.icon,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Expanded(
                    child: Text(
                      widget.desc,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.4),
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String n, l;
  const _Stat({required this.n, required this.l});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    child: Column(
      children: [
        ShaderMask(
          shaderCallback: (b) => const LinearGradient(
            colors: [Color(0xFFc084fc), Color(0xFF818cf8)],
          ).createShader(b),
          child: Text(
            n,
            style: const TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          l,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.38)),
        ),
      ],
    ),
  );
}

class _SDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 46, color: Colors.purple.withOpacity(0.14));
}

// ── APP MOCKUP ────────────────────────────────────────────────
class _AppMockup extends StatelessWidget {
  const _AppMockup();
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    return Container(
      width: isMobile ? double.infinity : 780,
      decoration: BoxDecoration(
        color: const Color(0xFF080514).withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.55),
            blurRadius: 70,
            offset: const Offset(0, 32),
          ),
          BoxShadow(color: Colors.purple.withOpacity(0.18), blurRadius: 90),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.06),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              border: Border(
                bottom: BorderSide(color: Colors.purple.withOpacity(0.12)),
              ),
            ),
            child: Row(
              children: [
                _dot(const Color(0xFFff5f57)),
                const SizedBox(width: 6),
                _dot(const Color(0xFFffbd2e)),
                const SizedBox(width: 6),
                _dot(const Color(0xFF28c840)),
                const SizedBox(width: 12),
                Text(
                  'aether_studio',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
              ],
            ),
          ),
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(16),
            ),
            child: SizedBox(
              height: isMobile ? 170 : 210,
              child: Row(
                children: [
                  // Hide sidebar on very small screens
                  if (!isMobile)
                    SizedBox(
                      width: 175,
                      child: ClipRect(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF04020F).withOpacity(0.8),
                            border: Border(
                              right: BorderSide(
                                color: Colors.purple.withOpacity(0.1),
                              ),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _side('✦', 'Generator', true),
                              _side('🕐', 'History', false),
                              _side('✂️', 'Crop & Resize', false),
                              _side('⬆️', 'Upscale', false),
                              const SizedBox(height: 4),
                              Text(
                                'DIRECTOR MODE',
                                style: TextStyle(
                                  fontSize: 9,
                                  letterSpacing: 1.5,
                                  color: Colors.white.withOpacity(0.25),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Wrap(
                                spacing: 4,
                                runSpacing: 4,
                                children: [
                                  _chip('🎬 Nolan', const Color(0xFF7c3aed)),
                                  _chip('🌿 Ghibli', const Color(0xFF22c55e)),
                                  _chip('🌆 Blade', const Color(0xFFec4899)),
                                  _chip('🎭 Kubrick', const Color(0xFFf97316)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.purple.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.purple.withOpacity(0.18),
                              ),
                            ),
                            child: Text(
                              'A lone samurai at sunset, cherry blossoms falling...',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.4),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.purple.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.purple.withOpacity(0.18),
                                  ),
                                ),
                                child: Text(
                                  'Cinematic ▾',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.white.withOpacity(0.4),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              if (!isMobile)
                                ...['1:1', '4:3', '16:9'].map(
                                  (r) => Padding(
                                    padding: const EdgeInsets.only(right: 5),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 9,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: r == '1:1'
                                            ? Colors.purple.withOpacity(0.3)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: r == '1:1'
                                              ? Colors.purpleAccent
                                              : Colors.white.withOpacity(0.08),
                                        ),
                                      ),
                                      child: Text(
                                        r,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF7c3aed),
                                      Color(0xFF6366f1),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.purple.withOpacity(0.45),
                                      blurRadius: 12,
                                    ),
                                  ],
                                ),
                                child: const Text(
                                  '✦ Generate',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.purple.withOpacity(0.12),
                                    Colors.indigo.withOpacity(0.07),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.purple.withOpacity(0.12),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'Your imagination, rendered',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.18),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _dot(Color c) => Container(
    width: 12,
    height: 12,
    decoration: BoxDecoration(shape: BoxShape.circle, color: c),
  );

  static Widget _side(String ic, String lb, bool a) => Container(
    margin: const EdgeInsets.only(bottom: 2),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(
      color: a ? Colors.purple.withOpacity(0.2) : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      border: a ? Border.all(color: Colors.purple.withOpacity(0.3)) : null,
    ),
    child: Row(
      children: [
        Text(ic, style: const TextStyle(fontSize: 12)),
        const SizedBox(width: 6),
        Text(
          lb,
          style: TextStyle(
            fontSize: 11,
            color: a ? Colors.white : Colors.white.withOpacity(0.4),
          ),
        ),
      ],
    ),
  );

  static Widget _chip(String lb, Color c) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
    decoration: BoxDecoration(
      color: c.withOpacity(0.12),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: c.withOpacity(0.25)),
    ),
    child: Text(lb, style: const TextStyle(fontSize: 9, color: Colors.white)),
  );
}

// ── PAINTERS ──────────────────────────────────────────────────
class _Particle {
  double angle, dist, size, speed, life, maxLife;
  Color color;
  _Particle({required Random rng})
    : angle = rng.nextDouble() * pi * 2,
      dist = 0,
      size = rng.nextDouble() * 4 + 1.5,
      speed = rng.nextDouble() * 65 + 38,
      life = 0,
      maxLife = rng.nextDouble() * 2 + 0.8,
      color = rng.nextBool()
          ? const Color(0xFFc084fc)
          : const Color(0xFF818cf8);
}

class _PortalPainter extends CustomPainter {
  final double r1, r2, pulse;
  final List<_Particle> particles;
  final Random rng;
  _PortalPainter({
    required this.r1,
    required this.r2,
    required this.pulse,
    required this.particles,
    required this.rng,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2;
    final c = Offset(cx, cy);
    _ring(canvas, c, 160, r1, 1.0, const Color(0xFFa855f7), false);
    _ring(canvas, c, 240, -r2, 0.55, const Color(0xFF6366f1), false);
    _ring(canvas, c, 340, r1 * 0.7, 0.3, const Color(0xFFa855f7), true);
    _ring(canvas, c, 460, -r2 * 0.5, 0.18, const Color(0xFF6366f1), true);
    _ring(canvas, c, 560, r1 * 0.3, 0.08, const Color(0xFFa855f7), true);
    for (int i = 0; i < 60; i++) {
      final a = (i / 60) * pi * 2 + r1 * pi * 2;
      final main = i % 5 == 0;
      canvas.drawLine(
        Offset(cx + cos(a) * 164, cy + sin(a) * 164),
        Offset(
          cx + cos(a) * (164 + (main ? 12 : 7)),
          cy + sin(a) * (164 + (main ? 12 : 7)),
        ),
        Paint()
          ..color = const Color(0xFFa855f7).withOpacity(main ? 0.65 : 0.28)
          ..strokeWidth = main ? 2 : 1
          ..strokeCap = StrokeCap.round,
      );
    }
    final cr = 50.0 + 18 * pulse;
    canvas.drawCircle(
      c,
      cr + 30,
      Paint()
        ..color = const Color(0xFF7c3aed).withOpacity(0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30),
    );
    canvas.drawCircle(
      c,
      cr,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFc084fc),
            const Color(0xFF7c3aed).withOpacity(0.8),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: c, radius: cr + 10)),
    );
    for (final p in particles) {
      p.life += 0.016;
      if (p.life > p.maxLife) {
        p.life = 0;
        p.angle = rng.nextDouble() * pi * 2;
        p.dist = 0;
        p.speed = rng.nextDouble() * 65 + 38;
      }
      p.dist += p.speed * 0.016;
      final alpha = (1 - p.life / p.maxLife).clamp(0.0, 1.0);
      canvas.drawCircle(
        Offset(cx + cos(p.angle) * p.dist, cy + sin(p.angle) * p.dist),
        p.size * alpha,
        Paint()
          ..color = p.color.withOpacity(alpha * 0.75)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );
    }
  }

  void _ring(
    Canvas canvas,
    Offset c,
    double rad,
    double rot,
    double op,
    Color col,
    bool dash,
  ) {
    final p = Paint()
      ..color = col.withOpacity(op)
      ..style = PaintingStyle.stroke
      ..strokeWidth = dash ? 1 : 1.5;
    if (!dash) {
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.rotate(rot * pi * 2);
      canvas.drawCircle(Offset.zero, rad, p);
      canvas.restore();
    } else {
      for (int i = 0; i < 40; i += 2) {
        canvas.drawArc(
          Rect.fromCircle(center: c, radius: rad),
          (i / 40) * pi * 2 + rot * pi * 2,
          pi / 40,
          false,
          p,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_) => true;
}

class _AikoPainter extends CustomPainter {
  final double spin, pulse, float;
  _AikoPainter({required this.spin, required this.pulse, required this.float});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2 + (-6 + 12 * float);
    final c = Offset(cx, cy);
    _r(canvas, c, 100, spin, 0.4, false);
    _r(canvas, c, 150, -spin * 0.7, 0.22, true);
    _r(canvas, c, 195, spin * 0.45, 0.11, true);
    final r = 58.0 + 10 * pulse;
    canvas.drawCircle(
      c,
      r + 22,
      Paint()
        ..color = const Color(0xFF7c3aed).withOpacity(0.13)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22),
    );
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.3, -0.3),
          colors: [Color(0xFF9d5cff), Color(0xFF4a148c), Color(0xFF1a0a2e)],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = const Color(0xFFa855f7).withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _r(
    Canvas canvas,
    Offset c,
    double rad,
    double rot,
    double op,
    bool dash,
  ) {
    final p = Paint()
      ..color = const Color(0xFFa855f7).withOpacity(op)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    if (!dash) {
      canvas.drawCircle(c, rad, p);
    } else {
      for (int i = 0; i < 30; i += 2) {
        canvas.drawArc(
          Rect.fromCircle(center: c, radius: rad),
          (i / 30) * pi * 2 + rot * pi * 2,
          pi / 30,
          false,
          p,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_) => true;
}

class _StarfieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(42);
    for (int i = 0; i < 220; i++) {
      final bright = rng.nextDouble() > 0.88;
      canvas.drawCircle(
        Offset(rng.nextDouble() * size.width, rng.nextDouble() * size.height),
        rng.nextDouble() * (bright ? 2.0 : 1.4) + 0.2,
        Paint()
          ..color = Colors.white.withOpacity(
            rng.nextDouble() * (bright ? 0.7 : 0.3) + 0.08,
          ),
      );
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
