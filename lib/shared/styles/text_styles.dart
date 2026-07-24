import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TextStyles {
  static TextStyle get heading1 => GoogleFonts.orbitron(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5,
    color: Colors.white,
  );

  static TextStyle get heading2 => GoogleFonts.orbitron(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: Colors.white,
  );

  static TextStyle get heading3 => GoogleFonts.orbitron(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
    color: Colors.white,
  );

  static TextStyle get heading4 => GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static TextStyle get heading5 => GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static TextStyle get heading6 => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static TextStyle get bodyLarge => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: Colors.white70,
    height: 1.5,
  );

  static TextStyle get bodyMedium => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: Colors.white70,
    height: 1.5,
  );

  static TextStyle get bodySmall => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: Colors.white54,
    height: 1.5,
  );

  static TextStyle get buttonLarge => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static TextStyle get buttonMedium => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static TextStyle get buttonSmall => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );

  static TextStyle get caption => GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.normal,
    color: Colors.white38,
  );

  static TextStyle get overline => GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: Colors.white38,
    letterSpacing: 1.0,
  );

  static TextStyle get gradientText => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    foreground: Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF6C63FF), Color(0xFF00D4FF)],
      ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
  );

  static TextStyle get neonText => GoogleFonts.orbitron(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    shadows: const [
      Shadow(
        blurRadius: 10,
        color: Color(0x336C63FF),
      ),
      Shadow(
        blurRadius: 20,
        color: Color(0x336C63FF),
      ),
    ],
  );

  static TextStyle get codeBlock => GoogleFonts.jetBrainsMono(
    fontSize: 14,
    color: Colors.greenAccent,
    backgroundColor: Colors.black26,
    height: 1.6,
  );
}