
part of 'feed_bloc.dart';

abstract class FeedEvent extends Equatable {
  const FeedEvent();

  @override
  List<Object> get props => [];
}

class LoadFeed extends FeedEvent {}

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
