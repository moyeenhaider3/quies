import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/genre_mapping.dart';
import '../bloc/quote_music_bloc.dart';
import '../bloc/quote_music_event.dart';

class GenreSelectionScreen extends StatelessWidget {
  const GenreSelectionScreen({super.key});

  static const _genreGradients = {
    'inspirational': [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    'love': [Color(0xFFEC4899), Color(0xFFF43F5E)],
    'peace': [Color(0xFF2DD4BF), Color(0xFF06B6D4)],
    'sad': [Color(0xFF64748B), Color(0xFF475569)],
    'success': [Color(0xFFF59E0B), Color(0xFFEF4444)],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.deepVoid,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white70),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Choose a Mood',
          style: GoogleFonts.outfit(
            color: AppTheme.starlight,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What speaks to you right now?',
              style: GoogleFonts.outfit(color: Colors.white60, fontSize: 16),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.separated(
                itemCount: supportedGenres.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final genre = supportedGenres[index];
                  final icon = genreIcons[genre] ?? '🎵';
                  final colors =
                      _genreGradients[genre] ??
                      [AppTheme.nebula, AppTheme.calmTeal];

                  return _GenreCard(
                    genre: genre,
                    icon: icon,
                    gradientColors: colors,
                    onTap: () {
                      context.read<QuoteMusicBloc>().add(SelectGenre(genre));
                      context.push('/quote-music');
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GenreCard extends StatelessWidget {
  final String genre;
  final String icon;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _GenreCard({
    required this.genre,
    required this.icon,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              gradientColors[0].withValues(alpha: 0.3),
              gradientColors[1].withValues(alpha: 0.15),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: gradientColors[0].withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  genre[0].toUpperCase() + genre.substring(1),
                  style: GoogleFonts.outfit(
                    color: AppTheme.starlight,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
