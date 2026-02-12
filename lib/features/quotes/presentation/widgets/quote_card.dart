import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../domain/entities/quote.dart';
import '../bloc/feed_bloc.dart';

class QuoteCard extends StatelessWidget {
  final Quote quote;
  final bool isLiked;
  final bool isBookmarked;

  const QuoteCard({
    super.key,
    required this.quote,
    this.isLiked = false,
    this.isBookmarked = false,
  });

  // Generate a consistent gradient based on the quote ID length or hash
  LinearGradient _getGradient(String id) {
    final gradients = [
      const LinearGradient(
        colors: [Color(0xFF0F172A), Color(0xFF312E81)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      const LinearGradient(
        colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      const LinearGradient(
        colors: [Color(0xFF2C3E50), Color(0xFF4CA1AF)], // Dark Blue to Teal
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      const LinearGradient(
        colors: [Color(0xFF232526), Color(0xFF414345)], // Midnight City
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ];
    final index = id.hashCode.abs() % gradients.length;
    return gradients[index];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(gradient: _getGradient(quote.id)),
      child: Stack(
        children: [
          // Background decoration (optional subtle patterns or noise could go here)
          Positioned(
            top: 100,
            left: 20,
            child: Icon(
              Icons.format_quote_rounded,
              size: 100,
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  // Quote Text
                  BlocBuilder<ThemeCubit, ThemeState>(
                    builder: (context, themeState) {
                      return Text(
                            quote.text,
                            style: AppTheme.quoteTextStyle(
                              fontFamily: themeState.quoteFont,
                              fontSize: themeState.quoteFontSize,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          )
                          .animate()
                          .fadeIn(duration: 800.ms)
                          .slideY(begin: 0.3, end: 0, curve: Curves.easeOut);
                    },
                  ),

                  const SizedBox(height: 32),

                  // Author
                  Text(
                        "- ${quote.author}",
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          color: Colors.white70,
                          fontStyle: FontStyle.italic,
                          letterSpacing: 1.0,
                        ),
                      )
                      .animate()
                      .fadeIn(delay: 400.ms, duration: 600.ms)
                      .slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 16),

                  // Tags/Category (Optional badge)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Text(
                      quote.category.toUpperCase(),
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: Colors.white60,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ).animate().fadeIn(delay: 600.ms),

                  const Spacer(),

                  // Actions Row
                  Padding(
                    padding: const EdgeInsets.only(bottom: 48.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildActionButton(
                          context,
                          icon: Icons.share_rounded,
                          label: 'Share',
                          onTap: () {
                            // Using a lightweight share approach or the Bloc event
                            context.read<FeedBloc>().add(ShareQuote(quote));
                            Share.share('"${quote.text}" - ${quote.author}');
                          },
                          delay: 800.ms,
                        ),
                        _buildActionButton(
                          context,
                          icon: isLiked
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          label: 'Like',
                          onTap: () {
                            context.read<FeedBloc>().add(ToggleLike(quote.id));
                          },
                          delay: 900.ms,
                          isPrimary: isLiked,
                          activeColor: Colors.redAccent,
                          isActive: isLiked,
                        ),
                        _buildActionButton(
                          context,
                          icon: isBookmarked
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_border_rounded,
                          label: 'Save',
                          onTap: () {
                            context.read<FeedBloc>().add(
                              ToggleBookmark(quote.id),
                            );
                          },
                          delay: 1000.ms,
                          isPrimary: isBookmarked,
                          activeColor: Colors.amberAccent,
                          isActive: isBookmarked,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Duration delay,
    bool isPrimary = false,
    Color? activeColor,
    bool isActive = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(50),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isPrimary
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isActive
                  ? (activeColor ?? Colors.black)
                  : (isPrimary ? Colors.black : Colors.white),
              size: 28,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.outfit(fontSize: 12, color: Colors.white70),
        ),
      ],
    ).animate().fadeIn(delay: delay).scale(curve: Curves.easeOutBack);
  }
}
