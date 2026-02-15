import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../presentation/widgets/animated_background.dart';
import '../../../../presentation/widgets/primary_button.dart';
import '../cubit/onboarding_cubit.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<OnboardingCubit>(),
      child: const _OnboardingView(),
    );
  }
}

class _OnboardingView extends StatefulWidget {
  const _OnboardingView();

  @override
  State<_OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<_OnboardingView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  static const int _totalPages = 5;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OnboardingCubit, OnboardingState>(
      listener: (context, state) {
        if (state.isCompleted) {
          context.go('/home');
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: Stack(
            children: [
              const AnimatedBackground(),
              SafeArea(
                child: Column(
                  children: [
                    // Top bar with back + skip
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Back button (hidden on first page)
                          AnimatedOpacity(
                            opacity: _currentPage > 0 ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 300),
                            child: IconButton(
                              onPressed: _currentPage > 0
                                  ? _previousPage
                                  : null,
                              icon: Icon(
                                Icons.arrow_back_ios_rounded,
                                color: AppTheme.starlight.withValues(
                                  alpha: 0.6,
                                ),
                                size: 20,
                              ),
                            ),
                          ),
                          // Skip button (hidden on last page)
                          if (_currentPage < _totalPages - 1)
                            TextButton(
                              onPressed: () => context
                                  .read<OnboardingCubit>()
                                  .skipOnboarding(),
                              child: Text(
                                'Skip',
                                style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.starlight.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                              ),
                            )
                          else
                            const SizedBox(width: 48),
                        ],
                      ),
                    ),

                    // Page content
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() => _currentPage = index);
                          context.read<OnboardingCubit>().pageChanged(index);
                        },
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _WelcomePage(onStart: _nextPage),
                          _MoodPage(onContinue: _nextPage),
                          _ThemePage(onContinue: _nextPage),
                          _GoalPage(onContinue: _nextPage),
                          const _CompletionPage(),
                        ],
                      ),
                    ),

                    // Bottom progress indicators
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_totalPages, (index) {
                          final isActive = index == _currentPage;
                          final isPast = index < _currentPage;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: isActive ? 28 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? AppTheme.calmTeal
                                  : isPast
                                  ? AppTheme.calmTeal.withValues(alpha: 0.5)
                                  : AppTheme.starlight.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Page 1: Welcome
// ─────────────────────────────────────────────────────────────────

class _WelcomePage extends StatelessWidget {
  final VoidCallback onStart;
  const _WelcomePage({required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),

          // Breathing circle animation
          Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.calmTeal.withValues(alpha: 0.3),
                      AppTheme.calmTeal.withValues(alpha: 0.05),
                    ],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.spa_rounded,
                    size: 48,
                    color: AppTheme.calmTeal,
                  ),
                ),
              )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                duration: 3000.ms,
                begin: const Offset(0.9, 0.9),
                end: const Offset(1.1, 1.1),
                curve: Curves.easeInOut,
              ),

          const SizedBox(height: 40),

          Text(
            'Quies',
            style: GoogleFonts.playfairDisplay(
              fontSize: 52,
              fontWeight: FontWeight.bold,
              color: AppTheme.calmTeal,
              letterSpacing: 2,
            ),
          ).animate().fadeIn(duration: 800.ms).moveY(begin: 20, end: 0),

          const SizedBox(height: 16),

          Text(
            'Find your inner calm\nthrough guided stillness.',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 18,
              color: AppTheme.starlight.withValues(alpha: 0.8),
              height: 1.5,
            ),
          ).animate().fadeIn(delay: 300.ms, duration: 800.ms),

          const Spacer(flex: 3),

          PrimaryButton(label: 'Begin Journey', onPressed: onStart)
              .animate()
              .fadeIn(delay: 600.ms, duration: 800.ms)
              .moveY(begin: 20, end: 0),

          const Spacer(flex: 1),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Page 2: How are you feeling? (Mood selection)
// ─────────────────────────────────────────────────────────────────

class _MoodPage extends StatelessWidget {
  final VoidCallback onContinue;
  const _MoodPage({required this.onContinue});

  static const _moods = [
    ('Calm', '😌', 'Seeking stillness'),
    ('Energized', '⚡', 'Ready to conquer'),
    ('Reflective', '🤔', 'Thinking deeply'),
    ('Anxious', '😰', 'Feeling unsettled'),
    ('Grateful', '🙏', 'Counting blessings'),
    ('Hopeful', '🌅', 'Looking ahead'),
    ('Stressed', '😣', 'Under pressure'),
    ('Tired', '😴', 'Low on energy'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),

                  Text(
                    'How are you\nfeeling right now?',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.starlight,
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(duration: 600.ms),

                  const SizedBox(height: 12),
                  Text(
                    'This helps us personalize your experience',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: AppTheme.starlight.withValues(alpha: 0.5),
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 200.ms, duration: 600.ms),

                  const SizedBox(height: 40),

                  BlocBuilder<OnboardingCubit, OnboardingState>(
                    builder: (context, state) {
                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        alignment: WrapAlignment.center,
                        children: _moods.asMap().entries.map((entry) {
                          final index = entry.key;
                          final (label, emoji, subtitle) = entry.value;
                          final isSelected = state.selectedMood == label;
                          return GestureDetector(
                                onTap: () => context
                                    .read<OnboardingCubit>()
                                    .updateMood(label),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  width:
                                      (MediaQuery.of(context).size.width - 72) /
                                      2,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppTheme.calmTeal.withValues(
                                            alpha: 0.15,
                                          )
                                        : AppTheme.softGlass,
                                    border: Border.all(
                                      color: isSelected
                                          ? AppTheme.calmTeal
                                          : Colors.transparent,
                                      width: 1.5,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        emoji,
                                        style: const TextStyle(fontSize: 28),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              label,
                                              style: GoogleFonts.outfit(
                                                fontSize: 15,
                                                fontWeight: isSelected
                                                    ? FontWeight.w600
                                                    : FontWeight.w500,
                                                color: isSelected
                                                    ? AppTheme.calmTeal
                                                    : AppTheme.starlight,
                                              ),
                                            ),
                                            Text(
                                              subtitle,
                                              style: GoogleFonts.outfit(
                                                fontSize: 11,
                                                color: AppTheme.starlight
                                                    .withValues(alpha: 0.45),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .animate()
                              .fadeIn(delay: (100 * index).ms, duration: 400.ms)
                              .moveY(begin: 10, end: 0);
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          BlocBuilder<OnboardingCubit, OnboardingState>(
            builder: (context, state) {
              final isEnabled = state.selectedMood != null;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: isEnabled ? 1.0 : 0.4,
                  child: PrimaryButton(
                    label: 'Continue',
                    onPressed: isEnabled ? onContinue : () {},
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Page 3: Quote themes / categories
// ─────────────────────────────────────────────────────────────────

class _ThemePage extends StatelessWidget {
  final VoidCallback onContinue;
  const _ThemePage({required this.onContinue});

  static const _themes = [
    ('Inspirational', '✨'),
    ('Motivational', '🔥'),
    ('Love', '❤️'),
    ('Wisdom', '📖'),
    ('Happiness', '😊'),
    ('Life', '🌱'),
    ('Philosophy', '🏛️'),
    ('Hope', '🌅'),
    ('Courage', '🦁'),
    ('Humor', '😄'),
    ('Nature', '🌿'),
    ('Freedom', '🕊️'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),

                  Text(
                    'What speaks\nto your soul?',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.starlight,
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(duration: 600.ms),

                  const SizedBox(height: 12),
                  Text(
                    'Pick topics for your personalized quote feed',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: AppTheme.starlight.withValues(alpha: 0.5),
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 200.ms, duration: 600.ms),

                  const SizedBox(height: 36),

                  BlocBuilder<OnboardingCubit, OnboardingState>(
                    builder: (context, state) {
                      return Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        alignment: WrapAlignment.center,
                        children: _themes.asMap().entries.map((entry) {
                          final index = entry.key;
                          final (label, emoji) = entry.value;
                          final isSelected = state.selectedThemes.contains(
                            label,
                          );
                          return GestureDetector(
                                onTap: () => context
                                    .read<OnboardingCubit>()
                                    .toggleTheme(label),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppTheme.calmTeal.withValues(
                                            alpha: 0.15,
                                          )
                                        : AppTheme.softGlass,
                                    border: Border.all(
                                      color: isSelected
                                          ? AppTheme.calmTeal
                                          : Colors.transparent,
                                      width: 1.5,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        emoji,
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        label,
                                        style: GoogleFonts.outfit(
                                          fontSize: 14,
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.w500,
                                          color: isSelected
                                              ? AppTheme.calmTeal
                                              : AppTheme.starlight,
                                        ),
                                      ),
                                      if (isSelected) ...[
                                        const SizedBox(width: 6),
                                        const Icon(
                                          Icons.check_circle_rounded,
                                          size: 16,
                                          color: AppTheme.calmTeal,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              )
                              .animate()
                              .fadeIn(delay: (80 * index).ms, duration: 400.ms)
                              .scale(begin: const Offset(0.9, 0.9));
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          BlocBuilder<OnboardingCubit, OnboardingState>(
            builder: (context, state) {
              final count = state.selectedThemes.length;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  children: [
                    if (count > 0)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          '$count selected',
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            color: AppTheme.calmTeal.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    PrimaryButton(label: 'Continue', onPressed: onContinue),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Page 4: What's your intention? (Goals)
// ─────────────────────────────────────────────────────────────────

class _GoalPage extends StatelessWidget {
  final VoidCallback onContinue;
  const _GoalPage({required this.onContinue});

  static const _goals = [
    ('Reduce stress', '🧘', 'Find moments of peace'),
    ('Sleep better', '🌙', 'Calm your mind at night'),
    ('Stay motivated', '🔥', 'Start mornings with purpose'),
    ('Practice gratitude', '🌻', 'Appreciate the small things'),
    ('Build resilience', '💪', 'Grow through challenges'),
    ('Just explore', '✨', 'See what resonates'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),

                  Text(
                    'What brings\nyou here?',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.starlight,
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(duration: 600.ms),

                  const SizedBox(height: 12),
                  Text(
                    'Choose your intention — pick as many as you like',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: AppTheme.starlight.withValues(alpha: 0.5),
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 200.ms, duration: 600.ms),

                  const SizedBox(height: 36),

                  BlocBuilder<OnboardingCubit, OnboardingState>(
                    builder: (context, state) {
                      return Column(
                        children: _goals.asMap().entries.map((entry) {
                          final index = entry.key;
                          final (label, emoji, subtitle) = entry.value;
                          final isSelected = state.selectedGoals.contains(
                            label,
                          );
                          return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: GestureDetector(
                                  onTap: () => context
                                      .read<OnboardingCubit>()
                                      .toggleGoal(label),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppTheme.calmTeal.withValues(
                                              alpha: 0.12,
                                            )
                                          : AppTheme.softGlass,
                                      border: Border.all(
                                        color: isSelected
                                            ? AppTheme.calmTeal
                                            : Colors.transparent,
                                        width: 1.5,
                                      ),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          emoji,
                                          style: const TextStyle(fontSize: 24),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                label,
                                                style: GoogleFonts.outfit(
                                                  fontSize: 15,
                                                  fontWeight: isSelected
                                                      ? FontWeight.w600
                                                      : FontWeight.w500,
                                                  color: isSelected
                                                      ? AppTheme.calmTeal
                                                      : AppTheme.starlight,
                                                ),
                                              ),
                                              Text(
                                                subtitle,
                                                style: GoogleFonts.outfit(
                                                  fontSize: 12,
                                                  color: AppTheme.starlight
                                                      .withValues(alpha: 0.45),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (isSelected)
                                          const Icon(
                                            Icons.check_circle_rounded,
                                            size: 20,
                                            color: AppTheme.calmTeal,
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                              .animate()
                              .fadeIn(delay: (80 * index).ms, duration: 400.ms)
                              .moveX(begin: 20, end: 0);
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: PrimaryButton(label: 'Continue', onPressed: onContinue),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Page 5: Completion — "You are ready"
// ─────────────────────────────────────────────────────────────────

class _CompletionPage extends StatelessWidget {
  const _CompletionPage();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),

          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.calmTeal.withValues(alpha: 0.1),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.calmTeal.withValues(alpha: 0.15),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: const Icon(
              Icons.check_rounded,
              size: 64,
              color: AppTheme.calmTeal,
            ),
          ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),

          const SizedBox(height: 36),

          Text(
            'You\'re all set.',
            style: GoogleFonts.playfairDisplay(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.starlight,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 300.ms),

          const SizedBox(height: 16),

          Text(
            'Your path to tranquility awaits.\nTake a deep breath and begin.',
            style: GoogleFonts.outfit(
              fontSize: 16,
              color: AppTheme.starlight.withValues(alpha: 0.7),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 500.ms),

          const Spacer(flex: 3),

          PrimaryButton(
            label: 'Enter Quies',
            onPressed: () =>
                context.read<OnboardingCubit>().completeOnboarding(),
          ).animate().fadeIn(delay: 800.ms).moveY(begin: 20, end: 0),

          const Spacer(flex: 1),
        ],
      ),
    );
  }
}
