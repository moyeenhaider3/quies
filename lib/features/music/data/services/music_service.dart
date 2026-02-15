import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/music_preview.dart';
import '../genre_mapping.dart';

/// Fetches music previews from the iTunes Search API.
@lazySingleton
class MusicService {
  final Dio _dio;

  MusicService(this._dio);

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
  /// Filters out tracks whose IDs are in [excludeTrackIds] for uniqueness.
  Future<MusicPreview> fetchMusic(
    String keyword, {
    Set<int> excludeTrackIds = const {},
  }) async {
    try {
      final response = await _dio.get(
        'https://itunes.apple.com/search',
        queryParameters: {
          'term': keyword,
          'media': 'music',
          'entity': 'song',
          'limit': 20,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch music: ${response.statusCode}');
      }

      final data = response.data as Map<String, dynamic>;
      final resultCount = data['resultCount'] as int? ?? 0;

      if (resultCount == 0) {
        throw Exception('No music found for "$keyword"');
      }

      final results = data['results'] as List<dynamic>;

      // Filter to tracks with valid preview
      final validResults = results
          .cast<Map<String, dynamic>>()
          .where(
            (item) =>
                item['previewUrl'] != null &&
                (item['previewUrl'] as String).isNotEmpty,
          )
          .toList();

      if (validResults.isEmpty) {
        throw Exception('No preview available for "$keyword"');
      }

      // Find first track not in exclusion set
      final selectedTrack = validResults.firstWhere(
        (item) => !excludeTrackIds.contains(item['trackId'] as int?),
        orElse: () => validResults.first, // Fallback: reuse if pool exhausted
      );

      return MusicPreview.fromJson(selectedTrack);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        throw Exception('No internet connection');
      }
      throw Exception('Network error: ${e.message}');
    }
  }
}
