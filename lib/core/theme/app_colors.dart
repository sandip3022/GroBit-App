import 'package:flutter/material.dart';

class AppColors {
  // 1. BASE COLORS
  static const Color primary = Color(0xFF2C3E50); // Midnight Navy
  static const Color primaryDark = Color(0xFF5D8AA8); // Air Force Blue
  static const Color secondary = Color(0xFFFF6B6B); // Soft Coral (Action)
  static const Color background = Color(0xFFF7F9FC); // Very light Grey-Blue

  static const Color darkBackground = Color(0xFF0F172A);
  static const Color surface = Colors.white;
  static const Color error = Color(0xFFE57373);
  static const Color darkSurface = Color(0xFF1E293B);

  // 2. TEXT COLORS
  static const Color textPrimary = Color(0xFF2D3436);
  static const Color textSecondary = Color(0xFF636E72);

  static const Color errorLight = Color(0xFFD32F2F); // Darker red for White backgrounds
  static const Color errorDark = Color(0xFFE57373); // Soft red for Dark backgrounds

  // Returns the color with specific opacity (e.g., 10%, 20%)
  static Color primaryTint10 = primary.withValues(alpha: 0.1);
  static Color primaryTint20 = primary.withValues(alpha: 0.2);

  static Color secondaryTint10 = secondary.withValues(alpha: 0.1);
  static Color secondaryTint20 = secondary.withValues(alpha: 0.2);

 
 static const Color white = Colors.white;
  static Color airForceBlue = const Color(0xFF5D8AA8);
  static Color softCoral = const Color(0xFFFF6B6B);
  static Color purple = const Color(0xFF6C5CE7);
  static Color teal = const Color(0xFF00B894);
  static Color blue = const Color(0xFF0984E3);
  static Color orange = const Color(0xFFE17055);
  static Color pink = const Color(0xFFFD79A8);


  static Color green = const Color(0xFF27AE60);
  static Color yellow = const Color(0xFFE17055);
  static Color red = const Color(0xFFE74C3C);
}
