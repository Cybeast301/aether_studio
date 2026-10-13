import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthUser {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final String provider;

  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.provider,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
    id: json['id'],
    name: json['name'],
    email: json['email'],
    avatarUrl: json['avatar_url'],
    provider: json['provider'],
  );
}

class AuthService extends ChangeNotifier {
  AuthService._();
  static final AuthService instance = AuthService._();

  static const String _baseUrl = 'https://aether-backend-c894.onrender.com';

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'auth_user';

  AuthUser? _user;
  String? _token;
  bool _isLoading = false;

  AuthUser? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null && _token != null;

  // ─────────────────────────────────────────────────────────
  // Load saved session
  // ─────────────────────────────────────────────────────────
  Future<void> loadSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      final userJson = prefs.getString(_userKey);
      if (token != null && userJson != null) {
        _token = token;
        _user = AuthUser.fromJson(jsonDecode(userJson));
        notifyListeners();
        await _verifyToken();
      }
    } catch (e) {
      debugPrint('Session load error: $e');
      await logout();
    }
  }

  Future<void> _verifyToken() async {
    try {
      final res = await http
          .get(Uri.parse('$_baseUrl/auth/me'), headers: _authHeaders)
          .timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) await logout();
    } catch (_) {}
  }

  // ─────────────────────────────────────────────────────────
  // 📧 Register
  // ─────────────────────────────────────────────────────────
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await http
          .post(
            Uri.parse('$_baseUrl/auth/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'name': name,
              'email': email,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        await _handleAuthResponse(res.body);
      } else {
        final error = jsonDecode(res.body);
        throw Exception(error['detail'] ?? 'Registration failed');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────────────────
  // 🔑 Login
  // ─────────────────────────────────────────────────────────
  Future<void> login({required String email, required String password}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await http
          .post(
            Uri.parse('$_baseUrl/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        await _handleAuthResponse(res.body);
      } else {
        final error = jsonDecode(res.body);
        throw Exception(error['detail'] ?? 'Login failed');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────────────────
  // 🔵 Google Sign-In
  // ─────────────────────────────────────────────────────────
  Future<void> googleSignIn(String firebaseToken) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await http
          .post(
            Uri.parse('$_baseUrl/auth/google'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'firebase_token': firebaseToken}),
          )
          .timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        await _handleAuthResponse(res.body);
      } else {
        final error = jsonDecode(res.body);
        throw Exception(error['detail'] ?? 'Google sign-in failed');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────────────────
  // 🚪 Logout
  // ─────────────────────────────────────────────────────────
  Future<void> logout() async {
    _user = null;
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────
  Future<void> _handleAuthResponse(String body) async {
    final data = jsonDecode(body);
    _token = data['access_token'];
    _user = AuthUser.fromJson(data['user']);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, _token!);
    await prefs.setString(_userKey, jsonEncode(data['user']));
    notifyListeners();
  }

  Map<String, String> get _authHeaders => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $_token',
  };
}
