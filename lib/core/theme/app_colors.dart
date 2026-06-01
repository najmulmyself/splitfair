import 'package:flutter/material.dart';

/// All app colors. Never reference Color() values directly in widgets.
/// Always use AppColors.X
abstract class AppColors {
  // ── Brand ──────────────────────────────────────────────────
  static const primaryViolet = Color(0xFF7C5CFF);
  static const coralPink = Color(0xFFFF6B9D);
  static const emeraldMint = Color(0xFF00D4AA);
  static const warmAmber = Color(0xFFFF9F43);

  // ── Gradient pairs ─────────────────────────────────────────
  static const violetGradient = [Color(0xFF7C5CFF), Color(0xFF9B7FFF)];
  static const coralGradient = [Color(0xFFFF6B9D), Color(0xFFFF9F43)];
  static const mintGradient = [Color(0xFF00D4AA), Color(0xFF7C5CFF)];
  static const amberGradient = [Color(0xFFFF9F43), Color(0xFFFF6B9D)];

  // ── Person avatar gradients (index-based, cycles) ───────────
  static const personGradients = [
    violetGradient,
    coralGradient,
    mintGradient,
    amberGradient,
  ];

  // ── Dark mode surfaces ──────────────────────────────────────
  static const bgBase = Color(0xFF0B0A1A);
  static const surface1 = Color(0xFF1A1836);
  static const surface2 = Color(0xFF221F45);
  static const surface3 = Color(0xFF2A2755);
  static const surfaceViolet = Color(0xFF231E4A);
  static const surfaceCoral = Color(0xFF2E1F35);
  static const surfaceMint = Color(0xFF1A2E38);

  // ── Light mode surfaces ─────────────────────────────────────
  static const bgBaseLight = Color(0xFFF4F3FF);
  static const surface1Light = Color(0xFFFFFFFF);
  static const surface2Light = Color(0xFFEDE9FF);

  // ── Text ────────────────────────────────────────────────────
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0x99FFFFFF); // 60% white
  static const textTertiary = Color(0x59FFFFFF); // 35% white
  static const textPrimaryLight = Color(0xFF0B0A1A);
  static const textSecondaryLight = Color(0x8C0B0A1A);

  // ── Borders ─────────────────────────────────────────────────
  static const borderDefault = Color(0x1AFFFFFF); // 10% white
  static const borderActive = Color(0x2EFFFFFF); // 18% white
  static const borderViolet = Color(0x99782CFF); // violet 40%
  static const borderCoral = Color(0x66FF6B9D); // coral 40%
  static const borderMint = Color(0x6600D4AA); // mint 40%
  static const borderRed = Color(0x80FF5050); // red 50%

  // ── Semantic ────────────────────────────────────────────────
  static const success = emeraldMint;
  static const warning = warmAmber;
  static const error = Color(0xFFFF5050);

  // ── AdMob / Ad slots ────────────────────────────────────────
  static const adBackground = Color(0xFF1E1C3A);

  // ── Light mode extras ────────────────────────────────────────
  static const surface3Light = Color(0xFFDDD9FF);
  static const textTertiaryLight = Color(0x590B0A1A); // 35% dark
  static const borderDefaultLight = Color(0x1A0B0A1A); // 10% dark
  static const borderActiveLight = Color(0x2E0B0A1A); // 18% dark

  // ── Mesh gradient overlay opacities (for background) ────────
  static const meshViolet = Color(0x33782CFF); // 20%
  static const meshCoral = Color(0x26FF6B9D); // 15%
  static const meshMint = Color(0x1A00D4AA); // 10%
}

/// Resolved theme-aware colors. Access via [BuildContext.colors].
///
/// Use this instead of referencing [AppColors] dark-mode constants directly
/// in widgets, so that light mode is respected.
class AppColorsResolved {
  const AppColorsResolved({required this.isDark});
  final bool isDark;

  Color get bgBase => isDark ? AppColors.bgBase : AppColors.bgBaseLight;
  Color get surface1 => isDark ? AppColors.surface1 : AppColors.surface1Light;
  Color get surface2 => isDark ? AppColors.surface2 : AppColors.surface2Light;
  Color get surface3 => isDark ? AppColors.surface3 : AppColors.surface3Light;
  Color get textPrimary =>
      isDark ? AppColors.textPrimary : AppColors.textPrimaryLight;
  Color get textSecondary =>
      isDark ? AppColors.textSecondary : AppColors.textSecondaryLight;
  Color get textTertiary =>
      isDark ? AppColors.textTertiary : AppColors.textTertiaryLight;
  Color get borderDefault =>
      isDark ? AppColors.borderDefault : AppColors.borderDefaultLight;
  Color get borderActive =>
      isDark ? AppColors.borderActive : AppColors.borderActiveLight;
}

extension AppColorsContext on BuildContext {
  /// Returns theme-aware resolved colors for the current brightness.
  AppColorsResolved get colors {
    final isDark = Theme.of(this).brightness == Brightness.dark;
    return AppColorsResolved(isDark: isDark);
  }
}
