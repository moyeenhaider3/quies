import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

/// Manages a single [AudioPlayer] instance for the entire feed.
///
/// Provides [play], [stop] methods and exposes current playback state.
/// Auto-stops playback after 12 seconds.
class FeedAudioController extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  Timer? _stopTimer;

  static const _playDuration = Duration(seconds: 12);

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
  /// Stops any currently playing track first.
  Future<void> playForQuote(String quoteId, String previewUrl) async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      await _player.stop();
      _stopTimer?.cancel();

      _currentQuoteId = quoteId;
      await _player.setUrl(previewUrl);
      _player.play();

      _isLoading = false;
      _isPlaying = true;
      notifyListeners();

      // Auto-stop after 12 seconds
      _stopTimer = Timer(_playDuration, () {
        stop();
      });
    } catch (e) {
      _isLoading = false;
      _currentQuoteId = null;
      notifyListeners();
    }
  }

  /// Stop any currently playing music.
  void stop() {
    _stopTimer?.cancel();
    _player.stop();
    _isPlaying = false;
    _currentQuoteId = null;
    notifyListeners();
  }

  /// Called when the feed page changes — stop current playback.
  void onPageChanged() {
    stop();
  }

  /// Whether music is currently playing for the given [quoteId].
  bool isPlayingForQuote(String quoteId) {
    return _isPlaying && _currentQuoteId == quoteId;
  }

  @override
  void dispose() {
    _stopTimer?.cancel();
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
