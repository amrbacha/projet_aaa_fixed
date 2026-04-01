import 'package:flutter/material.dart';

class AppTheme {
  // This class will now generate themes based on provided colors.
  static const Color darkBackgroundColor = Color(0xFF0D3B2E);

  static ThemeData light({required Color primaryColor, required Color accentColor}) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        primary: primaryColor,
        secondary: accentColor,
      ),
      scaffoldBackgroundColor: const Color(0xFFF5FBF7),
      fontFamily: 'Cairo',
    );
  }

  static ThemeData dark({required Color primaryColor, required Color accentColor}) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
        primary: primaryColor,
        secondary: accentColor,
        surface: darkBackgroundColor,
      ),
      scaffoldBackgroundColor: darkBackgroundColor,
      fontFamily: 'Cairo',
    );
  }
}

extension TextThemeCompat on TextTheme {
  TextStyle? get headline4 => displaySmall;
  TextStyle? get headline5 => headlineMedium;
  TextStyle? get headline6 => titleLarge;

  TextStyle? get subtitle1 => titleMedium;
  TextStyle? get subtitle2 => titleSmall;

  TextStyle? get bodyText1 => bodyLarge;
  TextStyle? get bodyText2 => bodyMedium;
}
