import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_service.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  bool _isSignIn = true, _obscure = true;
  String _error = '';
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _error = '');
    final auth = AuthService.instance;
    try {
      if (_isSignIn) {
        await auth.login(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text,
        );
      } else {
        await auth.register(
          name: _nameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text,
        );
      }
      if (mounted && auth.isLoggedIn)
        Navigator.pushReplacementNamed(context, '/app');
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFF04020F),
      body: Stack(
        children: [
          // Glow
          Positioned(
            top: -100,
            left: size.width / 2 - 300,
            child: AnimatedBuilder(
              animation: _pulseCtrl,
              builder: (_, __) => Container(
                width: 600,
                height: 600,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(
                        0xFF7c3aed,
                      ).withOpacity(0.12 + _pulseCtrl.value * 0.06),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo + back
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const RadialGradient(
                              colors: [Color(0xFFa855f7), Color(0xFF4a148c)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFa855f7).withOpacity(0.6),
                                blurRadius: 16,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        ShaderMask(
                          shaderCallback: (b) => const LinearGradient(
                            colors: [Color(0xFFa855f7), Color(0xFF6366f1)],
                          ).createShader(b),
                          child: const Text(
                            'AETHER',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\u2190 back to home',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.2),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Card
                  Container(
                    width: 440,
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: const Color(0xFF080514).withOpacity(0.85),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(0xFF7c3aed).withOpacity(0.25),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF7c3aed).withOpacity(0.12),
                          blurRadius: 60,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tabs
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              _Tab(
                                label: 'Sign In',
                                active: _isSignIn,
                                onTap: () => setState(() {
                                  _isSignIn = true;
                                  _error = '';
                                }),
                              ),
                              _Tab(
                                label: 'Sign Up',
                                active: !_isSignIn,
                                onTap: () => setState(() {
                                  _isSignIn = false;
                                  _error = '';
                                }),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Fields
                        if (!_isSignIn) ...[
                          _Field(
                            ctrl: _nameCtrl,
                            hint: 'Your name',
                            icon: Icons.person_outline_rounded,
                          ),
                          const SizedBox(height: 12),
                        ],
                        _Field(
                          ctrl: _emailCtrl,
                          hint: 'Email address',
                          icon: Icons.email_outlined,
                        ),
                        const SizedBox(height: 12),
                        _Field(
                          ctrl: _passCtrl,
                          hint: 'Password',
                          icon: Icons.lock_outline_rounded,
                          obscure: _obscure,
                          suffix: IconButton(
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: Colors.white.withOpacity(0.3),
                              size: 18,
                            ),
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                          ),
                        ),

                        // Error
                        if (_error.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.red.withOpacity(0.25),
                              ),
                            ),
                            child: Text(
                              _error,
                              style: TextStyle(
                                color: Colors.red.shade300,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),

                        // Submit button
                        SizedBox(
                          width: double.infinity,
                          child: GestureDetector(
                            onTap: auth.isLoading ? null : _submit,
                            child: AnimatedBuilder(
                              animation: _pulseCtrl,
                              builder: (_, __) => Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF7c3aed),
                                      Color(0xFF6366f1),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF7c3aed)
                                          .withOpacity(
                                            0.35 + _pulseCtrl.value * 0.15,
                                          ),
                                      blurRadius: 24 + _pulseCtrl.value * 12,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: auth.isLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(
                                          _isSignIn
                                              ? 'Sign In to Aether \u2192'
                                              : 'Create Account \u2192',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Hint text
                        Center(
                          child: Text(
                            _isSignIn
                                ? "Don't have an account? Sign up above"
                                : 'Already have an account? Sign in above',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.25),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _Tab({required this.label, required this.active, required this.onTap});
  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          gradient: active
              ? const LinearGradient(
                  colors: [Color(0xFF7c3aed), Color(0xFF6366f1)],
                )
              : null,
          borderRadius: BorderRadius.circular(10),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: const Color(0xFF7c3aed).withOpacity(0.35),
                    blurRadius: 14,
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: active ? Colors.white : Colors.white.withOpacity(0.35),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ),
  );
}

class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String hint;
  final IconData icon;
  final bool obscure;
  final Widget? suffix;
  const _Field({
    required this.ctrl,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.suffix,
  });
  @override
  Widget build(BuildContext context) => TextField(
    controller: ctrl,
    obscureText: obscure,
    style: const TextStyle(color: Colors.white, fontSize: 14),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 14),
      prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.3), size: 18),
      suffixIcon: suffix,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: const Color(0xFF7c3aed).withOpacity(0.2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: const Color(0xFF7c3aed).withOpacity(0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFa855f7)),
      ),
      filled: true,
      fillColor: const Color(0xFF7c3aed).withOpacity(0.06),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
    ),
  );
}
