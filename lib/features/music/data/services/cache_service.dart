import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';

import '../../../quotes/data/models/remote_quote_model.dart';
import '../../domain/entities/music_preview.dart';

/// Cached result containing both a quote and music preview.
class CachedResult {
  final RemoteQuote quote;
  final MusicPreview music;
  final DateTime cachedAt;

  const CachedResult({
    required this.quote,
    required this.music,
    required this.cachedAt,
  });

  Map<String, dynamic> toJson() => {
    'quote': quote.toJson(),
    'music': music.toJson(),
    'cachedAt': cachedAt.toIso8601String(),
  };

  factory CachedResult.fromJson(Map<String, dynamic> json) {
    return CachedResult(
      quote: RemoteQuote.fromJson(json['quote'] as Map<String, dynamic>),
      music: MusicPreview.fromJson(json['music'] as Map<String, dynamic>),
      cachedAt: DateTime.parse(json['cachedAt'] as String),
    );
  }
}

/// Hive-backed cache for combined quote+music results per genre.
@lazySingleton
class CacheService {
  final Box<dynamic> _box;

  CacheService(@Named('userBox') this._box);

  static String _key(String genre) => 'cached_result_$genre';

  /// Cache a quote+music result for the given [genre].
  Future<void> cacheResult(
    String genre,
    RemoteQuote quote,
    MusicPreview music,
  ) async {
    final cached = CachedResult(
      quote: quote,
      music: music,
      cachedAt: DateTime.now(),
    );
    await _box.put(_key(genre), json.encode(cached.toJson()));
  }

  /// Retrieve cached result for the given [genre], or null if none exists.
  CachedResult? getCachedResult(String genre) {
    final raw = _box.get(_key(genre));
    if (raw == null) return null;

    try {
      final data = json.decode(raw as String) as Map<String, dynamic>;
      return CachedResult.fromJson(data);
    } catch (_) {
      return null;
    }
  }
}
