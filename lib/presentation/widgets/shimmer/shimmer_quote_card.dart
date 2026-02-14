import 'package:flutter/material.dart';

import 'shimmer_chip.dart';
import 'shimmer_circle.dart';
import 'shimmer_line.dart';

/// A full-screen shimmer skeleton that mimics the QuoteCard layout.
///
/// Shows placeholder lines for quote text, author, tags, and action buttons
/// while content is loading.
class ShimmerQuoteCard extends StatelessWidget {
  const ShimmerQuoteCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Quote text lines
            const ShimmerLine(width: double.infinity),
            const SizedBox(height: 12),
            const ShimmerLine(width: double.infinity),
            const SizedBox(height: 12),
            const ShimmerLine(width: 200),
            const SizedBox(height: 24),

            // Author line
            const ShimmerLine(width: 140, height: 14),
            const SizedBox(height: 16),

            // Tag chips
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShimmerChip(width: 60),
                SizedBox(width: 8),
                ShimmerChip(width: 75),
                SizedBox(width: 8),
                ShimmerChip(width: 50),
              ],
            ),
            const SizedBox(height: 32),

            // Action button circles (Share, Like, Save, Author)
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ShimmerCircle(size: 44),
                ShimmerCircle(size: 44),
                ShimmerCircle(size: 44),
                ShimmerCircle(size: 44),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
