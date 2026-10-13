import 'dart:convert';
import 'dart:typed_data';
import 'package:aether_studio/core/services/aiko_rag_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'aiko_personality_service.dart';

class AiAssistantService {
  AiAssistantService._();
  static final AiAssistantService instance = AiAssistantService._();

  // ── 🚀 Groq — Chat + Prompt Helper (free + fast) ─────────
  static String get _groqApiKey => dotenv.env['GROQ_API_KEY'] ?? '';
  static const String _groqBaseUrl =
      'https://api.groq.com/openai/v1/chat/completions';
  static const String _groqModel = 'openai/gpt-oss-20b';

  // ── 🔍 Groq Vision — Image Analysis (free + reliable) ────
  // Same API key as chat — zero extra setup!
  static const String _groqVisionModel =
      'meta-llama/llama-4-scout-17b-16e-instruct';

  static const Duration _timeout = Duration(seconds: 60);

  // Always fetches locked system prompt from Firebase
  String get _systemPrompt =>
      AikoPersonalityService.instance.personality.safeSystemPrompt;

  // ─────────────────────────────────────────────────────────────

  // ─────────────────────────────────────────────────────────────
  Future<String> chat({
    required List<Map<String, String>> history,
    required String userMessage,
  }) async {
    // ✅ RAG — fetch relevant knowledge before responding
    final context = await AikoRagService.instance.getContext(userMessage);
    final systemWithContext = context.isEmpty
        ? _systemPrompt
        : '$_systemPrompt\n\n$context';

    final messages = <Map<String, dynamic>>[
      {
        'role': 'system',
        'content': systemWithContext, // ← personality + live art knowledge
      },
    ];

    for (final msg in history) {
      messages.add({
        'role': msg['role'] == 'assistant' ? 'assistant' : 'user',
        'content': msg['content'],
      });
    }
    messages.add({'role': 'user', 'content': userMessage});

    final response = await http
        .post(
          Uri.parse(_groqBaseUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_groqApiKey',
          },
          body: jsonEncode({
            'model': _groqModel,
            'messages': messages,
            'max_tokens': 300,
            'temperature': 0.8,
          }),
        )
        .timeout(_timeout);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body['choices'][0]['message']['content'] as String;
    }
    throw Exception('Chat failed: ${response.statusCode} ${response.body}');
  }

  // ─────────────────────────────────────────────────────────────
  // ✨ Prompt Helper — Groq (Llama 3.3)
  // ─────────────────────────────────────────────────────────────
  Future<String> improvePrompt(String originalPrompt) async {
    final response = await http
        .post(
          Uri.parse(_groqBaseUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_groqApiKey',
          },
          body: jsonEncode({
            'model': _groqModel,
            'messages': [
              {
                'role': 'system',
                'content':
                    'You are an expert AI image prompt engineer for Aether Studio. Return ONLY the improved prompt, nothing else. No explanations, no labels.',
              },
              {
                'role': 'user',
                'content':
                    '''Improve this prompt to make it more detailed, vivid and likely to produce a stunning image.
Add: lighting details, art style, mood, camera angle, quality keywords.
Keep it under 100 words.

Original prompt: $originalPrompt''',
              },
            ],
            'max_tokens': 150,
            'temperature': 0.7,
          }),
        )
        .timeout(_timeout);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body['choices'][0]['message']['content'] as String;
    }
    throw Exception(
      'Prompt improvement failed: ${response.statusCode} ${response.body}',
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 🔍 Image Analyzer — Groq Vision (Llama 4 Scout, free)
  // ─────────────────────────────────────────────────────────────
  Future<String> analyzeImage(Uint8List imageBytes) async {
    final base64Image = base64Encode(imageBytes);

    final response = await http
        .post(
          Uri.parse(_groqBaseUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_groqApiKey',
          },
          body: jsonEncode({
            'model': _groqVisionModel,
            'messages': [
              {
                'role': 'user',
                'content': [
                  {
                    'type': 'image_url',
                    'image_url': {'url': 'data:image/png;base64,$base64Image'},
                  },
                  {
                    'type': 'text',
                    'text':
                        'You are Aiko, the creative AI assistant of Aether Studio, created by Yash Pandey. Analyze this AI-generated image in a warm, enthusiastic way. Cover: main subject, art style, mood, colors, lighting, composition. Keep it under 80 words and make it feel like genuine appreciation of the artwork.',
                  },
                ],
              },
            ],
            'max_tokens': 200,
            'temperature': 0.7,
          }),
        )
        .timeout(_timeout);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body['choices'][0]['message']['content'] as String;
    }
    throw Exception(
      'Image analysis failed: ${response.statusCode} ${response.body}',
    );
  }
}
