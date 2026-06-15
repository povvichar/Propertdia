import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import 'glass_icon_button.dart';

/// Collapsing version of the module hero header — use as the first sliver in a
/// `CustomScrollView`. Expands to the full gradient hero (dark-glass back button
/// + small title row, large headline, subtitle, translucent watermark) and
/// collapses to a pinned compact bar (back + small title) as content scrolls.
///
/// Pair it with [ModuleHeroSheet] for the rounded "sticky" content container.
class ModuleHeroSliver extends StatelessWidget {
  const ModuleHeroSliver({
    super.key,
    required this.title,
    required this.headline,
    required this.subtitle,
    required this.icon,
    this.onBack,
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

  /// Hero content height when fully expanded (excludes the status-bar inset).
  final double expandedHeight;

  /// Watermark placement / size, tuned per screen. [iconTop] is measured from
  /// just below the status bar.
  final double iconSize;
  final double iconTop;
  final double iconRight;

  /// Pinned compact-bar content height (excludes the status-bar inset).
  static const double barHeight = 68;

  /// Rounded bottom corners on the header (visible expanded and collapsed).
  static const Radius _corner = Radius.circular(24);

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    final maxExtent = expandedHeight + topInset;
    final minExtent = barHeight + topInset;

    return SliverAppBar(
      pinned: true,
      // Stretch fills a top overscroll/bounce with the gradient instead of
      // exposing the light scaffold between the header and the content sheet.
      stretch: true,
      stretchTriggerOffset: 80,
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.heroHeaderEnd,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      expandedHeight: expandedHeight,
      collapsedHeight: barHeight,
      toolbarHeight: barHeight,
      // No `shape`: the bar's navy [backgroundColor] fills behind the gradient so
      // the rounded-bottom corner notches read navy (matching the sheet's gap),
      // instead of exposing the light scaffold.
      systemOverlayStyle: SystemUiOverlayStyle.light,
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final h = constraints.maxHeight;
          // 1.0 = fully expanded, 0.0 = fully collapsed.
          final t = ((h - minExtent) / (maxExtent - minExtent)).clamp(0.0, 1.0);
          return Container(
            decoration: const BoxDecoration(
              gradient: AppColors.heroHeader,
              borderRadius: BorderRadius.vertical(bottom: _corner),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: _corner),
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
                  Positioned(
                    top: topInset,
                    left: 16,
                    right: 16,
                    height: barHeight,
                    child: Row(
                      children: [
                        GlassIconButton(
                          asset: 'assets/icons/base/careleft.svg',
                          onTap: onBack ?? () => context.pop(),
                          iconColor: Colors.white,
                          fillColor: Colors.white.withValues(alpha: 0.18),
                          borderColor: Colors.white.withValues(alpha: 0.30),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Expanded headline + subtitle, anchored to the bottom and
                  // fading out as the header collapses.
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 18,
                    child: IgnorePointer(
                      child: Opacity(
                        opacity: t,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              headline,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.2,
                                letterSpacing: -0.4,
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

/// Rounded-top "sticky" content container that sits directly under
/// [ModuleHeroSliver]. Its rounded top corners + the small gradient gap above
/// read as a separate card floating below the rounded-bottom header. Subsequent
/// slivers (lists) render on the scaffold background, which matches [child]'s
/// fill.
class ModuleHeroSheet extends StatelessWidget {
  const ModuleHeroSheet({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(16, 24, 16, 0),
    this.gap = 12,
  });

  final Widget child;
  final EdgeInsets padding;

  /// Height of the gradient gap shown between the header and this sheet.
  final double gap;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      // Header end-color fills the gap above + the rounded top-corner notches.
      child: ColoredBox(
        color: AppColors.heroHeaderEnd,
        child: Container(
          margin: EdgeInsets.only(top: gap),
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
