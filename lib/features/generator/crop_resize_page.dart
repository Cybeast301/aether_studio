import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'package:aether_studio/features/generator/generator_controller.dart';
import 'package:aether_studio/features/generator/history_controller.dart';
import 'package:aether_studio/features/generator/theme_controller.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/constants.dart';

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html show AnchorElement, Blob, Url;

class CropResizePage extends StatefulWidget {
  const CropResizePage({super.key});

  @override
  State<CropResizePage> createState() => _CropResizePageState();
}

class _CropResizePageState extends State<CropResizePage> {
  final CropController _cropController = CropController();

  Uint8List? _sourceImage;
  Uint8List? _resultImage;
  bool _isProcessing = false;
  bool _isCropping = false;
  String? _errorMessage;

  int _outputWidth = 1024;
  int _outputHeight = 1024;
  bool _lockAspect = true;
  double _aspectRatio = 1.0;
  double? _cropAspect;

  bool _showControls = false;

  final List<Map<String, dynamic>> _presets = [
    {'label': 'Free', 'w': 0, 'h': 0, 'aspect': null, 'icon': Icons.crop_free},
    {
      'label': 'Square\n1:1',
      'w': 1024,
      'h': 1024,
      'aspect': 1.0,
      'icon': Icons.crop_square,
    },
    {
      'label': 'HD\n16:9',
      'w': 1280,
      'h': 720,
      'aspect': 16 / 9,
      'icon': Icons.crop_16_9,
    },
    {
      'label': '4:3',
      'w': 1024,
      'h': 768,
      'aspect': 4 / 3,
      'icon': Icons.crop_landscape,
    },
    {
      'label': 'Portrait\n3:4',
      'w': 768,
      'h': 1024,
      'aspect': 3 / 4,
      'icon': Icons.crop_portrait,
    },
    {
      'label': 'Story\n9:16',
      'w': 1080,
      'h': 1920,
      'aspect': 9 / 16,
      'icon': Icons.crop_portrait,
    },
  ];
  int _selectedPreset = 0;

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
        if (bytes != null) {
          setState(() {
            _sourceImage = bytes;
            _resultImage = null;
            _errorMessage = null;
          });
        }
      }
    } catch (e) {
      setState(() => _errorMessage = 'Failed to pick image: $e');
    }
  }

  void _applyPreset(int index) {
    final preset = _presets[index];
    setState(() {
      _selectedPreset = index;
      _cropAspect = preset['aspect'] as double?;
      if (preset['w'] != 0) {
        _outputWidth = preset['w'] as int;
        _outputHeight = preset['h'] as int;
        _aspectRatio = _outputWidth / _outputHeight;
      }
    });
  }

  void _doCrop() {
    if (_sourceImage == null) return;
    setState(() => _isCropping = true);
    _cropController.crop();
  }

  Future<void> _onCropped(Uint8List cropped) async {
    setState(() {
      _isCropping = false;
      _isProcessing = true;
    });
    try {
      final codec = await instantiateImageCodec(
        cropped,
        targetWidth: _outputWidth,
        targetHeight: _outputHeight,
      );
      final frame = await codec.getNextFrame();
      final byteData = await frame.image.toByteData(
        format: ImageByteFormat.png,
      );
      final result = byteData!.buffer.asUint8List();
      setState(() => _resultImage = result);
      if (mounted) {
        context.read<HistoryController>().addEntry(
          imageBytes: result,
          prompt: 'Cropped & Resized — ${_outputWidth}x$_outputHeight',
          style: 'Edited',
          aspectRatio: '$_outputWidth:$_outputHeight',
        );
      }
    } catch (e) {
      setState(() => _errorMessage = 'Processing failed: $e');
    }
    setState(() => _isProcessing = false);
  }

  Future<void> _downloadResult() async {
    if (_resultImage == null) return;
    final fileName =
        'aether_cropped_${DateTime.now().millisecondsSinceEpoch}.png';
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
          dialogTitle: 'Save cropped image',
          fileName: fileName,
          type: FileType.custom,
          allowedExtensions: ['png'],
        );
        if (savePath == null) return;
        await _writeDesktop(savePath, _resultImage!);
      }
    } catch (e) {
      setState(() => _errorMessage = 'Download failed: $e');
    }
  }

  Future<void> _writeDesktop(String path, Uint8List bytes) async {
    if (!kIsWeb) {
      final dynamic file = _makeFile(path);
      await file.writeAsBytes(bytes);
    }
  }

  dynamic _makeFile(String path) {
    throw UnsupportedError('Use conditional import for dart:io on desktop');
  }

  // ── Returns the label for the current preset ──
  String get _currentRatioLabel {
    final p = _presets[_selectedPreset];
    final label = (p['label'] as String).replaceAll('\n', ' ');
    if (_selectedPreset == 0) return 'Free crop';
    return '$label — ${_outputWidth}×$_outputHeight px';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeController>().isDark;
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Padding(
      padding: EdgeInsets.all(isMobile ? 12 : AppConstants.paddingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xFF6366F1).withOpacity(0.15),
                  border: Border.all(
                    color: const Color(0xFF6366F1).withOpacity(0.3),
                  ),
                ),
                child: const Icon(
                  Icons.crop_outlined,
                  color: Color(0xFF818CF8),
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Crop & Resize',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: isMobile ? 18 : 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Drag to crop, choose output size',
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
              if (isMobile && _sourceImage != null)
                GestureDetector(
                  onTap: () => setState(() => _showControls = !_showControls),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: _showControls
                          ? const Color(0xFF6366F1).withOpacity(0.2)
                          : (isDark
                                ? Colors.white.withOpacity(0.06)
                                : Colors.black.withOpacity(0.05)),
                      border: Border.all(
                        color: const Color(
                          0xFF6366F1,
                        ).withOpacity(_showControls ? 0.5 : 0.2),
                      ),
                    ),
                    child: Icon(
                      Icons.tune_rounded,
                      size: 18,
                      color: _showControls
                          ? const Color(0xFF818CF8)
                          : (isDark ? Colors.white60 : Colors.black54),
                    ),
                  ),
                ),
            ],
          ),

          SizedBox(height: isMobile ? 12 : AppConstants.paddingLg),

          // ── Ratio presets bar — always visible when image loaded ──
          if (_sourceImage != null && _resultImage == null) ...[
            _buildRatioBar(isDark, isMobile),
            const SizedBox(height: 10),
          ],

          // ── Body ──
          Expanded(
            child: isMobile
                ? _buildMobileLayout(isDark)
                : _buildDesktopLayout(isDark),
          ),
        ],
      ),
    );
  }

  // ✅ Horizontal scrollable ratio presets bar — shown above crop area
  Widget _buildRatioBar(bool isDark, bool isMobile) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_presets.length, (i) {
          final selected = _selectedPreset == i;
          final preset = _presets[i];
          final label = (preset['label'] as String).replaceAll('\n', ' ');
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => _applyPreset(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: selected
                      ? const Color(0xFF6366F1).withOpacity(0.2)
                      : isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.black.withOpacity(0.04),
                  border: Border.all(
                    color: selected
                        ? const Color(0xFF818CF8).withOpacity(0.8)
                        : isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.1),
                  ),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF6366F1).withOpacity(0.25),
                            blurRadius: 10,
                            spreadRadius: -3,
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ✅ Visual crop shape indicator
                    _CropShapeIndicator(
                      aspectRatio: preset['aspect'] as double?,
                      selected: selected,
                      isDark: isDark,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: TextStyle(
                        color: selected
                            ? (isDark ? Colors.white : const Color(0xFF3730A3))
                            : isDark
                            ? Colors.white.withOpacity(0.5)
                            : Colors.black54,
                        fontSize: 12,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

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
                color: const Color(0xFF6366F1).withOpacity(0.15),
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

  Widget _buildMobileLayout(bool isDark) {
    return Column(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: isDark
                  ? Colors.white.withOpacity(0.03)
                  : Colors.white.withOpacity(0.6),
              border: Border.all(
                color: const Color(0xFF6366F1).withOpacity(0.15),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _buildMainArea(isDark),
            ),
          ),
        ),

        if (_sourceImage != null) ...[
          const SizedBox(height: 10),
          if (_resultImage == null)
            Row(
              children: [
                Expanded(
                  child: _GlassButton(
                    label: 'Upload New',
                    icon: Icons.upload_rounded,
                    color: const Color(0xFF6366F1),
                    fullWidth: true,
                    isDark: isDark,
                    onTap: _pickImage,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _GlassButton(
                    label: (_isCropping || _isProcessing)
                        ? 'Processing...'
                        : 'Crop & Resize',
                    icon: Icons.crop_rounded,
                    color: const Color(0xFF3B4FE8),
                    fullWidth: true,
                    loading: _isCropping || _isProcessing,
                    isDark: isDark,
                    onTap: (_isCropping || _isProcessing) ? null : _doCrop,
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: _GlassButton(
                    label: 'Download',
                    icon: Icons.download_rounded,
                    color: const Color(0xFF3B82F6),
                    fullWidth: true,
                    isDark: isDark,
                    onTap: _downloadResult,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _GlassButton(
                    label: 'Crop Again',
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
                    label: 'New',
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
        ] else ...[
          const SizedBox(height: 10),
          _GlassButton(
            label: 'Upload Image',
            icon: Icons.upload_rounded,
            color: const Color(0xFF6366F1),
            fullWidth: true,
            isDark: isDark,
            onTap: _pickImage,
          ),
        ],

        if (_showControls && _sourceImage != null) ...[
          const SizedBox(height: 10),
          Container(
            constraints: const BoxConstraints(maxHeight: 280),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: isDark
                  ? Colors.white.withOpacity(0.03)
                  : Colors.white.withOpacity(0.7),
              border: Border.all(
                color: const Color(0xFF6366F1).withOpacity(0.15),
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildControlsContent(isDark),
            ),
          ),
        ],

        if (_errorMessage != null) ...[
          const SizedBox(height: 8),
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
        ],
      ],
    );
  }

  Widget _buildMainArea(bool isDark) {
    if (_sourceImage == null)
      return _EmptyUpload(onPick: _pickImage, isDark: isDark);

    if (_resultImage != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.memory(_resultImage!, fit: BoxFit.contain),
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.black.withOpacity(0.6),
                ),
                child: Text(
                  '✅ Result: ${_outputWidth}×$_outputHeight px',
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Stack(
      children: [
        Crop(
          image: _sourceImage!,
          controller: _cropController,
          aspectRatio: _cropAspect,
          onCropped: _onCropped,
          baseColor: isDark ? const Color(0xFF020818) : const Color(0xFFF8F7FF),
          maskColor: Colors.black.withOpacity(0.6),
          cornerDotBuilder: (size, edgeAlignment) =>
              DotControl(color: const Color(0xFF818CF8)),
          withCircleUi: false,
          initialSize: 0.8,
        ),

        // ✅ Ratio label overlay — top center
        Positioned(
          top: 12,
          left: 0,
          right: 0,
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Container(
                key: ValueKey(_selectedPreset),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.black.withOpacity(0.55),
                  border: Border.all(
                    color: const Color(0xFF818CF8).withOpacity(0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.crop_rounded,
                      size: 13,
                      color: Color(0xFF818CF8),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _currentRatioLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        if (_isCropping || _isProcessing)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Color(0xFF818CF8)),
                  SizedBox(height: 12),
                  Text(
                    'Processing...',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildControlsContent(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(text: 'OUTPUT SIZE', isDark: isDark),
        const SizedBox(height: 10),
        _DimensionField(
          label: 'Width',
          value: _outputWidth,
          isDark: isDark,
          onChanged: (v) => setState(() {
            _outputWidth = v;
            if (_lockAspect) _outputHeight = (v / _aspectRatio).round();
          }),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => setState(() => _lockAspect = !_lockAspect),
          child: Row(
            children: [
              Icon(
                _lockAspect ? Icons.lock_rounded : Icons.lock_open_rounded,
                size: 14,
                color: _lockAspect
                    ? const Color(0xFF818CF8)
                    : (isDark ? Colors.white.withOpacity(0.3) : Colors.black26),
              ),
              const SizedBox(width: 6),
              Text(
                'Lock aspect ratio',
                style: TextStyle(
                  color: _lockAspect
                      ? const Color(0xFF818CF8)
                      : (isDark
                            ? Colors.white.withOpacity(0.3)
                            : Colors.black26),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        _DimensionField(
          label: 'Height',
          value: _outputHeight,
          isDark: isDark,
          onChanged: (v) => setState(() {
            _outputHeight = v;
            if (_lockAspect) _outputWidth = (v * _aspectRatio).round();
          }),
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
        border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.15)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _GlassButton(
              label: 'Upload Image',
              icon: Icons.upload_rounded,
              color: const Color(0xFF6366F1),
              fullWidth: true,
              isDark: isDark,
              onTap: _pickImage,
            ),
            if (_sourceImage != null) ...[
              const SizedBox(height: 20),
              _buildControlsContent(isDark),
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
                  label: (_isCropping || _isProcessing)
                      ? 'Processing...'
                      : 'Crop & Resize',
                  icon: Icons.crop_rounded,
                  color: const Color(0xFF3B4FE8),
                  fullWidth: true,
                  loading: _isCropping || _isProcessing,
                  isDark: isDark,
                  onTap: (_isCropping || _isProcessing) ? null : _doCrop,
                )
              else ...[
                _GlassButton(
                  label: 'Download Result',
                  icon: Icons.download_rounded,
                  color: const Color(0xFF3B82F6),
                  fullWidth: true,
                  isDark: isDark,
                  onTap: _downloadResult,
                ),
                const SizedBox(height: 10),
                _GlassButton(
                  label: 'Crop Again',
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

//////////////////////////////////////////////////////////////
// ✅ Crop shape indicator — tiny visual of the crop ratio
//////////////////////////////////////////////////////////////
class _CropShapeIndicator extends StatelessWidget {
  final double? aspectRatio;
  final bool selected;
  final bool isDark;

  const _CropShapeIndicator({
    required this.aspectRatio,
    required this.selected,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    const maxW = 18.0;
    const maxH = 18.0;

    double w, h;
    if (aspectRatio == null) {
      // Free crop — dashed square
      w = maxW;
      h = maxH;
    } else if (aspectRatio! >= 1) {
      w = maxW;
      h = maxW / aspectRatio!;
    } else {
      h = maxH;
      w = maxH * aspectRatio!;
    }

    final color = selected
        ? const Color(0xFF818CF8)
        : (isDark ? Colors.white38 : Colors.black26);

    return SizedBox(
      width: maxW,
      height: maxH,
      child: Center(
        child: Container(
          width: w,
          height: h,
          decoration: BoxDecoration(
            border: Border.all(color: color, width: 1.5),
            borderRadius: BorderRadius.circular(2),
            color: selected
                ? const Color(0xFF6366F1).withOpacity(0.2)
                : Colors.transparent,
          ),
        ),
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
/// WIDGETS — unchanged
//////////////////////////////////////////////////////////////

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
              ? const Color(0xFF6366F1).withOpacity(0.05)
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
                      0xFF6366F1,
                    ).withOpacity(_hovered ? 0.2 : 0.1),
                    border: Border.all(
                      color: const Color(
                        0xFF6366F1,
                      ).withOpacity(_hovered ? 0.5 : 0.2),
                    ),
                  ),
                  child: Icon(
                    Icons.upload_rounded,
                    size: 40,
                    color: const Color(
                      0xFF818CF8,
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

class _DimensionField extends StatelessWidget {
  final String label;
  final int value;
  final bool isDark;
  final Function(int) onChanged;
  const _DimensionField({
    required this.label,
    required this.value,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 52,
          child: Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white.withOpacity(0.5) : Colors.black45,
              fontSize: 12,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
              border: Border.all(
                color: const Color(0xFF6366F1).withOpacity(0.2),
              ),
            ),
            child: TextField(
              controller: TextEditingController(text: value.toString()),
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 13,
              ),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
              ),
              onSubmitted: (v) {
                final parsed = int.tryParse(v);
                if (parsed != null && parsed > 0) onChanged(parsed);
              },
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          'px',
          style: TextStyle(
            color: isDark ? Colors.white.withOpacity(0.3) : Colors.black38,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  final bool isDark;
  const _SectionTitle({required this.text, required this.isDark});
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
