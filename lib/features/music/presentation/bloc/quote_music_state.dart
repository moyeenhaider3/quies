import 'package:equatable/equatable.dart';

import '../../../quotes/data/models/remote_quote_model.dart';
import '../../domain/entities/music_preview.dart';

sealed class QuoteMusicState extends Equatable {
  const QuoteMusicState();

  @override
  List<Object?> get props => [];
}

/// No genre selected yet.
class QuoteMusicInitial extends QuoteMusicState {
  const QuoteMusicInitial();
}

/// Fetching quote + music in progress.
class QuoteMusicLoading extends QuoteMusicState {
  final String genre;

  const QuoteMusicLoading(this.genre);

  @override
  List<Object?> get props => [genre];
}

/// Successfully loaded quote + music.
class QuoteMusicLoaded extends QuoteMusicState {
  final RemoteQuote quote;
  final MusicPreview music;
  final String genre;

  const QuoteMusicLoaded({
    required this.quote,
    required this.music,
    required this.genre,
  });

  @override
  List<Object?> get props => [quote, music, genre];
}

/// Error state — may contain cached data for fallback display.
class QuoteMusicError extends QuoteMusicState {
  final String message;
  final String? genre;
  final RemoteQuote? cachedQuote;
  final MusicPreview? cachedMusic;

  const QuoteMusicError({
    required this.message,
    this.genre,
    this.cachedQuote,
    this.cachedMusic,
  });

  bool get hasCachedData => cachedQuote != null && cachedMusic != null;

  @override
  List<Object?> get props => [message, genre, cachedQuote, cachedMusic];
}
