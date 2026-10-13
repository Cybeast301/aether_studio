import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

import '../../core/constants.dart';
import '../../core/services/ai_service.dart';
import 'history_controller.dart';
import 'prompt_history_controller.dart';
import 'widgets/cinematic_presets_widget.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

enum GeneratorStatus { idle, generating, success, error }

class GeneratorController extends ChangeNotifier {
  final HistoryController historyController;

  GeneratorController({required this.historyController});

  // ── Replace with your Railway URL once deployed ──────────────
  static const String _backendUrl = 'https://aether-backend-c894.onrender.com';

  // ─────────────────────────────────────────────────────────────
  // Prompt
  // ─────────────────────────────────────────────────────────────
  String _prompt = '';
  String get prompt => _prompt;

  void setPrompt(String value) {
    _prompt = value;
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────
  // Style
  // ─────────────────────────────────────────────────────────────
  String _selectedStyle = AppConstants.stylePresets.first;
  String get selectedStyle => _selectedStyle;

  void setStyle(String value) {
    _selectedStyle = value;
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────
  // Aspect Ratio
  // ─────────────────────────────────────────────────────────────
  String _selectedAspectRatio = AppConstants.aspectRatios.first;
  String get selectedAspectRatio => _selectedAspectRatio;

  void setAspectRatio(String value) {
    _selectedAspectRatio = value;
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────
  // Advanced Settings
  // ─────────────────────────────────────────────────────────────
  int _samplingSteps = AppConstants.defaultSteps;
  int get samplingSteps => _samplingSteps;

  void setSamplingSteps(int value) {
    _samplingSteps = value;
    notifyListeners();
  }

  double _cfgScale = AppConstants.defaultCfgScale;
  double get cfgScale => _cfgScale;

  void setCfgScale(double value) {
    _cfgScale = value;
    notifyListeners();
  }

  int? _seed;
  int? get seed => _seed;

  void setSeed(int? value) {
    _seed = value;
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────
  // 🎬 Cinematic Preset
  // ─────────────────────────────────────────────────────────────
  CinematicPreset? _cinematicPreset;
  CinematicPreset? get cinematicPreset => _cinematicPreset;

  void setCinematicPreset(CinematicPreset? preset) {
    _cinematicPreset = preset;
    notifyListeners();
  }

  String get _effectivePrompt {
    if (_cinematicPreset == null) return _prompt;
    return '$_prompt, ${_cinematicPreset!.promptSuffix}';
  }

  // ─────────────────────────────────────────────────────────────
  // Generation State
  // ─────────────────────────────────────────────────────────────
  GeneratorStatus _status = GeneratorStatus.idle;
  GeneratorStatus get status => _status;

  bool get isGenerating => _status == GeneratorStatus.generating;
  bool get hasResult => _status == GeneratorStatus.success;
  bool get hasError => _status == GeneratorStatus.error;

  Uint8List? _imageBytes;
  Uint8List? get imageBytes => _imageBytes;

  Uint8List? _bgRemovedBytes;
  Uint8List? get bgRemovedBytes => _bgRemovedBytes;

  bool _isRemovingBg = false;
  bool get isRemovingBg => _isRemovingBg;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _currentEntryId;

  // ─────────────────────────────────────────────────────────────
  // Generate Image
  // ─────────────────────────────────────────────────────────────
  Future<void> generate() async {
    if (_prompt.trim().isEmpty || isGenerating) return;

    _status = GeneratorStatus.generating;
    _imageBytes = null;
    _bgRemovedBytes = null;
    _errorMessage = null;
    _currentEntryId = null;
    notifyListeners();

    try {
      final result = await AiService.instance.generate(
        GenerationRequest(
          prompt: _effectivePrompt,
          style: _selectedStyle,
          aspectRatio: _selectedAspectRatio,
          steps: _samplingSteps,
          cfgScale: _cfgScale,
          seed: _seed,
        ),
      );

      _imageBytes = result.imageBytes;
      _status = GeneratorStatus.success;
      notifyListeners();

      PromptHistoryController.instance.add(_prompt);

      historyController
          .addEntry(
            imageBytes: result.imageBytes,
            prompt: _effectivePrompt,
            style: _selectedStyle,
            aspectRatio: _selectedAspectRatio,
          )
          .then((_) {
            if (historyController.entries.isNotEmpty) {
              _currentEntryId = historyController.entries.first.id;
            }
          })
          .catchError((e) {
            debugPrint('History save failed (non-critical): $e');
          });
    } on AiServiceException catch (e) {
      _errorMessage = e.message;
      _status = GeneratorStatus.error;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Unexpected error: $e';
      _status = GeneratorStatus.error;
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────────────────────
  // Remove Background — ✅ via FastAPI backend (no CORS)
  // ─────────────────────────────────────────────────────────────
  Future<void> removeBackground() async {
    if (_imageBytes == null || _isRemovingBg) return;

    _isRemovingBg = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$_backendUrl/removebg'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'image_base64': base64Encode(_imageBytes!)}),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        _bgRemovedBytes = base64Decode(body['image']);
        if (_currentEntryId != null) {
          historyController.updateBgRemoved(_currentEntryId!, _bgRemovedBytes!);
        }
      } else {
        _errorMessage = 'Background removal failed: ${response.statusCode}';
        _status = GeneratorStatus.error;
      }
    } catch (e) {
      _errorMessage = 'Background removal error: $e';
      _status = GeneratorStatus.error;
    }

    _isRemovingBg = false;
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────
  // Download Image
  // ─────────────────────────────────────────────────────────────
  Future<void> downloadImage({bool bgRemoved = false}) async {
    final bytes = bgRemoved ? _bgRemovedBytes : _imageBytes;
    if (bytes == null) return;

    try {
      final fileName =
          'aether_${bgRemoved ? 'nobg_' : ''}${DateTime.now().millisecondsSinceEpoch}.png';

      if (kIsWeb) {
        final b64 = base64Encode(bytes);
        final dataUrl = 'data:image/png;base64,$b64';
        // ignore: avoid_web_libraries_in_flutter
        final anchor = html.AnchorElement(href: dataUrl)
          ..setAttribute('download', fileName)
          ..click();
      } else {
        final savePath = await FilePicker.platform.saveFile(
          dialogTitle: 'Save your image',
          fileName: fileName,
          type: FileType.custom,
          allowedExtensions: ['png'],
        );
        if (savePath == null) return;
        await File(savePath).writeAsBytes(bytes);
      }
    } catch (e) {
      _errorMessage = 'Failed to save image: $e';
      _status = GeneratorStatus.error;
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────────────────────
  // Reset
  // ─────────────────────────────────────────────────────────────
  void reset() {
    _status = GeneratorStatus.idle;
    _imageBytes = null;
    _bgRemovedBytes = null;
    _errorMessage = null;
    _currentEntryId = null;
    notifyListeners();
  }
}
