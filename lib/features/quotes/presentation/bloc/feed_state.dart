part of 'feed_bloc.dart';

abstract class FeedState extends Equatable {
  const FeedState();

  @override
  List<Object> get props => [];
}

class FeedInitial extends FeedState {}

class FeedLoading extends FeedState {}

class FeedLoaded extends FeedState {
  final List<Quote> quotes;
  final List<FeedItem> feedItems;
  final Set<String> likedIds;
  final Set<String> bookmarkedIds;
  final String? currentMood;

  // Phase 7 additions
  final Map<String, MusicPreview> pairedMusic;
  final Set<String> soundEnabledQuoteIds;
  final List<String> activeTags;
  final String? activeAuthorSlug;
  final String? activeAuthorName;
  final List<TagModel> availableTags;
  final List<AuthorModel> authorSearchResults;
  final bool isOffline;
  final bool isLoadingMore;
  final int currentPage;
  final int totalPages;

  // Phase 8 additions
  final Set<int> usedTrackIds;

  const FeedLoaded(
    this.quotes, {
    this.feedItems = const [],
    this.likedIds = const {},
    this.bookmarkedIds = const {},
    this.currentMood,
    this.pairedMusic = const {},
    this.soundEnabledQuoteIds = const {},
    this.activeTags = const [],
    this.activeAuthorSlug,
    this.activeAuthorName,
    this.availableTags = const [],
    this.authorSearchResults = const [],
    this.isOffline = false,
    this.isLoadingMore = false,
    this.currentPage = 1,
    this.totalPages = 1,
    this.usedTrackIds = const {},
  });

  /// Whether any filter (tags or author) is currently active.
  bool get hasFilters => activeTags.isNotEmpty || activeAuthorSlug != null;

  FeedLoaded copyWith({
    List<Quote>? quotes,
    List<FeedItem>? feedItems,
    Set<String>? likedIds,
    Set<String>? bookmarkedIds,
    String? currentMood,
    Map<String, MusicPreview>? pairedMusic,
    Set<String>? soundEnabledQuoteIds,
    List<String>? activeTags,
    String? activeAuthorSlug,
    String? activeAuthorName,
    List<TagModel>? availableTags,
    List<AuthorModel>? authorSearchResults,
    bool? isOffline,
    bool? isLoadingMore,
    int? currentPage,
    int? totalPages,
    bool clearAuthorFilter = false,
    Set<int>? usedTrackIds,
  }) {
    return FeedLoaded(
      quotes ?? this.quotes,
      feedItems: feedItems ?? this.feedItems,
      likedIds: likedIds ?? this.likedIds,
      bookmarkedIds: bookmarkedIds ?? this.bookmarkedIds,
      currentMood: currentMood ?? this.currentMood,
      pairedMusic: pairedMusic ?? this.pairedMusic,
      soundEnabledQuoteIds: soundEnabledQuoteIds ?? this.soundEnabledQuoteIds,
      activeTags: activeTags ?? this.activeTags,
      activeAuthorSlug: clearAuthorFilter
          ? null
          : (activeAuthorSlug ?? this.activeAuthorSlug),
      activeAuthorName: clearAuthorFilter
          ? null
          : (activeAuthorName ?? this.activeAuthorName),
      availableTags: availableTags ?? this.availableTags,
      authorSearchResults: authorSearchResults ?? this.authorSearchResults,
      isOffline: isOffline ?? this.isOffline,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      usedTrackIds: usedTrackIds ?? this.usedTrackIds,
    );
  }

  @override
  List<Object> get props => [
    quotes,
    feedItems,
    likedIds,
    bookmarkedIds,
    currentMood ?? '',
    pairedMusic,
    soundEnabledQuoteIds,
    activeTags,
    activeAuthorSlug ?? '',
    activeAuthorName ?? '',
    availableTags,
    authorSearchResults,
    isOffline,
    isLoadingMore,
    currentPage,
    totalPages,
    usedTrackIds,
  ];
}

class FeedError extends FeedState {
  final String message;

  const FeedError(this.message);

  @override
  List<Object> get props => [message];
}
