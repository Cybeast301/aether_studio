import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../generator_controller.dart';
import '../theme_controller.dart'; // ✅

class GenerateButton extends StatefulWidget {
  final VoidCallback onPressed;
  const GenerateButton({super.key, required this.onPressed});

  @override
  State<GenerateButton> createState() => _GenerateButtonState();
}

class _GenerateButtonState extends State<GenerateButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerCtrl;

  @override
  void initState() {
    super.initState();
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isGenerating = context.watch<GeneratorController>().isGenerating;
    final isDark = context.watch<ThemeController>().isDark; // ✅

    return SizedBox(
      height: 52,
      child: AnimatedBuilder(
        animation: _shimmerCtrl,
        builder: (_, __) {
          return GestureDetector(
            onTap: isGenerating ? null : widget.onPressed,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: isGenerating
                    ? (isDark
                          ? Colors.white.withOpacity(0.04)
                          : Colors.black.withOpacity(0.04)) // ✅
                    : (isDark
                          ? Colors.white.withOpacity(0.08)
                          : const Color(0xFF4F46E5).withOpacity(0.12)), // ✅
                border: Border.all(
                  color: isGenerating
                      ? (isDark
                            ? Colors.white.withOpacity(0.1)
                            : Colors.black.withOpacity(0.1)) // ✅
                      : const Color(0xFF818CF8).withOpacity(0.6),
                  width: 1.2,
                ),
                boxShadow: isGenerating
                    ? null
                    : [
                        BoxShadow(
                          color: const Color(0xFF4F46E5).withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: -4,
                        ),
                        BoxShadow(
                          color: const Color(0xFF7C3AED).withOpacity(0.2),
                          blurRadius: 40,
                          spreadRadius: -8,
                        ),
                      ],
                gradient: isGenerating
                    ? null
                    : LinearGradient(
                        begin: Alignment(-1 + 2 * _shimmerCtrl.value, -0.5),
                        end: Alignment(1 + 2 * _shimmerCtrl.value, 0.5),
                        colors: isDark
                            ? [
                                // dark shimmer — white
                                Colors.white.withOpacity(0.0),
                                Colors.white.withOpacity(0.08),
                                const Color(0xFF818CF8).withOpacity(0.15),
                                Colors.white.withOpacity(0.0),
                              ]
                            : [
                                // ✅ light shimmer — purple tones
                                const Color(0xFF4F46E5).withOpacity(0.0),
                                const Color(0xFF6366F1).withOpacity(0.15),
                                const Color(0xFF818CF8).withOpacity(0.25),
                                const Color(0xFF4F46E5).withOpacity(0.0),
                              ],
                        stops: const [0.0, 0.35, 0.5, 1.0],
                      ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isGenerating)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF818CF8),
                      ),
                    )
                  else
                    Icon(
                      Icons.auto_awesome,
                      size: 18,
                      color: isDark
                          ? const Color(0xFFE0E7FF)
                          : const Color(0xFF4F46E5), // ✅
                    ),
                  const SizedBox(width: 10),
                  Text(
                    isGenerating ? 'Generating…' : 'Generate',
                    style: TextStyle(
                      color: isGenerating
                          ? (isDark
                                ? Colors.white.withOpacity(0.4)
                                : Colors.black.withOpacity(0.3)) // ✅
                          : (isDark
                                ? const Color(0xFFE0E7FF)
                                : const Color(0xFF4F46E5)), // ✅
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
