import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../shared/providers/app_providers.dart';
import '../../shared/utils/l10n_text.dart';
import 'app_colors.dart';

/// App typeface: Manrope (Latin) with a Kantumruy Pro fallback so Khmer
/// codepoints shape correctly while Latin/numbers stay in Manrope. Both are
/// loaded via the `google_fonts` package.
///
/// Referencing `GoogleFonts.kantumruyPro()` here also registers the font with
/// the engine, which is required for the fallback to actually render.
final String kFontFamily = GoogleFonts.manrope().fontFamily!;
final List<String> kFontFamilyFallback = [
  GoogleFonts.kantumruyPro().fontFamily!,
];

/// Khmer is a stacking script and should not be letter-spaced — tracking tuned
/// for Manrope (Latin) crowds or breaks Khmer clusters. So neutralise tracking
/// to 0 when the app is in Khmer; Latin keeps its [latin] value. Reads the
/// `currentLanguage` mirror (kept in sync by `PropertdiaApp.build`), so styles —
/// which are getters re-evaluated each build — track the active language.
double? khmerSafeLetterSpacing(double? latin) =>
    currentLanguage == AppLanguage.khmer ? 0 : latin;

TextStyle _sans({
  double? fontSize,
  FontWeight? fontWeight,
  Color? color,
  double? letterSpacing,
  double? height,
}) =>
    GoogleFonts.manrope(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: khmerSafeLetterSpacing(letterSpacing),
      height: height,
    ).copyWith(fontFamilyFallback: kFontFamilyFallback);

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
