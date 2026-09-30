import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

/// Clips the blur to each surface so the background stays crisp elsewhere.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.radius = 24,
    this.opacity = 0.66,
  });

  final Widget child;
  final EdgeInsets padding;
  final double radius;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.07),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: opacity),
              borderRadius: borderRadius,
              border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
