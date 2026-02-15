import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../presentation/widgets/shimmer/shimmer_line.dart';
import '../../../../presentation/widgets/shimmer/shimmer_quote_card.dart';
import '../../data/models/author_detail_model.dart';
import '../../data/models/remote_quote_model.dart';
import '../../domain/repositories/quote_repository.dart';

class AuthorDetailModal extends StatefulWidget {
  final String authorSlug;
  final String authorName;

  const AuthorDetailModal({
    super.key,
    required this.authorSlug,
    required this.authorName,
  });

  /// Show the author detail modal using a general dialog overlay.
  static void show(
    BuildContext context, {
    required String authorSlug,
    required String authorName,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Author detail',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (context, anim, secondAnim, child) {
        return FadeTransition(opacity: anim, child: child);
      },
      pageBuilder: (context, anim1, anim2) {
        return AuthorDetailModal(
          authorSlug: authorSlug,
          authorName: authorName,
        );
      },
    );
  }

  @override
  State<AuthorDetailModal> createState() => _AuthorDetailModalState();
}

class _AuthorDetailModalState extends State<AuthorDetailModal> {
  AuthorDetailModel? _authorDetail;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchAuthor();
  }

  Future<void> _fetchAuthor() async {
    final repository = GetIt.instance<QuoteRepository>();
    final result = await repository.getAuthorBySlug(widget.authorSlug);
    if (!mounted) return;
    result.fold(
      (failure) => setState(() {
        _error = 'Could not load author';
        _isLoading = false;
      }),
      (detail) => setState(() {
        _authorDetail = detail;
        _isLoading = false;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final modalHeight = MediaQuery.of(context).size.height * 0.8;
    final modalWidth = MediaQuery.of(context).size.width - 48;

    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: GestureDetector(
            onTap: () {}, // absorb taps on modal body
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Modal container
                Container(
                  height: modalHeight,
                  width: modalWidth,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.06),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: _buildContent(isDark, modalHeight),
                  ),
                ),
                // Close button below modal
                const SizedBox(height: 16),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close_rounded,
                    color: isDark ? Colors.white : const Color(0xB3000000),
                    size: 28,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.08),
                    fixedSize: const Size(48, 48),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(bool isDark, double modalHeight) {
    if (_isLoading) {
      return _buildLoadingState(isDark);
    }
    if (_error != null) {
      return _buildErrorState(isDark);
    }
    return _buildLoadedState(isDark, modalHeight);
  }

  Widget _buildLoadingState(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerLine(width: 200, height: 24),
          const SizedBox(height: 12),
          const ShimmerLine(width: 160, height: 14),
          const SizedBox(height: 20),
          const ShimmerLine(width: double.infinity, height: 14),
          const SizedBox(height: 8),
          const ShimmerLine(width: double.infinity, height: 14),
          const SizedBox(height: 8),
          const ShimmerLine(width: 220, height: 14),
          const Spacer(),
          const ShimmerQuoteCard(),
        ],
      ),
    );
  }

  Widget _buildErrorState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          _error!,
          style: GoogleFonts.outfit(
            fontSize: 16,
            color: isDark ? Colors.white54 : Colors.black45,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadedState(bool isDark, double modalHeight) {
    final author = _authorDetail!.author;
    final quotes = _authorDetail!.quotes;
    final mutedColor = isDark ? Colors.white54 : Colors.black45;
    final textColor = isDark ? Colors.white70 : Colors.black87;
    final carouselHeight = modalHeight * 0.45;

    return Column(
      children: [
        // Author info — scrollable
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  author.name,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ).animate().fadeIn(duration: 400.ms),
                const SizedBox(height: 8),
                if (author.description.isNotEmpty)
                  Text(
                    author.description,
                    style: GoogleFonts.outfit(fontSize: 14, color: mutedColor),
                  ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
                const SizedBox(height: 16),
                if (author.bio.isNotEmpty)
                  Text(
                    author.bio,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      height: 1.6,
                      color: textColor,
                    ),
                  ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.calmTeal.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '📝 ${author.quoteCount} quotes',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: AppTheme.calmTeal,
                    ),
                  ),
                ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        // Quote carousel
        if (quotes.isNotEmpty)
          SizedBox(
                height: carouselHeight,
                child: PageView.builder(
                  controller: PageController(viewportFraction: 0.85),
                  itemCount: quotes.length,
                  itemBuilder: (context, index) {
                    final rq = quotes[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: GestureDetector(
                        onTap: () => _openQuoteDetail(context, rq),
                        child: _buildCarouselCard(rq),
                      ),
                    );
                  },
                ),
              )
              .animate()
              .fadeIn(delay: 400.ms, duration: 500.ms)
              .slideY(begin: 0.1, end: 0),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildCarouselCard(RemoteQuote rq) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.getGradientForId(rq.id),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: Text(
                rq.content,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 18,
                  color: Colors.white,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
                maxLines: 8,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (rq.tags.isNotEmpty)
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: rq.tags.take(3).map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Text(
                    tag,
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      color: Colors.white60,
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  void _openQuoteDetail(BuildContext context, RemoteQuote rq) {
    final quote = rq.toQuote();
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => _QuoteDetailScreen(quote: quote)));
  }
}

/// Simple full-screen quote detail view opened from the carousel.
class _QuoteDetailScreen extends StatelessWidget {
  final dynamic quote;

  const _QuoteDetailScreen({required this.quote});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: AppTheme.getGradientForId(quote.id),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Back button
              Positioned(
                top: 16,
                left: 16,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white70,
                  ),
                ),
              ),
              // Quote content
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        quote.text,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 24,
                          color: Colors.white,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        '- ${quote.author}',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          color: Colors.white70,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (quote.tags.isNotEmpty)
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          alignment: WrapAlignment.center,
                          children: (quote.tags as List<String>).take(3).map((
                            tag,
                          ) {
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
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
