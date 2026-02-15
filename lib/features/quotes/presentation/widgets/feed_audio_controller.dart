import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

/// Manages a single [AudioPlayer] instance for the entire feed.
///
/// Provides [play], [stop] methods and exposes current playback state.
/// Loops music continuously for each quote until page change.
/// Transitions between songs with a quick fade (0.3s out, 0.2s silence, 0.3s in).
/// Default volume is ambient (0.3) for a calm, meditative experience.
class FeedAudioController extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();

  /// Base volume for ambient playback (0.0–1.0). Default 0.3 for calm listening.
  double _baseVolume = 0.3;
  double get baseVolume => _baseVolume;

  /// Track ID of the last played track to prevent consecutive repeats.
  int? _lastPlayedTrackId;
  int? get lastPlayedTrackId => _lastPlayedTrackId;

  /// The quote ID whose music is currently playing/loaded.
  String? _currentQuoteId;
  String? get currentQuoteId => _currentQuoteId;

  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  FeedAudioController() {
    _player.playerStateStream.listen((state) {
      final playing = state.playing;
      if (playing != _isPlaying) {
        _isPlaying = playing;
        notifyListeners();
      }
    });
  }

  /// Start playing music for [quoteId] from [previewUrl].
  ///
  /// Stops any currently playing track first with a fade transition.
  /// Music loops continuously until the user swipes to the next quote.
  Future<void> playForQuote(
    String quoteId,
    String previewUrl, {
    int quoteTextLength = 100,
    int? trackId,
  }) async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Fade out current track if playing
      if (_isPlaying) {
        await _fadeOut();
      } else {
        await _player.stop();
      }

      _currentQuoteId = quoteId;
      if (trackId != null) _lastPlayedTrackId = trackId;
      await _player.setUrl(previewUrl);
      await _player.setLoopMode(LoopMode.one);

      // Fade in new track at ambient volume
      await _fadeIn();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _currentQuoteId = null;
      notifyListeners();
    }
  }

  /// Fade out current audio over 0.3s from current volume.
  Future<void> _fadeOut() async {
    final currentVol = _baseVolume;
    const steps = 6;
    const stepDuration = Duration(milliseconds: 50); // 6 × 50ms = 300ms
    for (int i = steps; i >= 0; i--) {
      if (!_isPlaying) return;
      await _player.setVolume((i / steps) * currentVol);
      await Future.delayed(stepDuration);
    }
    await _player.stop();
    // Brief silence between tracks
    await Future.delayed(const Duration(milliseconds: 200));
  }

  /// Fade in audio over 0.3s to ambient base volume.
  Future<void> _fadeIn() async {
    await _player.setVolume(0);
    _player.play();
    _isPlaying = true;
    const steps = 6;
    const stepDuration = Duration(milliseconds: 50);
    for (int i = 0; i <= steps; i++) {
      await _player.setVolume((i / steps) * _baseVolume);
      await Future.delayed(stepDuration);
    }
  }

  /// Set the ambient base volume (0.0–1.0).
  void setVolume(double volume) {
    _baseVolume = volume.clamp(0.0, 1.0);
    if (_isPlaying) {
      _player.setVolume(_baseVolume);
    }
    notifyListeners();
  }

  /// Stop any currently playing music with a fade out.
  Future<void> stop() async {
    if (_isPlaying) {
      await _fadeOut();
    }
    _isPlaying = false;
    _currentQuoteId = null;
    notifyListeners();
  }

  /// Called when the feed page changes — stop current playback with fade.
  void onPageChanged() {
    stop();
  }

  /// Whether music is currently playing for the given [quoteId].
  bool isPlayingForQuote(String quoteId) {
    return _isPlaying && _currentQuoteId == quoteId;
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}

/// Provides [FeedAudioController] to the widget tree via [InheritedWidget].
class FeedAudioScope extends InheritedNotifier<FeedAudioController> {
  const FeedAudioScope({
    super.key,
    required FeedAudioController controller,
    required super.child,
  }) : super(notifier: controller);

  static FeedAudioController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<FeedAudioScope>();
    assert(scope != null, 'No FeedAudioScope found in context');
    return scope!.notifier!;
  }

  static FeedAudioController? maybeOf(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<FeedAudioScope>();
    return scope?.notifier;
  }
}
