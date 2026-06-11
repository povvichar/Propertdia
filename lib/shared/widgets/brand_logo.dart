import 'package:flutter/material.dart';

/// PROPERTDIA house mark: a roofline with a square-spiral "key" motif,
/// drawn with CustomPaint so it scales crisply at any size.
class BrandLogo extends StatelessWidget {
  const BrandLogo({
    super.key,
    this.size = 80,
    this.color = Colors.white,
    this.strokeWidth,
  });

  final double size;
  final Color color;
  final double? strokeWidth;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _BrandLogoPainter(
        color: color,
        strokeWidth: strokeWidth ?? size * 0.055,
      ),
    );
  }
}

class _BrandLogoPainter extends CustomPainter {
  _BrandLogoPainter({required this.color, required this.strokeWidth});

  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    // Roof: apex at top center, eaves extending past the walls.
    final roof = Path()
      ..moveTo(w * 0.08, h * 0.42)
      ..lineTo(w * 0.50, h * 0.06)
      ..lineTo(w * 0.92, h * 0.42);
    canvas.drawPath(roof, paint);

    // Walls (open at the top, under the roof).
    canvas.drawLine(
        Offset(w * 0.20, h * 0.40), Offset(w * 0.20, h * 0.94), paint);
    canvas.drawLine(
        Offset(w * 0.80, h * 0.40), Offset(w * 0.80, h * 0.94), paint);
    canvas.drawLine(
        Offset(w * 0.20, h * 0.94), Offset(w * 0.80, h * 0.94), paint);

    // Square spiral motif centered in the body of the house.
    final spiral = Path()
      ..moveTo(w * 0.36, h * 0.52)
      ..lineTo(w * 0.66, h * 0.52)
      ..lineTo(w * 0.66, h * 0.82)
      ..lineTo(w * 0.36, h * 0.82)
      ..lineTo(w * 0.36, h * 0.62)
      ..lineTo(w * 0.56, h * 0.62)
      ..lineTo(w * 0.56, h * 0.72)
      ..lineTo(w * 0.46, h * 0.72);
    canvas.drawPath(spiral, paint);
  }

  @override
  bool shouldRepaint(_BrandLogoPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}

/// Subtle diamond lattice used on the gold splash background.
class DiamondPatternPainter extends CustomPainter {
  const DiamondPatternPainter({required this.color, this.cell = 96});

  final Color color;
  final double cell;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (double y = -cell; y < size.height + cell; y += cell) {
      for (double x = -cell; x < size.width + cell; x += cell) {
        final offsetX = ((y / cell).round().isEven) ? 0.0 : cell / 2;
        final path = Path()
          ..moveTo(x + offsetX, y - cell * 0.42)
          ..lineTo(x + offsetX + cell * 0.42, y)
          ..lineTo(x + offsetX, y + cell * 0.42)
          ..lineTo(x + offsetX - cell * 0.42, y)
          ..close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(DiamondPatternPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.cell != cell;
}
