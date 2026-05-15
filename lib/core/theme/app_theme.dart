import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// Builds the [ThemeData] for the app.
/// Supports dark mode, light mode, and system default.
abstract class AppTheme {
  /// Dark theme (default).
  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.bgBase,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryViolet,
      secondary: AppColors.coralPink,
      surface: AppColors.surface1,
      error: AppColors.error,
    ),
    textTheme: _textTheme(AppColors.textPrimary),
    useMaterial3: true,
  );

  /// Light theme.
  static ThemeData get light => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.bgBaseLight,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primaryViolet,
      secondary: AppColors.coralPink,
      surface: AppColors.surface1Light,
      error: AppColors.error,
    ),
    textTheme: _textTheme(AppColors.textPrimaryLight),
    useMaterial3: true,
  );

  static TextTheme _textTheme(Color defaultColor) => TextTheme(
    displayLarge: AppTextStyles.heroAmount.copyWith(color: defaultColor),
    displayMedium: AppTextStyles.displayLg.copyWith(color: defaultColor),
    displaySmall: AppTextStyles.displayMd.copyWith(color: defaultColor),
    headlineLarge: AppTextStyles.heading1.copyWith(color: defaultColor),
    headlineMedium: AppTextStyles.heading2.copyWith(color: defaultColor),
    headlineSmall: AppTextStyles.heading3.copyWith(color: defaultColor),
    bodyLarge: AppTextStyles.bodyLg.copyWith(color: defaultColor),
    bodyMedium: AppTextStyles.bodyMd.copyWith(color: defaultColor),
    bodySmall: AppTextStyles.bodySm,
  );
}
