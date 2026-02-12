import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';

/// A full-screen breathing prompt card that appears in the feed
/// to encourage mindful pauses between quotes.
class BreathingPromptCard extends StatefulWidget {
  const BreathingPromptCard({super.key});

  @override
  State<BreathingPromptCard> createState() => _BreathingPromptCardState();
}

class _BreathingPromptCardState extends State<BreathingPromptCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _breathAnimation;
  late final Animation<double> _opacityAnimation;

  // Full breathing cycle: 4s in + 4s out = 8s
  static const _cycleDuration = Duration(seconds: 8);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _cycleDuration)
      ..repeat();

    // Scale: 0.6 → 1.0 (breathe in), 1.0 → 0.6 (breathe out)
    _breathAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.6,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 0.6,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_controller);

    // Glow opacity pulses with breath
    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.3,
          end: 0.7,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 0.7,
          end: 0.3,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getBreathText(double progress) {
    // First half = breathe in, second half = breathe out
    return progress < 0.5 ? 'Breathe in…' : 'Breathe out…';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1A1A2E)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final scale = _breathAnimation.value;
          final glowOpacity = _opacityAnimation.value;
          final breathText = _getBreathText(_controller.value);

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Breathing guidance text
              Text(
                'Take a moment',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 48),

              // Breathing circle with glow
              SizedBox(
                width: 200,
                height: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer glow ring
                    Transform.scale(
                      scale: scale * 1.2,
                      child: Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.calmTeal.withValues(
                                alpha: glowOpacity * 0.4,
                              ),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Main breathing circle
                    Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppTheme.calmTeal.withValues(alpha: glowOpacity),
                              AppTheme.calmTeal.withValues(
                                alpha: glowOpacity * 0.3,
                              ),
                            ],
                          ),
                          border: Border.all(
                            color: AppTheme.calmTeal.withValues(
                              alpha: glowOpacity * 0.6,
                            ),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    // Inner dot
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(
                          alpha: glowOpacity * 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Breathe in / Breathe out text
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 600),
                child: Text(
                  breathText,
                  key: ValueKey(breathText),
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    color: AppTheme.calmTeal.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w300,
                    letterSpacing: 2.0,
                  ),
                ),
              ),

              const SizedBox(height: 64),

              // Subtle swipe hint
              Text(
                'Swipe to continue',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.3),
                  letterSpacing: 1.0,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
