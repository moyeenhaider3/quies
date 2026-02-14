import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/tag_model.dart';

/// Bottom sheet for multi-select tag filtering.
///
/// Displays available tags from the API sorted by quote count. Users can
/// select multiple tags and apply the filter.
class TagFilterSheet extends StatefulWidget {
  final List<TagModel> availableTags;
  final List<String> selectedTags;
  final ValueChanged<List<String>> onApply;

  const TagFilterSheet({
    super.key,
    required this.availableTags,
    required this.selectedTags,
    required this.onApply,
  });

  @override
  State<TagFilterSheet> createState() => _TagFilterSheetState();
}

class _TagFilterSheetState extends State<TagFilterSheet> {
  late List<String> _selected;
  String _searchQuery = '';
  bool _showAll = false;
  static const _initialVisibleCount = 30;

  @override
  void initState() {
    super.initState();
    _selected = List<String>.from(widget.selectedTags);
  }

  List<TagModel> get _filteredTags {
    var tags = widget.availableTags;
    if (_searchQuery.isNotEmpty) {
      tags = tags
          .where(
            (t) => t.name.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }
    if (!_showAll && tags.length > _initialVisibleCount) {
      tags = tags.sublist(0, _initialVisibleCount);
    }
    return tags;
  }

  void _toggleTag(String slug) {
    setState(() {
      if (_selected.contains(slug)) {
        _selected.remove(slug);
      } else {
        _selected.add(slug);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredTags = _filteredTags;
    final canShowMore =
        !_showAll &&
        widget.availableTags.length > _initialVisibleCount &&
        _searchQuery.isEmpty;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
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
                  'Filter by Tags',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                if (_selected.isNotEmpty)
                  GestureDetector(
                    onTap: () => setState(() => _selected.clear()),
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
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search tags...',
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
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          const SizedBox(height: 12),

          // Tag chips
          Expanded(
            child: widget.availableTags.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(
                          color: AppTheme.calmTeal,
                          strokeWidth: 2,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Loading tags...',
                          style: GoogleFonts.outfit(
                            color: Colors.white54,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: filteredTags.map((tag) {
                            final isSelected = _selected.contains(tag.slug);
                            return GestureDetector(
                              onTap: () => _toggleTag(tag.slug),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppTheme.calmTeal.withValues(alpha: 0.2)
                                      : Colors.white.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppTheme.calmTeal.withValues(
                                            alpha: 0.5,
                                          )
                                        : Colors.white.withValues(alpha: 0.1),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (isSelected) ...[
                                      const Icon(
                                        Icons.check_rounded,
                                        size: 14,
                                        color: AppTheme.calmTeal,
                                      ),
                                      const SizedBox(width: 4),
                                    ],
                                    Text(
                                      tag.name,
                                      style: GoogleFonts.outfit(
                                        fontSize: 13,
                                        color: isSelected
                                            ? AppTheme.calmTeal
                                            : Colors.white70,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '(${tag.quoteCount})',
                                      style: GoogleFonts.outfit(
                                        fontSize: 11,
                                        color: Colors.white38,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        if (canShowMore) ...[
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: () => setState(() => _showAll = true),
                            child: Text(
                              'Show all ${widget.availableTags.length} tags',
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                color: AppTheme.calmTeal,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
          ),

          // Apply button
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selected.isNotEmpty
                    ? () => widget.onApply(_selected)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.calmTeal,
                  disabledBackgroundColor: Colors.white.withValues(alpha: 0.08),
                  foregroundColor: AppTheme.deepVoid,
                  disabledForegroundColor: Colors.white38,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  _selected.isEmpty
                      ? 'Select tags to filter'
                      : 'Apply (${_selected.length} selected)',
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
