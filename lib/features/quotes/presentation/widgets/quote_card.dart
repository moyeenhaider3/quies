import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../music/domain/entities/music_preview.dart';
import '../../domain/entities/quote.dart';
import '../bloc/feed_bloc.dart';
import 'author_detail_modal.dart';

class QuoteCard extends StatelessWidget {
  final Quote quote;
  final bool isLiked;
  final bool isBookmarked;
  final MusicPreview? music;
  final bool isSoundOn;
  final VoidCallback? onToggleSound;

  const QuoteCard({
    super.key,
    required this.quote,
    this.isLiked = false,
    this.isBookmarked = false,
    this.music,
    this.isSoundOn = false,
    this.onToggleSound,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(gradient: AppTheme.getGradientForId(quote.id)),
      child: SafeArea(
        child: Column(
          children: [
            // Fixed Top: Quote decoration icon
            // Container(
            //   height: 120,
            //   alignment: Alignment.topLeft,
            //   padding: const EdgeInsets.only(left: 20, top: 20),
            //   child: Icon(
            //     Icons.format_quote_rounded,
            //     size: 100,
            //     color: Colors.white.withValues(alpha: 0.05),
            //   ),
            // ),

            // Flexible Center: Quote content with responsive sizing
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.center,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: MediaQuery.of(context).size.width - 64,
                      maxWidth: MediaQuery.of(context).size.width - 64,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Align(
                          alignment: AlignmentGeometry.centerLeft,
                          child: Icon(
                            Icons.format_quote_rounded,
                            size: 100,
                            color: Colors.white.withValues(alpha: 0.05),
                          ),
                        ),
                        // Quote Text — word-by-word staggered animation (centered)
                        Container(
                          width: double.infinity,
                          alignment: Alignment.center,
                          child: BlocBuilder<ThemeCubit, ThemeState>(
                            builder: (context, themeState) {
                              return _buildAnimatedQuote(
                                quote.text,
                                themeState.quoteFont,
                                themeState.quoteFontSize,
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Author
                        Center(
                          child:
                              GestureDetector(
                                    onTap: () {
                                      if (quote.authorSlug != null) {
                                        AuthorDetailModal.show(
                                          context,
                                          authorSlug: quote.authorSlug!,
                                          authorName: quote.author,
                                        );
                                      }
                                    },
                                    child: Text(
                                      "- ${quote.author}",
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.outfit(
                                        fontSize: 18,
                                        color: Colors.white70,
                                        fontStyle: FontStyle.italic,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  )
                                  .animate()
                                  .fadeIn(delay: 400.ms, duration: 600.ms)
                                  .slideY(begin: 0.2, end: 0),
                        ),

                        const SizedBox(height: 16),

                        // Tags (multi-tag from API, up to 3)
                        if (quote.tags.isNotEmpty)
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            alignment: WrapAlignment.center,
                            children: quote.tags.take(3).map((tag) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.1),
                                  ),
                                ),
                                child: Text(
                                  tag,
                                  style: GoogleFonts.outfit(
                                    fontSize: 11,
                                    color: Colors.white60,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              );
                            }).toList(),
                          ).animate().fadeIn(delay: 600.ms),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Fixed Bottom: Audio icon and action buttons
            Container(
              height: 200,
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                children: [
                  // Audio icon (fixed position)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child:
                          GestureDetector(
                                onTap: music != null ? onToggleSound : null,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: music == null
                                        ? Colors.white.withValues(alpha: 0.05)
                                        : isSoundOn
                                        ? AppTheme.calmTeal.withValues(
                                            alpha: 0.25,
                                          )
                                        : Colors.white.withValues(alpha: 0.1),
                                    border: Border.all(
                                      color: music == null
                                          ? Colors.white.withValues(alpha: 0.08)
                                          : isSoundOn
                                          ? AppTheme.calmTeal.withValues(
                                              alpha: 0.5,
                                            )
                                          : Colors.white.withValues(
                                              alpha: 0.15,
                                            ),
                                    ),
                                  ),
                                  child: Icon(
                                    music == null
                                        ? Icons.music_off_rounded
                                        : isSoundOn
                                        ? Icons.volume_up_rounded
                                        : Icons.volume_off_rounded,
                                    color: music == null
                                        ? Colors.white.withValues(alpha: 0.2)
                                        : isSoundOn
                                        ? AppTheme.calmTeal
                                        : Colors.white38,
                                    size: 24,
                                  ),
                                ),
                              )
                              .animate()
                              .fadeIn(duration: 400.ms)
                              .scale(
                                begin: const Offset(0.8, 0.8),
                                end: const Offset(1, 1),
                                curve: Curves.easeOutBack,
                              ),
                    ),
                  ),

                  // Action buttons (fixed position)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 32.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildActionButton(
                            context,
                            icon: Icons.share_rounded,
                            label: 'Share',
                            onTap: () {
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
                              context.read<FeedBloc>().add(
                                ToggleLike(quote.id),
                              );
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
                          _buildActionButton(
                            context,
                            icon: Icons.person_outline_rounded,
                            label: 'Author',
                            onTap: () {
                              if (quote.authorSlug != null) {
                                AuthorDetailModal.show(
                                  context,
                                  authorSlug: quote.authorSlug!,
                                  authorName: quote.author,
                                );
                              }
                            },
                            delay: 1100.ms,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build word-by-word animated quote text.
  ///
  /// Each word fades in and slides from right with a staggered delay (80ms/word),
  /// creating an elegant reveal effect. Capped at 300ms base delay to keep
  /// long quotes from taking too long to fully appear.
  Widget _buildAnimatedQuote(String text, String fontFamily, double fontSize) {
    final words = text.split(' ');
    const staggerMs = 80;
    // Cap total stagger so very long quotes don't take forever
    final maxDelay = (words.length * staggerMs).clamp(0, 3000);
    final effectiveStagger = words.length > 1
        ? maxDelay ~/ words.length
        : staggerMs;

    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 4,
            runSpacing: 2,
            children: List.generate(words.length, (i) {
              final delay = Duration(milliseconds: i * effectiveStagger);
              return Text(
                    words[i],
                    textAlign: TextAlign.center,
                    style: AppTheme.quoteTextStyle(
                      fontFamily: fontFamily,
                      fontSize: fontSize,
                      color: Colors.white,
                    ),
                  )
                  .animate()
                  .fadeIn(delay: delay, duration: 400.ms)
                  .slideX(
                    delay: delay,
                    begin: 0.15,
                    end: 0,
                    duration: 350.ms,
                    curve: Curves.easeOut,
                  );
            }),
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
