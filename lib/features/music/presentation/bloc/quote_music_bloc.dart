import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../quotes/data/datasources/quote_remote_data_source.dart';
import '../../data/genre_mapping.dart';
import '../../data/services/cache_service.dart';
import '../../data/services/music_service.dart';
import 'quote_music_event.dart';
import 'quote_music_state.dart';

@injectable
class QuoteMusicBloc extends Bloc<QuoteMusicEvent, QuoteMusicState> {
  final QuoteRemoteDataSource _remoteDataSource;
  final MusicService _musicService;
  final CacheService _cacheService;

  String? _currentGenre;

  QuoteMusicBloc(this._remoteDataSource, this._musicService, this._cacheService)
    : super(const QuoteMusicInitial()) {
    on<SelectGenre>(_onSelectGenre);
    on<RefreshContent>(_onRefreshContent);
    on<StopAudio>(_onStopAudio);
  }

  Future<void> _onSelectGenre(
    SelectGenre event,
    Emitter<QuoteMusicState> emit,
  ) async {
    _currentGenre = event.genre;
    emit(QuoteMusicLoading(event.genre));

    await _fetchContent(event.genre, emit);
  }

  Future<void> _onRefreshContent(
    RefreshContent event,
    Emitter<QuoteMusicState> emit,
  ) async {
    final genre = _currentGenre;
    if (genre == null) return;

    emit(QuoteMusicLoading(genre));
    await _fetchContent(genre, emit);
  }

  void _onStopAudio(StopAudio event, Emitter<QuoteMusicState> emit) {
    // Audio stop is handled by the UI widget.
    // This event is a signal for any bloc-level cleanup if needed.
  }

  Future<void> _fetchContent(
    String genre,
    Emitter<QuoteMusicState> emit,
  ) async {
    try {
      // Map genre to API tag
      final tag = genreQuoteTagMap[genre] ?? genre;

      // Fetch quote and music in parallel
      final results = await Future.wait([
        _remoteDataSource.fetchRandomQuotes(limit: 1, tags: tag),
        _musicService.fetchMusicForGenre(genre),
      ]);

      final quotes = results[0] as List;
      final quote = quotes.first;
      final music = results[1] as dynamic;

      // Cache the result
      await _cacheService.cacheResult(genre, quote, music);

      emit(QuoteMusicLoaded(quote: quote, music: music, genre: genre));
    } catch (e) {
      // Try cached fallback
      final cached = _cacheService.getCachedResult(genre);

      emit(
        QuoteMusicError(
          message: e.toString(),
          genre: genre,
          cachedQuote: cached?.quote,
          cachedMusic: cached?.music,
        ),
      );
    }
  }
}
