import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../../core/constants.dart';
import '../generator_controller.dart';
import '../theme_controller.dart'; // ✅

class AspectRatioSelector extends StatelessWidget {
  const AspectRatioSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<GeneratorController>();
    final isDark = context.watch<ThemeController>().isDark; // ✅

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Aspect Ratio',
          style: TextStyle(
            color: isDark ? AppTheme.onSurfaceMuted : Colors.black54, // ✅
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: AppConstants.aspectRatios.map((ratio) {
              final isSelected = ratio == ctrl.selectedAspectRatio;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: _RatioButton(
                  ratio: ratio,
                  isSelected: isSelected,
                  isDark: isDark, // ✅
                  onTap: () =>
                      context.read<GeneratorController>().setAspectRatio(ratio),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _RatioButton extends StatefulWidget {
  final String ratio;
  final bool isSelected;
  final bool isDark; // ✅
  final VoidCallback onTap;

  const _RatioButton({
    required this.ratio,
    required this.isSelected,
    required this.isDark, // ✅
    required this.onTap,
  });

  @override
  State<_RatioButton> createState() => _RatioButtonState();
}

class _RatioButtonState extends State<_RatioButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isActive = widget.isSelected || _isHovered;
    final isDark = widget.isDark;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: widget.isSelected ? 1.08 : (_isHovered ? 1.04 : 1),
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? AppTheme.primary.withOpacity(0.25)
                  : isDark
                  ? Colors.white.withOpacity(0.04)
                  : Colors.black.withOpacity(0.05), // ✅
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusSm),
              border: Border.all(
                color: widget.isSelected
                    ? AppTheme.primary
                    : isDark
                    ? Colors.white.withOpacity(0.08)
                    : Colors.black.withOpacity(0.15), // ✅
              ),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: AppTheme.primary.withOpacity(0.35),
                        blurRadius: 16,
                        spreadRadius: 1,
                      ),
                    ]
                  : [],
            ),
            child: Text(
              widget.ratio,
              style: TextStyle(
                color: widget.isSelected
                    ? (isDark
                          ? AppTheme.primaryLight
                          : const Color(
                              0xFF3730A3,
                            )) // ✅ dark indigo in light mode
                    : isDark
                    ? AppTheme.onSurfaceMuted
                    : Colors.black54,
                fontSize: 13,
                fontWeight: widget.isSelected
                    ? FontWeight.w600
                    : FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
