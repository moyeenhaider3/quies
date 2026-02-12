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

  const FeedLoaded(
    this.quotes, {
    this.feedItems = const [],
    this.likedIds = const {},
    this.bookmarkedIds = const {},
    this.currentMood,
  });

  FeedLoaded copyWith({
    List<Quote>? quotes,
    List<FeedItem>? feedItems,
    Set<String>? likedIds,
    Set<String>? bookmarkedIds,
    String? currentMood,
  }) {
    return FeedLoaded(
      quotes ?? this.quotes,
      feedItems: feedItems ?? this.feedItems,
      likedIds: likedIds ?? this.likedIds,
      bookmarkedIds: bookmarkedIds ?? this.bookmarkedIds,
      currentMood: currentMood ?? this.currentMood,
    );
  }

  @override
  List<Object> get props => [
    quotes,
    feedItems,
    likedIds,
    bookmarkedIds,
    currentMood ?? '',
  ];
}

class FeedError extends FeedState {
  final String message;

  const FeedError(this.message);

  @override
  List<Object> get props => [message];
}
