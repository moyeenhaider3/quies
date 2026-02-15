import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quies/features/music/data/services/music_service.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;
  late MusicService service;

  setUp(() {
    mockDio = MockDio();
    service = MusicService(mockDio);
  });

  group('MusicService', () {
    test('fetchMusic returns MusicPreview on valid response', () async {
      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenAnswer(
        (_) async => Response(
          data: {
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
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: '/search'),
        ),
      );

      final preview = await service.fetchMusic('calm ambient');

      expect(preview.trackId, 123);
      expect(preview.trackName, 'Calm Song');
      expect(preview.previewUrl, 'https://audio.example.com/preview.mp3');
    });

    test('fetchMusic throws on empty results', () async {
      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenAnswer(
        (_) async => Response(
          data: {'resultCount': 0, 'results': []},
          statusCode: 200,
          requestOptions: RequestOptions(path: '/search'),
        ),
      );

      expect(() => service.fetchMusic('nonexistent'), throwsException);
    });

    test('fetchMusic skips results without previewUrl', () async {
      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenAnswer(
        (_) async => Response(
          data: {
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
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: '/search'),
        ),
      );

      final preview = await service.fetchMusic('test');

      expect(preview.trackId, 2);
      expect(preview.trackName, 'Has Preview');
    });

    test('fetchMusic throws when all results lack previewUrl', () async {
      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenAnswer(
        (_) async => Response(
          data: {
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
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: '/search'),
        ),
      );

      expect(() => service.fetchMusic('test'), throwsException);
    });

    test('fetchMusic throws on non-200 status', () async {
      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenAnswer(
        (_) async => Response(
          data: 'Server Error',
          statusCode: 500,
          requestOptions: RequestOptions(path: '/search'),
        ),
      );

      expect(() => service.fetchMusic('test'), throwsException);
    });

    test('fetchMusicForGenre uses correct keyword', () async {
      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenAnswer(
        (_) async => Response(
          data: {
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
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: '/search'),
        ),
      );

      await service.fetchMusicForGenre('inspirational');

      final captured = verify(
        () => mockDio.get(
          captureAny(),
          queryParameters: captureAny(named: 'queryParameters'),
        ),
      ).captured;
      final queryParams = captured[1] as Map<String, dynamic>;
      expect(queryParams['term'], 'motivational instrumental');
    });

    test('fetchMusicForGenre throws on unsupported genre', () {
      expect(
        () => service.fetchMusicForGenre('nonexistent_genre'),
        throwsException,
      );
    });
  });
}
