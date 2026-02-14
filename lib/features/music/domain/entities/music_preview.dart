import 'package:equatable/equatable.dart';

/// Represents a music preview track from the iTunes Search API.
class MusicPreview extends Equatable {
  final int trackId;
  final String trackName;
  final String artistName;
  final String previewUrl;
  final String artworkUrl;
  final String genre;

  const MusicPreview({
    required this.trackId,
    required this.trackName,
    required this.artistName,
    required this.previewUrl,
    required this.artworkUrl,
    required this.genre,
  });

  factory MusicPreview.fromJson(Map<String, dynamic> json) {
    return MusicPreview(
      trackId: json['trackId'] ?? 0,
      trackName: json['trackName'] ?? '',
      artistName: json['artistName'] ?? '',
      previewUrl: json['previewUrl'] ?? '',
      artworkUrl: json['artworkUrl100'] ?? '',
      genre: json['primaryGenreName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trackId': trackId,
      'trackName': trackName,
      'artistName': artistName,
      'previewUrl': previewUrl,
      'artworkUrl100': artworkUrl,
      'primaryGenreName': genre,
    };
  }

  @override
  List<Object?> get props => [
    trackId,
    trackName,
    artistName,
    previewUrl,
    artworkUrl,
    genre,
  ];
}
