import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// A shimmer-animated small bar for load-more indicators.
class ShimmerBar extends StatelessWidget {
  final double width;
  final double height;

  const ShimmerBar({super.key, this.width = 120, this.height = 4});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark
        ? const Color(0xFF2A2A3E)
        : const Color(0xFFE0E0E0);
    final shimmerColor = isDark
        ? const Color(0xFF3A3A4E)
        : const Color(0xFFF0F0F0);

    return Center(
      child:
          Container(
                width: width,
                height: height,
                decoration: BoxDecoration(
                  color: baseColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              )
              .animate(onPlay: (controller) => controller.repeat())
              .shimmer(duration: 1200.ms, color: shimmerColor),
    );
  }
}
