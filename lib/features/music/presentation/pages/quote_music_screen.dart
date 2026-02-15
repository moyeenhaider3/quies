import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../presentation/widgets/shimmer/shimmer_quote_card.dart';
import '../bloc/quote_music_bloc.dart';
import '../bloc/quote_music_event.dart';
import '../bloc/quote_music_state.dart';
import '../widgets/audio_player_widget.dart';

class QuoteMusicScreen extends StatelessWidget {
  const QuoteMusicScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.deepVoid,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white70),
          onPressed: () {
            context.read<QuoteMusicBloc>().add(const StopAudio());
            context.pop();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
            onPressed: () {
              context.read<QuoteMusicBloc>().add(const RefreshContent());
            },
          ),
        ],
      ),
      body: BlocBuilder<QuoteMusicBloc, QuoteMusicState>(
        builder: (context, state) {
          return switch (state) {
            QuoteMusicInitial() => _buildInitial(),
            QuoteMusicLoading(:final genre) => _buildLoading(genre),
            QuoteMusicLoaded(:final quote, :final music, :final genre) =>
              _buildLoaded(context, quote, music, genre),
            QuoteMusicError(
              :final message,
              :final cachedQuote,
              :final cachedMusic,
              :final genre,
            ) =>
              _buildError(context, message, cachedQuote, cachedMusic, genre),
          };
        },
      ),
    );
  }

  Widget _buildInitial() {
    return Center(
      child: Text(
        'Select a genre to begin',
        style: GoogleFonts.outfit(color: Colors.white54, fontSize: 16),
      ),
    );
  }

  Widget _buildLoading(String genre) {
    return const Center(child: ShimmerQuoteCard());
  }

  Widget _buildLoaded(
    BuildContext context,
    dynamic quote,
    dynamic music,
    String genre,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Genre badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: AppTheme.calmTeal.withValues(alpha: 0.15),
              border: Border.all(
                color: AppTheme.calmTeal.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              genre[0].toUpperCase() + genre.substring(1),
              style: GoogleFonts.outfit(
                color: AppTheme.calmTeal,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 40),

          // Quote text
          Text(
            '"${quote.content}"',
            textAlign: TextAlign.center,
            style: GoogleFonts.playfairDisplay(
              color: AppTheme.starlight,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 20),

          // Author
          Text(
            '— ${quote.author}',
            style: GoogleFonts.outfit(
              color: Colors.white54,
              fontSize: 16,
              fontStyle: FontStyle.italic,
            ),
          ),

          const SizedBox(height: 48),

          // Music player
          AudioPlayerWidget(
            previewUrl: music.previewUrl,
            trackName: music.trackName,
            artistName: music.artistName,
            artworkUrl: music.artworkUrl,
          ),

          const SizedBox(height: 32),

          // Refresh button
          TextButton.icon(
            onPressed: () {
              context.read<QuoteMusicBloc>().add(const RefreshContent());
            },
            icon: const Icon(
              Icons.auto_awesome,
              color: AppTheme.calmTeal,
              size: 18,
            ),
            label: Text(
              'New Inspiration',
              style: GoogleFonts.outfit(
                color: AppTheme.calmTeal,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildError(
    BuildContext context,
    String message,
    dynamic cachedQuote,
    dynamic cachedMusic,
    String? genre,
  ) {
    final hasCached = cachedQuote != null && cachedMusic != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 40),

          // Offline indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.orange.withValues(alpha: 0.15),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off, color: Colors.orange, size: 16),
                const SizedBox(width: 8),
                Text(
                  hasCached ? 'Offline — showing cached' : 'Connection error',
                  style: GoogleFonts.outfit(color: Colors.orange, fontSize: 13),
                ),
              ],
            ),
          ),

          if (hasCached) ...[
            const SizedBox(height: 40),

            // Show cached content
            Text(
              '"${cachedQuote.content}"',
              textAlign: TextAlign.center,
              style: GoogleFonts.playfairDisplay(
                color: AppTheme.starlight,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '— ${cachedQuote.author}',
              style: GoogleFonts.outfit(
                color: Colors.white54,
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 48),
            AudioPlayerWidget(
              previewUrl: cachedMusic.previewUrl,
              trackName: cachedMusic.trackName,
              artistName: cachedMusic.artistName,
              artworkUrl: cachedMusic.artworkUrl,
            ),
          ] else ...[
            const SizedBox(height: 60),
            Icon(Icons.cloud_off_rounded, color: Colors.white24, size: 64),
            const SizedBox(height: 16),
            Text(
              'Unable to load content',
              style: GoogleFonts.outfit(color: Colors.white54, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Check your connection and try again',
              style: GoogleFonts.outfit(color: Colors.white30, fontSize: 14),
            ),
          ],

          const SizedBox(height: 32),

          // Retry button
          ElevatedButton.icon(
            onPressed: () {
              context.read<QuoteMusicBloc>().add(const RefreshContent());
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.calmTeal.withValues(alpha: 0.2),
              foregroundColor: AppTheme.calmTeal,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
