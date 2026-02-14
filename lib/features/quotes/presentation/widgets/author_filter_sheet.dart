import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/author_model.dart';
import '../bloc/feed_bloc.dart';

/// Bottom sheet for author search and selection.
///
/// Provides a search field with 300ms debounce that queries the API for
/// authors. Selecting an author dispatches [ApplyAuthorFilter].
class AuthorFilterSheet extends StatefulWidget {
  final String? currentAuthorSlug;
  final void Function(String slug, String name) onSelect;

  const AuthorFilterSheet({
    super.key,
    this.currentAuthorSlug,
    required this.onSelect,
  });

  @override
  State<AuthorFilterSheet> createState() => _AuthorFilterSheetState();
}

class _AuthorFilterSheetState extends State<AuthorFilterSheet> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (query.length >= 2) {
        context.read<FeedBloc>().add(SearchAuthors(query));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.65,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.deepVoid,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  'Filter by Author',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                if (widget.currentAuthorSlug != null)
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      context.read<FeedBloc>().add(ClearFilters());
                    },
                    child: Text(
                      'Clear',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: AppTheme.calmTeal,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Search field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 14),
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Type to search authors...',
                hintStyle: GoogleFonts.outfit(color: Colors.white38),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Colors.white38,
                  size: 20,
                ),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.08),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          const SizedBox(height: 8),

          // Results
          Expanded(
            child: BlocBuilder<FeedBloc, FeedState>(
              buildWhen: (prev, curr) {
                if (prev is FeedLoaded && curr is FeedLoaded) {
                  return prev.authorSearchResults != curr.authorSearchResults;
                }
                return false;
              },
              builder: (context, state) {
                if (state is! FeedLoaded) return const SizedBox.shrink();

                final results = state.authorSearchResults;
                final query = _searchController.text;

                if (query.length < 2) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.person_search_rounded,
                          size: 48,
                          color: Colors.white.withValues(alpha: 0.15),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Type to search authors',
                          style: GoogleFonts.outfit(
                            color: Colors.white38,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (results.isEmpty) {
                  return Center(
                    child: Text(
                      'No authors found',
                      style: GoogleFonts.outfit(
                        color: Colors.white38,
                        fontSize: 14,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final author = results[index];
                    final isSelected = author.slug == widget.currentAuthorSlug;

                    return _AuthorTile(
                      author: author,
                      isSelected: isSelected,
                      onTap: () => widget.onSelect(author.slug, author.name),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthorTile extends StatelessWidget {
  final AuthorModel author;
  final bool isSelected;
  final VoidCallback onTap;

  const _AuthorTile({
    required this.author,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.calmTeal.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Author avatar placeholder
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
              child: Center(
                child: Text(
                  author.name.isNotEmpty ? author.name[0].toUpperCase() : '?',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? AppTheme.calmTeal : Colors.white54,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Name + bio
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    author.name,
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? AppTheme.calmTeal : Colors.white,
                    ),
                  ),
                  if (author.description.isNotEmpty)
                    Text(
                      author.description,
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: Colors.white38,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),

            // Quote count
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${author.quoteCount}',
                style: GoogleFonts.outfit(fontSize: 12, color: Colors.white54),
              ),
            ),

            if (isSelected) ...[
              const SizedBox(width: 8),
              const Icon(
                Icons.check_circle_rounded,
                size: 20,
                color: AppTheme.calmTeal,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
