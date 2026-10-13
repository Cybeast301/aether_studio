import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  ThemeController._();
  static final ThemeController instance = ThemeController._();

  static const String _key = 'is_dark_mode';
  bool _isDark = true;
  bool get isDark => _isDark;

  // ── Load saved theme on startup ──────────────────────────
  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDark = prefs.getBool(_key) ?? true; // default dark
    notifyListeners();
  }

  // ── Toggle and persist ───────────────────────────────────
  Future<void> toggle() async {
    _isDark = !_isDark;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, _isDark);
  }

  // ── Dark Theme ───────────────────────────────────────────
  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF020818),
    fontFamily: 'Inter',
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF6366F1),
      secondary: Color(0xFF7C3AED),
      surface: Color(0xFF0F172A),
      background: Color(0xFF020818),
    ),
  );

  // ── Light Theme ──────────────────────────────────────────
  static ThemeData get lightTheme => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF8F7FF),
    fontFamily: 'Inter',
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF6366F1),
      secondary: Color(0xFF7C3AED),
      surface: Color(0xFFFFFFFF),
      background: Color(0xFFF8F7FF),
    ),
  );
}
