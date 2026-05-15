import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme =>
      _buildTheme(palette: AppPalettes.light, brightness: Brightness.light);

  static ThemeData get darkTheme =>
      _buildTheme(palette: AppPalettes.dark, brightness: Brightness.dark);

  static ThemeData _buildTheme({
    required AppPalette palette,
    required Brightness brightness,
  }) {
    final isDark = brightness == Brightness.dark;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: palette.primaryButtons,
      onPrimary: isDark ? AppPalettes.dark.pageBackground : Colors.white,
      secondary: palette.categoryTags,
      onSecondary: isDark ? AppPalettes.dark.pageBackground : Colors.white,
      tertiary: palette.activeElements,
      onTertiary: isDark ? AppPalettes.dark.pageBackground : Colors.white,
      error: const Color(0xFFB3261E),
      onError: Colors.white,
      surface: palette.cardsSurface,
      onSurface: palette.mainText,
      outline: palette.borders,
      surfaceContainerLow: palette.recipeCardBackground,
      surfaceContainerHighest: palette.searchBarBackground,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      extensions: [palette],
    );

    return base.copyWith(
      scaffoldBackgroundColor: palette.pageBackground,
      dividerColor: palette.borders,
      iconTheme: IconThemeData(color: palette.icons),
      appBarTheme: AppBarTheme(
        backgroundColor: palette.navbarBackground,
        foregroundColor: palette.mainText,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: palette.cardsSurface,
        surfaceTintColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.searchBarBackground,
        hintStyle: TextStyle(color: palette.secondaryText),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: palette.borders),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: palette.borders),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: palette.primaryButtons),
        ),
      ),
      textTheme: _buildTextTheme(base.textTheme, palette),
    );
  }

  static TextTheme _buildTextTheme(TextTheme base, AppPalette palette) {
    return base.copyWith(
      displayLarge: TextStyle(
        fontSize: 56,
        height: 1.08,
        letterSpacing: -1.3,
        fontWeight: FontWeight.w700,
        color: palette.mainText,
      ),
      displayMedium: TextStyle(
        fontSize: 42,
        height: 1.14,
        letterSpacing: -0.6,
        fontWeight: FontWeight.w700,
        color: palette.mainText,
      ),
      headlineMedium: TextStyle(
        fontSize: 30,
        height: 1.2,
        letterSpacing: -0.4,
        fontWeight: FontWeight.w700,
        color: palette.mainText,
      ),
      titleLarge: TextStyle(
        fontSize: 24,
        height: 1.25,
        fontWeight: FontWeight.w700,
        color: palette.mainText,
      ),
      titleMedium: TextStyle(
        fontSize: 18,
        height: 1.3,
        fontWeight: FontWeight.w700,
        color: palette.mainText,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        height: 1.55,
        fontWeight: FontWeight.w400,
        color: palette.secondaryText,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        height: 1.45,
        fontWeight: FontWeight.w400,
        color: palette.secondaryText,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        letterSpacing: 0.2,
        fontWeight: FontWeight.w600,
        color: palette.mainText,
      ),
    );
  }
}
