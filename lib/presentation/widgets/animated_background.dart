
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnimatedBackground extends StatelessWidget {
  const AnimatedBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base dark background
        Container(color: AppTheme.deepVoid),
        
        // Animated gradient blobs
        Positioned(
          top: -100,
          left: -100,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppTheme.nebula.withValues(alpha: 0.4), 
                  Colors.transparent
                ],
              ),
            ),
          ).animate(onPlay: (controller) => controller.repeat(reverse: true))
           .scale(duration: 4000.ms, begin: const Offset(1, 1), end: const Offset(1.2, 1.2))
           .move(duration: 6000.ms, begin: const Offset(0, 0), end: const Offset(20, 20)),
        ),

        Positioned(
          bottom: -50,
          right: -50,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppTheme.calmTeal.withValues(alpha: 0.2), 
                  Colors.transparent
                ],
              ),
            ),
          ).animate(onPlay: (controller) => controller.repeat(reverse: true))
           .scale(duration: 5000.ms, begin: const Offset(1, 1), end: const Offset(1.3, 1.3))
           .move(duration: 7000.ms, begin: const Offset(0, 0), end: const Offset(-30, -30)),
        ),
        
        // Glass overlay for texture
        Container(
          color: Colors.black.withValues(alpha: 0.1),
        ),
      ],
    );
  }
}
