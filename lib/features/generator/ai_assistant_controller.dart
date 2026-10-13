import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'ai_assistant_service.dart';

enum AiMode { chat, promptHelper, imageAnalyzer }

enum AiStatus { idle, loading, error }

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;

  ChatMessage({required this.text, required this.isUser, DateTime? time})
    : time = time ?? DateTime.now();
}

class AiAssistantController extends ChangeNotifier {
  bool _isOpen = false;
  bool get isOpen => _isOpen;

  void toggle() {
    _isOpen = !_isOpen;
    notifyListeners();
  }

  void open() {
    _isOpen = true;
    notifyListeners();
  }

  void close() {
    _isOpen = false;
    notifyListeners();
  }

  AiMode _mode = AiMode.chat;
  AiMode get mode => _mode;
  void setMode(AiMode mode) {
    _mode = mode;
    notifyListeners();
  }

  AiStatus _status = AiStatus.idle;
  AiStatus get status => _status;
  bool get isLoading => _status == AiStatus.loading;

  final List<ChatMessage> _messages = [
    ChatMessage(
      text:
          "Hi! I'm Aiko ✨ I can chat with you, improve your prompts, or analyze your generated images. How can I help?",
      isUser: false,
    ),
  ];
  List<ChatMessage> get messages => List.unmodifiable(_messages);

  String? _improvedPrompt;
  String? get improvedPrompt => _improvedPrompt;

  String? _imageAnalysis;
  String? get imageAnalysis => _imageAnalysis;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // ── 💬 Send Chat Message ────────────────────────────────
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || isLoading) return;

    _messages.add(ChatMessage(text: text, isUser: true));
    _status = AiStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // Build history excluding the message we just added
      final history = _messages
          .take(_messages.length - 1)
          .map(
            (m) => {'role': m.isUser ? 'user' : 'assistant', 'content': m.text},
          )
          .toList();

      // ✅ Correct Gemini service signature
      final reply = await AiAssistantService.instance.chat(
        history: history,
        userMessage: text,
      );

      _messages.add(ChatMessage(text: reply, isUser: false));
      _status = AiStatus.idle;
    } catch (e) {
      _errorMessage = 'Failed to get response: $e';
      _status = AiStatus.error;
    }
    notifyListeners();
  }

  // ── ✨ Improve Prompt ───────────────────────────────────
  Future<String?> improvePrompt(String prompt) async {
    if (prompt.trim().isEmpty || isLoading) return null;

    _status = AiStatus.loading;
    _improvedPrompt = null;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await AiAssistantService.instance.improvePrompt(prompt);
      _improvedPrompt = result;
      _status = AiStatus.idle;
      notifyListeners();
      return result;
    } catch (e) {
      _errorMessage = 'Failed to improve prompt: $e';
      _status = AiStatus.error;
      notifyListeners();
      return null;
    }
  }

  // ── 🔍 Analyze Image ────────────────────────────────────
  Future<void> analyzeImage(Uint8List imageBytes) async {
    if (isLoading) return;

    _mode = AiMode.imageAnalyzer;
    _isOpen = true;
    _status = AiStatus.loading;
    _imageAnalysis = null;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await AiAssistantService.instance.analyzeImage(imageBytes);
      _imageAnalysis = result;
      _status = AiStatus.idle;
    } catch (e) {
      _errorMessage = 'Failed to analyze image: $e';
      _status = AiStatus.error;
    }
    notifyListeners();
  }

  // ── 🗑 Clear Chat ───────────────────────────────────────
  void clearChat() {
    _messages.clear();
    _messages.add(
      ChatMessage(
        text:
            "Chat cleared! I'm Aiko✨ How can I help you create something amazing?",
        isUser: false,
      ),
    );
    _improvedPrompt = null;
    _imageAnalysis = null;
    _errorMessage = null;
    _status = AiStatus.idle;
    notifyListeners();
  }
}
