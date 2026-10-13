import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../../core/constants.dart';
import '../generator_controller.dart';
import '../theme_controller.dart'; // ✅

class StyleSelector extends StatelessWidget {
  const StyleSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<GeneratorController>();
    final isDark = context.watch<ThemeController>().isDark; // ✅

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Style',
          style: TextStyle(
            color: isDark ? AppTheme.onSurfaceMuted : Colors.black54, // ✅
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: ctrl.selectedStyle,
          dropdownColor: isDark ? AppTheme.surfaceCard : Colors.white, // ✅
          style: TextStyle(
            color: isDark ? AppTheme.onSurface : Colors.black87, // ✅
            fontSize: 14,
          ),
          icon: Icon(
            Icons.expand_more,
            color: isDark ? AppTheme.onSurfaceMuted : Colors.black45, // ✅
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: isDark
                ? Colors.white.withOpacity(0.04)
                : Colors.white.withOpacity(0.8), // ✅
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusSm),
              borderSide: BorderSide(
                color: isDark
                    ? Colors.white.withOpacity(0.08)
                    : Colors.black.withOpacity(0.15), // ✅
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusSm),
              borderSide: BorderSide(
                color: isDark
                    ? Colors.white.withOpacity(0.08)
                    : Colors.black.withOpacity(0.15), // ✅
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusSm),
              borderSide: const BorderSide(color: AppTheme.primary),
            ),
          ),
          items: AppConstants.stylePresets
              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
              .toList(),
          onChanged: (v) {
            if (v != null) context.read<GeneratorController>().setStyle(v);
          },
        ),
      ],
    );
  }
}
