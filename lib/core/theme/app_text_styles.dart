import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Typography scale. Use these — never set fontSize directly in widgets.
abstract class AppTextStyles {
  static const _sf = '.SF Pro Text';
  static const _sfDisplay = '.SF Pro Display';
  static const _sfRounded = '.SF Pro Rounded';
  static const _sfMono = '.SF Mono';

  // ── Display / Hero (big amounts) ───────────────────────────
  static const heroAmount = TextStyle(
    fontFamily: _sfRounded,
    fontSize: 72,
    fontWeight: FontWeight.w800,
    height: 1.0,
    color: AppColors.textPrimary,
  );
  static const displayLg = TextStyle(
    fontFamily: _sfRounded,
    fontSize: 44,
    fontWeight: FontWeight.w700,
    height: 1.1,
    color: AppColors.textPrimary,
  );
  static const displayMd = TextStyle(
    fontFamily: _sfDisplay,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.15,
    color: AppColors.textPrimary,
  );

  // ── Headings ────────────────────────────────────────────────
  static const heading1 = TextStyle(
    fontFamily: _sfDisplay,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: AppColors.textPrimary,
  );
  static const heading2 = TextStyle(
    fontFamily: _sfDisplay,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.textPrimary,
  );
  static const heading3 = TextStyle(
    fontFamily: _sfDisplay,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  // ── Body ────────────────────────────────────────────────────
  static const bodyLg = TextStyle(
    fontFamily: _sf,
    fontSize: 17,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.textPrimary,
  );
  static const bodyMd = TextStyle(
    fontFamily: _sf,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textPrimary,
  );
  static const bodyMdMedium = TextStyle(
    fontFamily: _sf,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 1.5,
    color: AppColors.textPrimary,
  );
  static const bodySm = TextStyle(
    fontFamily: _sf,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.textSecondary,
  );
  static const bodyXs = TextStyle(
    fontFamily: _sf,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.3,
    color: AppColors.textTertiary,
  );

  // ── Mono (all amounts, currency, %) ─────────────────────────
  static const monoLg = TextStyle(
    fontFamily: _sfMono,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.2,
    color: AppColors.textPrimary,
  );
  static const monoMd = TextStyle(
    fontFamily: _sfMono,
    fontSize: 17,
    fontWeight: FontWeight.w500,
    height: 1.3,
    color: AppColors.textPrimary,
  );
  static const monoSm = TextStyle(
    fontFamily: _sfMono,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.3,
    color: AppColors.textSecondary,
  );
  static const monoXs = TextStyle(
    fontFamily: _sfMono,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.3,
    color: AppColors.textTertiary,
  );

  // ── Button ──────────────────────────────────────────────────
  static const buttonLg = TextStyle(
    fontFamily: _sfRounded,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 1.2,
    color: AppColors.textPrimary,
  );
  static const buttonMd = TextStyle(
    fontFamily: _sf,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.2,
    color: AppColors.textPrimary,
  );
  static const buttonSm = TextStyle(
    fontFamily: _sf,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.2,
    color: AppColors.textPrimary,
  );
}
