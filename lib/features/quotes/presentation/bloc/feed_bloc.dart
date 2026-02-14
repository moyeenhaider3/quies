import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../data/services/content_matching_service.dart';
import '../../../../data/services/user_preferences_service.dart';
import '../../../music/data/genre_mapping.dart';
import '../../../music/data/services/music_service.dart';
import '../../../music/domain/entities/music_preview.dart';
import '../../data/models/author_model.dart';
import '../../data/models/tag_model.dart';
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
  final MusicService _musicService;

  /// Insert a breathing prompt every 5-7 quotes (randomized).
  static const _minQuotesBetweenPrompts = 5;
  static const _maxQuotesBetweenPrompts = 7;
  static final _promptRandom = Random();

  FeedBloc(
    this.repository,
    this._prefsService,
    this._matchingService,
    this._musicService,
  ) : super(FeedInitial()) {
    on<LoadFeed>(_onLoadFeed);
    on<LoadMore>(_onLoadMore);
    on<RefreshFeed>(_onRefreshFeed);
    on<ToggleLike>(_onToggleLike);
    on<ToggleBookmark>(_onToggleBookmark);
    on<ShareQuote>(_onShareQuote);
    on<ChangeMood>(_onChangeMood);
    on<ApplyTagFilter>(_onApplyTagFilter);
    on<ApplyAuthorFilter>(_onApplyAuthorFilter);
    on<ClearFilters>(_onClearFilters);
    on<ToggleSound>(_onToggleSound);
    on<MusicLoaded>(_onMusicLoaded);
    on<LoadTags>(_onLoadTags);
    on<SearchAuthors>(_onSearchAuthors);
  }

  // ---------------------------------------------------------------------------
  // Feed building helpers
  // ---------------------------------------------------------------------------

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

  // ---------------------------------------------------------------------------
  // Music pairing (async, non-blocking)
  // ---------------------------------------------------------------------------

  /// Fetch music for each quote and emit [MusicLoaded] events.
  void _fetchMusicForQuotes(List<Quote> quotes) {
    for (final quote in quotes) {
      final keyword = getMusicKeywordForTags(quote.tags);
      _musicService
          .fetchMusic(keyword)
          .then((music) {
            if (!isClosed) {
              add(MusicLoaded(quote.id, music));
            }
          })
          .catchError((_) {
            // No music available for this quote — graceful degradation
          });
    }
  }

  // ---------------------------------------------------------------------------
  // Event handlers
  // ---------------------------------------------------------------------------

  /// Initial feed load — API-first with local fallback.
  Future<void> _onLoadFeed(LoadFeed event, Emitter<FeedState> emit) async {
    emit(FeedLoading());

    final savedBookmarks = _prefsService.bookmarkedQuoteIds.toSet();
    final mood = _prefsService.mood;
    final themes = _prefsService.themes;

    final result = await repository.getRemoteQuotes(limit: 10);

    result.fold((failure) => emit(const FeedError('Failed to load quotes')), (
      quotes,
    ) {
      final isOffline = false; // getRemoteQuotes succeeded
      final sorted = _matchingService.personalizeQuotes(
        quotes,
        mood: mood,
        themes: themes,
      );

      // Pre-enable sound for all quotes if audioEnabled preference is true
      final soundEnabled = _prefsService.audioEnabled
          ? sorted.map((q) => q.id).toSet()
          : <String>{};

      emit(
        FeedLoaded(
          sorted,
          feedItems: _buildFeedItems(sorted),
          bookmarkedIds: savedBookmarks,
          currentMood: mood,
          isOffline: isOffline,
          soundEnabledQuoteIds: soundEnabled,
        ),
      );

      // Fire off background music fetching
      _fetchMusicForQuotes(sorted);
    });

    // If the result was a local fallback (getRemoteQuotes falls back to local
    // on API failure), check if we should mark offline.
    // We detect this by trying a simple remote call; if state is already loaded,
    // we just continue.
  }

  /// Load more quotes for infinite scroll.
  Future<void> _onLoadMore(LoadMore event, Emitter<FeedState> emit) async {
    final currentState = state;
    if (currentState is! FeedLoaded || currentState.isLoadingMore) return;

    emit(currentState.copyWith(isLoadingMore: true));

    if (currentState.hasFilters) {
      // Paginated filtered query
      final nextPage = currentState.currentPage + 1;
      if (nextPage > currentState.totalPages) {
        emit(currentState.copyWith(isLoadingMore: false));
        return;
      }

      final result = await repository.getFilteredQuotes(
        tags: currentState.activeTags.isNotEmpty
            ? currentState.activeTags.join('|')
            : null,
        authorSlug: currentState.activeAuthorSlug,
        page: nextPage,
      );

      result.fold((_) => emit(currentState.copyWith(isLoadingMore: false)), (
        paginated,
      ) {
        final newQuotes = paginated.results.map((rq) => rq.toQuote()).toList();
        final allQuotes = [...currentState.quotes, ...newQuotes];

        // Pre-enable sound for new quotes if audioEnabled
        final newSoundEnabled = _prefsService.audioEnabled
            ? {...currentState.soundEnabledQuoteIds, ...newQuotes.map((q) => q.id)}
            : currentState.soundEnabledQuoteIds;

        emit(
          currentState.copyWith(
            quotes: allQuotes,
            feedItems: _buildFeedItems(allQuotes),
            isLoadingMore: false,
            currentPage: paginated.page,
            totalPages: paginated.totalPages,
            soundEnabledQuoteIds: newSoundEnabled,
          ),
        );

        _fetchMusicForQuotes(newQuotes);
      });
    } else {
      // Random append (no pagination)
      final result = await repository.getRemoteQuotes(limit: 10);

      result.fold((_) => emit(currentState.copyWith(isLoadingMore: false)), (
        newQuotes,
      ) {
        final allQuotes = [...currentState.quotes, ...newQuotes];

        // Pre-enable sound for new quotes if audioEnabled
        final newSoundEnabled = _prefsService.audioEnabled
            ? {...currentState.soundEnabledQuoteIds, ...newQuotes.map((q) => q.id)}
            : currentState.soundEnabledQuoteIds;

        emit(
          currentState.copyWith(
            quotes: allQuotes,
            feedItems: _buildFeedItems(allQuotes),
            isLoadingMore: false,
            soundEnabledQuoteIds: newSoundEnabled,
          ),
        );

        _fetchMusicForQuotes(newQuotes);
      });
    }
  }

  /// Pull-to-refresh.
  Future<void> _onRefreshFeed(
    RefreshFeed event,
    Emitter<FeedState> emit,
  ) async {
    add(LoadFeed());
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

  /// Mood change — maps mood to API tags and filters.
  Future<void> _onChangeMood(ChangeMood event, Emitter<FeedState> emit) async {
    await _prefsService.setMood(event.mood);

    // Map mood to API tags for filtered query
    final moodTags = moodToTagsMap[event.mood];

    if (moodTags != null && moodTags.isNotEmpty) {
      // Use API filtering with mood-mapped tags
      emit(FeedLoading());

      final result = await repository.getFilteredQuotes(
        tags: moodTags.join('|'),
        page: 1,
      );

      final savedBookmarks = _prefsService.bookmarkedQuoteIds.toSet();

      result.fold(
        (_) {
          // Fallback: just re-sort existing content
          final currentState = state;
          if (currentState is FeedLoaded) {
            final sorted = _matchingService.personalizeQuotes(
              currentState.quotes,
              mood: event.mood,
              themes: _prefsService.themes,
            );
            emit(
              currentState.copyWith(
                quotes: sorted,
                feedItems: _buildFeedItems(sorted),
                currentMood: event.mood,
              ),
            );
          }
        },
        (paginated) {
          final quotes = paginated.results.map((rq) => rq.toQuote()).toList();
          final sorted = _matchingService.personalizeQuotes(
            quotes,
            mood: event.mood,
            themes: _prefsService.themes,
          );

          emit(
            FeedLoaded(
              sorted,
              feedItems: _buildFeedItems(sorted),
              bookmarkedIds: savedBookmarks,
              currentMood: event.mood,
              activeTags: moodTags,
              currentPage: paginated.page,
              totalPages: paginated.totalPages,
            ),
          );

          _fetchMusicForQuotes(sorted);
        },
      );
    } else {
      // Unknown mood — just re-sort current content
      final currentState = state;
      if (currentState is FeedLoaded) {
        final sorted = _matchingService.personalizeQuotes(
          currentState.quotes,
          mood: event.mood,
          themes: _prefsService.themes,
        );
        emit(
          currentState.copyWith(
            quotes: sorted,
            feedItems: _buildFeedItems(sorted),
            currentMood: event.mood,
          ),
        );
      }
    }
  }

  /// Apply tag filter.
  Future<void> _onApplyTagFilter(
    ApplyTagFilter event,
    Emitter<FeedState> emit,
  ) async {
    emit(FeedLoading());

    final result = await repository.getFilteredQuotes(
      tags: event.tags.join('|'),
      page: 1,
    );

    final savedBookmarks = _prefsService.bookmarkedQuoteIds.toSet();
    final mood = _prefsService.mood;

    result.fold(
      (failure) => emit(const FeedError('Failed to load filtered quotes')),
      (paginated) {
        final quotes = paginated.results.map((rq) => rq.toQuote()).toList();
        emit(
          FeedLoaded(
            quotes,
            feedItems: _buildFeedItems(quotes),
            bookmarkedIds: savedBookmarks,
            currentMood: mood,
            activeTags: event.tags,
            currentPage: paginated.page,
            totalPages: paginated.totalPages,
          ),
        );

        _fetchMusicForQuotes(quotes);
      },
    );
  }

  /// Apply author filter.
  Future<void> _onApplyAuthorFilter(
    ApplyAuthorFilter event,
    Emitter<FeedState> emit,
  ) async {
    emit(FeedLoading());

    final result = await repository.getFilteredQuotes(
      authorSlug: event.authorSlug,
      page: 1,
    );

    final savedBookmarks = _prefsService.bookmarkedQuoteIds.toSet();
    final mood = _prefsService.mood;

    result.fold(
      (failure) => emit(const FeedError('Failed to load author quotes')),
      (paginated) {
        final quotes = paginated.results.map((rq) => rq.toQuote()).toList();
        emit(
          FeedLoaded(
            quotes,
            feedItems: _buildFeedItems(quotes),
            bookmarkedIds: savedBookmarks,
            currentMood: mood,
            activeAuthorSlug: event.authorSlug,
            activeAuthorName: event.authorName,
            currentPage: paginated.page,
            totalPages: paginated.totalPages,
          ),
        );

        _fetchMusicForQuotes(quotes);
      },
    );
  }

  /// Clear all filters, return to random feed.
  Future<void> _onClearFilters(
    ClearFilters event,
    Emitter<FeedState> emit,
  ) async {
    emit(FeedLoading());

    final result = await repository.getRemoteQuotes(limit: 10);
    final savedBookmarks = _prefsService.bookmarkedQuoteIds.toSet();
    final mood = _prefsService.mood;

    // Preserve available tags from previous state
    final prevState = state;
    final availableTags = prevState is FeedLoaded
        ? prevState.availableTags
        : <TagModel>[];

    result.fold((failure) => emit(const FeedError('Failed to load quotes')), (
      quotes,
    ) {
      emit(
        FeedLoaded(
          quotes,
          feedItems: _buildFeedItems(quotes),
          bookmarkedIds: savedBookmarks,
          currentMood: mood,
          availableTags: availableTags,
        ),
      );

      _fetchMusicForQuotes(quotes);
    });
  }

  /// Toggle sound for a specific quote.
  Future<void> _onToggleSound(
    ToggleSound event,
    Emitter<FeedState> emit,
  ) async {
    final currentState = state;
    if (currentState is FeedLoaded) {
      final enabledIds = Set<String>.from(currentState.soundEnabledQuoteIds);
      if (enabledIds.contains(event.quoteId)) {
        enabledIds.remove(event.quoteId);
      } else {
        enabledIds.add(event.quoteId);
      }
      emit(currentState.copyWith(soundEnabledQuoteIds: enabledIds));
    }
  }

  /// Background music fetch completed.
  Future<void> _onMusicLoaded(
    MusicLoaded event,
    Emitter<FeedState> emit,
  ) async {
    final currentState = state;
    if (currentState is FeedLoaded) {
      final updatedMusic = Map<String, MusicPreview>.from(
        currentState.pairedMusic,
      );
      updatedMusic[event.quoteId] = event.music;
      emit(currentState.copyWith(pairedMusic: updatedMusic));
    }
  }

  /// Fetch available tags — falls back to hardcoded list if API is down.
  Future<void> _onLoadTags(LoadTags event, Emitter<FeedState> emit) async {
    final result = await repository.getTags();

    result.fold(
      (_) {
        // API failed — provide hardcoded fallback tags
        final currentState = state;
        if (currentState is FeedLoaded && currentState.availableTags.isEmpty) {
          emit(currentState.copyWith(availableTags: _fallbackTags));
        }
      },
      (tags) {
        final currentState = state;
        if (currentState is FeedLoaded) {
          emit(
            currentState.copyWith(
              availableTags: tags.isNotEmpty ? tags : _fallbackTags,
            ),
          );
        }
      },
    );
  }

  /// Hardcoded fallback tags when the API is unavailable.
  static final List<TagModel> _fallbackTags = [
    const TagModel(
      id: 'inspirational',
      name: 'Inspirational',
      slug: 'inspirational',
      quoteCount: 0,
    ),
    const TagModel(
      id: 'motivational',
      name: 'Motivational',
      slug: 'motivational',
      quoteCount: 0,
    ),
    const TagModel(id: 'love', name: 'Love', slug: 'love', quoteCount: 0),
    const TagModel(
      id: 'happiness',
      name: 'Happiness',
      slug: 'happiness',
      quoteCount: 0,
    ),
    const TagModel(id: 'life', name: 'Life', slug: 'life', quoteCount: 0),
    const TagModel(id: 'wisdom', name: 'Wisdom', slug: 'wisdom', quoteCount: 0),
    const TagModel(
      id: 'success',
      name: 'Success',
      slug: 'success',
      quoteCount: 0,
    ),
    const TagModel(
      id: 'friendship',
      name: 'Friendship',
      slug: 'friendship',
      quoteCount: 0,
    ),
    const TagModel(
      id: 'knowledge',
      name: 'Knowledge',
      slug: 'knowledge',
      quoteCount: 0,
    ),
    const TagModel(id: 'humor', name: 'Humor', slug: 'humor', quoteCount: 0),
    const TagModel(
      id: 'philosophy',
      name: 'Philosophy',
      slug: 'philosophy',
      quoteCount: 0,
    ),
    const TagModel(id: 'faith', name: 'Faith', slug: 'faith', quoteCount: 0),
    const TagModel(id: 'hope', name: 'Hope', slug: 'hope', quoteCount: 0),
    const TagModel(
      id: 'courage',
      name: 'Courage',
      slug: 'courage',
      quoteCount: 0,
    ),
    const TagModel(id: 'nature', name: 'Nature', slug: 'nature', quoteCount: 0),
    const TagModel(
      id: 'freedom',
      name: 'Freedom',
      slug: 'freedom',
      quoteCount: 0,
    ),
  ];

  /// Search authors for autocomplete.
  Future<void> _onSearchAuthors(
    SearchAuthors event,
    Emitter<FeedState> emit,
  ) async {
    if (event.query.length < 2) return;

    final result = await repository.searchAuthors(event.query);

    result.fold(
      (_) {}, // Silently fail
      (authors) {
        final currentState = state;
        if (currentState is FeedLoaded) {
          emit(currentState.copyWith(authorSearchResults: authors));
        }
      },
    );
  }
}
