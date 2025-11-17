import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Material 3 Theme Configuration with Pastel Color Palette
/// Color scheme: Pink #FFB6C1, Peach #FFDAB9, Mint #E0FFF0, Soft Gray #F5F5F5, Dark Text #2C3E50
class AppTheme {
  // Pastel Colors
  static const Color primaryPink = Color(0xFFFFB6C1);
  static const Color secondaryPeach = Color(0xFFFFDAB9);
  static const Color accentMint = Color(0xFFE0FFF0);
  static const Color backgroundSoftGray = Color(0xFFF5F5F5);
  static const Color textDark = Color(0xFF2C3E50);

  // Supporting colors
  static const Color errorRed = Color(0xFFFF6B6B);
  static const Color successGreen = Color(0xFF6BCF7F);
  static const Color warningYellow = Color(0xFFFFC837);
  static const Color infoBlue = Color(0xFF5DADE2);

  // Dark mode warm colors
  static const Color darkPrimaryPink = Color(0xFFFFB6C1);
  static const Color darkSecondaryPeach = Color(0xFFFFDAB9);
  static const Color darkBackgroundGray = Color(0xFF1E1E1E);
  static const Color darkSurfaceGray = Color(0xFF2D2D2D);
  static const Color darkTextLight = Color(0xFFE8E8E8);

  // Border radius
  static const double borderRadius = 16.0;

  /// Light Theme
  static ThemeData get lightTheme {
    final ColorScheme colorScheme = ColorScheme.light(
      primary: primaryPink,
      onPrimary: Colors.white,
      secondary: secondaryPeach,
      onSecondary: textDark,
      tertiary: accentMint,
      onTertiary: textDark,
      error: errorRed,
      onError: Colors.white,
      surface: backgroundSoftGray,
      onSurface: textDark,
      surfaceContainerHighest: Colors.white,
      outline: textDark.withOpacity(0.2),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,

      // Typography - Poppins font family
      textTheme: GoogleFonts.poppinsTextTheme().apply(
        bodyColor: textDark,
        displayColor: textDark,
      ),

      // AppBar Theme
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: backgroundSoftGray,
        foregroundColor: textDark,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        color: Colors.white,
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.1),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          side: BorderSide(color: primaryPink, width: 2),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: textDark.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: textDark.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: primaryPink, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: errorRed, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        labelStyle: GoogleFonts.poppins(color: textDark.withOpacity(0.6)),
        hintStyle: GoogleFonts.poppins(color: textDark.withOpacity(0.4)),
      ),

      // FloatingActionButton Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 4,
        backgroundColor: primaryPink,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),

      // BottomNavigationBar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryPink,
        unselectedItemColor: textDark.withOpacity(0.5),
        selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w400),
        elevation: 8,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: accentMint,
        labelStyle: GoogleFonts.poppins(color: textDark),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius / 2),
        ),
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: textDark.withOpacity(0.1),
        thickness: 1,
        space: 1,
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryPink,
      ),

      // Scaffold Background
      scaffoldBackgroundColor: backgroundSoftGray,
    );
  }

  /// Dark Theme with Warm Colors
  static ThemeData get darkTheme {
    final ColorScheme colorScheme = ColorScheme.dark(
      primary: darkPrimaryPink,
      onPrimary: darkTextLight,
      secondary: darkSecondaryPeach,
      onSecondary: darkTextLight,
      tertiary: accentMint,
      onTertiary: textDark,
      error: errorRed,
      onError: Colors.white,
      surface: darkSurfaceGray,
      onSurface: darkTextLight,
      surfaceContainerHighest: darkSurfaceGray,
      outline: darkTextLight.withOpacity(0.2),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,

      // Typography - Poppins font family
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: darkTextLight,
        displayColor: darkTextLight,
      ),

      // AppBar Theme
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: darkBackgroundGray,
        foregroundColor: darkTextLight,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: darkTextLight,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        color: darkSurfaceGray,
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.3),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          side: BorderSide(color: darkPrimaryPink, width: 2),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurfaceGray,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: darkTextLight.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: darkTextLight.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: darkPrimaryPink, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: errorRed, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        labelStyle: GoogleFonts.poppins(color: darkTextLight.withOpacity(0.6)),
        hintStyle: GoogleFonts.poppins(color: darkTextLight.withOpacity(0.4)),
      ),

      // FloatingActionButton Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 4,
        backgroundColor: darkPrimaryPink,
        foregroundColor: darkTextLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),

      // BottomNavigationBar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: darkSurfaceGray,
        selectedItemColor: darkPrimaryPink,
        unselectedItemColor: darkTextLight.withOpacity(0.5),
        selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w400),
        elevation: 8,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: darkSurfaceGray,
        labelStyle: GoogleFonts.poppins(color: darkTextLight),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius / 2),
        ),
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: darkTextLight.withOpacity(0.1),
        thickness: 1,
        space: 1,
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: darkPrimaryPink,
      ),

      // Scaffold Background
      scaffoldBackgroundColor: darkBackgroundGray,
    );
  }
}
