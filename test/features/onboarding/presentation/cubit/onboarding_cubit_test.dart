
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quies/data/services/user_preferences_service.dart';
import 'package:quies/features/onboarding/presentation/cubit/onboarding_cubit.dart';

class MockUserPreferencesService extends Mock implements UserPreferencesService {}

void main() {
  group('OnboardingCubit', () {
    late UserPreferencesService mockPreferencesService;
    late OnboardingCubit cubit;

    setUp(() {
      mockPreferencesService = MockUserPreferencesService();
      when(() => mockPreferencesService.setOnboardingCompleted(any()))
          .thenAnswer((_) async {});
      when(() => mockPreferencesService.setMood(any()))
          .thenAnswer((_) async {});
      when(() => mockPreferencesService.setThemes(any()))
          .thenAnswer((_) async {});
      cubit = OnboardingCubit(mockPreferencesService);
    });

    test('initial state is OnboardingState()', () {
      expect(cubit.state, const OnboardingState());
    });

    blocTest<OnboardingCubit, OnboardingState>(
      'emits [OnboardingState(currentPage: 1)] when pageChanged(1) is called',
      build: () => cubit,
      act: (cubit) => cubit.pageChanged(1),
      expect: () => [const OnboardingState(currentPage: 1)],
    );

    blocTest<OnboardingCubit, OnboardingState>(
      'emits [OnboardingState(selectedMood: "Calm")] when updateMood("Calm") is called',
      build: () => cubit,
      act: (cubit) => cubit.updateMood('Calm'),
      expect: () => [const OnboardingState(selectedMood: 'Calm')],
    );

    blocTest<OnboardingCubit, OnboardingState>(
      'emits [OnboardingState(isCompleted: true)] when skipOnboarding() is called',
      build: () => cubit,
      act: (cubit) => cubit.skipOnboarding(),
      expect: () => [const OnboardingState(isCompleted: true)],
      verify: (_) {
        verify(() => mockPreferencesService.setOnboardingCompleted(true)).called(1);
      },
    );

    blocTest<OnboardingCubit, OnboardingState>(
      'emits [OnboardingState(isCompleted: true)] when completeOnboarding() is called',
      build: () => cubit,
      act: (cubit) => cubit.completeOnboarding(),
      expect: () => [const OnboardingState(isCompleted: true)],
      verify: (_) {
        verify(() => mockPreferencesService.setOnboardingCompleted(true)).called(1);
      },
    );
  });
}
