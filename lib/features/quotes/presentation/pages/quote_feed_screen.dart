import 'dart:ui';

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
import '../widgets/quote_card.dart';
import '../widgets/tag_filter_sheet.dart';
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
  double _headerGlassOpacity = 0.0;

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
          trackId: music.trackId,
        );
      });
    }
  }

  void _onPageChanged(int index, FeedLoaded feedState) {
    final item = feedState.feedItems[index];

    // Stop current audio on page change
    _audioController.onPageChanged();

    // Glass header intensifies after first page
    setState(() {
      _headerGlassOpacity = index > 0 ? 1.0 : 0.0;
    });

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
          trackId: music.trackId,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'How are you feeling?',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        _showTagBubblesModal(context);
                      },
                      child: Icon(
                        Icons.info_outline_rounded,
                        size: 20,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.4)
                            : Colors.black.withValues(alpha: 0.35),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: _moods.map((entry) {
                    final (label, emoji) = entry;
                    return GestureDetector(
                      onTap: () {
                        context.read<FeedBloc>().add(ChangeMood(label));
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.06)
                              : Colors.black.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.black.withValues(alpha: 0.06),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(emoji, style: const TextStyle(fontSize: 18)),
                            const SizedBox(width: 6),
                            Text(
                              label,
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                color: isDark ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                _showMoodTagsForMood(context, label);
                              },
                              child: Icon(
                                Icons.info_outline_rounded,
                                size: 16,
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.35)
                                    : Colors.black.withValues(alpha: 0.3),
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

  void _showTagSheet(BuildContext context, FeedLoaded state) {
    // Load tags if not yet loaded
    if (state.availableTags.isEmpty) {
      context.read<FeedBloc>().add(LoadTags());
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<FeedBloc>(),
        child: BlocBuilder<FeedBloc, FeedState>(
          builder: (ctx, s) {
            final loaded = s is FeedLoaded ? s : state;
            return TagFilterSheet(
              availableTags: loaded.availableTags,
              selectedTags: loaded.activeTags,
              onApply: (tags) {
                Navigator.of(ctx).pop();
                ctx.read<FeedBloc>().add(ApplyTagFilter(tags));
              },
            );
          },
        ),
      ),
    );
  }

  void _showMoodTagsForMood(BuildContext context, String moodLabel) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final moodTags = moodToTagsMap[moodLabel] ?? [];

    if (moodTags.isEmpty) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
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
                const SizedBox(height: 16),
                Text(
                  'Tags for "$moodLabel"',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap a tag to filter quotes',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: moodTags.map((tag) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        context.read<FeedBloc>().add(ApplyTagFilter([tag]));
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.06)
                              : Colors.black.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.black.withValues(alpha: 0.06),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.label_outline_rounded,
                              size: 14,
                              color: AppTheme.calmTeal.withValues(alpha: 0.6),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              tag,
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                color: isDark ? Colors.white70 : Colors.black87,
                                fontWeight: FontWeight.w400,
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

  void _showTagBubblesModal(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Collect all unique tags from mood-to-tags mapping
    final allTags = <String>{};
    for (final tags in moodToTagsMap.values) {
      allTags.addAll(tags);
    }
    final tagList = allTags.toList()..sort();

    // Icons for variety in bubbles
    const tagIcons = [
      Icons.spa_rounded,
      Icons.favorite_rounded,
      Icons.lightbulb_outline_rounded,
      Icons.auto_awesome_rounded,
      Icons.psychology_rounded,
      Icons.self_improvement_rounded,
      Icons.wb_sunny_rounded,
      Icons.nightlight_round,
      Icons.local_florist_rounded,
      Icons.anchor_rounded,
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.85,
          expand: false,
          builder: (_, scrollController) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.black12,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Explore Tags',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap a tag to filter quotes',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: tagList.asMap().entries.map((entry) {
                            final index = entry.key;
                            final tag = entry.value;
                            final icon = tagIcons[index % tagIcons.length];
                            // Varied sizes for bubble effect
                            final sizeVariant = index % 3;
                            final fontSize = sizeVariant == 0
                                ? 13.0
                                : sizeVariant == 1
                                ? 12.0
                                : 14.0;
                            final hPad = sizeVariant == 0
                                ? 14.0
                                : sizeVariant == 1
                                ? 10.0
                                : 16.0;
                            final vPad = sizeVariant == 0
                                ? 10.0
                                : sizeVariant == 1
                                ? 8.0
                                : 12.0;

                            return GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                context.read<FeedBloc>().add(
                                  ApplyTagFilter([tag]),
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: hPad,
                                  vertical: vPad,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.06)
                                      : Colors.black.withValues(alpha: 0.04),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.08)
                                        : Colors.black.withValues(alpha: 0.06),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      icon,
                                      size: 14,
                                      color: AppTheme.calmTeal.withValues(
                                        alpha: 0.6,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      tag,
                                      style: GoogleFonts.outfit(
                                        fontSize: fontSize,
                                        color: isDark
                                            ? Colors.white70
                                            : Colors.black87,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
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
                                              trackId: music.trackId,
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

            // Top bar: frosted glass header with branding
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: ClipRect(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: _headerGlassOpacity * 15.0,
                      sigmaY: _headerGlassOpacity * 15.0,
                    ),
                    child: Builder(
                      builder: (context) {
                        final isDark =
                            Theme.of(context).brightness == Brightness.dark;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                          padding: EdgeInsets.only(
                            top: MediaQuery.of(context).padding.top + 8,
                            left: 16,
                            right: 16,
                            bottom: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.black.withValues(
                                    alpha: _headerGlassOpacity * 0.5,
                                  )
                                : Colors.white.withValues(
                                    alpha: _headerGlassOpacity * 0.7,
                                  ),
                            border: Border(
                              bottom: BorderSide(
                                color: isDark
                                    ? Colors.white.withValues(
                                        alpha: _headerGlassOpacity * 0.06,
                                      )
                                    : Colors.black.withValues(
                                        alpha: _headerGlassOpacity * 0.06,
                                      ),
                              ),
                            ),
                            boxShadow: _headerGlassOpacity > 0
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: _headerGlassOpacity * 0.08,
                                      ),
                                      blurRadius: 12,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: BlocBuilder<FeedBloc, FeedState>(
                            builder: (context, state) {
                              final isDark =
                                  Theme.of(context).brightness ==
                                  Brightness.dark;
                              // Get accent color from current quote's gradient
                              Color accentColor = isDark
                                  ? Colors.white70
                                  : const Color(0xFF475569);
                              if (state is FeedLoaded &&
                                  state.feedItems.isNotEmpty) {
                                final firstItem = state.feedItems.first;
                                if (firstItem is QuoteFeedItem) {
                                  accentColor = AppTheme.getPrimaryColorForId(
                                    firstItem.quote.id,
                                  );
                                }
                              }

                              final loadedState = state is FeedLoaded
                                  ? state
                                  : null;
                              final hasFilters =
                                  loadedState?.hasFilters ?? false;
                              final activeTags = loadedState?.activeTags ?? [];

                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Row 1: Mood+Tags (left) | Quies (center) | Settings+Bookmark (right)
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Left column: Mood + Tags buttons
                                      BlocBuilder<FeedBloc, FeedState>(
                                        buildWhen: (prev, curr) {
                                          if (prev is FeedLoaded &&
                                              curr is FeedLoaded) {
                                            return prev.currentMood !=
                                                    curr.currentMood ||
                                                prev.isOffline !=
                                                    curr.isOffline ||
                                                prev.activeTags !=
                                                    curr.activeTags;
                                          }
                                          return true;
                                        },
                                        builder: (context, moodState) {
                                          final mood = moodState is FeedLoaded
                                              ? moodState.currentMood
                                              : null;
                                          final isOffline =
                                              moodState is FeedLoaded
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
                                          final tagCount =
                                              moodState is FeedLoaded
                                              ? moodState.activeTags.length
                                              : 0;
                                          return Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Mood button
                                              GestureDetector(
                                                onTap: () =>
                                                    _showMoodSelector(context),
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 6,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: accentColor
                                                        .withValues(
                                                          alpha: 0.15,
                                                        ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          16,
                                                        ),
                                                    border: Border.all(
                                                      color: accentColor
                                                          .withValues(
                                                            alpha: 0.25,
                                                          ),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    emoji,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              // Tags button
                                              GestureDetector(
                                                onTap: () {
                                                  if (loadedState != null) {
                                                    _showTagSheet(
                                                      context,
                                                      loadedState,
                                                    );
                                                  }
                                                },
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 5,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: tagCount > 0
                                                        ? AppTheme.calmTeal
                                                              .withValues(
                                                                alpha: 0.2,
                                                              )
                                                        : (isDark
                                                              ? Colors.white
                                                                    .withValues(
                                                                      alpha:
                                                                          0.1,
                                                                    )
                                                              : Colors.black
                                                                    .withValues(
                                                                      alpha:
                                                                          0.06,
                                                                    )),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          14,
                                                        ),
                                                    border: Border.all(
                                                      color: tagCount > 0
                                                          ? AppTheme.calmTeal
                                                                .withValues(
                                                                  alpha: 0.4,
                                                                )
                                                          : (isDark
                                                                ? Colors.white
                                                                      .withValues(
                                                                        alpha:
                                                                            0.12,
                                                                      )
                                                                : Colors.black
                                                                      .withValues(
                                                                        alpha:
                                                                            0.1,
                                                                      )),
                                                    ),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .label_outline_rounded,
                                                        size: 14,
                                                        color: tagCount > 0
                                                            ? AppTheme.deepVoid
                                                                  .withOpacity(
                                                                    0.8,
                                                                  )
                                                            : (isDark
                                                                  ? Colors
                                                                        .white54
                                                                  : Colors
                                                                        .black54),
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        tagCount > 0
                                                            ? 'Tags ($tagCount)'
                                                            : 'Tags',
                                                        style: GoogleFonts.outfit(
                                                          fontSize: 12,
                                                          color: tagCount > 0
                                                              ? AppTheme
                                                                    .deepVoid
                                                                    .withOpacity(
                                                                      0.8,
                                                                    )
                                                              : (isDark
                                                                    ? Colors
                                                                          .white70
                                                                    : Colors
                                                                          .black87),
                                                          fontWeight:
                                                              tagCount > 0
                                                              ? FontWeight.w600
                                                              : FontWeight.w400,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              if (isOffline) ...[
                                                const SizedBox(height: 6),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.orange
                                                        .withValues(alpha: 0.2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    'Offline',
                                                    style: GoogleFonts.outfit(
                                                      fontSize: 11,
                                                      color: Colors.orange,
                                                      fontWeight:
                                                          FontWeight.w500,
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
                                              style:
                                                  GoogleFonts.playfairDisplay(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w600,
                                                    color: isDark
                                                        ? Colors.white
                                                              .withValues(
                                                                alpha: 0.9,
                                                              )
                                                        : Theme.of(context)
                                                              .colorScheme
                                                              .onSurface,
                                                    letterSpacing: 1.5,
                                                  ),
                                            ),
                                            // Subtle progress indicator below branding
                                            if (_quotesExplored > 0)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 4,
                                                ),
                                                child: AnimatedOpacity(
                                                  opacity: 1.0,
                                                  duration: const Duration(
                                                    milliseconds: 600,
                                                  ),
                                                  child: Text(
                                                    _quotesExplored == 1
                                                        ? '1 quote explored'
                                                        : '$_quotesExplored quotes explored',
                                                    style: GoogleFonts.outfit(
                                                      fontSize: 11,
                                                      color: isDark
                                                          ? Colors.white
                                                                .withValues(
                                                                  alpha: 0.4,
                                                                )
                                                          : Theme.of(context)
                                                                .colorScheme
                                                                .onSurface
                                                                .withValues(
                                                                  alpha: 0.5,
                                                                ),
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      letterSpacing: 0.5,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),

                                      // Right column: Settings + Bookmark
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            onPressed: () =>
                                                context.push('/settings'),
                                            icon: Icon(
                                              Icons.settings_rounded,
                                              color: accentColor.withValues(
                                                alpha: 0.9,
                                              ),
                                              size: 24,
                                            ),
                                            tooltip: 'Settings',
                                            visualDensity:
                                                VisualDensity.compact,
                                            padding: const EdgeInsets.all(6),
                                            constraints: const BoxConstraints(),
                                          ),
                                          const SizedBox(height: 4),
                                          IconButton(
                                            onPressed: () =>
                                                context.push('/bookmarks'),
                                            icon: Icon(
                                              Icons
                                                  .collections_bookmark_rounded,
                                              color: accentColor.withValues(
                                                alpha: 0.9,
                                              ),
                                              size: 24,
                                            ),
                                            tooltip: 'Saved Quotes',
                                            visualDensity:
                                                VisualDensity.compact,
                                            padding: const EdgeInsets.all(6),
                                            constraints: const BoxConstraints(),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),

                                  // Row 2: Active filter chips (only when filters active)
                                  if (hasFilters)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: SizedBox(
                                        height: 32,
                                        child: ListView(
                                          scrollDirection: Axis.horizontal,
                                          children: [
                                            // Clear All chip
                                            GestureDetector(
                                              onTap: () {
                                                context.read<FeedBloc>().add(
                                                  ClearFilters(),
                                                );
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 6,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: isDark
                                                      ? Colors.white.withValues(
                                                          alpha: 0.05,
                                                        )
                                                      : Colors.black.withValues(
                                                          alpha: 0.04,
                                                        ),
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                  border: Border.all(
                                                    color: isDark
                                                        ? Colors.white
                                                              .withValues(
                                                                alpha: 0.12,
                                                              )
                                                        : Colors.black
                                                              .withValues(
                                                                alpha: 0.1,
                                                              ),
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.close_rounded,
                                                      size: 14,
                                                      color: isDark
                                                          ? Colors.white54
                                                          : Colors.black54,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      'Clear All',
                                                      style: GoogleFonts.outfit(
                                                        fontSize: 12,
                                                        color: isDark
                                                            ? Colors.white70
                                                            : Colors.black87,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            // Active tag chips
                                            ...activeTags.map((tag) {
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                  right: 6,
                                                ),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    final updated =
                                                        List<String>.from(
                                                          activeTags,
                                                        )..remove(tag);
                                                    if (updated.isEmpty) {
                                                      context
                                                          .read<FeedBloc>()
                                                          .add(ClearFilters());
                                                    } else {
                                                      context
                                                          .read<FeedBloc>()
                                                          .add(
                                                            ApplyTagFilter(
                                                              updated,
                                                            ),
                                                          );
                                                    }
                                                  },
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 10,
                                                          vertical: 6,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: AppTheme.calmTeal
                                                          .withValues(
                                                            alpha: 0.15,
                                                          ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            16,
                                                          ),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Text(
                                                          tag,
                                                          style:
                                                              GoogleFonts.outfit(
                                                                fontSize: 12,
                                                                color: AppTheme
                                                                    .deepVoid
                                                                    .withOpacity(
                                                                      0.8,
                                                                    ),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                        ),
                                                        const SizedBox(
                                                          width: 4,
                                                        ),
                                                        Icon(
                                                          Icons.close_rounded,
                                                          size: 12,
                                                          color: AppTheme
                                                              .deepVoid
                                                              .withOpacity(0.8),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
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
