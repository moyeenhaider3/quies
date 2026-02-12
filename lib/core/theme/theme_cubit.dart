import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../data/services/user_preferences_service.dart';
import 'app_theme.dart';

class ThemeState {
  final ThemeData themeData;
  final bool isDarkMode;
  final String quoteFont;
  final double quoteFontSize;

  const ThemeState({
    required this.themeData,
    required this.isDarkMode,
    required this.quoteFont,
    required this.quoteFontSize,
  });

  ThemeState copyWith({
    ThemeData? themeData,
    bool? isDarkMode,
    String? quoteFont,
    double? quoteFontSize,
  }) {
    return ThemeState(
      themeData: themeData ?? this.themeData,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      quoteFont: quoteFont ?? this.quoteFont,
      quoteFontSize: quoteFontSize ?? this.quoteFontSize,
    );
  }
}

@injectable
class ThemeCubit extends Cubit<ThemeState> {
  final UserPreferencesService _prefsService;

  ThemeCubit(this._prefsService)
    : super(
        ThemeState(
          themeData: _prefsService.isDarkMode
              ? AppTheme.darkTheme
              : AppTheme.lightTheme,
          isDarkMode: _prefsService.isDarkMode,
          quoteFont: _prefsService.quoteFont,
          quoteFontSize: _prefsService.quoteFontSize,
        ),
      );

  void toggleTheme() {
    final newIsDark = !state.isDarkMode;
    _prefsService.setIsDarkMode(newIsDark);
    emit(
      state.copyWith(
        isDarkMode: newIsDark,
        themeData: newIsDark ? AppTheme.darkTheme : AppTheme.lightTheme,
      ),
    );
  }

  void setQuoteFont(String font) {
    _prefsService.setQuoteFont(font);
    emit(state.copyWith(quoteFont: font));
  }

  void setQuoteFontSize(double size) {
    _prefsService.setQuoteFontSize(size);
    emit(state.copyWith(quoteFontSize: size));
  }
}
