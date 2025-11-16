import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// TODO: Additional typography styles
// Custom text styles beyond the theme defaults

class AppTypography {
  AppTypography._();

  // Heading styles
  static TextStyle get heading1 => GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.bold,
      );

  static TextStyle get heading2 => GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get heading3 => GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
      );

  // Body styles
  static TextStyle get bodyLarge => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get bodyMedium => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get bodySmall => GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w400,
      );

  // Special styles
  static TextStyle get button => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get caption => GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w400,
      );
}
