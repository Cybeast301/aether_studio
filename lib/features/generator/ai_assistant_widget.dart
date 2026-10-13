import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'ai_assistant_controller.dart';
import 'generator_controller.dart';

class AiAssistantWidget extends StatelessWidget {
  const AiAssistantWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<AiAssistantController>();
    return Stack(
      children: [
        if (ctrl.isOpen)
          Positioned(bottom: 100, right: 24, child: _ChatPanel()),
        Positioned(bottom: 24, right: 24, child: _AikoOrbButton()),
      ],
    );
  }
}

//////////////////////////////////////////////////////////////
/// 💜 AIKO ORB BUTTON
//////////////////////////////////////////////////////////////

class _AikoOrbButton extends StatefulWidget {
  @override
  State<_AikoOrbButton> createState() => _AikoOrbButtonState();
}

class _AikoOrbButtonState extends State<_AikoOrbButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseCtrl, _floatCtrl, _rotateCtrl, _blinkCtrl;
  late Animation<double> _pulseAnim, _floatAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
    _rotateCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
    _blinkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _pulseAnim = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _floatAnim = Tween<double>(
      begin: -4,
      end: 4,
    ).animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));
    Future.delayed(const Duration(seconds: 3), _autoBlink);
  }

  void _autoBlink() async {
    if (!mounted) return;
    await _blinkCtrl.forward();
    await _blinkCtrl.reverse();
    await Future.delayed(Duration(milliseconds: 2500 + Random().nextInt(2000)));
    _autoBlink();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _floatCtrl.dispose();
    _rotateCtrl.dispose();
    _blinkCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<AiAssistantController>();
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnim, _floatAnim]),
      builder: (context, _) => Transform.translate(
        offset: Offset(0, _floatAnim.value),
        child: GestureDetector(
          onTap: ctrl.toggle,
          child: SizedBox(
            width: 72,
            height: 72,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _rotateCtrl,
                  builder: (_, __) => Transform.rotate(
                    angle: _rotateCtrl.value * 2 * pi,
                    child: CustomPaint(
                      size: const Size(72, 72),
                      painter: _RotatingRingPainter(isOpen: ctrl.isOpen),
                    ),
                  ),
                ),
                Container(
                  width: 64 * _pulseAnim.value,
                  height: 64 * _pulseAnim.value,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: ctrl.isOpen
                            ? Colors.purpleAccent.withOpacity(0.55)
                            : const Color(0xFF7c3aed).withOpacity(0.45),
                        blurRadius: 22,
                        spreadRadius: 4,
                      ),
                      BoxShadow(
                        color: ctrl.isOpen
                            ? Colors.purpleAccent.withOpacity(0.25)
                            : const Color(0xFF4a0080).withOpacity(0.2),
                        blurRadius: 40,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      center: const Alignment(-0.3, -0.4),
                      radius: 0.85,
                      colors: ctrl.isOpen
                          ? [
                              const Color(0xFF9d5cff),
                              const Color(0xFF5B21B6),
                              const Color(0xFF2E0A6E),
                            ]
                          : [
                              const Color(0xFF7c4fd4),
                              const Color(0xFF4a148c),
                              const Color(0xFF1a0a2e),
                            ],
                    ),
                    border: Border.all(
                      color: ctrl.isOpen
                          ? Colors.purpleAccent.withOpacity(0.8)
                          : Colors.purpleAccent.withOpacity(0.45),
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: ctrl.isOpen
                        ? _CloseOverlay()
                        : AnimatedBuilder(
                            animation: _blinkCtrl,
                            builder: (_, __) => CustomPaint(
                              painter: _AikoFacePainter(
                                blinkValue: _blinkCtrl.value,
                              ),
                            ),
                          ),
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 6,
                  child: _SparkDot(
                    size: 5,
                    color: ctrl.isOpen
                        ? Colors.purpleAccent
                        : const Color(0xFFc084fc),
                    delay: 0,
                  ),
                ),
                Positioned(
                  bottom: 8,
                  left: 4,
                  child: _SparkDot(
                    size: 4,
                    color: ctrl.isOpen
                        ? Colors.purpleAccent
                        : const Color(0xFFa78bfa),
                    delay: 0.5,
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 6,
                  child: _SparkDot(
                    size: 3,
                    color: const Color(0xFFe879f9),
                    delay: 1.0,
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

class _SparkDot extends StatefulWidget {
  final double size, delay;
  final Color color;
  const _SparkDot({
    required this.size,
    required this.color,
    required this.delay,
  });
  @override
  State<_SparkDot> createState() => _SparkDotState();
}

class _SparkDotState extends State<_SparkDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _ctrl,
    builder: (_, __) => Opacity(
      opacity: (_ctrl.value * 0.8 + 0.2).clamp(0.0, 1.0),
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.color,
          boxShadow: [BoxShadow(color: widget.color, blurRadius: 4)],
        ),
      ),
    ),
  );
}

class _RotatingRingPainter extends CustomPainter {
  final bool isOpen;
  _RotatingRingPainter({required this.isOpen});
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 8; i++) {
      paint.color = Color.lerp(
        const Color(0xFFa78bfa),
        const Color(0xFFe879f9),
        i / 8,
      )!.withOpacity(isOpen ? 0.7 : 0.35);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        (i / 8) * 2 * pi,
        0.4,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_RotatingRingPainter old) => old.isOpen != isOpen;
}

class _AikoFacePainter extends CustomPainter {
  final double blinkValue;
  _AikoFacePainter({required this.blinkValue});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final hairPaint = Paint()
      ..shader = LinearGradient(
        colors: const [Color(0xFF6B50D0), Color(0xFF4A2FA8)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy - 4),
        width: size.width * 0.88,
        height: size.height * 0.82,
      ),
      hairPaint,
    );
    final skinPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.2, -0.3),
        colors: const [Color(0xFFFFF0E8), Color(0xFFFFDCC8), Color(0xFFF5C8A8)],
      ).createShader(Rect.fromLTWH(cx - 18, cy - 20, 36, 40));
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy + 2),
        width: size.width * 0.68,
        height: size.height * 0.72,
      ),
      skinPaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(cx - 20, cy - 18)
        ..quadraticBezierTo(cx - 24, cy - 8, cx - 22, cy)
        ..quadraticBezierTo(cx - 18, cy - 5, cx - 14, cy - 2)
        ..quadraticBezierTo(cx - 12, cy - 12, cx - 16, cy - 18),
      hairPaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(cx + 20, cy - 18)
        ..quadraticBezierTo(cx + 24, cy - 8, cx + 22, cy)
        ..quadraticBezierTo(cx + 18, cy - 5, cx + 14, cy - 2)
        ..quadraticBezierTo(cx + 12, cy - 12, cx + 16, cy - 18),
      hairPaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(cx - 8, cy - 20)
        ..quadraticBezierTo(cx - 4, cy - 8, cx - 3, cy - 3)
        ..lineTo(cx + 3, cy - 3)
        ..quadraticBezierTo(cx + 4, cy - 8, cx + 8, cy - 20),
      hairPaint,
    );
    _drawEye(canvas, Offset(cx - 9, cy + 3), 8, blinkValue);
    _drawEye(canvas, Offset(cx + 9, cy + 3), 8, blinkValue);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - 16, cy + 9), width: 10, height: 5),
      Paint()..color = Colors.pink.withOpacity(0.22),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx + 16, cy + 9), width: 10, height: 5),
      Paint()..color = Colors.pink.withOpacity(0.22),
    );
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx, cy + 12), width: 5, height: 3),
      0,
      3.14159,
      false,
      Paint()
        ..color = const Color(0xFFB07850).withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx, cy + 16), width: 12, height: 6),
      0,
      3.14159,
      false,
      Paint()
        ..color = const Color(0xFFB05848).withOpacity(0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - 5, cy - 16), width: 14, height: 6),
      Paint()..color = const Color(0xFF9080FF).withOpacity(0.4),
    );
  }

  void _drawEye(Canvas canvas, Offset center, double size, double blinkVal) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(1.0, 1.0 - blinkVal);
    canvas.translate(-center.dx, -center.dy);
    canvas.drawOval(
      Rect.fromCenter(center: center, width: size, height: size * 1.1),
      Paint()..color = Colors.white,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + 0.5),
        width: size * 0.72,
        height: size * 0.82,
      ),
      Paint()
        ..shader =
            RadialGradient(
              colors: const [
                Color(0xFFC85040),
                Color(0xFF8B2820),
                Color(0xFF3A1008),
              ],
              center: Alignment(-0.3, -0.4),
            ).createShader(
              Rect.fromCenter(center: center, width: size, height: size),
            ),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + 0.5),
        width: size * 0.38,
        height: size * 0.45,
      ),
      Paint()..color = const Color(0xFF100404),
    );
    canvas.drawCircle(
      Offset(center.dx - size * 0.16, center.dy - size * 0.18),
      size * 0.2,
      Paint()..color = Colors.white.withOpacity(0.92),
    );
    canvas.drawCircle(
      Offset(center.dx + size * 0.15, center.dy + size * 0.15),
      size * 0.1,
      Paint()..color = Colors.white.withOpacity(0.5),
    );
    canvas.drawArc(
      Rect.fromCenter(center: center, width: size, height: size * 1.1),
      3.14159,
      3.14159,
      false,
      Paint()
        ..color = const Color(0xFF1A0808)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _AikoFacePainter old) =>
      old.blinkValue != blinkValue;
}

class _CloseOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      gradient: RadialGradient(colors: [Color(0xFF9d5cff), Color(0xFF2E0A6E)]),
    ),
    child: const Center(
      child: Icon(Icons.close_rounded, color: Colors.white, size: 26),
    ),
  );
}

//////////////////////////////////////////////////////////////
/// 💬 CHAT PANEL
//////////////////////////////////////////////////////////////

class _ChatPanel extends StatefulWidget {
  @override
  State<_ChatPanel> createState() => _ChatPanelState();
}

class _ChatPanelState extends State<_ChatPanel>
    with SingleTickerProviderStateMixin {
  final TextEditingController _textCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final FocusNode _focusNode = FocusNode(); // ✅ added
  late AnimationController _slideCtrl;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut));
    _slideCtrl.forward();
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    _slideCtrl.dispose();
    _focusNode.dispose(); // ✅ added
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients)
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
    });
  }

  void _sendMessage(AiAssistantController ctrl) {
    final t = _textCtrl.text.trim();
    if (t.isNotEmpty) {
      ctrl.sendMessage(t);
      _textCtrl.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<AiAssistantController>();
    final genCtrl = context.read<GeneratorController>();
    _scrollToBottom();

    return SlideTransition(
      position: _slideAnim,
      child: Container(
        width: 340,
        height: 480,
        decoration: BoxDecoration(
          color: const Color(0xFF0a0618),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.purpleAccent.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.purpleAccent.withOpacity(0.18),
              blurRadius: 30,
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.white.withOpacity(0.06)),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.purpleAccent.withOpacity(0.5),
                        width: 1.5,
                      ),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/aiko_avatar.png',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.purpleAccent.withOpacity(0.2),
                          child: const Center(
                            child: Text(
                              'A',
                              style: TextStyle(
                                color: Colors.purpleAccent,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.purpleAccent,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'AIKO · AI ASSISTANT',
                    style: TextStyle(
                      color: Colors.purpleAccent,
                      fontSize: 11,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  _ModeTab(label: '💬', mode: AiMode.chat, ctrl: ctrl),
                  _ModeTab(label: '✨', mode: AiMode.promptHelper, ctrl: ctrl),
                  _ModeTab(label: '🔍', mode: AiMode.imageAnalyzer, ctrl: ctrl),
                ],
              ),
            ),

            Expanded(
              child: ctrl.mode == AiMode.chat
                  ? _ChatContent(ctrl: ctrl, scrollCtrl: _scrollCtrl)
                  : ctrl.mode == AiMode.promptHelper
                  ? _PromptHelperContent(ctrl: ctrl)
                  : _ImageAnalyzerContent(ctrl: ctrl, genCtrl: genCtrl),
            ),

            // ✅ Chat input with Enter = send, Shift+Enter = new line
            if (ctrl.mode == AiMode.chat)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.white.withOpacity(0.06)),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 120),
                        child: KeyboardListener(
                          focusNode: FocusNode(), // ✅ intercept keyboard
                          onKeyEvent: (event) {
                            if (event is KeyDownEvent &&
                                event.logicalKey == LogicalKeyboardKey.enter) {
                              if (HardwareKeyboard.instance.isShiftPressed) {
                                // ✅ Shift+Enter — insert newline manually
                                final pos = _textCtrl.selection.base.offset;
                                final text = _textCtrl.text;
                                final safePos = pos < 0 ? text.length : pos;
                                _textCtrl.value = TextEditingValue(
                                  text:
                                      text.substring(0, safePos) +
                                      '\n' +
                                      text.substring(safePos),
                                  selection: TextSelection.collapsed(
                                    offset: safePos + 1,
                                  ),
                                );
                              } else {
                                // ✅ Enter — send only, TextField never sees the key
                                _sendMessage(ctrl);
                              }
                            }
                          },
                          child: TextField(
                            controller: _textCtrl,
                            focusNode: _focusNode,
                            maxLines: null,
                            minLines: 1,
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction
                                .send, // ✅ prevents newline on Enter
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Ask Aiko anything...',
                              hintStyle: TextStyle(
                                color: Colors.white.withOpacity(0.3),
                                fontSize: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.white.withOpacity(0.1),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.white.withOpacity(0.1),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Colors.purpleAccent,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.04),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                            ),
                            onSubmitted: (_) =>
                                _sendMessage(ctrl), // ✅ fallback
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _sendMessage(ctrl),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.purpleAccent.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.purpleAccent.withOpacity(0.4),
                          ),
                        ),
                        child: ctrl.isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.purpleAccent,
                                ),
                              )
                            : const Icon(
                                Icons.send,
                                color: Colors.purpleAccent,
                                size: 18,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
/// 💬 CHAT CONTENT
//////////////////////////////////////////////////////////////

class _ChatContent extends StatelessWidget {
  final AiAssistantController ctrl;
  final ScrollController scrollCtrl;
  const _ChatContent({required this.ctrl, required this.scrollCtrl});

  void _copy(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('✅ Copied!'),
        backgroundColor: Colors.deepPurple,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollCtrl,
      padding: const EdgeInsets.all(12),
      itemCount: ctrl.messages.length + (ctrl.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == ctrl.messages.length) return const _TypingIndicator();
        final msg = ctrl.messages[index];
        final isUser = msg.isUser;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: isUser
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isUser) ...[
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.purpleAccent.withOpacity(0.4),
                      width: 1.5,
                    ),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/aiko_avatar.png',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.purpleAccent.withOpacity(0.2),
                        child: const Center(
                          child: Text(
                            'A',
                            style: TextStyle(
                              color: Colors.purpleAccent,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Column(
                  crossAxisAlignment: isUser
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isUser
                            ? Colors.purpleAccent.withOpacity(0.2)
                            : Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(14),
                          topRight: const Radius.circular(14),
                          bottomLeft: Radius.circular(isUser ? 14 : 4),
                          bottomRight: Radius.circular(isUser ? 4 : 14),
                        ),
                        border: Border.all(
                          color: isUser
                              ? Colors.purpleAccent.withOpacity(0.3)
                              : Colors.white.withOpacity(0.06),
                        ),
                      ),
                      child: Text(
                        msg.text,
                        softWrap: true,
                        overflow: TextOverflow.visible,
                        style: TextStyle(
                          color: isUser
                              ? Colors.white
                              : Colors.white.withOpacity(0.9),
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ),
                    if (!isUser)
                      GestureDetector(
                        onTap: () => _copy(context, msg.text),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 3, left: 2),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.copy,
                                size: 11,
                                color: Colors.white.withOpacity(0.25),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                'Copy',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.25),
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

//////////////////////////////////////////////////////////////
/// ⌛ TYPING INDICATOR
//////////////////////////////////////////////////////////////

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();
  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.purpleAccent.withOpacity(0.4),
              width: 1.5,
            ),
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/aiko_avatar.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.purpleAccent.withOpacity(0.2),
                child: const Center(
                  child: Text(
                    'A',
                    style: TextStyle(
                      color: Colors.purpleAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(14),
          ),
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) => Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                final b = sin((_ctrl.value * 2 * pi) - (i * 0.5));
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.purpleAccent.withOpacity(
                      0.4 + 0.6 * ((b + 1) / 2),
                    ),
                  ),
                  transform: Matrix4.translationValues(
                    0,
                    -3 * ((b + 1) / 2),
                    0,
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    ),
  );
}

//////////////////////////////////////////////////////////////
/// ✨ PROMPT HELPER
//////////////////////////////////////////////////////////////

class _PromptHelperContent extends StatefulWidget {
  final AiAssistantController ctrl;
  const _PromptHelperContent({required this.ctrl});
  @override
  State<_PromptHelperContent> createState() => _PromptHelperContentState();
}

class _PromptHelperContentState extends State<_PromptHelperContent> {
  final TextEditingController _promptCtrl = TextEditingController();
  final TextEditingController _improvedCtrl = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _promptCtrl.addListener(() {
      final h = _promptCtrl.text.trim().isNotEmpty;
      if (h != _hasText) setState(() => _hasText = h);
    });
    widget.ctrl.addListener(_onCtrlChanged);
  }

  void _onCtrlChanged() {
    if (widget.ctrl.improvedPrompt != null &&
        _improvedCtrl.text != widget.ctrl.improvedPrompt) {
      setState(() => _improvedCtrl.text = widget.ctrl.improvedPrompt!);
    }
  }

  @override
  void dispose() {
    widget.ctrl.removeListener(_onCtrlChanged);
    _promptCtrl.dispose();
    _improvedCtrl.dispose();
    super.dispose();
  }

  void _copy(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('✅ Copied to clipboard!'),
        backgroundColor: Colors.deepPurple,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = widget.ctrl;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '✨ Prompt Helper',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _promptCtrl,
            maxLines: 4,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Type your prompt here...',
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.3),
                fontSize: 13,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.purpleAccent),
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.04),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 12),
          _LiquidButton(
            label: ctrl.isLoading ? 'Improving...' : 'Improve My Prompt',
            icon: ctrl.isLoading ? null : Icons.auto_fix_high,
            isLoading: ctrl.isLoading,
            disabled: ctrl.isLoading || !_hasText,
            onTap: () => ctrl.improvePrompt(_promptCtrl.text.trim()),
          ),
          if (ctrl.improvedPrompt != null &&
              ctrl.improvedPrompt!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '✨ Improved:',
                  style: TextStyle(
                    color: Colors.purpleAccent.withOpacity(0.9),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                GestureDetector(
                  onTap: () => _copy(context, _improvedCtrl.text),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.purpleAccent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.purpleAccent.withOpacity(0.4),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.copy, size: 13, color: Colors.purpleAccent),
                        SizedBox(width: 4),
                        Text(
                          'Copy',
                          style: TextStyle(
                            color: Colors.purpleAccent,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _improvedCtrl,
              maxLines: null,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                height: 1.5,
              ),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.purpleAccent.withOpacity(0.3),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.purpleAccent.withOpacity(0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.purpleAccent),
                ),
                filled: true,
                fillColor: Colors.purpleAccent.withOpacity(0.08),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ],
          if (ctrl.errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              ctrl.errorMessage!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
/// 🔍 IMAGE ANALYZER
//////////////////////////////////////////////////////////////

class _ImageAnalyzerContent extends StatelessWidget {
  final AiAssistantController ctrl;
  final GeneratorController genCtrl;
  const _ImageAnalyzerContent({required this.ctrl, required this.genCtrl});

  void _copy(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('✅ Copied!'),
        backgroundColor: Colors.deepPurple,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🔍 Image Analyzer',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          if (genCtrl.imageBytes != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.memory(
                genCtrl.imageBytes!,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 12),
            _LiquidButton(
              label: ctrl.isLoading ? 'Analyzing...' : 'Analyze Image',
              icon: ctrl.isLoading ? null : Icons.search,
              isLoading: ctrl.isLoading,
              disabled: ctrl.isLoading,
              onTap: () => ctrl.analyzeImage(genCtrl.imageBytes!),
              color: const Color(0xFF4338CA),
            ),
            if (ctrl.imageAnalysis != null) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Aiko says:',
                    style: TextStyle(
                      color: Colors.purpleAccent.withOpacity(0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _copy(context, ctrl.imageAnalysis!),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.purpleAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: Colors.purpleAccent.withOpacity(0.3),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.copy,
                            size: 11,
                            color: Colors.purpleAccent,
                          ),
                          SizedBox(width: 3),
                          Text(
                            'Copy',
                            style: TextStyle(
                              color: Colors.purpleAccent,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.purpleAccent.withOpacity(0.2),
                  ),
                ),
                child: Text(
                  ctrl.imageAnalysis!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ] else
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.image_outlined,
                      size: 48,
                      color: Colors.white.withOpacity(0.15),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Generate an image first\nthen analyze it here',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.3),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (ctrl.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                ctrl.errorMessage!,
                style: const TextStyle(color: Colors.redAccent, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
/// 💧 LIQUID BUTTON
//////////////////////////////////////////////////////////////

class _LiquidButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final bool isLoading, disabled;
  final VoidCallback onTap;
  final Color color;
  const _LiquidButton({
    required this.label,
    required this.onTap,
    this.icon,
    this.isLoading = false,
    this.disabled = false,
    this.color = Colors.deepPurple,
  });
  @override
  State<_LiquidButton> createState() => _LiquidButtonState();
}

class _LiquidButtonState extends State<_LiquidButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _ripple;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _ripple = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTap() {
    if (widget.disabled) return;
    _ctrl.forward(from: 0);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        _onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedBuilder(
        animation: _ripple,
        builder: (_, __) => AnimatedScale(
          scale: _pressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: Container(
            width: double.infinity,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: widget.disabled
                  ? LinearGradient(
                      colors: [
                        widget.color.withOpacity(0.3),
                        widget.color.withOpacity(0.2),
                      ],
                    )
                  : LinearGradient(
                      begin: Alignment(-1 + _ripple.value * 2, -0.5),
                      end: Alignment(1 + _ripple.value * 2, 0.5),
                      colors: [
                        widget.color,
                        Color.lerp(
                          widget.color,
                          Colors.purpleAccent,
                          0.5 + 0.5 * _ripple.value,
                        )!,
                        widget.color,
                      ],
                    ),
              boxShadow: widget.disabled
                  ? []
                  : [
                      BoxShadow(
                        color: widget.color.withOpacity(
                          0.4 * (1 - _ripple.value * 0.5),
                        ),
                        blurRadius: 12,
                        spreadRadius: -2,
                      ),
                    ],
            ),
            child: Center(
              child: widget.isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(widget.icon, size: 16, color: Colors.white),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          widget.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
/// 🔘 MODE TAB
//////////////////////////////////////////////////////////////

class _ModeTab extends StatelessWidget {
  final String label;
  final AiMode mode;
  final AiAssistantController ctrl;
  const _ModeTab({required this.label, required this.mode, required this.ctrl});
  @override
  Widget build(BuildContext context) {
    final active = ctrl.mode == mode;
    return GestureDetector(
      onTap: () => ctrl.setMode(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(left: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: active
              ? Colors.purpleAccent.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: active
                ? Colors.purpleAccent.withOpacity(0.5)
                : Colors.transparent,
          ),
        ),
        child: Text(label, style: const TextStyle(fontSize: 14)),
      ),
    );
  }
}
