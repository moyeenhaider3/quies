
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
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

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
    );
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
              // 1. Background Layer
              const AnimatedBackground(),

              // 2. Content Layer
              SafeArea(
                child: Column(
                  children: [
                    // Top Bar (Skip Button)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (_currentPage < 2)
                            TextButton(
                              onPressed: () => context.read<OnboardingCubit>().skipOnboarding(),
                              child: Text(
                                'Skip',
                                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                                  color: AppTheme.starlight.withValues(alpha: 0.6),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Page Content
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() => _currentPage = index);
                          context.read<OnboardingCubit>().pageChanged(index);
                        },
                        physics: const NeverScrollableScrollPhysics(), // Disable swipe to enforce flow
                        children: [
                          _WelcomePage(onStart: _nextPage),
                          _MoodPage(onContinue: _nextPage),
                          const _CompletionPage(),
                        ],
                      ),
                    ),
                    
                    // Bottom Indicators (Optional, maybe dots?)
                     Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (index) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentPage == index ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _currentPage == index 
                                  ? AppTheme.calmTeal 
                                  : AppTheme.starlight.withValues(alpha: 0.2),
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
          Text(
            'Quies',
            style: AppTheme.lightTheme.textTheme.displayLarge?.copyWith(
              fontSize: 48,
              color: AppTheme.calmTeal,
            ),
          ).animate().fadeIn(duration: 800.ms).moveY(begin: 20, end: 0),
          
          const SizedBox(height: 16),
          
          Text(
            'Find your inner calm\nthrough guided stillness.',
            textAlign: TextAlign.center,
            style: AppTheme.lightTheme.textTheme.bodyLarge,
          ).animate().fadeIn(delay: 300.ms, duration: 800.ms),
          
          const Spacer(flex: 3),
          
          PrimaryButton(
            label: 'Begin Journey',
            onPressed: onStart,
          ).animate().fadeIn(delay: 600.ms, duration: 800.ms).moveY(begin: 20, end: 0),
          
          const Spacer(flex: 1),
        ],
      ),
    );
  }
}

class _MoodPage extends StatelessWidget {
  final VoidCallback onContinue;

  const _MoodPage({required this.onContinue});

  final List<String> moods = const ['Stressed', 'Anxious', 'Tired', 'Okay'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(flex: 1),
          Text(
            'How are you feeling right now?',
            style: AppTheme.lightTheme.textTheme.displayMedium,
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 48),
          
          BlocBuilder<OnboardingCubit, OnboardingState>(
            builder: (context, state) {
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: moods.map((mood) {
                  final isSelected = state.selectedMood == mood;
                  return GestureDetector(
                    onTap: () => context.read<OnboardingCubit>().updateMood(mood),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 140, // Fixed width for grid-like look
                      height: 100,
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.calmTeal.withValues(alpha: 0.2) : AppTheme.softGlass,
                        border: Border.all(
                          color: isSelected ? AppTheme.calmTeal : Colors.transparent,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          mood,
                          style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? AppTheme.calmTeal : AppTheme.starlight,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          
          const Spacer(flex: 2),
          
          BlocBuilder<OnboardingCubit, OnboardingState>(
            builder: (context, state) {
              final isEnabled = state.selectedMood != null;
              return AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: isEnabled ? 1.0 : 0.5,
                child: PrimaryButton(
                  label: 'Continue',
                  onPressed: isEnabled ? onContinue : () {}, // No-op if disabled
                ),
              );
            },
          ),
          const Spacer(flex: 1),
        ],
      ),
    );
  }
}

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
            ),
            child: const Icon(
              Icons.check_rounded,
              size: 64,
              color: AppTheme.calmTeal,
            ),
          ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
          
          const SizedBox(height: 32),
          
          Text(
            'You are ready.',
            style: AppTheme.lightTheme.textTheme.displayMedium,
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 300.ms),
          
          const SizedBox(height: 16),
          
          Text(
            'Your path to tranquility awaits.',
            style: AppTheme.lightTheme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 500.ms),
          
          const Spacer(flex: 3),
          
          PrimaryButton(
            label: 'Enter Quies',
            onPressed: () => context.read<OnboardingCubit>().completeOnboarding(),
          ).animate().fadeIn(delay: 800.ms).moveY(begin: 20, end: 0),
          
          const Spacer(flex: 1),
        ],
      ),
    );
  }
}
