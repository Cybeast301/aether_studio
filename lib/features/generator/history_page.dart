import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'history_controller.dart';
import 'theme_controller.dart'; // ✅ added
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html show AnchorElement, Blob, Url;

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final history = context.watch<HistoryController>();
    final isDark = context.watch<ThemeController>().isDark; // ✅ added

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'History',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black87, // ✅
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Your previously generated images',
                    style: TextStyle(
                      color: isDark ? Colors.white54 : Colors.black45, // ✅
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              if (!history.isEmpty)
                TextButton.icon(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                  ),
                  label: const Text(
                    'Clear All',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                  onPressed: () => _confirmClear(context, history),
                ),
            ],
          ),

          const SizedBox(height: 24),

          // ── Grid or Empty State ──────────────────────────────
          Expanded(
            child: history.isEmpty
                ? const _EmptyHistory()
                : GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 280,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.75,
                        ),
                    itemCount: history.entries.length,
                    itemBuilder: (context, index) {
                      final entry = history.entries[index];
                      return _HistoryCard(entry: entry);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _confirmClear(BuildContext context, HistoryController history) {
    final isDark = ThemeController.instance.isDark;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1B4B) : Colors.white, // ✅
        title: Text(
          'Clear History',
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        ), // ✅
        content: Text(
          'Are you sure you want to delete all history?',
          style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
        ), // ✅
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: isDark ? Colors.white54 : Colors.black45),
            ), // ✅
          ),
          TextButton(
            onPressed: () {
              history.clearAll();
              Navigator.pop(context);
            },
            child: const Text(
              'Clear All',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
/// 🖼 HISTORY CARD
//////////////////////////////////////////////////////////////

class _HistoryCard extends StatefulWidget {
  final HistoryEntry entry;
  const _HistoryCard({required this.entry});

  @override
  State<_HistoryCard> createState() => _HistoryCardState();
}

class _HistoryCardState extends State<_HistoryCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final history = context.read<HistoryController>();
    final isDark = context.watch<ThemeController>().isDark; // ✅

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _hovered
                ? Colors.purpleAccent.withOpacity(0.5)
                : isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.black.withOpacity(0.1), // ✅
          ),
          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color: Colors.purpleAccent.withOpacity(0.2),
                    blurRadius: 20,
                  ),
                ]
              : [],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Image ────────────────────────────────────────
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.memory(widget.entry.imageBytes, fit: BoxFit.cover),
                    if (_hovered)
                      Container(
                        color: Colors.black.withOpacity(0.5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _ActionIcon(
                              icon: Icons.download,
                              tooltip: 'Download',
                              onTap: () => _download(
                                widget.entry.imageBytes,
                                'aether_${widget.entry.id}.png',
                              ),
                            ),
                            const SizedBox(width: 12),
                            _ActionIcon(
                              icon: Icons.delete_outline,
                              tooltip: 'Delete',
                              color: Colors.redAccent,
                              onTap: () => history.deleteEntry(widget.entry.id),
                            ),
                          ],
                        ),
                      ),
                    if (widget.entry.bgRemovedBytes != null)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'BG Removed',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // ── Info ─────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(10),
                color: isDark
                    ? const Color(0xFF0F0F1E)
                    : const Color(0xFFF3F0FF), // ✅
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.entry.prompt,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87, // ✅
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _Chip(widget.entry.style),
                        const SizedBox(width: 6),
                        _Chip(widget.entry.aspectRatio),
                        const Spacer(),
                        Text(
                          _formatTime(widget.entry.createdAt),
                          style: TextStyle(
                            color: isDark
                                ? Colors.white38
                                : Colors.black38, // ✅
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ FIXED: web-safe download using html blob
  Future<void> _download(Uint8List bytes, String fileName) async {
    try {
      if (kIsWeb) {
        final blob = html.Blob([bytes], 'image/png');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', fileName)
          ..click();
        html.Url.revokeObjectUrl(url);
      }
    } catch (_) {}
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

//////////////////////////////////////////////////////////////
/// 🔘 ACTION ICON BUTTON
//////////////////////////////////////////////////////////////

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final Color color;

  const _ActionIcon({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
/// 🏷 CHIP
//////////////////////////////////////////////////////////////

class _Chip extends StatelessWidget {
  final String label;
  const _Chip(this.label);

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeController>().isDark; // ✅
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.08)
            : Colors.black.withOpacity(0.07), // ✅
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isDark ? Colors.white54 : Colors.black54,
          fontSize: 10,
        ), // ✅
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
/// 🌌 EMPTY STATE
//////////////////////////////////////////////////////////////

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeController>().isDark; // ✅
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.15),
          ), // ✅
          const SizedBox(height: 16),
          Text(
            'No history yet',
            style: TextStyle(
              color: isDark ? Colors.white54 : Colors.black54,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ), // ✅
          const SizedBox(height: 8),
          Text(
            'Generate an image to see it here',
            style: TextStyle(
              color: isDark ? Colors.white30 : Colors.black38,
              fontSize: 14,
            ),
          ), // ✅
        ],
      ),
    );
  }
}
