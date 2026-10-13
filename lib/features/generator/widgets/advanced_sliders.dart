import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../../core/constants.dart';
import '../generator_controller.dart';

class AdvancedSliders extends StatelessWidget {
  const AdvancedSliders({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<GeneratorController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Sampling Steps ──────────────────────────────────────────────────
        _SliderHeader(
          label: 'Sampling Steps',
          value: ctrl.samplingSteps.toString(),
          tooltip: 'Number of iterations to refine the image. Higher means more detail but slower generation.',
        ),
        SliderTheme(
          data: _sliderTheme(context),
          child: Slider(
            value: ctrl.samplingSteps.toDouble(),
            min: 1,
            max: 50,
            divisions: 49,
            onChanged: (v) => ctrl.setSamplingSteps(v.round()),
          ),
        ),
        const SizedBox(height: 16),

        // ── CFG Scale ───────────────────────────────────────────────────────
        _SliderHeader(
          label: 'CFG Scale',
          value: ctrl.cfgScale.toStringAsFixed(1),
          tooltip: 'Classifier Free Guidance. Higher values make the AI follow your prompt more strictly.',
        ),
        SliderTheme(
          data: _sliderTheme(context),
          child: Slider(
            value: ctrl.cfgScale,
            min: 1.0,
            max: 20.0,
            divisions: 19,
            onChanged: (v) => ctrl.setCfgScale(v),
          ),
        ),
        const SizedBox(height: 16),

        // ── Seed (Numeric Input) ────────────────────────────────────────────
        const Text(
          'Seed',
          style: TextStyle(
            color: AppTheme.onSurfaceMuted,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: ctrl.seed?.toString() ?? '',
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppTheme.onSurface, fontSize: 14),
                decoration: _inputDecoration('Enter seed (optional)'),
                onChanged: (v) {
                  final val = int.tryParse(v);
                  ctrl.setSeed(val);
                },
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () {
                // In a real app, we might use a random generator here
                // For now, let's just clear it if they want "random"
                ctrl.setSeed(null);
              },
              icon: const Icon(Icons.refresh, size: 20),
              tooltip: 'Randomize Seed',
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.04),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusSm),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  SliderThemeData _sliderTheme(BuildContext context) {
    return SliderTheme.of(context).copyWith(
      activeTrackColor: AppTheme.primary,
      inactiveTrackColor: Colors.white.withOpacity(0.08),
      thumbColor: Colors.white,
      overlayColor: AppTheme.primary.withOpacity(0.12),
      trackHeight: 4,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
      overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppTheme.onSurfaceMuted, fontSize: 14),
      filled: true,
      fillColor: Colors.white.withOpacity(0.04),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSm),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSm),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSm),
        borderSide: const BorderSide(color: AppTheme.primary),
      ),
    );
  }
}

class _SliderHeader extends StatelessWidget {
  final String label;
  final String value;
  final String tooltip;

  const _SliderHeader({
    required this.label,
    required this.value,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.onSurfaceMuted,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Tooltip(
              message: tooltip,
              child: const Icon(
                Icons.info_outline,
                size: 14,
                color: AppTheme.onSurfaceMuted,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.onSurface,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
