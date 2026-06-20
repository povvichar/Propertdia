import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'glass_icon_button.dart';

/// Collapsing module hero header — use as the first sliver in a
/// `CustomScrollView`. A full-bleed navy gradient `SliverAppBar` (runs edge to
/// edge and under the status bar) that expands to the full hero (dark-glass back
/// button + small title row, large headline, subtitle, translucent watermark)
/// and collapses to a pinned compact bar (back + small title) as content
/// scrolls.
///
/// Its bottom edge is **flat**; the curve lives on the content instead — pair it
/// with [ModuleHeroSheet], whose rounded top corners (with navy filling the
/// corner notches) make the light sheet appear to curve up out of the header.
class ModuleHeroSliver extends StatelessWidget {
  const ModuleHeroSliver({
    super.key,
    required this.title,
    required this.headline,
    required this.subtitle,
    required this.icon,
    this.onBack,
    this.showBack = true,
    this.expandedHeight = 188,
    this.iconSize = 168,
    this.iconTop = 14,
    this.iconRight = -28,
  });

  final String title;
  final String headline;
  final String subtitle;

  /// SVG asset path for the translucent watermark.
  final String icon;

  /// Back action. Defaults to `context.pop()`.
  final VoidCallback? onBack;

  /// Whether to show the back button. Set false when the header is used as a
  /// top-level nav tab (no route to pop back to).
  final bool showBack;

  /// Hero content height when fully expanded (excludes the status-bar inset).
  final double expandedHeight;

  /// Watermark placement / size, tuned per screen. [iconTop] is measured from
  /// just below the status bar.
  final double iconSize;
  final double iconTop;
  final double iconRight;

  /// Pinned compact-bar content height (excludes the status-bar inset). The
  /// back + title row is lifted off the flat bottom edge by [_barBottomGap], so
  /// the compact title isn't jammed against the content below.
  static const double barHeight = 90;

  /// Breathing room between the compact title row and the header's bottom edge
  /// (also where the expanded headline is anchored).
  static const double _barBottomGap = 6;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    final maxExtent = expandedHeight + topInset;
    final minExtent = barHeight + topInset;

    return SliverAppBar(
      pinned: true,
      // Stretch fills a top overscroll/bounce with the gradient instead of
      // exposing the light scaffold above the header.
      stretch: true,
      stretchTriggerOffset: 80,
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.heroHeaderEnd,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      elevation: 0,
      // Material 3 raises a shadow when content scrolls under a pinned app bar;
      // suppress it so the header reads continuous with the content (no seam).
      scrolledUnderElevation: 0,
      expandedHeight: expandedHeight,
      collapsedHeight: barHeight,
      toolbarHeight: barHeight,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final h = constraints.maxHeight;
          // 1.0 = fully expanded, 0.0 = fully collapsed.
          final t = ((h - minExtent) / (maxExtent - minExtent)).clamp(0.0, 1.0);
          // Expanded headline/subtitle stay fully visible through most of the
          // collapse and only fade out late (t 0.7 → 0.5), still clearing the
          // pinned compact title before they would overlap it.
          final headlineOpacity = ((t - 0.5) / 0.2).clamp(0.0, 1.0);
          return ClipRect(
            child: DecoratedBox(
              decoration: const BoxDecoration(gradient: AppColors.heroHeader),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Watermark — fades out as the header collapses.
                  Positioned(
                    right: iconRight,
                    top: topInset + iconTop,
                    child: Opacity(
                      opacity: 0.10 * t,
                      child: SvgPicture.asset(
                        icon,
                        width: iconSize,
                        height: iconSize,
                        colorFilter: const ColorFilter.mode(
                            Colors.white, BlendMode.srcIn),
                      ),
                    ),
                  ),
                  // Pinned compact bar: back + small title (always visible).
                  // The header bottom is flat (no white sheet-lip) so content
                  // sits flush against the navy and reads continuous with it.
                  Positioned(
                    top: topInset,
                    left: 16,
                    right: 16,
                    height: barHeight - _barBottomGap,
                    child: Row(
                      children: [
                        if (showBack) ...[
                          GlassIconButton(
                            asset: 'assets/icons/base/careleft.svg',
                            onTap: onBack ?? () => context.pop(),
                            iconColor: Colors.white,
                            fillColor: Colors.white.withValues(alpha: 0.18),
                            borderColor: Colors.white.withValues(alpha: 0.30),
                          ),
                          const SizedBox(width: 14),
                        ],
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: khmerSafeLetterSpacing(-0.3),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Expanded headline + subtitle, anchored just above the flat
                  // bottom edge and fading out as the header collapses.
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: _barBottomGap + 6,
                    child: IgnorePointer(
                      child: Opacity(
                        opacity: headlineOpacity,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              headline,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.2,
                                letterSpacing: khmerSafeLetterSpacing(-0.4),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              subtitle,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.72),
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Rounded-top content sheet that sits directly under [ModuleHeroSliver]. Its
/// top corners are rounded and the navy header colour fills the corner notches,
/// so the light sheet appears to curve up out of the navy header (the iOS
/// "sheet rising into the header" look — the reverse of a rounded-bottom header).
class ModuleHeroSheet extends StatelessWidget {
  const ModuleHeroSheet({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(16, 24, 16, 0),
    this.gap = 12,
  });

  final Widget child;
  final EdgeInsets padding;

  /// Retained for API compatibility; the sheet now curves directly out of the
  /// header with no gradient gap.
  final double gap;

  /// Radius of the sheet's rounded top corners (the visible curve).
  static const Radius _sheetRadius = Radius.circular(24);

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      // Navy fills the rounded-top corner notches so the light sheet reads as
      // curving up out of the navy header (no light scaffold in the notches).
      child: ColoredBox(
        color: AppColors.heroHeaderEnd,
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: _sheetRadius),
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
