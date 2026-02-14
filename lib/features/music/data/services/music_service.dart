import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';

import '../../domain/entities/music_preview.dart';
import '../genre_mapping.dart';

/// Fetches music previews from the iTunes Search API.
@lazySingleton
class MusicService {
  final http.Client _client;

  MusicService(this._client);

  /// Fetches a music preview for the given [genre].
  /// Uses [genreMusicMap] for primary keyword, falls back to [fallbackMusicMap].
  Future<MusicPreview> fetchMusicForGenre(String genre) async {
    final keyword = genreMusicMap[genre];
    if (keyword == null) {
      throw Exception('Unsupported genre: $genre');
    }

    try {
      return await fetchMusic(keyword);
    } catch (_) {
      // Try fallback keyword
      final fallback = fallbackMusicMap[genre];
      if (fallback != null) {
        return await fetchMusic(fallback);
      }
      rethrow;
    }
  }

  /// Fetches a music preview by search [keyword] from iTunes.
  /// Validates that at least one result has a non-null previewUrl.
  Future<MusicPreview> fetchMusic(String keyword) async {
    final encodedKeyword = Uri.encodeComponent(keyword);
    final url = Uri.parse(
      'https://itunes.apple.com/search?term=$encodedKeyword&media=music&entity=song&limit=5',
    );

    try {
      final response = await _client
          .get(url)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch music: ${response.statusCode}');
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      final resultCount = data['resultCount'] as int? ?? 0;

      if (resultCount == 0) {
        throw Exception('No music found for "$keyword"');
      }

      final results = data['results'] as List<dynamic>;

      // Find first result with a valid previewUrl
      final validTrack = results.cast<Map<String, dynamic>>().firstWhere(
        (item) =>
            item['previewUrl'] != null &&
            (item['previewUrl'] as String).isNotEmpty,
        orElse: () => throw Exception('No preview available for "$keyword"'),
      );

      return MusicPreview.fromJson(validTrack);
    } on SocketException {
      throw Exception('No internet connection');
    } on HttpException {
      throw Exception('HTTP error');
    } on FormatException {
      throw Exception('Invalid response format');
    }
  }
}
