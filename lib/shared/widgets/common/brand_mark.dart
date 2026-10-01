import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

/// A scalable ring, heart, and M motif inspired by the supplied Muhurtham logo.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 48});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Muhurtham logo',
      image: true,
      child: Container(
        width: size,
        height: size,
        padding: EdgeInsets.all(size * 0.16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size * 0.3),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6D465F), Color(0xFF392B3F)],
          ),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.10),
              blurRadius: 20,
            ),
          ],
        ),
        child: CustomPaint(painter: _LogoPainter()),
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 100, size.height / 100);
    final paint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawOval(const Rect.fromLTWH(20, 3, 60, 62), paint);
    final heart = Path()
      ..moveTo(50, 91)
      ..cubicTo(8, 65, 1, 45, 15, 32)
      ..cubicTo(26, 22, 41, 27, 50, 40)
      ..cubicTo(59, 27, 74, 22, 85, 32)
      ..cubicTo(99, 45, 92, 65, 50, 91);
    canvas.drawPath(heart, paint);
    canvas.drawPath(
      Path()
        ..moveTo(31, 65)
        ..lineTo(31, 47)
        ..lineTo(50, 64)
        ..lineTo(69, 47)
        ..lineTo(69, 65),
      paint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _LogoPainter oldDelegate) => false;
}
