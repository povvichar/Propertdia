import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// A price pill pinned to a map coordinate.
///
/// Colour encodes listing type at a glance:
///   gold pill  + navy text  → For Sale
///   blue pill  + white text → For Rent
///   navy pill  + white text → selected (either type)
class PriceMarker extends StatelessWidget {
  const PriceMarker({
    super.key,
    required this.label,
    required this.accent,
    required this.selected,
    required this.onTap,
  });

  final String label;

  /// `AppColors.gold` for sale, `AppColors.info` for rent.
  final Color accent;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Pill background: navy when selected, accent colour when idle.
    final pillBg = selected ? AppColors.navy : accent;

    // Gold is a light/bright hue — use navy text for legibility.
    // Blue and navy are dark — use white text.
    final bool onLight = !selected && accent == AppColors.gold;
    final textColor = onLight ? AppColors.navy : Colors.white;

    // Dot: gold accent on selected state; otherwise contrasting dot on the fill.
    final dotColor = selected
        ? AppColors.gold
        : onLight
            ? AppColors.navy.withValues(alpha: 0.55)
            : Colors.white.withValues(alpha: 0.75);

    // Shadow matches the pill colour for a natural glow.
    final shadowColor = pillBg.withValues(alpha: selected ? 0.40 : 0.38);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: selected ? 1.12 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutBack,
        alignment: Alignment.bottomCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: pillBg,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: selected ? 16 : 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: dotColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
            // Downward pointer anchors the pin to the exact coordinate.
            CustomPaint(
              size: const Size(12, 7),
              painter: _PointerPainter(color: pillBg),
            ),
          ],
        ),
      ),
    );
  }
}

class _PointerPainter extends CustomPainter {
  _PointerPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_PointerPainter old) => old.color != color;
}
