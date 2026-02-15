import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

/// Manages a single [AudioPlayer] instance for the entire feed.
///
/// Provides [play], [stop] methods and exposes current playback state.
/// Auto-stops playback after a dynamic duration based on quote length.
/// Transitions between songs with a quick fade (0.3s out, 0.2s silence, 0.3s in).
class FeedAudioController extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  Timer? _stopTimer;

  /// Calculate play duration: 1 second per 10 characters, clamped 7-15s.
  static Duration calculateDuration(int quoteTextLength) {
    final seconds = (quoteTextLength / 10).round().clamp(7, 15);
    return Duration(seconds: seconds);
  }

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
  /// [quoteTextLength] determines how long the preview plays (7-15s).
  Future<void> playForQuote(
    String quoteId,
    String previewUrl, {
    int quoteTextLength = 100,
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
      _stopTimer?.cancel();

      _currentQuoteId = quoteId;
      await _player.setUrl(previewUrl);

      // Fade in new track
      await _fadeIn();

      _isLoading = false;
      notifyListeners();

      // Auto-stop after dynamic duration
      final duration = calculateDuration(quoteTextLength);
      _stopTimer = Timer(duration, () {
        stop();
      });
    } catch (e) {
      _isLoading = false;
      _currentQuoteId = null;
      notifyListeners();
    }
  }

  /// Fade out current audio over 0.3s.
  Future<void> _fadeOut() async {
    const steps = 6;
    const stepDuration = Duration(milliseconds: 50); // 6 × 50ms = 300ms
    for (int i = steps; i >= 0; i--) {
      if (!_isPlaying) return;
      await _player.setVolume(i / steps);
      await Future.delayed(stepDuration);
    }
    await _player.stop();
    // Brief silence between tracks
    await Future.delayed(const Duration(milliseconds: 200));
  }

  /// Fade in audio over 0.3s.
  Future<void> _fadeIn() async {
    await _player.setVolume(0);
    _player.play();
    _isPlaying = true;
    const steps = 6;
    const stepDuration = Duration(milliseconds: 50);
    for (int i = 0; i <= steps; i++) {
      await _player.setVolume(i / steps);
      await Future.delayed(stepDuration);
    }
  }

  /// Stop any currently playing music with a fade out.
  Future<void> stop() async {
    _stopTimer?.cancel();
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
