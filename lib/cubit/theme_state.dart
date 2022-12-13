part of 'theme_cubit.dart';

@immutable
abstract class ThemeCubitState {}

class ThemeCubitInitial extends ThemeCubitState {
  ThemeCubitInitial();
}

class ThemeModeChangedState extends ThemeCubitState {
  ThemeMode currentTheme;
  ThemeModeChangedState({
    required this.currentTheme,
  });
}


class ThemeValueAddedState extends ThemeCubitState {
  ThemeMode currentTheme;
  int currentValue;
  ThemeValueAddedState(
      {required this.currentTheme, required this.currentValue});
}
