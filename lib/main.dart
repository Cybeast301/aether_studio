import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:aether_studio/features/auth/auth_service.dart';
import 'package:aether_studio/features/generator/theme_controller.dart';
import 'firebase_options.dart';
import 'app.dart';

void main() async {
  // ✅ MUST be first before anything else
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize Supabase
  await Supabase.initialize(
    url: 'https://bnmmqaatucvmvlaaqfki.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJubW1xYWF0dWN2bXZsYWFxZmtpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzE5MTQxNjMsImV4cCI6MjA4NzQ5MDE2M30.C25KRexWgP3rp17x6q4td52QUS5HPYER1STIPvhW4LQ',
  );

  // ✅ Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await ThemeController.instance.loadTheme();

  // ✅ Load saved auth session
  await AuthService.instance.loadSession();

  runApp(const AetherStudioApp());
}
