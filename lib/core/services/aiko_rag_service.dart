import 'dart:convert';
import 'package:http/http.dart' as http;

//////////////////////////////////////////////////////////////
/// 🧠 AIKO RAG SERVICE
/// Retrieval Augmented Generation using Supabase pgvector
/// Aiko searches her knowledge base before every response
//////////////////////////////////////////////////////////////

class AikoRagService {
  AikoRagService._();
  static final AikoRagService instance = AikoRagService._();

  // Supabase
  static const String _supabaseUrl = 'https://bnmmqaatucvmvlaaqfki.supabase.co';
  static const String _serviceKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJubW1xYWF0dWN2bXZsYWFxZmtpIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3MTkxNDE2MywiZXhwIjoyMDg3NDkwMTYzfQ.EhAdb0hNbDjsk3Hr1pkrL_JxOYnrbGsslqBn8AuajaU';

  // Groq for embeddings (using chat to simulate embedding via keyword extraction)
  static const String _groqApiKey =
      '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';
  static const String _groqBaseUrl =
      'https://api.groq.com/openai/v1/chat/completions';

  bool _seeded = false;

  /// Call once on startup — seeds knowledge if table is empty
  Future<void> initialize() async {
    try {
      final count = await _getKnowledgeCount();
      if (count == 0) {
        await seedKnowledge();
        _seeded = true;
      } else {
        _seeded = true;
      }
    } catch (e) {
      // Silently fail — app works without RAG
      debugPrint('RAG init failed: $e');
    }
  }

  /// Search knowledge base for relevant context
  /// Returns top matches as a formatted string to inject into prompt
  Future<String> getContext(String userMessage) async {
    if (!_seeded) return '';
    try {
      // Use keyword-based search (no embedding API needed)
      final results = await _keywordSearch(userMessage);
      if (results.isEmpty) return '';

      final buffer = StringBuffer();
      buffer.writeln('📚 AIKO KNOWLEDGE BASE — Relevant facts:');
      for (final r in results) {
        buffer.writeln('• [${r['topic']}]: ${r['content']}');
      }
      return buffer.toString();
    } catch (e) {
      return '';
    }
  }

  /// Keyword-based search using Supabase REST API (no vector needed)
  Future<List<Map<String, dynamic>>> _keywordSearch(String query) async {
    final keywords = _extractKeywords(query);
    if (keywords.isEmpty) return [];

    // Search using ilike for each keyword
    final conditions = keywords
        .take(3)
        .map((k) => 'content.ilike.%$k%,topic.ilike.%$k%')
        .join(',');

    final response = await http
        .get(
          Uri.parse(
            '$_supabaseUrl/rest/v1/aiko_knowledge?or=($conditions)&limit=4&select=topic,content',
          ),
          headers: {
            'apikey': _serviceKey,
            'Authorization': 'Bearer $_serviceKey',
            'Content-Type': 'application/json',
          },
        )
        .timeout(const Duration(seconds: 8));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    }
    return [];
  }

  /// Extract meaningful keywords from user message
  List<String> _extractKeywords(String message) {
    final stopWords = {
      'a',
      'an',
      'the',
      'is',
      'it',
      'in',
      'on',
      'at',
      'to',
      'for',
      'of',
      'and',
      'or',
      'but',
      'what',
      'how',
      'why',
      'when',
      'who',
      'can',
      'could',
      'would',
      'should',
      'tell',
      'me',
      'about',
      'my',
      'i',
      'you',
      'we',
      'they',
      'he',
      'she',
      'do',
      'does',
      'did',
      'make',
      'create',
      'generate',
      'want',
      'need',
      'like',
      'get',
    };
    return message
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .split(' ')
        .where((w) => w.length > 3 && !stopWords.contains(w))
        .toList();
  }

  Future<int> _getKnowledgeCount() async {
    final response = await http
        .get(
          Uri.parse('$_supabaseUrl/rest/v1/aiko_knowledge?select=count'),
          headers: {
            'apikey': _serviceKey,
            'Authorization': 'Bearer $_serviceKey',
            'Prefer': 'count=exact',
          },
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final count = response.headers['content-range']?.split('/')?.last;
      return int.tryParse(count ?? '0') ?? 0;
    }
    return 0;
  }

  /// Insert a single knowledge entry
  Future<void> _insert(String topic, String content) async {
    await http
        .post(
          Uri.parse('$_supabaseUrl/rest/v1/aiko_knowledge'),
          headers: {
            'apikey': _serviceKey,
            'Authorization': 'Bearer $_serviceKey',
            'Content-Type': 'application/json',
            'Prefer': 'return=minimal',
          },
          body: jsonEncode({'topic': topic, 'content': content}),
        )
        .timeout(const Duration(seconds: 10));
  }

  //////////////////////////////////////////////////////////////
  /// 📚 SEED — Aiko's Art Knowledge Base
  //////////////////////////////////////////////////////////////
  Future<void> seedKnowledge() async {
    final knowledge = _buildKnowledgeBase();
    for (final entry in knowledge) {
      await _insert(entry['topic']!, entry['content']!);
    }
  }

  List<Map<String, String>> _buildKnowledgeBase() => [
    // ── ART STYLES ──────────────────────────────────────────
    {
      'topic': 'Anime Art Style',
      'content':
          'Anime style features large expressive eyes, vibrant hair colors, simplified facial features, cel shading, and clean line art. Key prompt words: anime, manga, cel shading, Studio Ghibli, Makoto Shinkai, JoJo style, Artgerm.',
    },
    {
      'topic': 'Photorealistic Style',
      'content':
          'Photorealism aims to replicate photography. Key terms: hyperrealistic, 8K, RAW photo, DSLR, sharp focus, photorealistic, octane render, Unreal Engine 5, subsurface scattering, ray tracing.',
    },
    {
      'topic': 'Oil Painting Style',
      'content':
          'Oil painting features rich textures, blended colors, visible brushstrokes. Key prompt terms: oil painting, impasto, chiaroscuro, baroque, renaissance, Rembrandt lighting, Van Gogh style, painterly.',
    },
    {
      'topic': 'Watercolor Style',
      'content':
          'Watercolor art has soft edges, color bleeding, transparency, and delicate washes. Prompt terms: watercolor, aquarelle, wet on wet, soft edges, dreamy, transparent layers, ink wash.',
    },
    {
      'topic': 'Digital Art Style',
      'content':
          'Digital concept art is used in games and films. Key terms: concept art, matte painting, digital painting, ArtStation, Greg Rutkowski, trending on ArtStation, illustration, 2D digital art.',
    },
    {
      'topic': 'Pixel Art Style',
      'content':
          'Pixel art uses small square pixels for retro aesthetics. Key terms: pixel art, 8-bit, 16-bit, sprite, retro game, pixelated, isometric pixel art, pixel artist.',
    },
    {
      'topic': 'Cyberpunk Style',
      'content':
          'Cyberpunk features neon lights, dark dystopian cities, rain-soaked streets. Prompt terms: cyberpunk, neon, Blade Runner, synthwave, neon noir, futuristic city, holographic, rain reflections.',
    },
    {
      'topic': 'Fantasy Art Style',
      'content':
          'Fantasy art depicts magical worlds, creatures, and epic scenes. Key terms: fantasy art, epic fantasy, magical realism, dark fantasy, D&D art, Lord of the Rings, mythical, dragon, wizard.',
    },
    {
      'topic': 'Impressionism',
      'content':
          'Impressionism captures light and movement with loose brushwork. Artists: Monet, Renoir, Pissarro. Prompt terms: impressionist, loose brushwork, dappled light, plein air, Monet style, painterly.',
    },
    {
      'topic': 'Surrealism',
      'content':
          'Surrealism blends dreamlike imagery with reality. Artists: Salvador Dali, René Magritte. Prompt terms: surrealist, dreamlike, impossible, Salvador Dali style, melting clocks, subconscious.',
    },

    // ── LIGHTING TECHNIQUES ──────────────────────────────────
    {
      'topic': 'Golden Hour Lighting',
      'content':
          'Golden hour occurs just after sunrise or before sunset. Features warm orange and golden tones, long soft shadows, glowing atmosphere. Prompt terms: golden hour, magic hour, warm light, sunset glow, backlit.',
    },
    {
      'topic': 'Rim Lighting',
      'content':
          'Rim lighting places a light source behind the subject creating an edge glow. Creates dramatic silhouette effect. Prompt terms: rim lighting, backlight, edge light, cinematic lighting, dramatic.',
    },
    {
      'topic': 'Volumetric Lighting',
      'content':
          'Volumetric light creates visible light rays through atmosphere. Also called god rays. Prompt terms: volumetric lighting, god rays, crepuscular rays, light shafts, atmospheric, foggy.',
    },
    {
      'topic': 'Neon Lighting',
      'content':
          'Neon lighting creates vivid colored glows in dark environments. Used in cyberpunk and nighttime scenes. Prompt terms: neon lights, neon glow, colored lighting, pink and blue neon, light reflections.',
    },
    {
      'topic': 'Studio Lighting',
      'content':
          'Studio lighting is clean and controlled for portraits. Types: three-point lighting, Rembrandt lighting, butterfly lighting. Prompt terms: studio lighting, professional lighting, softbox, even lighting.',
    },
    {
      'topic': 'Dramatic Chiaroscuro',
      'content':
          'Chiaroscuro uses strong contrast between light and dark. Mastered by Rembrandt and Caravaggio. Prompt terms: chiaroscuro, dramatic shadows, high contrast, Rembrandt lighting, dark background.',
    },
    {
      'topic': 'Moonlight Lighting',
      'content':
          'Moonlight creates cool blue-silver tones, mysterious moods. Prompt terms: moonlight, night scene, cool blue light, silver glow, nocturnal, starlight, mysterious night atmosphere.',
    },

    // ── COMPOSITION ──────────────────────────────────────────
    {
      'topic': 'Rule of Thirds',
      'content':
          'The rule of thirds divides the image into a 3x3 grid. Place subjects at intersection points for visual interest. Prompt terms: rule of thirds, dynamic composition, off-center subject.',
    },
    {
      'topic': 'Symmetrical Composition',
      'content':
          'Perfect symmetry creates order and grandeur. Used by Kubrick in film. Prompt terms: perfect symmetry, centered composition, mirror image, architectural symmetry, balanced.',
    },
    {
      'topic': 'Leading Lines',
      'content':
          'Leading lines guide the viewer\'s eye through the image. Roads, rivers, hallways create depth. Prompt terms: leading lines, perspective, vanishing point, depth, corridor shot.',
    },
    {
      'topic': 'Depth and Layers',
      'content':
          'Creating depth with foreground, midground, and background layers. Prompt terms: depth of field, foreground elements, layered composition, atmospheric perspective, bokeh background.',
    },

    // ── CAMERA & PHOTOGRAPHY TERMS ───────────────────────────
    {
      'topic': 'Bokeh and Depth of Field',
      'content':
          'Bokeh is the aesthetic blur of out-of-focus areas. Created by wide aperture lenses. Prompt terms: bokeh, f/1.4, f/1.8, shallow depth of field, blurred background, 85mm lens, portrait lens.',
    },
    {
      'topic': 'Camera Angles',
      'content':
          'Camera angles affect mood dramatically. Low angle = powerful subject. High angle = vulnerability. Dutch angle = unease. Prompt terms: low angle shot, birds eye view, worms eye view, dutch angle, eye level.',
    },
    {
      'topic': 'Cinematic Aspect Ratios',
      'content':
          'Cinematic images use wide aspect ratios like 2.39:1 anamorphic. Prompt terms: cinematic, anamorphic lens, letterbox, widescreen, film grain, 35mm film, Kodak Portra.',
    },

    // ── FAMOUS ARTISTS & PROMPT ENGINEERING ──────────────────
    {
      'topic': 'Greg Rutkowski Style',
      'content':
          'Greg Rutkowski creates epic fantasy digital art with dramatic lighting and detailed environments. Use "by Greg Rutkowski" or "Greg Rutkowski style" for epic fantasy results.',
    },
    {
      'topic': 'Artgerm Style',
      'content':
          'Artgerm (Stanley Lau) creates clean, beautiful character portraits combining anime and realism. Use "Artgerm style" for stunning character art with perfect proportions.',
    },
    {
      'topic': 'Makoto Shinkai Style',
      'content':
          'Makoto Shinkai creates breathtaking anime landscapes with volumetric light, detailed skies, and emotional atmospheres. Films: Your Name, Weathering With You. Use "Makoto Shinkai style".',
    },
    {
      'topic': 'Studio Ghibli Style',
      'content':
          'Studio Ghibli creates warm, whimsical hand-drawn animations. Directors: Hayao Miyazaki, Isao Takahata. Use "Studio Ghibli style" or "Ghibli aesthetic" for soft, painterly results.',
    },
    {
      'topic': 'Prompt Quality Keywords',
      'content':
          'Add these to any prompt for better quality: masterpiece, best quality, ultra-detailed, 8K resolution, award winning, highly detailed, professional, sharp focus, intricate details.',
    },
    {
      'topic': 'Negative Prompt Tips',
      'content':
          'Common negative prompts to improve quality: blurry, ugly, deformed, extra limbs, bad anatomy, watermark, signature, low quality, pixelated, overexposed, underexposed.',
    },

    // ── MOOD & ATMOSPHERE ────────────────────────────────────
    {
      'topic': 'Dark and Moody Atmosphere',
      'content':
          'For dark atmospheric images: dark fantasy, gothic, moody, overcast, brooding, mysterious, dark souls aesthetic, grim, shadowy, desaturated colors, atmospheric fog.',
    },
    {
      'topic': 'Warm and Cozy Atmosphere',
      'content':
          'For warm cozy images: cottage core, warm lighting, golden tones, firelight, autumn, hygge, soft light, warm color palette, comfortable, peaceful, nostalgic.',
    },
    {
      'topic': 'Epic and Grand Atmosphere',
      'content':
          'For epic grand scenes: epic scale, vast landscape, heroic, cinematic scope, dramatic clouds, monumental, awe-inspiring, wide establishing shot, sweeping vistas.',
    },

    // ── COLOR THEORY ─────────────────────────────────────────
    {
      'topic': 'Color Palettes',
      'content':
          'Color palette affects mood strongly. Cool blues = calm/sad. Warm reds/oranges = energy/passion. Purple = mystery/magic. Green = nature/growth. Desaturated = melancholic. Vibrant = energetic.',
    },
    {
      'topic': 'Complementary Colors',
      'content':
          'Complementary colors (opposite on color wheel) create visual tension. Blue/orange is the most popular cinematic combo. Purple/yellow for fantasy. Red/green for Christmas. Great for dramatic scenes.',
    },

    // ── AETHER STUDIO SPECIFIC ───────────────────────────────
    {
      'topic': 'Aether Studio Tips',
      'content':
          'Aether Studio generates best results with specific prompts. Include: subject, style, lighting, mood, camera angle, and quality keywords. The Prompt Helper feature can improve any prompt automatically.',
    },
    {
      'topic': 'Best Prompt Structure',
      'content':
          'Best prompt formula: [Subject] + [Art Style] + [Lighting] + [Mood/Atmosphere] + [Camera/Angle] + [Quality Keywords]. Example: "Samurai warrior, anime style, golden hour rim lighting, epic mood, low angle, masterpiece 8K".',
    },
    {
      'topic': 'Style Presets in Aether Studio',
      'content':
          'Aether Studio has built-in style presets: Photorealistic, Digital Art, Anime, Oil Painting, Watercolour, Cinematic, Sketch, Pixel Art. Each preset optimizes the generation for that visual style.',
    },
    {
      'topic': 'Aspect Ratios for Different Uses',
      'content':
          '1:1 square = social media posts. 16:9 landscape = desktop wallpapers, YouTube thumbnails. 9:16 portrait = phone wallpapers, Instagram stories. 4:3 = traditional photography. 3:4 = portrait photography.',
    },
  ];
}

// Minimal debugPrint to avoid import issues
void debugPrint(String message) {
  // ignore: avoid_print
  print(message);
}
