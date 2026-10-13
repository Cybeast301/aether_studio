import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../generator_controller.dart';
import '../prompt_history_controller.dart';

class PromptInput extends StatefulWidget {
  const PromptInput({super.key});

  @override
  State<PromptInput> createState() => _PromptInputState();
}

class _PromptInputState extends State<PromptInput> {
  final TextEditingController _textCtrl = TextEditingController();
  bool _showHistory = false;

  @override
  void initState() {
    super.initState();
    PromptHistoryController.instance.load();
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<GeneratorController>();
    final historyCtrl = context.watch<PromptHistoryController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Prompt TextField ──────────────────────────────
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.white.withOpacity(0.8),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.08)
                  : const Color(0xFF6366F1).withOpacity(0.2),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: _textCtrl,
                  maxLines: isMobile ? 2 : 3,
                  minLines: 1,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF1E1B4B),
                    fontSize: isMobile ? 13 : 14,
                  ),
                  decoration: InputDecoration(
                    hintText: isMobile
                        ? 'Describe your vision...'
                        : 'Describe your vision and let AI bring it to life...',
                    hintStyle: TextStyle(
                      color: isDark
                          ? Colors.white.withOpacity(0.3)
                          : Colors.black.withOpacity(0.3),
                      fontSize: isMobile ? 13 : 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(isMobile ? 12 : 16),
                  ),
                  onChanged: (v) => ctrl.setPrompt(v),
                ),
              ),

              // History toggle button
              if (historyCtrl.prompts.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(
                    top: isMobile ? 6 : 8,
                    right: isMobile ? 6 : 8,
                  ),
                  child: Tooltip(
                    message: 'Recent prompts',
                    child: GestureDetector(
                      onTap: () => setState(() => _showHistory = !_showHistory),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: EdgeInsets.all(isMobile ? 6 : 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: _showHistory
                              ? const Color(0xFF6366F1).withOpacity(0.2)
                              : Colors.transparent,
                        ),
                        child: Icon(
                          Icons.history_rounded,
                          size: isMobile ? 16 : 18,
                          color: _showHistory
                              ? const Color(0xFF818CF8)
                              : (isDark
                                    ? Colors.white.withOpacity(0.4)
                                    : Colors.black.withOpacity(0.3)),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),

        // ── History Dropdown ──────────────────────────────
        if (_showHistory && historyCtrl.prompts.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 6),
            constraints: BoxConstraints(maxHeight: isMobile ? 180 : 240),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: isDark ? const Color(0xFF0F172A) : Colors.white,
              border: Border.all(
                color: const Color(0xFF6366F1).withOpacity(0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.4 : 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.history_rounded,
                        size: 14,
                        color: Color(0xFF818CF8),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Recent Prompts',
                        style: TextStyle(
                          color: isDark
                              ? Colors.white.withOpacity(0.5)
                              : Colors.black.withOpacity(0.4),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          historyCtrl.clear();
                          setState(() => _showHistory = false);
                        },
                        child: Text(
                          'Clear all',
                          style: TextStyle(
                            color: Colors.red.withOpacity(0.6),
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Divider(
                  height: 1,
                  color: isDark
                      ? Colors.white.withOpacity(0.06)
                      : Colors.black.withOpacity(0.06),
                ),

                // List
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    itemCount: historyCtrl.prompts.length,
                    itemBuilder: (_, i) {
                      final prompt = historyCtrl.prompts[i];
                      return _PromptItem(
                        prompt: prompt,
                        isDark: isDark,
                        isMobile: isMobile,
                        onSelect: () {
                          _textCtrl.text = prompt;
                          ctrl.setPrompt(prompt);
                          setState(() => _showHistory = false);
                        },
                        onRemove: () {
                          historyCtrl.remove(prompt);
                          if (historyCtrl.prompts.isEmpty) {
                            setState(() => _showHistory = false);
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

//////////////////////////////////////////////////////////////
/// 💎 PROMPT ITEM
//////////////////////////////////////////////////////////////

class _PromptItem extends StatefulWidget {
  final String prompt;
  final bool isDark;
  final bool isMobile;
  final VoidCallback onSelect;
  final VoidCallback onRemove;

  const _PromptItem({
    required this.prompt,
    required this.isDark,
    required this.isMobile,
    required this.onSelect,
    required this.onRemove,
  });

  @override
  State<_PromptItem> createState() => _PromptItemState();
}

class _PromptItemState extends State<_PromptItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onSelect,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: EdgeInsets.symmetric(
            horizontal: 14,
            vertical: widget.isMobile ? 11 : 9, // taller tap target on mobile
          ),
          color: _hovered
              ? const Color(0xFF6366F1).withOpacity(0.08)
              : Colors.transparent,
          child: Row(
            children: [
              Icon(
                Icons.subdirectory_arrow_right_rounded,
                size: 13,
                color: _hovered
                    ? const Color(0xFF818CF8)
                    : (widget.isDark
                          ? Colors.white.withOpacity(0.2)
                          : Colors.black.withOpacity(0.2)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.prompt,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: widget.isDark
                        ? Colors.white.withOpacity(_hovered ? 1.0 : 0.7)
                        : Colors.black.withOpacity(_hovered ? 0.9 : 0.6),
                    fontSize: widget.isMobile ? 12 : 13,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Always show remove on mobile (no hover on touch)
              GestureDetector(
                onTap: widget.onRemove,
                child: Icon(
                  Icons.close_rounded,
                  size: 14,
                  color: widget.isMobile
                      ? Colors.red.withOpacity(0.4)
                      : (_hovered
                            ? Colors.red.withOpacity(0.6)
                            : Colors.transparent),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
