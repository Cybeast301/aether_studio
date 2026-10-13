import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aether_studio/features/auth/auth_service.dart';

class HistoryEntry {
  final String id;
  final Uint8List imageBytes;
  final Uint8List? bgRemovedBytes;
  final String prompt;
  final String style;
  final String aspectRatio;
  final DateTime createdAt;
  final String imageUrl;
  final String? bgRemovedUrl;
  final bool isSynced;

  const HistoryEntry({
    required this.id,
    required this.imageBytes,
    this.bgRemovedBytes,
    required this.prompt,
    required this.style,
    required this.aspectRatio,
    required this.createdAt,
    required this.imageUrl,
    this.bgRemovedUrl,
    this.isSynced = false,
  });

  HistoryEntry copyWithBgRemoved(Uint8List bgRemoved, String bgUrl) {
    return HistoryEntry(
      id: id,
      imageBytes: imageBytes,
      bgRemovedBytes: bgRemoved,
      prompt: prompt,
      style: style,
      aspectRatio: aspectRatio,
      createdAt: createdAt,
      imageUrl: imageUrl,
      bgRemovedUrl: bgUrl,
      isSynced: isSynced,
    );
  }

  HistoryEntry copyAsSynced() {
    return HistoryEntry(
      id: id,
      imageBytes: imageBytes,
      bgRemovedBytes: bgRemovedBytes,
      prompt: prompt,
      style: style,
      aspectRatio: aspectRatio,
      createdAt: createdAt,
      imageUrl: imageUrl,
      bgRemovedUrl: bgRemovedUrl,
      isSynced: true,
    );
  }
}

class HistoryController extends ChangeNotifier {
  final List<HistoryEntry> _entries = [];
  final _supabase = Supabase.instance.client;

  List<HistoryEntry> get entries => List.unmodifiable(_entries);
  bool get isEmpty => _entries.isEmpty;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // ── Current logged-in user id ────────────────────────────
  String? get _userId => AuthService.instance.user?.id;

  Future<void> loadHistory() async {
    if (_userId == null) {
      debugPrint('⚠️ loadHistory: no user logged in');
      _entries.clear();
      notifyListeners();
      return;
    }

    debugPrint('📥 loadHistory: loading for user $_userId');
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _supabase
          .from('history')
          .select()
          .eq('user_id', _userId!)
          .order('created_at', ascending: false)
          .limit(50)
          .timeout(const Duration(seconds: 15));

      debugPrint('📊 Found ${data.length} rows in DB for user $_userId');
      _entries.clear();

      for (final row in data) {
        try {
          final imageUrl = row['image_url'] as String?;
          debugPrint('🖼️ Downloading: $imageUrl');
          if (imageUrl == null || imageUrl.isEmpty) continue;

          final imageBytes = await _supabase.storage
              .from('aether-images')
              .download(imageUrl)
              .timeout(const Duration(seconds: 20));

          debugPrint('✅ Downloaded: $imageUrl (${imageBytes.length} bytes)');

          Uint8List? bgBytes;
          final bgUrl = row['bg_removed_url'] as String?;
          if (bgUrl != null && bgUrl.isNotEmpty) {
            try {
              bgBytes = await _supabase.storage
                  .from('aether-images')
                  .download(bgUrl)
                  .timeout(const Duration(seconds: 20));
            } catch (_) {
              bgBytes = null;
            }
          }

          _entries.add(
            HistoryEntry(
              id: row['id'] as String? ?? '',
              imageBytes: imageBytes,
              bgRemovedBytes: bgBytes,
              prompt: row['prompt'] as String? ?? '',
              style: row['style'] as String? ?? '',
              aspectRatio: row['aspect_ratio'] as String? ?? '',
              createdAt: row['created_at'] != null
                  ? DateTime.parse(row['created_at'] as String)
                  : DateTime.now(),
              imageUrl: imageUrl,
              bgRemovedUrl: bgUrl,
              isSynced: true,
            ),
          );
        } catch (e) {
          debugPrint('❌ Skipping entry: $e');
          continue;
        }
      }
      debugPrint('✅ loadHistory done: ${_entries.length} entries loaded');
    } catch (e) {
      debugPrint('❌ loadHistory error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // ✅ LOCAL FIRST — shows instantly, syncs in background
  Future<void> addEntry({
    required Uint8List imageBytes,
    required String prompt,
    required String style,
    required String aspectRatio,
  }) async {
    if (_userId == null) {
      debugPrint('⚠️ Not logged in — history not saved');
      return;
    }

    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final imagePath = 'images/$_userId/$id.png'; // ✅ per-user folder

    final entry = HistoryEntry(
      id: id,
      imageBytes: imageBytes,
      prompt: prompt,
      style: style,
      aspectRatio: aspectRatio,
      createdAt: DateTime.now(),
      imageUrl: imagePath,
      isSynced: false,
    );

    // Show instantly
    _entries.insert(0, entry);
    notifyListeners();

    // Sync in background
    _syncToSupabase(entry, imageBytes, imagePath);
  }

  Future<void> _syncToSupabase(
    HistoryEntry entry,
    Uint8List imageBytes,
    String imagePath,
  ) async {
    for (int attempt = 1; attempt <= 3; attempt++) {
      try {
        debugPrint('Supabase sync attempt $attempt...');

        await _supabase.storage
            .from('aether-images')
            .uploadBinary(imagePath, imageBytes)
            .timeout(const Duration(seconds: 60));

        await _supabase
            .from('history')
            .insert({
              'id': entry.id,
              'user_id': _userId, // ✅ tag with user
              'prompt': entry.prompt,
              'style': entry.style,
              'aspect_ratio': entry.aspectRatio,
              'image_url': imagePath,
              'created_at': entry.createdAt.toIso8601String(),
            })
            .timeout(const Duration(seconds: 15));

        final index = _entries.indexWhere((e) => e.id == entry.id);
        if (index != -1) {
          _entries[index] = _entries[index].copyAsSynced();
          notifyListeners();
        }
        debugPrint('✅ Synced to Supabase!');
        return;
      } catch (e) {
        debugPrint('Sync attempt $attempt failed: $e');
        if (attempt < 3) await Future.delayed(Duration(seconds: attempt * 2));
      }
    }
    debugPrint('⚠️ Sync failed after 3 attempts');
  }

  Future<void> updateBgRemoved(String id, Uint8List bgRemoved) async {
    final bgPath = 'images/$_userId/${id}_nobg.png'; // ✅ per-user folder

    final index = _entries.indexWhere((e) => e.id == id);
    if (index != -1) {
      _entries[index] = _entries[index].copyWithBgRemoved(bgRemoved, bgPath);
      notifyListeners();
    }

    try {
      await _supabase.storage
          .from('aether-images')
          .uploadBinary(bgPath, bgRemoved)
          .timeout(const Duration(seconds: 60));

      await _supabase
          .from('history')
          .update({'bg_removed_url': bgPath})
          .eq('id', id)
          .timeout(const Duration(seconds: 15));
    } catch (e) {
      debugPrint('Error syncing bg removed: $e');
    }
  }

  Future<void> deleteEntry(String id) async {
    final index = _entries.indexWhere((e) => e.id == id);
    if (index == -1) return;
    final entry = _entries[index];
    _entries.removeAt(index);
    notifyListeners();

    try {
      await _supabase.storage.from('aether-images').remove([entry.imageUrl]);
      if (entry.bgRemovedUrl != null) {
        await _supabase.storage.from('aether-images').remove([
          entry.bgRemovedUrl!,
        ]);
      }
      await _supabase.from('history').delete().eq('id', id);
    } catch (e) {
      debugPrint('Error deleting from Supabase: $e');
    }
  }

  Future<void> clearAll() async {
    if (_userId == null) return;

    final paths = _entries.map((e) => e.imageUrl).toList();
    final bgPaths = _entries
        .where((e) => e.bgRemovedUrl != null)
        .map((e) => e.bgRemovedUrl!)
        .toList();

    _entries.clear();
    notifyListeners();

    try {
      if (paths.isNotEmpty)
        await _supabase.storage.from('aether-images').remove(paths);
      if (bgPaths.isNotEmpty)
        await _supabase.storage.from('aether-images').remove(bgPaths);
      // ✅ Only delete THIS user's history
      await _supabase.from('history').delete().eq('user_id', _userId!);
    } catch (e) {
      debugPrint('Error clearing Supabase: $e');
    }
  }

  // ✅ Call this on logout to wipe local cache
  void clearLocal() {
    _entries.clear();
    notifyListeners();
  }
}
