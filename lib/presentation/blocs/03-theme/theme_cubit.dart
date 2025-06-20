import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit({
    bool darkMode = false,
  }) : super(ThemeState(isDarkmode: darkMode));

  void toggleTheme() {
    emit(ThemeState(isDarkmode: !state.isDarkmode));
  }

  void setDarkMode() {
    emit(ThemeState(isDarkmode: true));
  }

  void setlightMode() {
    emit(ThemeState(isDarkmode: false));
  }
}
