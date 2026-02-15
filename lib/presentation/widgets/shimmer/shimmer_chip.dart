import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// A shimmer-animated chip placeholder for tag loading states.
class ShimmerChip extends StatelessWidget {
  final double width;

  const ShimmerChip({super.key, this.width = 60});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark
        ? const Color(0xFF2A2A3E)
        : const Color(0xFFE0E0E0);
    final shimmerColor = isDark
        ? const Color(0xFF3A3A4E)
        : const Color(0xFFF0F0F0);

    return Container(
          width: width,
          height: 24,
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(12),
          ),
        )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(duration: 1200.ms, color: shimmerColor);
  }
}
