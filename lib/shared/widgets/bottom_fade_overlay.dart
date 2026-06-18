import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Fixed glassmorphism overlay pinned to the bottom of a scrolling view. It
/// softly fades content into the background as it exits the viewport: a
/// vertical [color] gradient (transparent → opaque downward) blends the content
/// into the surface, while a [blur] backdrop filter adds the frosted-glass feel.
/// A [ShaderMask] ramps the whole effect from invisible at the top edge to full
/// at the bottom, so the transition reads as a gentle fade rather than a band.
///
/// Drop it as the last child of a [Stack] that sits over a scroll view
/// (`Positioned(left: 0, right: 0, bottom: 0, child: BottomFadeOverlay())`).
/// It is wrapped in [IgnorePointer], so taps pass straight through to content.
class BottomFadeOverlay extends StatelessWidget {
  const BottomFadeOverlay({
    super.key,
    this.height = 40,
    this.blur = 10,
    this.color,
  });

  /// Overlay height — keep it in the 24–48px range for a subtle edge fade.
  final double height;

  /// Backdrop blur sigma at full strength (bottom edge).
  final double blur;

  /// Surface colour the content fades into. Defaults to [AppColors.background].
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.background;
    return IgnorePointer(
      child: ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (rect) => const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black],
          stops: [0.0, 0.85],
        ).createShader(rect),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
            child: Container(
              height: height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [c.withValues(alpha: 0), c.withValues(alpha: 0.92)],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
