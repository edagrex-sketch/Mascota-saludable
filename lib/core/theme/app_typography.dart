import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography scale for Mascota Saludable
///
/// Headlines: Outfit (geometric, modern, premium)
/// Body / Labels: Inter (legible, neutral, systematic)
class AppTypography {
  AppTypography._();

  // ── Display ──
  static TextStyle get displayLg => GoogleFonts.outfit(
        fontSize: 40,
        fontWeight: FontWeight.w600,
        height: 48 / 40,
        letterSpacing: -0.02,
      );

  // ── Headlines ──
  static TextStyle get headlineLg => GoogleFonts.outfit(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        height: 40 / 32,
        letterSpacing: -0.01,
      );

  static TextStyle get headlineLgMobile => GoogleFonts.outfit(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        height: 36 / 28,
      );

  static TextStyle get headlineMd => GoogleFonts.outfit(
        fontSize: 24,
        fontWeight: FontWeight.w500,
        height: 32 / 24,
      );

  static TextStyle get titleLg => GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        height: 28 / 20,
      );

  // ── Body ──
  static TextStyle get bodyLg => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
      );

  static TextStyle get bodyMd => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 20 / 14,
      );

  // ── Labels ──
  static TextStyle get labelLg => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 16 / 12,
        letterSpacing: 0.05,
      );

  static TextStyle get labelMd => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 16 / 11,
      );
}
