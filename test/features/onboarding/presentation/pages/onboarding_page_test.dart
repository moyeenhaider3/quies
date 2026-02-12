
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quies/core/di/injection.dart';
import 'package:quies/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:quies/features/onboarding/presentation/pages/onboarding_page.dart';

class MockOnboardingCubit extends Mock implements OnboardingCubit {}

void main() {
  late MockOnboardingCubit mockCubit;

  setUp(() {
    mockCubit = MockOnboardingCubit();
    getIt.registerSingleton<OnboardingCubit>(mockCubit);
    when(() => mockCubit.pageChanged(any())).thenReturn(null);
    when(() => mockCubit.skipOnboarding()).thenAnswer((_) async {});
    when(() => mockCubit.completeOnboarding()).thenAnswer((_) async {});
    when(() => mockCubit.state).thenReturn(const OnboardingState());
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockCubit.close()).thenAnswer((_) async {});
  });

  tearDown(() {
    getIt.reset();
  });

  testWidgets('OnboardingPage renders Welcome Page initially', (tester) async {
    final router = GoRouter(
      initialLocation: '/onboarding',
      routes: [
        GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingPage()),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pump(const Duration(seconds: 1)); // Wait for animations

    expect(find.text('Quies'), findsOneWidget);
    expect(find.textContaining('inner calm'), findsOneWidget);
    expect(find.text('Begin Journey'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
    
    // Unmount to stop infinite animations
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });

  testWidgets('Tapping Skip calls cubit.skipOnboarding', (tester) async {
    final router = GoRouter(
      initialLocation: '/onboarding',
      routes: [
        GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingPage()),
        GoRoute(path: '/home', builder: (context, state) => const SizedBox()),
      ],
    );

    // Provide a dummy state
    when(() => mockCubit.state).thenReturn(const OnboardingState());

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pump(const Duration(seconds: 1)); // Allow fade-ins

    await tester.tap(find.text('Skip'));
    verify(() => mockCubit.skipOnboarding()).called(1);

    // Unmount
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });

  testWidgets('Mood selection calls updateMood', (tester) async {
    final router = GoRouter(
      initialLocation: '/onboarding',
      routes: [
        GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingPage()),
      ],
    );

    when(() => mockCubit.state).thenReturn(const OnboardingState());

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pump(const Duration(seconds: 1)); // Allow fade-ins

    // Navigate to Mood Page
    await tester.tap(find.text('Begin Journey'));
    await tester.pump(const Duration(milliseconds: 600)); // Page transition
    await tester.pump(const Duration(seconds: 2)); // Staggered animations fully settle

    // Tap 'Stressed' mood
    // Note: Text might be inside AnimatedContainer -> Center -> Text. Finder by text should work.
    await tester.tap(find.text('Stressed'));
    
    verify(() => mockCubit.updateMood('Stressed')).called(1);

    // Unmount
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });
}
