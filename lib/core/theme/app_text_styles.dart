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
  );
  static const displayLg = TextStyle(
    fontFamily: _sfRounded,
    fontSize: 44,
    fontWeight: FontWeight.w700,
    height: 1.1,
  );
  static const displayMd = TextStyle(
    fontFamily: _sfDisplay,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.15,
  );

  // ── Headings ────────────────────────────────────────────────
  static const heading1 = TextStyle(
    fontFamily: _sfDisplay,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );
  static const heading2 = TextStyle(
    fontFamily: _sfDisplay,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );
  static const heading3 = TextStyle(
    fontFamily: _sfDisplay,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  // ── Body ────────────────────────────────────────────────────
  static const bodyLg = TextStyle(
    fontFamily: _sf,
    fontSize: 17,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );
  static const bodyMd = TextStyle(
    fontFamily: _sf,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
  static const bodyMdMedium = TextStyle(
    fontFamily: _sf,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 1.5,
  );
  static const bodySm = TextStyle(
    fontFamily: _sf,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );
  static const bodyXs = TextStyle(
    fontFamily: _sf,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.3,
  );

  // ── Mono (all amounts, currency, %) ─────────────────────────
  static const monoLg = TextStyle(
    fontFamily: _sfMono,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );
  static const monoMd = TextStyle(
    fontFamily: _sfMono,
    fontSize: 17,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );
  static const monoSm = TextStyle(
    fontFamily: _sfMono,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );
  static const monoXs = TextStyle(
    fontFamily: _sfMono,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );

  // ── Button ──────────────────────────────────────────────────
  static const buttonLg = TextStyle(
    fontFamily: _sfRounded,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );
  static const buttonMd = TextStyle(
    fontFamily: _sf,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );
  static const buttonSm = TextStyle(
    fontFamily: _sf,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.2,
  );
}
