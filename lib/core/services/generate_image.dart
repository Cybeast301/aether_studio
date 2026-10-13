import 'dart:convert';
import 'package:http/http.dart' as http;

class GenerateImageService {
  // 🔐 Replace with your real OpenAI API key
  static const String _apiKey = "YOUR_OPENAI_API_KEY";

  static const String _endpoint =
      "https://api.openai.com/v1/images/generations";

  /// Main function to generate image
  static Future<String?> generate({
    required String prompt,
    required String style,
    required String ratio,
  }) async {
    try {
      final fullPrompt = _buildPrompt(prompt, style);

      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $_apiKey",
        },
        body: jsonEncode({
          "model": "gpt-image-1",
          "prompt": fullPrompt,
          "size": _mapRatioToSize(ratio),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["data"][0]["url"];
      } else {
        print("Error: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Exception: $e");
      return null;
    }
  }

  /// Add style enhancement automatically
  static String _buildPrompt(String userPrompt, String style) {
    final stylePresets = {
      "Anime":
          "high detail anime style, vibrant colors, cinematic lighting, sharp focus",
      "Realistic":
          "ultra realistic, DSLR quality, natural skin tones, depth of field",
      "Formal":
          "professional corporate style, clean lighting, neutral background",
      "Branding":
          "modern branding composition, typography focused, minimal layout",
      "Historical":
          "vintage atmosphere, film grain, muted colors, historical realism",
    };

    final styleEnhancement = stylePresets[style] ?? "";

    return "$userPrompt, $styleEnhancement";
  }

  /// Convert ratio to API size
  static String _mapRatioToSize(String ratio) {
    switch (ratio) {
      case "1:1":
        return "1024x1024";
      case "16:9":
        return "1792x1024";
      case "9:16":
        return "1024x1792";
      case "4:5":
        return "1024x1280";
      case "3:2":
        return "1536x1024";
      default:
        return "1024x1024";
    }
  }
}
