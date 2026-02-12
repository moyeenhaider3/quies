
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../data/services/user_preferences_service.dart';

part 'onboarding_state.dart';

@injectable
class OnboardingCubit extends Cubit<OnboardingState> {
  final UserPreferencesService _preferencesService;

  OnboardingCubit(this._preferencesService) : super(const OnboardingState());

  void pageChanged(int index) {
    emit(state.copyWith(currentPage: index));
  }

  void updateMood(String mood) {
    emit(state.copyWith(selectedMood: mood));
  }

  void toggleTheme(String theme) {
    final currentThemes = List<String>.from(state.selectedThemes);
    if (currentThemes.contains(theme)) {
      currentThemes.remove(theme);
    } else {
      currentThemes.add(theme);
    }
    emit(state.copyWith(selectedThemes: currentThemes));
  }

  Future<void> completeOnboarding() async {
    await _preferencesService.setMood(state.selectedMood ?? 'Calm');
    await _preferencesService.setThemes(state.selectedThemes);
    await _preferencesService.setOnboardingCompleted(true);
    emit(state.copyWith(isCompleted: true));
  }

  Future<void> skipOnboarding() async {
    await _preferencesService.setOnboardingCompleted(true);
    emit(state.copyWith(isCompleted: true));
  }
}
