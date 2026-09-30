import 'package:flutter/material.dart';

class AppTextStyles {
  AppTextStyles._();

  // Hero text style - for large headings
  static const TextStyle hero = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 40,
    fontWeight: FontWeight.w700,
    color: Color(0xFF222222),
    letterSpacing: 0.5,
    height: 1.2,
  );

  // H1 - Main headings
  static const TextStyle h1 = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 30,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.3,
    height: 1.3,
  );

  // H2 - Sub headings
  static const TextStyle h2 = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
    height: 1.4,
  );

  // Title - Section titles
  static const TextStyle title = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
    height: 1.5,
  );

  // Body - Regular text
  static const TextStyle body = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.6,
    letterSpacing: 0.1,
  );

  // Caption - Small text
  static const TextStyle caption = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 13,
    color: Colors.grey,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.1,
  );

  // Gold text style
  static const TextStyle gold = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Color(0xFFD4AF37), // Gold color
    letterSpacing: 0.5,
  );

  // Large gold heading
  static const TextStyle goldHeading = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: Color(0xFFD4AF37),
    letterSpacing: 1.0,
    height: 1.2,
  );

  // Wedding theme body text
  static const TextStyle weddingBody = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: Color(0xFFB8A9C9), // Secondary text color
    height: 1.6,
    letterSpacing: 0.2,
  );

  // Button text
  static const TextStyle button = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: Colors.black,
  );

  // Small label
  static const TextStyle label = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
    color: Color(0xFFB8A9C9),
  );
}

// ✅ FIXED: Extension without creating instance of AppTextStyles
extension TextStylesExtension on BuildContext {
  TextStyle get hero => const TextStyle(
    fontFamily: 'Roboto',
    fontSize: 40,
    fontWeight: FontWeight.w700,
    color: Color(0xFF222222),
    letterSpacing: 0.5,
    height: 1.2,
  );

  TextStyle get h1 => const TextStyle(
    fontFamily: 'Roboto',
    fontSize: 30,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.3,
    height: 1.3,
  );

  TextStyle get h2 => const TextStyle(
    fontFamily: 'Roboto',
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
    height: 1.4,
  );

  TextStyle get title => const TextStyle(
    fontFamily: 'Roboto',
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
    height: 1.5,
  );

  TextStyle get body => const TextStyle(
    fontFamily: 'Roboto',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.6,
    letterSpacing: 0.1,
  );

  TextStyle get caption => const TextStyle(
    fontFamily: 'Roboto',
    fontSize: 13,
    color: Colors.grey,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.1,
  );

  TextStyle get gold => const TextStyle(
    fontFamily: 'Roboto',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Color(0xFFD4AF37),
    letterSpacing: 0.5,
  );

  TextStyle get goldHeading => const TextStyle(
    fontFamily: 'Roboto',
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: Color(0xFFD4AF37),
    letterSpacing: 1.0,
    height: 1.2,
  );

  TextStyle get weddingBody => const TextStyle(
    fontFamily: 'Roboto',
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: Color(0xFFB8A9C9),
    height: 1.6,
    letterSpacing: 0.2,
  );

  TextStyle get button => const TextStyle(
    fontFamily: 'Roboto',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: Colors.black,
  );

  TextStyle get label => const TextStyle(
    fontFamily: 'Roboto',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
    color: Color(0xFFB8A9C9),
  );
}
