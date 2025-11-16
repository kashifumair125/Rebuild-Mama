import 'package:flutter/material.dart';

// TODO: Additional color definitions
// Extended color palette beyond the main theme colors

// Note: Main color scheme is defined in lib/config/theme.dart
class AppColors {
  AppColors._();

  // Semantic colors for specific use cases
  static const Color success = Color(0xFF6BCF7F);
  static const Color warning = Color(0xFFFFC837);
  static const Color info = Color(0xFF5DADE2);
  static const Color danger = Color(0xFFFF6B6B);

  // Gradient colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFFB6C1), Color(0xFFFFDAB9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
