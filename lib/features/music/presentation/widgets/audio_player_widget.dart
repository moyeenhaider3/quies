import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';

import '../../../../core/theme/app_theme.dart';

/// Plays a music preview URL for ~12 seconds with play/pause controls.
class AudioPlayerWidget extends StatefulWidget {
  final String previewUrl;
  final String trackName;
  final String artistName;
  final String artworkUrl;

  const AudioPlayerWidget({
    super.key,
    required this.previewUrl,
    required this.trackName,
    required this.artistName,
    required this.artworkUrl,
  });

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayer _player;
  Timer? _stopTimer;
  bool _isLoading = false;
  bool _isPlaying = false;
  bool _hasError = false;
  double _progress = 0;
  Timer? _progressTimer;

  static const _playDuration = Duration(seconds: 12);

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _setupPlayerListeners();
  }

  void _setupPlayerListeners() {
    _player.playerStateStream.listen((state) {
      if (!mounted) return;
      setState(() {
        _isPlaying = state.playing;
      });
    });
  }

  @override
  void didUpdateWidget(AudioPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.previewUrl != widget.previewUrl) {
      _stopPlayback();
    }
  }

  Future<void> _play() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _progress = 0;
    });

    try {
      await _player.stop();
      await _player.setUrl(widget.previewUrl);
      _player.play();

      setState(() {
        _isLoading = false;
        _isPlaying = true;
      });

      // Auto-stop after 12 seconds
      _stopTimer?.cancel();
      _stopTimer = Timer(_playDuration, _stopPlayback);

      // Progress indicator
      _progressTimer?.cancel();
      _progressTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
        if (!mounted) return;
        setState(() {
          _progress += 0.1 / _playDuration.inSeconds;
          if (_progress > 1) _progress = 1;
        });
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  void _stopPlayback() {
    _stopTimer?.cancel();
    _progressTimer?.cancel();
    _player.stop();
    if (mounted) {
      setState(() {
        _isPlaying = false;
        _progress = 0;
      });
    }
  }

  void _togglePlayPause() {
    if (_isPlaying) {
      _stopPlayback();
    } else {
      _play();
    }
  }

  @override
  void dispose() {
    _stopTimer?.cancel();
    _progressTimer?.cancel();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppTheme.softGlass,
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // Artwork
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: widget.artworkUrl.isNotEmpty
                    ? Image.network(
                        widget.artworkUrl,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _artworkPlaceholder(),
                      )
                    : _artworkPlaceholder(),
              ),
              const SizedBox(width: 14),

              // Track info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.trackName,
                      style: GoogleFonts.outfit(
                        color: AppTheme.starlight,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.artistName,
                      style: GoogleFonts.outfit(
                        color: Colors.white54,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Play/Pause button
              _buildPlayButton(),
            ],
          ),

          // Progress bar
          if (_isPlaying || _progress > 0) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _progress,
                backgroundColor: Colors.white10,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppTheme.calmTeal,
                ),
                minHeight: 3,
              ),
            ),
          ],

          // Error message
          if (_hasError) ...[
            const SizedBox(height: 8),
            Text(
              'Unable to play preview',
              style: GoogleFonts.outfit(
                color: Colors.redAccent.withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlayButton() {
    if (_isLoading) {
      return const SizedBox(
        width: 44,
        height: 44,
        child: Padding(
          padding: EdgeInsets.all(10),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppTheme.calmTeal,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: _togglePlayPause,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.calmTeal.withValues(alpha: 0.2),
          border: Border.all(color: AppTheme.calmTeal.withValues(alpha: 0.5)),
        ),
        child: Icon(
          _isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded,
          color: AppTheme.calmTeal,
          size: 26,
        ),
      ),
    );
  }

  Widget _artworkPlaceholder() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppTheme.nebula.withValues(alpha: 0.5),
      ),
      child: const Icon(Icons.music_note, color: Colors.white38, size: 28),
    );
  }
}
