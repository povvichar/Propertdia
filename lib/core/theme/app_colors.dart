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

  // Investor tiers (gold/goldSoft reused for the Gold rank)
  static const Color silver = Color(0xFF8E97A6);
  static const Color silverSoft = Color(0xFFEEF0F3);
  static const Color platinum = Color(0xFF3A4660);
  static const Color platinumSoft = Color(0xFFE7EAF1);

  // Surfaces
  static const Color background = Color(0xFFF9FAFF);
  static const Color surface = Colors.white;
  static const Color surfaceMuted = Color(0xFFF5F6FA);
  static const Color iconTile = Color(0xFFE9ECF4);

  // Text
  static const Color textPrimary = Color(0xFF15203B);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textOnDarkMuted = Color(0xFFC7CEDC);

  // Misc
  static const Color border = Color(0xFFF2F2F2);
  static const Color divider = Color(0xFFF0F1F6);
  static const Color overlayNavy = Color(0xCC1E2A47);
  static const Color danger = Color(0xFFE5484D);
  static const Color success = Color(0xFF0F973D);
  static const Color successSoft = Color(0xFFE7F6EC);
  static const Color warning = Color(0xFFF3A218);
  static const Color info = Color(0xFF0088FF);

  // Gradients
  static const Gradient goldShimmer = LinearGradient(
    colors: [gold, goldDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient navyDepth = LinearGradient(
    colors: [navy, navyDeep],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Immersive module hero header — bright blue fading to deep navy.
  static const Color heroHeaderTop = Color(0xFF405CA5);
  static const Color heroHeaderEnd = Color(0xFF18223C);
  static const Gradient heroHeader = LinearGradient(
    colors: [heroHeaderTop, heroHeaderEnd],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Diagonal variant of the hero gradient — bright blue at the bottom-right
  /// fading to deep navy at the top-left. Used for promo/banner cards.
  static const Gradient heroDiagonal = LinearGradient(
    colors: [heroHeaderTop, heroHeaderEnd],
    begin: Alignment.bottomRight,
    end: Alignment.topLeft,
  );

  static const Gradient photoOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x00000000), Color(0x44000000)],
  );

  // Shadows
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: const Color(0xFF1E2A47).withValues(alpha: 0.07),
          blurRadius: 16,
          spreadRadius: 0,
          offset: const Offset(0, 4),
        ),
      ];

}
