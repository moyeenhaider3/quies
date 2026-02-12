import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../data/services/content_matching_service.dart';
import '../../../../data/services/user_preferences_service.dart';
import '../../domain/entities/feed_item.dart';
import '../../domain/entities/quote.dart';
import '../../domain/repositories/quote_repository.dart';

part 'feed_event.dart';
part 'feed_state.dart';

@injectable
class FeedBloc extends Bloc<FeedEvent, FeedState> {
  final QuoteRepository repository;
  final UserPreferencesService _prefsService;
  final ContentMatchingService _matchingService;

  /// Insert a breathing prompt every 5-7 quotes (randomized).
  static const _minQuotesBetweenPrompts = 5;
  static const _maxQuotesBetweenPrompts = 7;
  static final _promptRandom = Random();

  FeedBloc(this.repository, this._prefsService, this._matchingService)
    : super(FeedInitial()) {
    on<LoadFeed>(_onLoadFeed);
    on<ToggleLike>(_onToggleLike);
    on<ToggleBookmark>(_onToggleBookmark);
    on<ShareQuote>(_onShareQuote);
    on<ChangeMood>(_onChangeMood);
  }

  /// Interleave breathing prompts into a list of quotes.
  static List<FeedItem> _buildFeedItems(List<Quote> quotes) {
    final items = <FeedItem>[];
    var nextPromptAt =
        _minQuotesBetweenPrompts +
        _promptRandom.nextInt(
          _maxQuotesBetweenPrompts - _minQuotesBetweenPrompts + 1,
        );
    var quoteCount = 0;

    for (final quote in quotes) {
      items.add(QuoteFeedItem(quote));
      quoteCount++;

      if (quoteCount >= nextPromptAt && quoteCount < quotes.length) {
        items.add(const BreathingPromptItem());
        quoteCount = 0;
        nextPromptAt =
            _minQuotesBetweenPrompts +
            _promptRandom.nextInt(
              _maxQuotesBetweenPrompts - _minQuotesBetweenPrompts + 1,
            );
      }
    }

    return items;
  }

  Future<void> _onToggleLike(ToggleLike event, Emitter<FeedState> emit) async {
    final currentState = state;
    if (currentState is FeedLoaded) {
      final updatedLikes = Set<String>.from(currentState.likedIds);
      if (updatedLikes.contains(event.quoteId)) {
        updatedLikes.remove(event.quoteId);
      } else {
        updatedLikes.add(event.quoteId);
      }
      emit(currentState.copyWith(likedIds: updatedLikes));
    }
  }

  Future<void> _onToggleBookmark(
    ToggleBookmark event,
    Emitter<FeedState> emit,
  ) async {
    final currentState = state;
    if (currentState is FeedLoaded) {
      final updatedBookmarks = Set<String>.from(currentState.bookmarkedIds);
      if (updatedBookmarks.contains(event.quoteId)) {
        updatedBookmarks.remove(event.quoteId);
        await _prefsService.removeBookmark(event.quoteId);
      } else {
        updatedBookmarks.add(event.quoteId);
        await _prefsService.addBookmark(event.quoteId);
      }
      emit(currentState.copyWith(bookmarkedIds: updatedBookmarks));
    }
  }

  Future<void> _onShareQuote(ShareQuote event, Emitter<FeedState> emit) async {
    // Share handled at the UI layer via share_plus
  }

  Future<void> _onChangeMood(ChangeMood event, Emitter<FeedState> emit) async {
    await _prefsService.setMood(event.mood);
    final currentState = state;
    if (currentState is FeedLoaded) {
      final sorted = _matchingService.personalizeQuotes(
        currentState.quotes,
        mood: event.mood,
        themes: _prefsService.themes,
      );
      emit(
        FeedLoaded(
          sorted,
          feedItems: _buildFeedItems(sorted),
          likedIds: currentState.likedIds,
          bookmarkedIds: currentState.bookmarkedIds,
          currentMood: event.mood,
        ),
      );
    }
  }

  Future<void> _onLoadFeed(LoadFeed event, Emitter<FeedState> emit) async {
    emit(FeedLoading());
    final result = await repository.getQuotes();
    final savedBookmarks = _prefsService.bookmarkedQuoteIds.toSet();
    final mood = _prefsService.mood;
    final themes = _prefsService.themes;
    result.fold((failure) => emit(const FeedError('Failed to load quotes')), (
      quotes,
    ) {
      final sorted = _matchingService.personalizeQuotes(
        quotes,
        mood: mood,
        themes: themes,
      );
      emit(
        FeedLoaded(
          sorted,
          feedItems: _buildFeedItems(sorted),
          bookmarkedIds: savedBookmarks,
          currentMood: mood,
        ),
      );
    });
  }
}
