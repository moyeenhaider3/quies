import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../bloc/feed_bloc.dart';
import 'tag_filter_sheet.dart';

/// Horizontal filter bar displayed at the top of the feed.
///
/// Shows mood, tags, and author filter chips. Active filters are highlighted
/// with teal accent. A clear button appears when any filter is active.
class FilterBar extends StatelessWidget {
  const FilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeedBloc, FeedState>(
      buildWhen: (prev, curr) {
        if (prev is FeedLoaded && curr is FeedLoaded) {
          return prev.activeTags != curr.activeTags ||
              prev.activeAuthorSlug != curr.activeAuthorSlug ||
              prev.currentMood != curr.currentMood ||
              prev.availableTags != curr.availableTags;
        }
        return true;
      },
      builder: (context, state) {
        if (state is! FeedLoaded) return const SizedBox.shrink();

        final hasFilters = state.hasFilters;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Chip row
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  // Clear All chip (first when filters active)
                  if (hasFilters) ...[
                    _FilterChip(
                      label: 'Clear All',
                      icon: Icons.close_rounded,
                      isActive: false,
                      isClear: true,
                      onTap: () {
                        context.read<FeedBloc>().add(ClearFilters());
                      },
                    ),
                    const SizedBox(width: 10),
                  ],

                  // Tags chip
                  _FilterChip(
                    label: state.activeTags.isNotEmpty
                        ? 'Tags (${state.activeTags.length})'
                        : 'Tags',
                    icon: Icons.label_outline_rounded,
                    isActive: state.activeTags.isNotEmpty,
                    onTap: () => _showTagSheet(context, state),
                  ),
                ],
              ),
            ),

            // Active filter badges
            if (state.activeTags.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 6, right: 16),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    ...state.activeTags.map(
                      (tag) => _ActiveBadge(
                        label: tag,
                        onClear: () {
                          final updated = List<String>.from(state.activeTags)
                            ..remove(tag);
                          if (updated.isEmpty) {
                            context.read<FeedBloc>().add(ClearFilters());
                          } else {
                            context.read<FeedBloc>().add(
                              ApplyTagFilter(updated),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
          ],
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

  // Author sheet hidden for now — kept for future use
  // void _showAuthorSheet(BuildContext context, FeedLoaded state) { ... }
}

/// A single filter chip in the bar.
class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final bool isClear;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.isActive,
    this.isClear = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.calmTeal.withValues(alpha: 0.2)
              : isClear
              ? (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04))
              : (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.06)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? AppTheme.calmTeal.withValues(alpha: 0.4)
                : (isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.1)),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? AppTheme.calmTeal : (isDark ? Colors.white54 : Colors.black54),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 13,
                color: isActive ? AppTheme.calmTeal : (isDark ? Colors.white70 : Colors.black87),
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            if (isActive) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.close_rounded,
                size: 14,
                color: AppTheme.calmTeal.withValues(alpha: 0.7),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A small active-filter badge with remove button.
class _ActiveBadge extends StatelessWidget {
  final String label;
  final VoidCallback onClear;

  const _ActiveBadge({required this.label, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.calmTeal.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 11,
              color: AppTheme.calmTeal,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onClear,
            child: Icon(
              Icons.close_rounded,
              size: 12,
              color: AppTheme.calmTeal.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
