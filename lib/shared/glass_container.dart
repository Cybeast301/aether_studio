import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/theme.dart';

class GlassContainer extends StatefulWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double blur;
  final Color? fillColor;
  final Border? border;
  final bool enableHover;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(AppConstants.padding),
    this.borderRadius = AppConstants.borderRadiusMd,
    this.blur = AppConstants.glassBlur,
    this.fillColor,
    this.border,
    this.enableHover = true,
  });

  @override
  State<GlassContainer> createState() => _GlassContainerState();
}

class _GlassContainerState extends State<GlassContainer> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(widget.borderRadius);

    Widget content = ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: widget.blur, sigmaY: widget.blur),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: widget.width,
          height: widget.height,
          padding: widget.padding,
          decoration: BoxDecoration(
            color: widget.fillColor ?? AppTheme.surfaceGlass,
            borderRadius: radius,
            border:
                widget.border ??
                Border.all(
                  color: _isHovered
                      ? AppTheme.primary.withOpacity(0.6)
                      : Colors.white.withOpacity(0.08),
                  width: 1,
                ),
            boxShadow: _isHovered
                ? AppTheme.intenseGlowShadow
                : AppTheme.glowShadow,
          ),
          child: Stack(
            children: [
              /// ✨ Subtle top light reflection
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: radius,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.05),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              /// 👇 Actual content
              widget.child,
            ],
          ),
        ),
      ),
    );

    if (!widget.enableHover) return content;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        scale: _isHovered ? 1.02 : 1,
        child: content,
      ),
    );
  }
}
