import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/services/user_preferences_service.dart';
import '../../../../presentation/widgets/shimmer/shimmer_bar.dart';
import '../../../../presentation/widgets/shimmer/shimmer_quote_card.dart';
import '../../../music/data/genre_mapping.dart';
import '../../domain/entities/feed_item.dart';
import '../bloc/feed_bloc.dart';
import '../widgets/breathing_prompt_card.dart';
import '../widgets/feed_audio_controller.dart';
import '../widgets/filter_bar.dart';
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
    ('Stressed', '😣'),
    ('Tired', '😴'),
  ];

  bool _showWelcomeBack = false;
  int _quotesExplored = 0;
  bool _hasInitialAutoPlay = false;

  late final UserPreferencesService _prefsService;
  late final FeedAudioController _audioController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _prefsService = getIt<UserPreferencesService>();
    _audioController = FeedAudioController();

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
    _audioController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _audioController.stop();
      _prefsService.setLastActiveTimestamp(
        DateTime.now().millisecondsSinceEpoch,
      );
    } else if (state == AppLifecycleState.resumed) {
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

  void _tryInitialAutoPlay(FeedLoaded state) {
    if (_hasInitialAutoPlay) return;

    // Find first quote in feed
    final firstQuoteItem = state.feedItems
        .whereType<QuoteFeedItem>()
        .firstOrNull;
    if (firstQuoteItem == null) return;

    final quote = firstQuoteItem.quote;
    final music = state.pairedMusic[quote.id];
    final isSoundOn = state.soundEnabledQuoteIds.contains(quote.id);

    // Auto-play when music is available and sound is enabled
    if (music != null && isSoundOn) {
      _hasInitialAutoPlay = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _audioController.playForQuote(
          quote.id,
          music.previewUrl,
          quoteTextLength: quote.text.length,
        );
      });
    }
  }

  void _onPageChanged(int index, FeedLoaded feedState) {
    final item = feedState.feedItems[index];

    // Stop current audio on page change
    _audioController.onPageChanged();

    if (item is QuoteFeedItem) {
      setState(() {
        _quotesExplored++;
      });

      // Auto-play music if sound is enabled for this quote
      final quote = item.quote;
      final music = feedState.pairedMusic[quote.id];
      final isSoundOn = feedState.soundEnabledQuoteIds.contains(quote.id);

      if (music != null && isSoundOn) {
        _audioController.playForQuote(
          quote.id,
          music.previewUrl,
          quoteTextLength: quote.text.length,
        );
      }

      // Infinite scroll: load more when near the end
      if (index >= feedState.feedItems.length - 3) {
        context.read<FeedBloc>().add(LoadMore());
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
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
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
                                Text(
                                  emoji,
                                  style: const TextStyle(fontSize: 22),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  label,
                                  style: GoogleFonts.outfit(
                                    fontSize: 15,
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (moodToTagsMap.containsKey(label)) ...[
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: (moodToTagsMap[label] ?? []).map((tag) {
                              return GestureDetector(
                                onTap: () {
                                  context.read<FeedBloc>().add(
                                    ApplyTagFilter([tag]),
                                  );
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  constraints: const BoxConstraints(
                                    minHeight: 28,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.08)
                                          : Colors.black.withValues(
                                              alpha: 0.04,
                                            ),
                                    ),
                                  ),
                                  child: Text(
                                    tag,
                                    style: GoogleFonts.outfit(
                                      fontSize: 11,
                                      color: isDark
                                          ? Colors.white38
                                          : Colors.black38,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
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
      body: FeedAudioScope(
        controller: _audioController,
        child: Stack(
          children: [
            BlocBuilder<FeedBloc, FeedState>(
              builder: (context, state) {
                if (state is FeedLoading) {
                  return const ShimmerQuoteCard();
                } else if (state is FeedError) {
                  return Center(child: Text(state.message));
                } else if (state is FeedLoaded) {
                  // Trigger auto-play for first quote when music becomes available
                  _tryInitialAutoPlay(state);

                  return Column(
                    children: [
                      // Top spacing for status bar + top bar
                      SizedBox(height: MediaQuery.of(context).padding.top + 52),

                      // Filter bar (contains mood + tags in unified row)
                      const FilterBar(),
                      const SizedBox(height: 8),

                      // Feed
                      Expanded(
                        child: Stack(
                          children: [
                            PageView.builder(
                              scrollDirection: Axis.vertical,
                              physics: const BouncingScrollPhysics(),
                              itemCount: state.feedItems.length,
                              onPageChanged: (index) =>
                                  _onPageChanged(index, state),
                              itemBuilder: (context, index) {
                                final item = state.feedItems[index];
                                return switch (item) {
                                  QuoteFeedItem(:final quote) => Center(
                                    child: QuoteCard(
                                      quote: quote,
                                      isLiked: state.likedIds.contains(
                                        quote.id,
                                      ),
                                      isBookmarked: state.bookmarkedIds
                                          .contains(quote.id),
                                      music: state.pairedMusic[quote.id],
                                      isSoundOn: state.soundEnabledQuoteIds
                                          .contains(quote.id),
                                      onToggleSound: () {
                                        final wasEnabled = state
                                            .soundEnabledQuoteIds
                                            .contains(quote.id);
                                        context.read<FeedBloc>().add(
                                          ToggleSound(quote.id),
                                        );
                                        // Handle audio playback toggle
                                        final music =
                                            state.pairedMusic[quote.id];
                                        if (music != null) {
                                          if (wasEnabled) {
                                            // Was ON, now turning OFF → stop
                                            _audioController.stop();
                                          } else {
                                            // Was OFF, now turning ON → play
                                            _audioController.playForQuote(
                                              quote.id,
                                              music.previewUrl,
                                              quoteTextLength:
                                                  quote.text.length,
                                            );
                                          }
                                        }
                                      },
                                    ),
                                  ),
                                  BreathingPromptItem() => const Center(
                                    child: BreathingPromptCard(),
                                  ),
                                };
                              },
                            ),

                            // Loading more indicator
                            if (state.isLoadingMore)
                              const Positioned(
                                bottom: 16,
                                left: 0,
                                right: 0,
                                child: ShimmerBar(width: 120, height: 4),
                              ),
                          ],
                        ),
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            // Top bar: vertical icons on left + centered branding
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 16,
              right: 16,
              child: BlocBuilder<FeedBloc, FeedState>(
                builder: (context, state) {
                  // Get accent color from current quote's gradient
                  Color accentColor = Colors.white70;
                  if (state is FeedLoaded && state.feedItems.isNotEmpty) {
                    final firstItem = state.feedItems.first;
                    if (firstItem is QuoteFeedItem) {
                      accentColor = AppTheme.getPrimaryColorForId(
                        firstItem.quote.id,
                      );
                    }
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left side: Mood selector
                      BlocBuilder<FeedBloc, FeedState>(
                        buildWhen: (prev, curr) {
                          if (prev is FeedLoaded && curr is FeedLoaded) {
                            return prev.currentMood != curr.currentMood ||
                                prev.isOffline != curr.isOffline;
                          }
                          return true;
                        },
                        builder: (context, moodState) {
                          final mood = moodState is FeedLoaded
                              ? moodState.currentMood
                              : null;
                          final isOffline = moodState is FeedLoaded
                              ? moodState.isOffline
                              : false;
                          final emoji = mood != null
                              ? _moods
                                    .firstWhere(
                                      (e) => e.$1 == mood,
                                      orElse: () => ('', '🎯'),
                                    )
                                    .$2
                              : '🎯';
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () => _showMoodSelector(context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: accentColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: accentColor.withValues(
                                        alpha: 0.25,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    emoji,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                              if (isOffline) ...[
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Offline',
                                    style: GoogleFonts.outfit(
                                      fontSize: 11,
                                      color: Colors.orange,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          );
                        },
                      ),

                      // Center: Expanded area with "Quies" branding centered
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              'Quies',
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withValues(alpha: 0.9),
                                letterSpacing: 1.5,
                              ),
                            ),
                            // Subtle progress indicator below branding
                            if (_quotesExplored > 0)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: AnimatedOpacity(
                                  opacity: 1.0,
                                  duration: const Duration(milliseconds: 600),
                                  child: Text(
                                    _quotesExplored == 1
                                        ? '1 quote explored'
                                        : '$_quotesExplored quotes explored',
                                    style: GoogleFonts.outfit(
                                      fontSize: 11,
                                      color: Colors.white.withValues(
                                        alpha: 0.4,
                                      ),
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Right side: Vertical column with settings on top, bookmarks below
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () => context.push('/settings'),
                            icon: Icon(
                              Icons.settings_rounded,
                              color: accentColor.withValues(alpha: 0.9),
                              size: 24,
                            ),
                            tooltip: 'Settings',
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.all(6),
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(height: 4),
                          IconButton(
                            onPressed: () => context.push('/bookmarks'),
                            icon: Icon(
                              Icons.collections_bookmark_rounded,
                              color: accentColor.withValues(alpha: 0.9),
                              size: 24,
                            ),
                            tooltip: 'Saved Quotes',
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.all(6),
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),

            // Welcome back overlay
            if (_showWelcomeBack)
              WelcomeBackOverlay(onDismiss: _dismissWelcomeBack),
          ],
        ),
      ),
    );
  }
}
