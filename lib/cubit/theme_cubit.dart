import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeCubitState> {
  ThemeCubit() : super(ThemeCubitInitial());

  void changeTheme(ThemeMode themeMode) {
    emit(ThemeModeChangedState(currentTheme: themeMode));
  }

  void calculateTheme(ThemeMode themeMode, bool isDecreasing) {
    var currentValue = themeMode == ThemeMode.light ? 1 : 2;
    if (isDecreasing) {
      currentValue = currentValue * -1;
    }
    emit(ThemeValueAddedState(
        currentTheme: themeMode,
        currentValue: currentValue));
  }

  int getThemeValue(ThemeMode themeMode) {
    return themeMode == ThemeMode.light ? 1 : 2;
  }
}
