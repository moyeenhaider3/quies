import 'package:flutter_test/flutter_test.dart';
import 'package:quies/features/music/domain/entities/music_preview.dart';

void main() {
  group('MusicPreview', () {
    test('fromJson creates MusicPreview with valid data', () {
      final json = {
        'trackId': 12345,
        'trackName': 'Calm Waves',
        'artistName': 'Nature Sounds',
        'previewUrl': 'https://audio-ssl.itunes.apple.com/preview.mp3',
        'artworkUrl100': 'https://is5-ssl.mzstatic.com/image/thumb/100x100.jpg',
        'primaryGenreName': 'Ambient',
      };

      final preview = MusicPreview.fromJson(json);

      expect(preview.trackId, 12345);
      expect(preview.trackName, 'Calm Waves');
      expect(preview.artistName, 'Nature Sounds');
      expect(
        preview.previewUrl,
        'https://audio-ssl.itunes.apple.com/preview.mp3',
      );
      expect(
        preview.artworkUrl,
        'https://is5-ssl.mzstatic.com/image/thumb/100x100.jpg',
      );
      expect(preview.genre, 'Ambient');
    });

    test('fromJson handles null previewUrl gracefully', () {
      final json = {
        'trackId': 12345,
        'trackName': 'Test Song',
        'artistName': 'Test Artist',
        'previewUrl': null,
        'artworkUrl100': null,
        'primaryGenreName': null,
      };

      final preview = MusicPreview.fromJson(json);

      expect(preview.previewUrl, '');
      expect(preview.artworkUrl, '');
      expect(preview.genre, '');
    });

    test('fromJson handles missing fields with defaults', () {
      final json = <String, dynamic>{'trackId': null};

      final preview = MusicPreview.fromJson(json);

      expect(preview.trackId, 0);
      expect(preview.trackName, '');
      expect(preview.artistName, '');
      expect(preview.previewUrl, '');
    });

    test('toJson produces correct output', () {
      const preview = MusicPreview(
        trackId: 999,
        trackName: 'My Track',
        artistName: 'My Artist',
        previewUrl: 'https://example.com/audio.mp3',
        artworkUrl: 'https://example.com/art.jpg',
        genre: 'Pop',
      );

      final json = preview.toJson();

      expect(json['trackId'], 999);
      expect(json['trackName'], 'My Track');
      expect(json['artistName'], 'My Artist');
      expect(json['previewUrl'], 'https://example.com/audio.mp3');
      expect(json['artworkUrl100'], 'https://example.com/art.jpg');
      expect(json['primaryGenreName'], 'Pop');
    });

    test('fromJson/toJson round-trip preserves data', () {
      const original = MusicPreview(
        trackId: 42,
        trackName: 'Round Trip',
        artistName: 'Test Band',
        previewUrl: 'https://audio.example.com/test.mp3',
        artworkUrl: 'https://img.example.com/art.jpg',
        genre: 'Rock',
      );

      final json = original.toJson();
      final restored = MusicPreview.fromJson(json);

      expect(restored, original);
    });

    test('equality works correctly', () {
      const a = MusicPreview(
        trackId: 1,
        trackName: 'Song',
        artistName: 'Artist',
        previewUrl: 'url',
        artworkUrl: 'art',
        genre: 'Pop',
      );

      const b = MusicPreview(
        trackId: 1,
        trackName: 'Song',
        artistName: 'Artist',
        previewUrl: 'url',
        artworkUrl: 'art',
        genre: 'Pop',
      );

      const c = MusicPreview(
        trackId: 2,
        trackName: 'Song',
        artistName: 'Artist',
        previewUrl: 'url',
        artworkUrl: 'art',
        genre: 'Pop',
      );

      expect(a, b);
      expect(a, isNot(c));
    });
  });
}
