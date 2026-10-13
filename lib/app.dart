import 'package:aether_studio/core/services/aiko_rag_service.dart'
    hide debugPrint;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'features/generator/generator_controller.dart';
import 'features/generator/generator_page.dart';
import 'features/generator/history_controller.dart';
import 'features/generator/ai_assistant_controller.dart';
import 'features/generator/aiko_personality_service.dart';
import 'features/generator/theme_controller.dart';
import 'features/generator/prompt_history_controller.dart';
import 'features/auth/auth_service.dart';
import 'landing_page.dart';
import 'features/auth/auth_page.dart';
import 'splash_screen.dart';

class AetherStudioApp extends StatelessWidget {
  const AetherStudioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeController.instance),
        ChangeNotifierProvider(create: (_) => AuthService.instance),
        ChangeNotifierProvider(create: (_) => HistoryController()),
        ChangeNotifierProvider(create: (_) => AiAssistantController()),
        ChangeNotifierProvider(create: (_) => PromptHistoryController.instance),
        ChangeNotifierProxyProvider<HistoryController, GeneratorController>(
          create: (ctx) => GeneratorController(
            historyController: ctx.read<HistoryController>(),
          ),
          update: (ctx, history, prev) =>
              prev ?? GeneratorController(historyController: history),
        ),
      ],
      child: Consumer<ThemeController>(
        builder: (context, themeCtrl, _) {
          return MaterialApp(
            title: 'Aether Studio',
            debugShowCheckedModeBanner: false,
            theme: ThemeController.lightTheme,
            darkTheme: ThemeController.darkTheme,
            themeMode: themeCtrl.isDark ? ThemeMode.dark : ThemeMode.light,
            // ── Routing ──────────────────────────────────────
            initialRoute: '/',
            routes: {
              '/': (_) => const _RootRedirect(),
              '/auth': (_) => const AuthPage(),
              '/app': (_) => const _AppStartup(),
            },
          );
        },
      ),
    );
  }
}

// ── Root redirect — checks auth AFTER session is loaded ──────
class _RootRedirect extends StatefulWidget {
  const _RootRedirect();
  @override
  State<_RootRedirect> createState() => _RootRedirectState();
}

class _RootRedirectState extends State<_RootRedirect> {
  @override
  void initState() {
    super.initState();
    _redirect();
  }

  void _redirect() {
    // Session already loaded in main() — just check and redirect
    if (AuthService.instance.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pushReplacementNamed('/app');
      });
    }
    // Not logged in — LandingPage shows normally
  }

  @override
  Widget build(BuildContext context) => const LandingPage();
}

// ── App startup — loads all services then shows generator ────
class _AppStartup extends StatefulWidget {
  const _AppStartup();

  @override
  State<_AppStartup> createState() => _AppStartupState();
}

class _AppStartupState extends State<_AppStartup> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _loadEverything();
  }

  Future<void> _loadEverything() async {
    final userId = AuthService.instance.user?.id;
    debugPrint('🔄 Loading for user: $userId');

    await Future.wait([
      AikoPersonalityService.instance.load().catchError((_) {}),
      AikoRagService.instance.initialize().catchError((_) {}),
      context.read<HistoryController>().loadHistory().catchError((e) {
        debugPrint('History load error: $e');
      }),
      PromptHistoryController.instance.load().catchError((_) {}),
    ]);

    debugPrint(
      '✅ Loaded ${context.read<HistoryController>().entries.length} entries for $userId',
    );

    if (mounted) setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_ready) return const GeneratorPage();
    return SplashScreen(onComplete: () {}, isDataReady: _ready);
  }
}
