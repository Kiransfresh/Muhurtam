import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class PinkGlassBackground extends StatelessWidget {
  const PinkGlassBackground({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF7FA), Color(0xFFFCE8F0), Color(0xFFF5EFFA)],
        ),
      ),
      child: Stack(
        children: [
          const Positioned(
            right: -120,
            top: 80,
            child: _Glow(color: AppColors.blush, size: 420),
          ),
          const Positioned(
            left: -130,
            bottom: 80,
            child: _Glow(color: AppColors.lavender, size: 360),
          ),
          child,
        ],
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.color, required this.size});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
        ),
      ),
    );
  }
}
