import 'dart:convert';
import 'dart:typed_data';
import 'package:aether_studio/features/generator/generator_controller.dart';
import 'package:aether_studio/features/generator/history_controller.dart';
import 'package:aether_studio/features/generator/theme_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import '../../../core/constants.dart';

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html show AnchorElement, Blob, Url;

class UpscalePage extends StatefulWidget {
  const UpscalePage({super.key});
  @override
  State<UpscalePage> createState() => _UpscalePageState();
}

class _UpscalePageState extends State<UpscalePage> {
  Uint8List? _sourceImage;
  Uint8List? _resultImage;
  bool _isProcessing = false;
  String? _errorMessage;
  int _selectedScale = 2;
  double _sliderPos = 0.5;

  static const String _backendUrl = 'https://aether-backend-c894.onrender.com';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctrl = context.read<GeneratorController>();
      if (ctrl.imageBytes != null)
        setState(() => _sourceImage = ctrl.imageBytes);
    });
  }

  Future<void> _pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );
      if (result != null && result.files.isNotEmpty) {
        final bytes = result.files.first.bytes;
        if (bytes != null)
          setState(() {
            _sourceImage = bytes;
            _resultImage = null;
            _errorMessage = null;
          });
      }
    } catch (e) {
      setState(() => _errorMessage = 'Failed to pick image: $e');
    }
  }

  Future<void> _upscale() async {
    if (_sourceImage == null) return;
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });
    try {
      final result = await _clipdropUpscale(_sourceImage!, _selectedScale);
      if (result != null) {
        setState(() => _resultImage = result);
        if (mounted) {
          context.read<HistoryController>().addEntry(
            imageBytes: result,
            prompt: 'Upscaled ${_selectedScale}x',
            style: 'Upscaled',
            aspectRatio: '1:1',
          );
        }
      } else {
        setState(() => _errorMessage = 'Upscale failed — please try again');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Upscale error: $e');
    }
    setState(() => _isProcessing = false);
  }

  Future<Uint8List?> _clipdropUpscale(Uint8List imageBytes, int scale) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_backendUrl/upscale'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'image_base64': base64Encode(imageBytes),
              'scale': scale,
            }),
          )
          .timeout(const Duration(seconds: 90));
      if (response.statusCode == 200) {
        return base64Decode(jsonDecode(response.body)['image']);
      }
      setState(
        () => _errorMessage = _parseError(response.statusCode, response.body),
      );
      return null;
    } catch (e) {
      rethrow;
    }
  }

  String _parseError(int statusCode, String body) {
    switch (statusCode) {
      case 400:
        return 'Invalid image format. Please use PNG or JPG.';
      case 401:
        return 'API key invalid.';
      case 402:
        return 'Clipdrop credits exhausted. Top up at clipdrop.co';
      case 429:
        return 'Too many requests. Please wait and try again.';
      case 500:
        return 'Clipdrop server error. Please try again later.';
      default:
        return 'Upscale failed ($statusCode). Please try again.';
    }
  }

  Future<void> _download() async {
    if (_resultImage == null) return;
    final fileName =
        'aether_upscaled_${_selectedScale}x_${DateTime.now().millisecondsSinceEpoch}.png';
    try {
      if (kIsWeb) {
        final blob = html.Blob([_resultImage!], 'image/png');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', fileName)
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        final savePath = await FilePicker.platform.saveFile(
          dialogTitle: 'Save upscaled image',
          fileName: fileName,
          type: FileType.custom,
          allowedExtensions: ['png'],
        );
        if (savePath == null) return;
        await _writeFile(savePath, _resultImage!);
      }
    } catch (e) {
      setState(() => _errorMessage = 'Download failed: $e');
    }
  }

  Future<void> _writeFile(String path, Uint8List bytes) async {
    if (!kIsWeb) {
      final dynamic file = await _getFile(path);
      await file.writeAsBytes(bytes);
    }
  }

  dynamic _getFile(String path) =>
      (path.isNotEmpty) ? _DesktopFile(path) : null;

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeController>().isDark;
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Padding(
      padding: EdgeInsets.all(isMobile ? 12 : AppConstants.paddingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xFF3B82F6).withOpacity(0.15),
                  border: Border.all(
                    color: const Color(0xFF3B82F6).withOpacity(0.3),
                  ),
                ),
                child: const Icon(
                  Icons.hd_outlined,
                  color: Color(0xFF60A5FA),
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upscale',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: isMobile ? 18 : 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      isMobile
                          ? 'Enhance to HD quality'
                          : 'Enhance your images to stunning HD quality',
                      style: TextStyle(
                        color: isDark
                            ? Colors.white.withOpacity(0.4)
                            : Colors.black45,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // ── Clipdrop badge — hide on mobile ─────────
              if (!isMobile)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: const Color(0xFF3B82F6).withOpacity(0.1),
                    border: Border.all(
                      color: const Color(0xFF3B82F6).withOpacity(0.25),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bolt, size: 13, color: Color(0xFF60A5FA)),
                      SizedBox(width: 4),
                      Text(
                        'Powered by Clipdrop',
                        style: TextStyle(
                          color: Color(0xFF60A5FA),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          SizedBox(height: isMobile ? 12 : AppConstants.paddingLg),

          // ── Body ─────────────────────────────────────────
          Expanded(
            child: isMobile
                ? _buildMobileLayout(isDark)
                : _buildDesktopLayout(isDark),
          ),
        ],
      ),
    );
  }

  // ── DESKTOP layout ────────────────────────────────────────
  Widget _buildDesktopLayout(bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: isDark
                  ? Colors.white.withOpacity(0.03)
                  : Colors.white.withOpacity(0.6),
              border: Border.all(
                color: const Color(0xFF3B82F6).withOpacity(0.15),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: _buildMainArea(isDark),
            ),
          ),
        ),
        const SizedBox(width: AppConstants.paddingLg),
        SizedBox(width: 260, child: _buildControls(isDark)),
      ],
    );
  }

  // ── MOBILE layout ─────────────────────────────────────────
  Widget _buildMobileLayout(bool isDark) {
    return Column(
      children: [
        // Scale selector always visible on mobile
        if (_sourceImage != null && _resultImage == null) ...[
          Row(
            children: [
              Expanded(
                child: _ScaleOption(
                  label: '2x',
                  subtitle: 'Fast',
                  selected: _selectedScale == 2,
                  isDark: isDark,
                  onTap: () => setState(() => _selectedScale = 2),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ScaleOption(
                  label: '4x',
                  subtitle: 'Ultra HD',
                  selected: _selectedScale == 4,
                  isDark: isDark,
                  onTap: () => setState(() => _selectedScale = 4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],

        // Main image area
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: isDark
                  ? Colors.white.withOpacity(0.03)
                  : Colors.white.withOpacity(0.6),
              border: Border.all(
                color: const Color(0xFF3B82F6).withOpacity(0.15),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _buildMainArea(isDark),
            ),
          ),
        ),

        const SizedBox(height: 10),

        // Error message
        if (_errorMessage != null) ...[
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.red.withOpacity(0.1),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 12),
            ),
          ),
          const SizedBox(height: 8),
        ],

        // Bottom action buttons
        if (_sourceImage == null)
          _GlassButton(
            label: 'Upload Image',
            icon: Icons.upload_rounded,
            color: const Color(0xFF3B82F6),
            fullWidth: true,
            isDark: isDark,
            onTap: _pickImage,
          )
        else if (_resultImage == null)
          Row(
            children: [
              Expanded(
                child: _GlassButton(
                  label: 'Upload New',
                  icon: Icons.upload_rounded,
                  color: const Color(0xFF3B82F6),
                  fullWidth: true,
                  isDark: isDark,
                  onTap: _pickImage,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _GlassButton(
                  label: _isProcessing
                      ? 'Upscaling...'
                      : 'Upscale ${_selectedScale}x',
                  icon: Icons.hd_outlined,
                  color: const Color(0xFF3B82F6),
                  fullWidth: true,
                  loading: _isProcessing,
                  isDark: isDark,
                  onTap: _isProcessing ? null : _upscale,
                ),
              ),
            ],
          )
        else
          Column(
            children: [
              _GlassButton(
                label: 'Download HD Image',
                icon: Icons.download_rounded,
                color: const Color(0xFF3B82F6),
                fullWidth: true,
                isDark: isDark,
                onTap: _download,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _GlassButton(
                      label: 'Try Again',
                      icon: Icons.refresh_rounded,
                      color: Colors.white,
                      fullWidth: true,
                      isOutlined: true,
                      isDark: isDark,
                      onTap: () => setState(() {
                        _resultImage = null;
                        _errorMessage = null;
                      }),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _GlassButton(
                      label: 'New Image',
                      icon: Icons.upload_rounded,
                      color: Colors.white,
                      fullWidth: true,
                      isOutlined: true,
                      isDark: isDark,
                      onTap: () => setState(() {
                        _sourceImage = null;
                        _resultImage = null;
                        _errorMessage = null;
                      }),
                    ),
                  ),
                ],
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildMainArea(bool isDark) {
    if (_sourceImage == null)
      return _EmptyUpload(onPick: _pickImage, isDark: isDark);

    if (_isProcessing) {
      return Container(
        color: isDark
            ? Colors.black.withOpacity(0.3)
            : Colors.white.withOpacity(0.5),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  color: Color(0xFF60A5FA),
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Upscaling ${_selectedScale}x with Clipdrop...',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This may take up to 60 seconds',
                style: TextStyle(
                  color: isDark
                      ? Colors.white.withOpacity(0.3)
                      : Colors.black38,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_resultImage != null) {
      return GestureDetector(
        onHorizontalDragUpdate: (d) {
          final box = context.findRenderObject() as RenderBox;
          setState(
            () => _sliderPos = (d.localPosition.dx / box.size.width).clamp(
              0.0,
              1.0,
            ),
          );
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.memory(_resultImage!, fit: BoxFit.contain),
            ClipRect(
              clipper: _HalfClipper(_sliderPos),
              child: Image.memory(_sourceImage!, fit: BoxFit.contain),
            ),
            LayoutBuilder(
              builder: (_, c) => Stack(
                children: [
                  Positioned(
                    left: _sliderPos * c.maxWidth - 1,
                    top: 0,
                    bottom: 0,
                    child: Container(width: 2, color: Colors.white),
                  ),
                  Positioned(
                    left: _sliderPos * c.maxWidth - 20,
                    top: c.maxHeight / 2 - 20,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: const Icon(
                        Icons.compare_arrows,
                        size: 22,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 12,
                    bottom: 12,
                    child: _Badge(text: 'Original'),
                  ),
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: _Badge(
                      text: '${_selectedScale}x Upscaled',
                      color: const Color(0xFF3B82F6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.memory(_sourceImage!, fit: BoxFit.contain),
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.black.withOpacity(0.6),
              ),
              child: Text(
                'Ready to upscale — choose scale',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildControls(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isDark
            ? Colors.white.withOpacity(0.03)
            : Colors.white.withOpacity(0.7),
        border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.15)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _GlassButton(
              label: 'Upload Image',
              icon: Icons.upload_rounded,
              color: const Color(0xFF3B82F6),
              fullWidth: true,
              isDark: isDark,
              onTap: _pickImage,
            ),
            if (_sourceImage != null) ...[
              const SizedBox(height: 24),
              _SectionLabel(text: 'UPSCALE FACTOR', isDark: isDark),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _ScaleOption(
                      label: '2x',
                      subtitle: 'Fast',
                      selected: _selectedScale == 2,
                      isDark: isDark,
                      onTap: () => setState(() => _selectedScale = 2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ScaleOption(
                      label: '4x',
                      subtitle: 'Ultra HD',
                      selected: _selectedScale == 4,
                      isDark: isDark,
                      onTap: () => setState(() => _selectedScale = 4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color(0xFF3B82F6).withOpacity(0.08),
                  border: Border.all(
                    color: const Color(0xFF3B82F6).withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.bolt, size: 14, color: Color(0xFF60A5FA)),
                        SizedBox(width: 6),
                        Text(
                          'Powered by Clipdrop AI',
                          style: TextStyle(
                            color: Color(0xFF60A5FA),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _selectedScale == 2
                          ? 'Doubles resolution using Stability AI. Fast and high quality.'
                          : 'Quadruples resolution — maximum HD quality.',
                      style: TextStyle(
                        color: isDark
                            ? Colors.white.withOpacity(0.4)
                            : Colors.black45,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.red.withOpacity(0.1),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (_resultImage == null)
                _GlassButton(
                  label: _isProcessing
                      ? 'Upscaling...'
                      : 'Upscale ${_selectedScale}x',
                  icon: Icons.hd_outlined,
                  color: const Color(0xFF3B82F6),
                  fullWidth: true,
                  loading: _isProcessing,
                  isDark: isDark,
                  onTap: _isProcessing ? null : _upscale,
                )
              else ...[
                _GlassButton(
                  label: 'Download HD Image',
                  icon: Icons.download_rounded,
                  color: const Color(0xFF3B82F6),
                  fullWidth: true,
                  isDark: isDark,
                  onTap: _download,
                ),
                const SizedBox(height: 10),
                _GlassButton(
                  label: 'Try Again',
                  icon: Icons.refresh_rounded,
                  color: Colors.white,
                  fullWidth: true,
                  isOutlined: true,
                  isDark: isDark,
                  onTap: () => setState(() {
                    _resultImage = null;
                    _errorMessage = null;
                  }),
                ),
                const SizedBox(height: 10),
                _GlassButton(
                  label: 'New Image',
                  icon: Icons.upload_rounded,
                  color: Colors.white,
                  fullWidth: true,
                  isOutlined: true,
                  isDark: isDark,
                  onTap: () => setState(() {
                    _sourceImage = null;
                    _resultImage = null;
                    _errorMessage = null;
                  }),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _DesktopFile {
  final String path;
  _DesktopFile(this.path);
  Future<void> writeAsBytes(Uint8List bytes) async {
    if (!kIsWeb) {
      final dynamic f = _createFile(path);
      await f.writeAsBytes(bytes);
    }
  }

  dynamic _createFile(String p) =>
      throw UnsupportedError('Use conditional import for dart:io');
}

class _ScaleOption extends StatelessWidget {
  final String label, subtitle;
  final bool selected, isDark;
  final VoidCallback onTap;
  const _ScaleOption({
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: selected
              ? const Color(0xFF3B82F6).withOpacity(0.2)
              : isDark
              ? Colors.white.withOpacity(0.04)
              : Colors.black.withOpacity(0.04),
          border: Border.all(
            color: selected
                ? const Color(0xFF60A5FA).withOpacity(0.7)
                : isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.12),
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withOpacity(0.2),
                    blurRadius: 12,
                    spreadRadius: -4,
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: selected
                    ? Colors.white
                    : isDark
                    ? Colors.white.withOpacity(0.4)
                    : Colors.black45,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                color: selected
                    ? const Color(0xFF60A5FA)
                    : isDark
                    ? Colors.white.withOpacity(0.25)
                    : Colors.black26,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyUpload extends StatefulWidget {
  final VoidCallback onPick;
  final bool isDark;
  const _EmptyUpload({required this.onPick, required this.isDark});
  @override
  State<_EmptyUpload> createState() => _EmptyUploadState();
}

class _EmptyUploadState extends State<_EmptyUpload> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onPick,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          color: _hovered
              ? const Color(0xFF3B82F6).withOpacity(0.05)
              : Colors.transparent,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(
                      0xFF3B82F6,
                    ).withOpacity(_hovered ? 0.2 : 0.1),
                    border: Border.all(
                      color: const Color(
                        0xFF3B82F6,
                      ).withOpacity(_hovered ? 0.5 : 0.2),
                    ),
                  ),
                  child: Icon(
                    Icons.upload_rounded,
                    size: 40,
                    color: const Color(
                      0xFF60A5FA,
                    ).withOpacity(_hovered ? 1.0 : 0.6),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Click to upload image',
                  style: TextStyle(
                    color: widget.isDark
                        ? Colors.white.withOpacity(_hovered ? 0.8 : 0.4)
                        : Colors.black.withOpacity(_hovered ? 0.7 : 0.35),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'PNG, JPG, WEBP supported',
                  style: TextStyle(
                    color: widget.isDark
                        ? Colors.white.withOpacity(0.25)
                        : Colors.black26,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HalfClipper extends CustomClipper<Rect> {
  final double pos;
  _HalfClipper(this.pos);
  @override
  Rect getClip(Size size) => Rect.fromLTWH(0, 0, size.width * pos, size.height);
  @override
  bool shouldReclip(_HalfClipper old) => old.pos != pos;
}

class _Badge extends StatelessWidget {
  final String text;
  final Color? color;
  const _Badge({required this.text, this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(6),
      color: (color ?? Colors.white).withOpacity(0.15),
      border: Border.all(color: (color ?? Colors.white).withOpacity(0.3)),
    ),
    child: Text(
      text,
      style: TextStyle(
        color: color ?? Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

class _SectionLabel extends StatelessWidget {
  final String text;
  final bool isDark;
  const _SectionLabel({required this.text, required this.isDark});
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(
      color: isDark ? Colors.white.withOpacity(0.35) : Colors.black38,
      fontSize: 10,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.5,
    ),
  );
}

class _GlassButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final bool fullWidth, isOutlined, loading, isDark;
  const _GlassButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.isDark,
    this.onTap,
    this.fullWidth = false,
    this.isOutlined = false,
    this.loading = false,
  });
  @override
  State<_GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<_GlassButton> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    final disabled = widget.onTap == null;
    final c = widget.color;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: widget.fullWidth ? double.infinity : null,
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: disabled
                ? (widget.isDark
                      ? Colors.white.withOpacity(0.03)
                      : Colors.black.withOpacity(0.03))
                : widget.isOutlined
                ? Colors.transparent
                : c.withOpacity(_hovered ? 0.2 : 0.12),
            border: Border.all(
              color: disabled
                  ? (widget.isDark
                        ? Colors.white.withOpacity(0.08)
                        : Colors.black.withOpacity(0.08))
                  : c.withOpacity(_hovered ? 0.7 : 0.35),
            ),
            boxShadow: disabled || widget.isOutlined
                ? null
                : [
                    BoxShadow(
                      color: c.withOpacity(_hovered ? 0.3 : 0.1),
                      blurRadius: 12,
                      spreadRadius: -4,
                    ),
                  ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.loading)
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: c),
                )
              else
                Icon(
                  widget.icon,
                  size: 15,
                  color: disabled
                      ? (widget.isDark
                            ? Colors.white.withOpacity(0.2)
                            : Colors.black26)
                      : c.withOpacity(0.9),
                ),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: TextStyle(
                  color: disabled
                      ? (widget.isDark
                            ? Colors.white.withOpacity(0.2)
                            : Colors.black26)
                      : widget.isDark
                      ? Colors.white.withOpacity(_hovered ? 1.0 : 0.8)
                      : Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
