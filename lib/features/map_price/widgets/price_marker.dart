import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// A price pill pinned to a map coordinate. Pops up and turns navy when
/// selected; otherwise a clean white pill with an accent dot.
class PriceMarker extends StatelessWidget {
  const PriceMarker({
    super.key,
    required this.label,
    required this.accent,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final Color accent;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: selected ? AppColors.navy : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? AppColors.navy : accent.withValues(alpha: 0.55),
                  width: 1.4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.navy.withValues(alpha: selected ? 0.30 : 0.16),
                    blurRadius: selected ? 14 : 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: selected ? AppColors.gold : accent,
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
                      color: selected ? Colors.white : AppColors.navy,
                    ),
                  ),
                ],
              ),
            ),
            // Downward pointer to the exact coordinate.
            CustomPaint(
              size: const Size(12, 7),
              painter: _PointerPainter(
                color: selected ? AppColors.navy : Colors.white,
              ),
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
