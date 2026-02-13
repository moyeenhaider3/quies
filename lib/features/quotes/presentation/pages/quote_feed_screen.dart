import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection.dart';
import '../../../../data/services/user_preferences_service.dart';
import '../../domain/entities/feed_item.dart';
import '../bloc/feed_bloc.dart';
import '../widgets/breathing_prompt_card.dart';
import '../widgets/quote_card.dart';
import '../widgets/welcome_back_overlay.dart';

class QuoteFeedScreen extends StatefulWidget {
  const QuoteFeedScreen({super.key});

  @override
  State<QuoteFeedScreen> createState() => _QuoteFeedScreenState();
}

class _QuoteFeedScreenState extends State<QuoteFeedScreen>
    with WidgetsBindingObserver {
  static const _moods = [
    ('Calm', '😌'),
    ('Energized', '⚡'),
    ('Reflective', '🤔'),
    ('Anxious', '😰'),
    ('Grateful', '🙏'),
    ('Hopeful', '🌅'),
  ];

  bool _showWelcomeBack = false;
  int _quotesExplored = 0;

  late final UserPreferencesService _prefsService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _prefsService = getIt<UserPreferencesService>();

    // Check if returning after inactivity
    if (_prefsService.hasBeenInactiveFor(minutes: 30)) {
      _showWelcomeBack = true;
    }

    // Record active timestamp
    _prefsService.setLastActiveTimestamp(DateTime.now().millisecondsSinceEpoch);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // Record when the user left
      _prefsService.setLastActiveTimestamp(
        DateTime.now().millisecondsSinceEpoch,
      );
    } else if (state == AppLifecycleState.resumed) {
      // Check if they were away long enough
      if (_prefsService.hasBeenInactiveFor(minutes: 30)) {
        setState(() {
          _showWelcomeBack = true;
        });
      }
      _prefsService.setLastActiveTimestamp(
        DateTime.now().millisecondsSinceEpoch,
      );
    }
  }

  void _dismissWelcomeBack() {
    setState(() {
      _showWelcomeBack = false;
    });
  }

  void _onPageChanged(int index, FeedState feedState) {
    if (feedState is FeedLoaded) {
      final item = feedState.feedItems[index];
      if (item is QuoteFeedItem) {
        setState(() {
          _quotesExplored++;
        });
      }
    }
  }

  void _showMoodSelector(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'How are you feeling?',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _moods.map((entry) {
                    final (label, emoji) = entry;
                    return GestureDetector(
                      onTap: () {
                        context.read<FeedBloc>().add(ChangeMood(label));
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : Colors.black.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.1)
                                : Colors.black.withValues(alpha: 0.08),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(emoji, style: const TextStyle(fontSize: 22)),
                            const SizedBox(width: 8),
                            Text(
                              label,
                              style: GoogleFonts.outfit(
                                fontSize: 15,
                                color: isDark ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BlocBuilder<FeedBloc, FeedState>(
            builder: (context, state) {
              if (state is FeedLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is FeedError) {
                return Center(child: Text(state.message));
              } else if (state is FeedLoaded) {
                return PageView.builder(
                  scrollDirection: Axis.vertical,
                  physics: const BouncingScrollPhysics(),
                  itemCount: state.feedItems.length,
                  onPageChanged: (index) => _onPageChanged(index, state),
                  itemBuilder: (context, index) {
                    final item = state.feedItems[index];
                    return switch (item) {
                      QuoteFeedItem(:final quote) => Center(
                        child: QuoteCard(
                          quote: quote,
                          isLiked: state.likedIds.contains(quote.id),
                          isBookmarked: state.bookmarkedIds.contains(quote.id),
                        ),
                      ),
                      BreathingPromptItem() => const Center(
                        child: BreathingPromptCard(),
                      ),
                    };
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // Gentle progress indicator (top center)
          if (_quotesExplored > 0)
            Positioned(
              top: MediaQuery.of(context).padding.top + 14,
              left: 0,
              right: 0,
              child: Center(
                child: AnimatedOpacity(
                  opacity: _quotesExplored > 0 ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 600),
                  child: Text(
                    _quotesExplored == 1
                        ? '1 quote explored'
                        : '$_quotesExplored quotes explored',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.4),
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),

          // Top bar: mood selector + bookmarks
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            child: BlocBuilder<FeedBloc, FeedState>(
              buildWhen: (prev, curr) {
                if (prev is FeedLoaded && curr is FeedLoaded) {
                  return prev.currentMood != curr.currentMood;
                }
                return true;
              },
              builder: (context, state) {
                final mood = state is FeedLoaded ? state.currentMood : null;
                final emoji = mood != null
                    ? _moods
                          .firstWhere(
                            (e) => e.$1 == mood,
                            orElse: () => ('', '🎯'),
                          )
                          .$2
                    : '🎯';
                return GestureDetector(
                  onTap: () => _showMoodSelector(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(emoji, style: const TextStyle(fontSize: 18)),
                        if (mood != null) ...[
                          const SizedBox(width: 6),
                          Text(
                            mood,
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 16,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => context.push('/bookmarks'),
                      icon: Icon(
                        Icons.collections_bookmark_rounded,
                        color: Colors.white70,
                        size: 28,
                      ),
                      tooltip: 'Saved Quotes',
                    ),
                    IconButton(
                      onPressed: () => context.push('/settings'),
                      icon: Icon(
                        Icons.settings_rounded,
                        color: Colors.white70,
                        size: 28,
                      ),
                      tooltip: 'Settings',
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Welcome back overlay
          if (_showWelcomeBack)
            WelcomeBackOverlay(onDismiss: _dismissWelcomeBack),
        ],
      ),
    );
  }
}
