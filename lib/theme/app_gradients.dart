import 'package:flutter/material.dart';

class AppGradients {
  AppGradients._();

  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7B2CBF), Color(0xFFFF4FA3)],
  );

  static const LinearGradient gold = LinearGradient(
    colors: [Color(0xFFD4AF37), Color(0xFFFFE082)],
  );

  static const LinearGradient dark = LinearGradient(
    colors: [Color(0xFF121212), Color(0xFF2D2D2D)],
  );

  static const LinearGradient hero = LinearGradient(
    colors: [Color(0xFF6A1B9A), Color(0xFFFF4FA3), Color(0xFFFF77C8)],
  );
}
