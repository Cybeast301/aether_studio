import 'dart:typed_data';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../../core/constants.dart';
import '../../../shared/glass_container.dart';
import '../generator_controller.dart';
import '../theme_controller.dart';

class PreviewPanel extends StatelessWidget {
  const PreviewPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<GeneratorController>();
    final isMobile = MediaQuery.of(context).size.width < 768;

    return SizedBox.expand(
      child: GlassContainer(
        padding: const EdgeInsets.all(AppConstants.paddingLg),
        child: isMobile
            ? SingleChildScrollView(child: _buildContent(ctrl, context))
            : _buildContent(ctrl, context),
      ),
    );
  }

  Widget _buildContent(GeneratorController ctrl, BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    if (ctrl.isGenerating)
      return const Center(child: CircularProgressIndicator());
    if (ctrl.hasError) return Center(child: Text(ctrl.errorMessage ?? 'Error'));

    if (ctrl.hasResult && ctrl.imageBytes != null) {
      if (ctrl.bgRemovedBytes != null) return _BeforeAfterView();

      if (isMobile) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Image: fixed height on mobile ──
            SizedBox(
              height: 280,
              width: double.infinity,
              child: _ImagePreview(imageBytes: ctrl.imageBytes!),
            ),
            const SizedBox(height: 14),
            _ActionPanel(),
          ],
        );
      }

      return Row(
        children: [
          Expanded(child: _ImagePreview(imageBytes: ctrl.imageBytes!)),
          const SizedBox(width: AppConstants.paddingLg),
          Expanded(child: _ActionPanel()),
        ],
      );
    }
    return const _EmptyState();
  }
}

//////////////////////////////////////////////////////////////
/// 🔀 BEFORE & AFTER VIEW
//////////////////////////////////////////////////////////////

class _BeforeAfterView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<GeneratorController>();
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: isMobile ? 200 : 300,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    _Label(text: isMobile ? '🖼 Original' : '🖼 Original'),
                    const SizedBox(height: 4),
                    Expanded(
                      child: _ImagePreview(imageBytes: ctrl.imageBytes!),
                    ),
                  ],
                ),
              ),
              SizedBox(width: isMobile ? 8 : AppConstants.paddingLg),
              Expanded(
                child: Column(
                  children: [
                    _Label(
                      text: isMobile ? '✨ BG Removed' : '✨ Background Removed',
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: _ImagePreview(
                        imageBytes: ctrl.bgRemovedBytes!,
                        checkered: true,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (isMobile)
          Column(
            children: [
              LiquidGlassButton(
                label: 'Download Original',
                icon: Icons.download_rounded,
                color: const Color(0xFF3B82F6),
                fullWidth: true,
                compact: true,
                onTap: () => ctrl.downloadImage(bgRemoved: false),
              ),
              const SizedBox(height: 8),
              LiquidGlassButton(
                label: 'Download No-BG',
                icon: Icons.download_rounded,
                color: const Color(0xFF8B5CF6),
                fullWidth: true,
                compact: true,
                onTap: () => ctrl.downloadImage(bgRemoved: true),
              ),
              const SizedBox(height: 8),
              LiquidGlassButton(
                label: 'Regenerate',
                icon: Icons.refresh_rounded,
                color: Colors.white,
                fullWidth: true,
                compact: true,
                isOutlined: true,
                onTap: ctrl.generate,
              ),
            ],
          )
        else
          Row(
            children: [
              Expanded(
                child: LiquidGlassButton(
                  label: 'Download Original',
                  icon: Icons.download_rounded,
                  color: const Color(0xFF3B82F6),
                  onTap: () => ctrl.downloadImage(bgRemoved: false),
                ),
              ),
              const SizedBox(width: AppConstants.padding),
              Expanded(
                child: LiquidGlassButton(
                  label: 'Download No-BG',
                  icon: Icons.download_rounded,
                  color: const Color(0xFF8B5CF6),
                  onTap: () => ctrl.downloadImage(bgRemoved: true),
                ),
              ),
              const SizedBox(width: AppConstants.padding),
              Expanded(
                child: LiquidGlassButton(
                  label: 'Regenerate',
                  icon: Icons.refresh_rounded,
                  color: Colors.white,
                  isOutlined: true,
                  onTap: ctrl.generate,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

//////////////////////////////////////////////////////////////
/// 🖼 IMAGE PREVIEW
//////////////////////////////////////////////////////////////

class _ImagePreview extends StatelessWidget {
  final Uint8List imageBytes;
  final bool checkered;
  const _ImagePreview({required this.imageBytes, this.checkered = false});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (checkered)
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusMd),
              child: CustomPaint(painter: _CheckerPainter()),
            ),
          ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusMd),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withOpacity(0.4),
                  blurRadius: 40,
                ),
              ],
            ),
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMd),
          child: Image.memory(
            imageBytes,
            fit: BoxFit.contain,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
      ],
    );
  }
}

//////////////////////////////////////////////////////////////
/// ⬇ ACTION PANEL
//////////////////////////////////////////////////////////////

class _ActionPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<GeneratorController>();
    final isDark = context.watch<ThemeController>().isDark;
    final isMobile = MediaQuery.of(context).size.width < 768;

    if (isMobile) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LiquidGlassButton(
            label: 'Download',
            icon: Icons.download_rounded,
            color: const Color(0xFF3B82F6),
            fullWidth: true,
            compact: true,
            onTap: () => ctrl.downloadImage(bgRemoved: false),
          ),
          const SizedBox(height: 8),
          LiquidGlassButton(
            label: ctrl.isRemovingBg ? 'Removing BG...' : 'Remove Background',
            icon: Icons.auto_fix_high_rounded,
            color: const Color(0xFF8B5CF6),
            fullWidth: true,
            compact: true,
            loading: ctrl.isRemovingBg,
            onTap: ctrl.isRemovingBg ? null : ctrl.removeBackground,
          ),
          const SizedBox(height: 8),
          LiquidGlassButton(
            label: 'Regenerate',
            icon: Icons.refresh_rounded,
            color: Colors.white,
            fullWidth: true,
            compact: true,
            isOutlined: true,
            onTap: ctrl.generate,
          ),
          const SizedBox(height: 8),
        ],
      );
    }

    return GlassContainer(
      padding: const EdgeInsets.all(AppConstants.paddingLg),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Creation',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? AppTheme.onSurface : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            _InfoRow(label: 'Style', value: ctrl.selectedStyle),
            _InfoRow(label: 'Aspect Ratio', value: ctrl.selectedAspectRatio),
            const SizedBox(height: 24),
            LiquidGlassButton(
              label: 'Download Image',
              icon: Icons.download_rounded,
              color: const Color(0xFF3B82F6),
              fullWidth: true,
              onTap: () => ctrl.downloadImage(bgRemoved: false),
            ),
            const SizedBox(height: 12),
            LiquidGlassButton(
              label: ctrl.isRemovingBg ? 'Removing BG...' : 'Remove Background',
              icon: Icons.auto_fix_high_rounded,
              color: const Color(0xFF8B5CF6),
              fullWidth: true,
              loading: ctrl.isRemovingBg,
              onTap: ctrl.isRemovingBg ? null : ctrl.removeBackground,
            ),
            const SizedBox(height: 12),
            LiquidGlassButton(
              label: 'Regenerate',
              icon: Icons.refresh_rounded,
              color: Colors.white,
              fullWidth: true,
              isOutlined: true,
              onTap: ctrl.generate,
            ),
          ],
        ),
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
/// 💧 LIQUID GLASS BUTTON
//////////////////////////////////////////////////////////////

class LiquidGlassButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final bool fullWidth, isOutlined, loading, compact;

  const LiquidGlassButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    this.onTap,
    this.fullWidth = false,
    this.isOutlined = false,
    this.loading = false,
    this.compact = false,
  });

  @override
  State<LiquidGlassButton> createState() => _LiquidGlassButtonState();
}

class _LiquidGlassButtonState extends State<LiquidGlassButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pressAnim;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _pressAnim = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onTap == null;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: disabled
          ? SystemMouseCursors.forbidden
          : SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => _ctrl.forward(),
        onTapUp: (_) {
          _ctrl.reverse();
          if (!disabled) widget.onTap?.call();
        },
        onTapCancel: () => _ctrl.reverse(),
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => Transform.scale(
            scale: _pressAnim.value,
            child: _buildButtonBody(disabled),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonBody(bool disabled) {
    final c = disabled ? Colors.white.withOpacity(0.15) : widget.color;
    final height = widget.compact ? 38.0 : 48.0;
    final fontSize = widget.compact ? 12.5 : 13.5;
    final iconSize = widget.compact ? 14.0 : 16.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: widget.fullWidth ? double.infinity : null,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: disabled
            ? LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.04),
                  Colors.white.withOpacity(0.02),
                ],
              )
            : widget.isOutlined
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(_hovered ? 0.12 : 0.07),
                  Colors.white.withOpacity(_hovered ? 0.06 : 0.03),
                ],
              )
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  c.withOpacity(_hovered ? 0.75 : 0.55),
                  c.withOpacity(_hovered ? 0.45 : 0.30),
                  c.withOpacity(_hovered ? 0.25 : 0.15),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
        border: Border.all(
          color: disabled
              ? Colors.white.withOpacity(0.08)
              : widget.isOutlined
              ? Colors.white.withOpacity(_hovered ? 0.4 : 0.25)
              : c.withOpacity(_hovered ? 0.9 : 0.6),
          width: 1.0,
        ),
        boxShadow: disabled
            ? null
            : [
                BoxShadow(
                  color: c.withOpacity(_hovered ? 0.4 : 0.2),
                  blurRadius: _hovered ? 20 : 10,
                  spreadRadius: -2,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.08),
                  blurRadius: 4,
                  spreadRadius: -1,
                  offset: const Offset(0, -1),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 8,
              right: 8,
              height: 1.5,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.white.withOpacity(disabled ? 0.05 : 0.5),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisSize: widget.fullWidth
                      ? MainAxisSize.max
                      : MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.loading)
                      SizedBox(
                        width: iconSize,
                        height: iconSize,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: widget.color.withOpacity(0.8),
                        ),
                      )
                    else
                      Icon(
                        widget.icon,
                        size: iconSize,
                        color: disabled
                            ? Colors.white.withOpacity(0.2)
                            : widget.isOutlined
                            ? Colors.white.withOpacity(0.7)
                            : Colors.white.withOpacity(0.95),
                      ),
                    const SizedBox(width: 6),
                    Text(
                      widget.label,
                      style: TextStyle(
                        color: disabled
                            ? Colors.white.withOpacity(0.2)
                            : widget.isOutlined
                            ? Colors.white.withOpacity(_hovered ? 0.9 : 0.7)
                            : Colors.white.withOpacity(0.95),
                        fontWeight: FontWeight.w600,
                        fontSize: fontSize,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
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
/// 🏁 CHECKERED PAINTER
//////////////////////////////////////////////////////////////

class _CheckerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const squareSize = 12.0;
    final paint1 = Paint()..color = Colors.white;
    final paint2 = Paint()..color = Colors.grey.shade300;
    for (double y = 0; y < size.height; y += squareSize) {
      for (double x = 0; x < size.width; x += squareSize) {
        final isEven =
            ((x / squareSize).floor() + (y / squareSize).floor()) % 2 == 0;
        canvas.drawRect(
          Rect.fromLTWH(x, y, squareSize, squareSize),
          isEven ? paint1 : paint2,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

//////////////////////////////////////////////////////////////
/// 🏷 LABEL / INFO ROW / EMPTY STATE
//////////////////////////////////////////////////////////////

class _Label extends StatelessWidget {
  final String text;
  const _Label({required this.text});
  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeController>().isDark;
    return Text(
      text,
      style: TextStyle(
        color: isDark ? AppTheme.onSurface : Colors.black87,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  const _InfoRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeController>().isDark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(
            '$label:',
            style: TextStyle(
              color: isDark ? AppTheme.onSurfaceMuted : Colors.black45,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(
              color: isDark ? AppTheme.onSurface : Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeController>().isDark;
    return SizedBox.expand(
      child: Center(
        child: Text(
          'Convert your shadows into reality',
          style: TextStyle(
            color: isDark ? AppTheme.onSurfaceMuted : Colors.black54,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
