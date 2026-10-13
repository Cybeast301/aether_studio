import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  ////////////////////////////////////////////////////////////
  /// 🎨 Core Brand Colors
  ////////////////////////////////////////////////////////////

  static const Color primary = Color(0xFF7C3AED); // violet-600
  static const Color primaryLight = Color(0xFFA78BFA); // violet-400
  static const Color accent = Color(0xFF06B6D4); // cyan-500

  static const Color surface = Color(0xFF0F0F1A);
  static const Color surfaceCard = Color(0xFF1A1A2E);
  static const Color surfaceGlass = Color(0x1AFFFFFF);

  static const Color onSurface = Color(0xFFF1F5F9);
  static const Color onSurfaceMuted = Color(0xFF94A3B8);

  ////////////////////////////////////////////////////////////
  /// 🌈 Animated Background Gradients
  ////////////////////////////////////////////////////////////

  static const List<Color> animatedGradient1 = [
    Color(0xFF0F0F1A),
    Color(0xFF1A1A2E),
    Color(0xFF2A1E4F),
  ];

  static const List<Color> animatedGradient2 = [
    Color(0xFF1A1A2E),
    Color(0xFF0F0F1A),
    Color(0xFF16213E),
  ];

  ////////////////////////////////////////////////////////////
  /// 💎 Glass Border Glow
  ////////////////////////////////////////////////////////////

  static LinearGradient glassBorderGradient = LinearGradient(
    colors: [
      primary.withOpacity(0.6),
      accent.withOpacity(0.6),
      primaryLight.withOpacity(0.6),
    ],
  );

  ////////////////////////////////////////////////////////////
  /// 🔥 Button Gradient
  ////////////////////////////////////////////////////////////

  static LinearGradient primaryButtonGradient = const LinearGradient(
    colors: [Color(0xFF7C3AED), Color(0xFF06B6D4)],
  );

  ////////////////////////////////////////////////////////////
  /// ✨ Glow Shadows
  ////////////////////////////////////////////////////////////

  static List<BoxShadow> glowShadow = [
    BoxShadow(color: primary.withOpacity(0.4), blurRadius: 20, spreadRadius: 1),
  ];

  static List<BoxShadow> intenseGlowShadow = [
    BoxShadow(color: primary.withOpacity(0.6), blurRadius: 35, spreadRadius: 3),
  ];

  ////////////////////////////////////////////////////////////
  /// 🧠 Premium Dark Theme
  ////////////////////////////////////////////////////////////

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: surface,
    colorScheme: const ColorScheme.dark(
      primary: primary,
      secondary: accent,
      surface: surfaceCard,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: onSurface,
    ),
    fontFamily: 'Inter',
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: onSurface, fontWeight: FontWeight.w700),
      headlineMedium: TextStyle(color: onSurface, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(color: onSurface),
      bodyMedium: TextStyle(color: onSurfaceMuted),
    ),
    iconTheme: const IconThemeData(color: onSurfaceMuted),
    cardTheme: CardThemeData(
      color: surfaceCard,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}
