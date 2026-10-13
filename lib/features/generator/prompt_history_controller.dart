import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:aether_studio/features/auth/auth_service.dart';

class PromptHistoryController extends ChangeNotifier {
  PromptHistoryController._();
  static final PromptHistoryController instance = PromptHistoryController._();

  static const int _maxItems = 30;

  List<String> _prompts = [];
  List<String> get prompts => List.unmodifiable(_prompts);

  // ✅ Per-user key — each account gets its own prompt history
  String get _key {
    final userId = AuthService.instance.user?.id;
    return userId != null ? 'prompt_history_$userId' : 'prompt_history_guest';
  }

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw != null) {
        _prompts = List<String>.from(jsonDecode(raw));
      } else {
        _prompts = []; // ✅ clean slate for new/different user
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load prompt history: $e');
    }
  }

  Future<void> add(String prompt) async {
    final trimmed = prompt.trim();
    if (trimmed.isEmpty) return;
    _prompts.remove(trimmed);
    _prompts.insert(0, trimmed);
    if (_prompts.length > _maxItems) {
      _prompts = _prompts.sublist(0, _maxItems);
    }
    notifyListeners();
    await _save();
  }

  Future<void> remove(String prompt) async {
    _prompts.remove(prompt);
    notifyListeners();
    await _save();
  }

  Future<void> clear() async {
    _prompts.clear();
    notifyListeners();
    await _save();
  }

  // ✅ Call on logout to wipe from RAM
  void clearLocal() {
    _prompts.clear();
    notifyListeners();
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, jsonEncode(_prompts));
    } catch (e) {
      debugPrint('Failed to save prompt history: $e');
    }
  }
}
