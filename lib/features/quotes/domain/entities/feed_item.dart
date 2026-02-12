import 'package:equatable/equatable.dart';

import 'quote.dart';

/// Represents an item in the feed — either a quote or a breathing prompt.
sealed class FeedItem extends Equatable {
  const FeedItem();
}

/// A quote displayed in the feed.
class QuoteFeedItem extends FeedItem {
  final Quote quote;

  const QuoteFeedItem(this.quote);

  @override
  List<Object?> get props => [quote];
}

/// A breathing prompt interleaved between quotes to prevent mindless scrolling.
class BreathingPromptItem extends FeedItem {
  const BreathingPromptItem();

  @override
  List<Object?> get props => [];
}
