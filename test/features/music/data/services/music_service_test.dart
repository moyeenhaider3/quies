import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:quies/features/music/data/services/music_service.dart';

void main() {
  group('MusicService', () {
    test('fetchMusic returns MusicPreview on valid response', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          json.encode({
            'resultCount': 1,
            'results': [
              {
                'trackId': 123,
                'trackName': 'Calm Song',
                'artistName': 'Test Artist',
                'previewUrl': 'https://audio.example.com/preview.mp3',
                'artworkUrl100': 'https://img.example.com/art.jpg',
                'primaryGenreName': 'Ambient',
              },
            ],
          }),
          200,
        );
      });

      final service = MusicService(mockClient);
      final preview = await service.fetchMusic('calm ambient');

      expect(preview.trackId, 123);
      expect(preview.trackName, 'Calm Song');
      expect(preview.previewUrl, 'https://audio.example.com/preview.mp3');
    });

    test('fetchMusic throws on empty results', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          json.encode({'resultCount': 0, 'results': []}),
          200,
        );
      });

      final service = MusicService(mockClient);

      expect(() => service.fetchMusic('nonexistent'), throwsException);
    });

    test('fetchMusic skips results without previewUrl', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          json.encode({
            'resultCount': 2,
            'results': [
              {
                'trackId': 1,
                'trackName': 'No Preview',
                'artistName': 'Artist 1',
                'previewUrl': null,
                'artworkUrl100': 'https://img.example.com/1.jpg',
                'primaryGenreName': 'Pop',
              },
              {
                'trackId': 2,
                'trackName': 'Has Preview',
                'artistName': 'Artist 2',
                'previewUrl': 'https://audio.example.com/2.mp3',
                'artworkUrl100': 'https://img.example.com/2.jpg',
                'primaryGenreName': 'Pop',
              },
            ],
          }),
          200,
        );
      });

      final service = MusicService(mockClient);
      final preview = await service.fetchMusic('test');

      expect(preview.trackId, 2);
      expect(preview.trackName, 'Has Preview');
    });

    test('fetchMusic throws when all results lack previewUrl', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          json.encode({
            'resultCount': 2,
            'results': [
              {
                'trackId': 1,
                'trackName': 'No Preview 1',
                'artistName': 'Artist',
                'previewUrl': null,
              },
              {
                'trackId': 2,
                'trackName': 'No Preview 2',
                'artistName': 'Artist',
                'previewUrl': null,
              },
            ],
          }),
          200,
        );
      });

      final service = MusicService(mockClient);

      expect(() => service.fetchMusic('test'), throwsException);
    });

    test('fetchMusic throws on non-200 status', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Server Error', 500);
      });

      final service = MusicService(mockClient);

      expect(() => service.fetchMusic('test'), throwsException);
    });

    test('fetchMusicForGenre uses correct keyword', () async {
      String? capturedQuery;
      final mockClient = MockClient((request) async {
        capturedQuery = request.url.queryParameters['term'];
        return http.Response(
          json.encode({
            'resultCount': 1,
            'results': [
              {
                'trackId': 1,
                'trackName': 'Test',
                'artistName': 'Artist',
                'previewUrl': 'https://example.com/audio.mp3',
                'artworkUrl100': '',
                'primaryGenreName': '',
              },
            ],
          }),
          200,
        );
      });

      final service = MusicService(mockClient);
      await service.fetchMusicForGenre('inspirational');

      expect(capturedQuery, 'motivational instrumental');
    });

    test('fetchMusicForGenre throws on unsupported genre', () {
      final mockClient = MockClient((request) async {
        return http.Response('', 200);
      });

      final service = MusicService(mockClient);

      expect(
        () => service.fetchMusicForGenre('nonexistent_genre'),
        throwsException,
      );
    });
  });
}
