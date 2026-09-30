import 'package:flutter/material.dart';

class AppShadows {
  AppShadows._();

  static final List<BoxShadow> card = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 20,
      spreadRadius: 1,
      offset: const Offset(0, 10),
    ),
  ];

  static final List<BoxShadow> button = [
    BoxShadow(
      color: const Color(0xFFFF4FA3).withValues(alpha: 0.25),
      blurRadius: 18,
      offset: const Offset(0, 8),
    ),
  ];
}
