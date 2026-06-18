import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme/app_colors.dart';

/// Frosted circular icon button — the app's shared liquid-glass control
/// (back, close, recenter…). Translucent fill + hairline border + blur.
class GlassIconButton extends StatelessWidget {
  const GlassIconButton({
    super.key,
    required this.asset,
    required this.onTap,
    this.size = 40,
    this.iconSize = 18,
    this.iconColor = AppColors.navy,
    this.fillColor,
    this.borderColor,
  });

  final String asset;
  final VoidCallback onTap;
  final double size;
  final double iconSize;
  final Color iconColor;

  /// Glass fill. Defaults to a light frost (white @78%) for light backgrounds.
  final Color? fillColor;

  /// Hairline border. Defaults to white @70%.
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: fillColor ?? Colors.white.withValues(alpha: 0.78),
              shape: BoxShape.circle,
              border: Border.all(
                color: borderColor ?? Colors.white.withValues(alpha: 0.7),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.navy.withValues(alpha: 0.10),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: SvgPicture.asset(
                asset,
                width: iconSize,
                height: iconSize,
                colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
