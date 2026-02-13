part of 'onboarding_cubit.dart';

class OnboardingState extends Equatable {
  final int currentPage;
  final String? selectedMood;
  final List<String> selectedThemes;
  final List<String> selectedGoals;
  final bool isCompleted;

  const OnboardingState({
    this.currentPage = 0,
    this.selectedMood,
    this.selectedThemes = const [],
    this.selectedGoals = const [],
    this.isCompleted = false,
  });

  OnboardingState copyWith({
    int? currentPage,
    String? selectedMood,
    List<String>? selectedThemes,
    List<String>? selectedGoals,
    bool? isCompleted,
  }) {
    return OnboardingState(
      currentPage: currentPage ?? this.currentPage,
      selectedMood: selectedMood ?? this.selectedMood,
      selectedThemes: selectedThemes ?? this.selectedThemes,
      selectedGoals: selectedGoals ?? this.selectedGoals,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  List<Object?> get props => [
    currentPage,
    selectedMood,
    selectedThemes,
    selectedGoals,
    isCompleted,
  ];
}
