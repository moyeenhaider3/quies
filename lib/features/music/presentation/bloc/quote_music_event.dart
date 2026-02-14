import 'package:equatable/equatable.dart';

sealed class QuoteMusicEvent extends Equatable {
  const QuoteMusicEvent();

  @override
  List<Object?> get props => [];
}

/// User selects a genre — triggers quote + music fetch.
class SelectGenre extends QuoteMusicEvent {
  final String genre;

  const SelectGenre(this.genre);

  @override
  List<Object?> get props => [genre];
}

/// Refresh content for the current genre.
class RefreshContent extends QuoteMusicEvent {
  const RefreshContent();
}

/// Signal to stop audio playback.
class StopAudio extends QuoteMusicEvent {
  const StopAudio();
}
