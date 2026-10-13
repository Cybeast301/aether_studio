import 'package:aether_studio/features/generator/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ThemeToggle extends StatefulWidget {
  const ThemeToggle({super.key});
  @override
  State<ThemeToggle> createState() => _ThemeToggleState();
}

class _ThemeToggleState extends State<ThemeToggle>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _slide = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
    if (!ThemeController.instance.isDark) _ctrl.value = 1.0;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onToggle() {
    final ctrl = context.read<ThemeController>();
    ctrl.toggle();
    if (ctrl.isDark) {
      _ctrl.reverse();
    } else {
      _ctrl.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeController>().isDark;
    return GestureDetector(
      onTap: _onToggle,
      child: AnimatedBuilder(
        animation: _slide,
        builder: (_, __) {
          return Container(
            width: 56,
            height: 28,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              // Track color transitions between dark/light
              color: Color.lerp(
                const Color(0xFF1e1b4b), // dark track — deep indigo
                const Color(0xFFe0e7ff), // light track — soft lavender
                _slide.value,
              ),
              border: Border.all(
                color: Color.lerp(
                  const Color(0xFF6366f1).withOpacity(0.5),
                  const Color(0xFF6366f1).withOpacity(0.3),
                  _slide.value,
                )!,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366f1).withOpacity(0.2),
                  blurRadius: 8,
                  spreadRadius: -2,
                ),
              ],
            ),
            child: Stack(
              children: [
                // ── Sun icon (left side) ──
                Positioned(
                  left: 6,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Opacity(
                      opacity: _slide.value,
                      child: const Icon(
                        Icons.wb_sunny_rounded,
                        size: 13,
                        color: Color(0xFFf59e0b),
                      ),
                    ),
                  ),
                ),
                // ── Moon icon (right side) ──
                Positioned(
                  right: 6,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Opacity(
                      opacity: 1 - _slide.value,
                      child: const Icon(
                        Icons.nightlight_round,
                        size: 13,
                        color: Color(0xFF818cf8),
                      ),
                    ),
                  ),
                ),
                // ── Sliding thumb ──
                Positioned(
                  left: 3 + (_slide.value * 28),
                  top: 3,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Color.lerp(
                            const Color(0xFF818cf8),
                            const Color(0xFFfbbf24),
                            _slide.value,
                          )!,
                          Color.lerp(
                            const Color(0xFF6366f1),
                            const Color(0xFFf59e0b),
                            _slide.value,
                          )!,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color.lerp(
                            const Color(0xFF6366f1),
                            const Color(0xFFf59e0b),
                            _slide.value,
                          )!.withOpacity(0.6),
                          blurRadius: 8,
                          spreadRadius: -1,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
