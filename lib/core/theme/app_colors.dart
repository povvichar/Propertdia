import 'package:flutter/material.dart';

/// PROPERTDIA brand color tokens, extracted from the Figma designs.
abstract class AppColors {
  // Brand
  static const Color gold = Color(0xFFF2A71B);
  static const Color goldDark = Color(0xFFE09A12);
  static const Color goldSoft = Color(0xFFFBEED3);
  static const Color navy = Color(0xFF1E2A47);
  static const Color navyDeep = Color(0xFF16203A);
  static const Color navyIcon = Color(0xFF233560);

  // Surfaces
  static const Color background = Color(0xFFF9FAFF);
  static const Color surface = Colors.white;
  static const Color surfaceMuted = Color(0xFFF5F6FA);
  static const Color iconTile = Color(0xFFE9ECF4);

  // Text
  static const Color textPrimary = Color(0xFF15203B);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textOnDark = Colors.white;
  static const Color textOnDarkMuted = Color(0xFFC7CEDC);

  // Misc
  static const Color border = Color(0xFFE3E6EE);
  static const Color overlayNavy = Color(0xCC1E2A47);
  static const Color danger = Color(0xFFE5484D);
}
