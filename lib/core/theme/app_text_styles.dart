import 'package:flutter/material.dart';

import 'app_colors.dart';

/// App typeface: Google Sans (Latin) with a Google Sans Khmer fallback so Khmer
/// codepoints shape correctly while staying visually consistent.
const String kFontFamily = 'Google Sans';
const List<String> kFontFamilyFallback = ['Google Sans Khmer'];

TextStyle _sans({
  double? fontSize,
  FontWeight? fontWeight,
  Color? color,
  double? letterSpacing,
  double? height,
}) =>
    TextStyle(
      fontFamily: kFontFamily,
      fontFamilyFallback: kFontFamilyFallback,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );

abstract class AppTextStyles {
  // ── Display ──────────────────────────────────────────────────────────────
  static TextStyle get displayLarge => _sans(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -1.0,
        height: 1.15,
      );

  static TextStyle get displayMedium => _sans(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.8,
        height: 1.2,
      );

  // ── Titles ───────────────────────────────────────────────────────────────
  static TextStyle get titleLarge => _sans(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.4,
        height: 1.3,
      );

  static TextStyle get titleMedium => _sans(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: -0.2,
        height: 1.35,
      );

  static TextStyle get titleSmall => _sans(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: -0.1,
        height: 1.4,
      );

  // ── Body ─────────────────────────────────────────────────────────────────
  static TextStyle get bodyLarge => _sans(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.55,
      );

  static TextStyle get bodyMedium => _sans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.5,
      );

  static TextStyle get bodySmall => _sans(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.45,
      );

  // ── Labels ───────────────────────────────────────────────────────────────
  static TextStyle get labelLarge => _sans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: 0.1,
      );

  static TextStyle get labelMedium => _sans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        letterSpacing: 0.15,
      );

  static TextStyle get labelSmall => _sans(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        letterSpacing: 0.25,
      );

  // ── Semantic ─────────────────────────────────────────────────────────────
  static TextStyle get price => _sans(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: AppColors.navy,
        letterSpacing: -0.3,
      );

  static TextStyle get sectionTitle => _sans(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.2,
      );

  static TextStyle get heroBannerTitle => _sans(
        fontSize: 21,
        fontWeight: FontWeight.w700,
        color: AppColors.gold,
        letterSpacing: -0.4,
        height: 1.25,
      );

  static TextStyle get heroBannerSubtitle => _sans(
        fontSize: 13.5,
        fontWeight: FontWeight.w400,
        color: Colors.white,
        height: 1.45,
      );
}
