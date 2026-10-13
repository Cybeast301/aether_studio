import 'package:aether_studio/features/generator/generator_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//////////////////////////////////////////////////////////////
/// 🎬 CINEMATIC PRESETS DATA
//////////////////////////////////////////////////////////////

class CinematicPreset {
  final String name;
  final String emoji;
  final String description;
  final String promptSuffix; // injected into generation prompt
  final Color color;

  const CinematicPreset({
    required this.name,
    required this.emoji,
    required this.description,
    required this.promptSuffix,
    required this.color,
  });
}

const List<CinematicPreset> cinematicPresets = [
  CinematicPreset(
    name: 'Nolan',
    emoji: '🎬',
    description: 'Epic & dark',
    promptSuffix:
        'shot like Christopher Nolan, IMAX cinematic, dramatic dark tones, shallow depth of field, ultra sharp, moody atmospheric lighting, emotional intensity',
    color: Color(0xFF3B82F6),
  ),
  CinematicPreset(
    name: 'Ghibli',
    emoji: '🌿',
    description: 'Whimsical warmth',
    promptSuffix:
        'Studio Ghibli style, hand painted, warm golden light, lush natural environments, whimsical soft atmosphere, painterly brushstrokes, Hayao Miyazaki',
    color: Color(0xFF22C55E),
  ),
  CinematicPreset(
    name: 'Blade Runner',
    emoji: '🌆',
    description: 'Neon noir',
    promptSuffix:
        'Blade Runner 2049 style, neon cyberpunk, rain-soaked streets, dramatic neon reflections, dark moody atmosphere, Roger Deakins cinematography, volumetric fog',
    color: Color(0xFFEC4899),
  ),
  CinematicPreset(
    name: 'Kubrick',
    emoji: '🎭',
    description: 'Cold symmetry',
    promptSuffix:
        'Stanley Kubrick style, perfect one-point perspective symmetry, cold clinical lighting, eerie stillness, wide angle lens, methodical composition',
    color: Color(0xFFF59E0B),
  ),
  CinematicPreset(
    name: 'Wong Kar-wai',
    emoji: '🌸',
    description: 'Dreamy & hazy',
    promptSuffix:
        'Wong Kar-wai style, slow motion haze, warm nostalgic tones, motion blur, neon signs, intimate close-ups, melancholic romantic mood, film grain',
    color: Color(0xFFEF4444),
  ),
  CinematicPreset(
    name: 'Villeneuve',
    emoji: '🪐',
    description: 'Vast & epic',
    promptSuffix:
        'Denis Villeneuve style, Dune cinematography, vast landscapes, otherworldly scale, golden desert light, minimal dialogue tension, Greig Fraser photography',
    color: Color(0xFFD97706),
  ),
];

//////////////////////////////////////////////////////////////
/// 🎬 CINEMATIC PRESETS WIDGET — fits in sidebar Advanced Settings box
//////////////////////////////////////////////////////////////

class CinematicPresetsWidget extends StatelessWidget {
  const CinematicPresetsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<GeneratorController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
          child: Row(
            children: [
              const Text('🎬', style: TextStyle(fontSize: 13)),
              const SizedBox(width: 6),
              const Text(
                'DIRECTOR MODE',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              const Spacer(),
              if (ctrl.cinematicPreset != null)
                GestureDetector(
                  onTap: () => ctrl.setCinematicPreset(null),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: Colors.white.withOpacity(0.07),
                      border: Border.all(color: Colors.white.withOpacity(0.12)),
                    ),
                    child: const Text(
                      'Clear',
                      style: TextStyle(color: Colors.white38, fontSize: 9),
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Preset grid
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: cinematicPresets.map((preset) {
              final selected = ctrl.cinematicPreset?.name == preset.name;
              return _PresetChip(
                preset: preset,
                selected: selected,
                onTap: () => ctrl.setCinematicPreset(selected ? null : preset),
              );
            }).toList(),
          ),
        ),

        // Active preset info
        if (ctrl.cinematicPreset != null)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.fromLTRB(8, 8, 8, 4),
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: ctrl.cinematicPreset!.color.withOpacity(0.08),
              border: Border.all(
                color: ctrl.cinematicPreset!.color.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Text(
                  ctrl.cinematicPreset!.emoji,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Shot like ${ctrl.cinematicPreset!.name}',
                        style: TextStyle(
                          color: ctrl.cinematicPreset!.color,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Style injected into your next generation ✨',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.35),
                          fontSize: 9.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 6),
      ],
    );
  }
}

//////////////////////////////////////////////////////////////
/// 🎬 PRESET CHIP
//////////////////////////////////////////////////////////////

class _PresetChip extends StatefulWidget {
  final CinematicPreset preset;
  final bool selected;
  final VoidCallback onTap;

  const _PresetChip({
    required this.preset,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_PresetChip> createState() => _PresetChipState();
}

class _PresetChipState extends State<_PresetChip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.selected || _hovered;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: widget.selected
                ? widget.preset.color.withOpacity(0.18)
                : active
                ? Colors.white.withOpacity(0.06)
                : Colors.white.withOpacity(0.03),
            border: Border.all(
              color: widget.selected
                  ? widget.preset.color.withOpacity(0.6)
                  : Colors.white.withOpacity(active ? 0.15 : 0.07),
            ),
            boxShadow: widget.selected
                ? [
                    BoxShadow(
                      color: widget.preset.color.withOpacity(0.2),
                      blurRadius: 8,
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.preset.emoji, style: const TextStyle(fontSize: 11)),
              const SizedBox(width: 5),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.preset.name,
                    style: TextStyle(
                      color: widget.selected
                          ? widget.preset.color
                          : Colors.white.withOpacity(active ? 0.9 : 0.55),
                      fontSize: 11,
                      fontWeight: widget.selected
                          ? FontWeight.w700
                          : FontWeight.w400,
                    ),
                  ),
                  Text(
                    widget.preset.description,
                    style: TextStyle(
                      color: widget.selected
                          ? widget.preset.color.withOpacity(0.7)
                          : Colors.white.withOpacity(0.28),
                      fontSize: 8.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
