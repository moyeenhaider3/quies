part of 'feed_bloc.dart';

abstract class FeedEvent extends Equatable {
  const FeedEvent();

  @override
  List<Object> get props => [];
}

/// Initial API-powered feed load.
class LoadFeed extends FeedEvent {}

/// Infinite scroll — load more quotes.
class LoadMore extends FeedEvent {}

/// Pull-to-refresh — reload feed from scratch.
class RefreshFeed extends FeedEvent {}

class ToggleLike extends FeedEvent {
  final String quoteId;
  const ToggleLike(this.quoteId);
  @override
  List<Object> get props => [quoteId];
}

class ToggleBookmark extends FeedEvent {
  final String quoteId;
  const ToggleBookmark(this.quoteId);
  @override
  List<Object> get props => [quoteId];
}

class ShareQuote extends FeedEvent {
  final Quote quote;
  const ShareQuote(this.quote);
  @override
  List<Object> get props => [quote];
}

class ChangeMood extends FeedEvent {
  final String mood;
  const ChangeMood(this.mood);
  @override
  List<Object> get props => [mood];
}

/// Apply tag filter(s) — triggers paginated API query.
class ApplyTagFilter extends FeedEvent {
  final List<String> tags;
  const ApplyTagFilter(this.tags);
  @override
  List<Object> get props => [tags];
}

/// Apply author filter — triggers paginated API query.
class ApplyAuthorFilter extends FeedEvent {
  final String authorSlug;
  final String authorName;
  const ApplyAuthorFilter(this.authorSlug, this.authorName);
  @override
  List<Object> get props => [authorSlug, authorName];
}

/// Clear all filters, return to random feed.
class ClearFilters extends FeedEvent {}

/// Toggle sound on/off for a specific quote.
class ToggleSound extends FeedEvent {
  final String quoteId;
  const ToggleSound(this.quoteId);
  @override
  List<Object> get props => [quoteId];
}

/// Background music fetch completed for a quote.
class MusicLoaded extends FeedEvent {
  final String quoteId;
  final MusicPreview music;
  const MusicLoaded(this.quoteId, this.music);
  @override
  List<Object> get props => [quoteId, music];
}

/// Fetch available tags from the API.
class LoadTags extends FeedEvent {}

/// Search authors for autocomplete.
class SearchAuthors extends FeedEvent {
  final String query;
  const SearchAuthors(this.query);
  @override
  List<Object> get props => [query];
}
