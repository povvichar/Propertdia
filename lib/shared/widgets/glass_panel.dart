import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Shared liquid-glass surface — frosted translucent fill, hairline white
/// border and a soft navy shadow. The blur reads strongest when there is
/// content (imagery or a scrolling list) behind it. Mirrors the values used
/// by the home `_GlassNav` and the map `GlassSurface`.
class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.radius = 18,
    this.padding,
    this.opacity = 0.72,
    this.blur = 22,
    this.border = true,
    this.shadow = true,
  });

  final Widget child;
  final double radius;
  final EdgeInsetsGeometry? padding;
  final double opacity;
  final double blur;
  final bool border;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: opacity),
            borderRadius: BorderRadius.circular(radius),
            border: border
                ? Border.all(
                    color: Colors.white.withValues(alpha: 0.7),
                    width: 1,
                  )
                : null,
            boxShadow: shadow
                ? [
                    BoxShadow(
                      color: AppColors.navy.withValues(alpha: 0.10),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: child,
        ),
      ),
    );
  }
}
