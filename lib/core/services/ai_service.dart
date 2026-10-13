import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:aether_studio/features/auth/auth_service.dart';

class AiServiceException implements Exception {
  final int? statusCode;
  final String message;
  const AiServiceException(this.message, {this.statusCode});

  @override
  String toString() =>
      'AiServiceException(${statusCode != null ? '$statusCode ' : ''}$message)';
}

class GenerationRequest {
  final String prompt;
  final String style;
  final String aspectRatio;
  final int steps;
  final double cfgScale;
  final int? seed;

  const GenerationRequest({
    required this.prompt,
    required this.style,
    required this.aspectRatio,
    this.steps = 4,
    this.cfgScale = 7.5,
    this.seed,
  });

  Map<String, dynamic> toJson() {
    final size = _ratioToSize(aspectRatio);
    return {
      'prompt': '$prompt, style: $style',
      'num_steps': steps,
      'width': size[0],
      'height': size[1],
      if (seed != null) 'seed': seed,
    };
  }

  static List<int> _ratioToSize(String ratio) {
    switch (ratio) {
      case '1:1':
        return [1024, 1024];
      case '4:3':
        return [1024, 768];
      case '3:4':
        return [768, 1024];
      case '16:9':
        return [1024, 576];
      case '9:16':
        return [576, 1024];
      case '2:3':
        return [682, 1024];
      case '3:2':
        return [1024, 682];
      default:
        return [1024, 1024];
    }
  }
}

class GenerationResult {
  final Uint8List imageBytes;
  const GenerationResult({required this.imageBytes});
}

class AiService {
  AiService._();
  static final AiService instance = AiService._();

  final String _backendUrl = 'https://aether-backend-c894.onrender.com';
  static const Duration _timeout = Duration(seconds: 120);

  Future<GenerationResult> generate(GenerationRequest request) async {
    final uri = Uri.parse('$_backendUrl/generate');

    late http.Response response;
    try {
      response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${AuthService.instance.token ?? ''}',
            },
            body: jsonEncode(request.toJson()),
          )
          .timeout(_timeout);
    } on Exception catch (e) {
      throw AiServiceException('Network error: $e');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final body = jsonDecode(response.body);
        final imageData = body['image'];
        if (imageData != null && imageData is String && imageData.isNotEmpty) {
          return GenerationResult(imageBytes: base64Decode(imageData));
        }
      } catch (e) {
        throw AiServiceException('Failed to parse response: $e');
      }
      throw const AiServiceException('No image data in response');
    }

    String serverMessage = 'Server error (${response.statusCode})';
    try {
      final body = jsonDecode(response.body);
      serverMessage = body['detail']?.toString() ?? serverMessage;
    } catch (_) {}

    throw AiServiceException(serverMessage, statusCode: response.statusCode);
  }
}
