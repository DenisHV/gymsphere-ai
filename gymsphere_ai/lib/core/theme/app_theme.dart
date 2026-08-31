import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get temaOscuro {
    return ThemeData(
      scaffoldBackgroundColor: AppColors.neutral,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.tertiary,
      ),
      useMaterial3: true,
      textTheme: TextTheme(
        headlineLarge: GoogleFonts.sora(
          fontWeight: FontWeight.bold,
          color: AppColors.secondary,
        ),
        headlineMedium: GoogleFonts.sora(
          fontWeight: FontWeight.bold,
          color: AppColors.secondary,
        ),
        bodyMedium: GoogleFonts.hankenGrotesk(
          color: AppColors.secondary,
        ),
        labelSmall: GoogleFonts.jetBrainsMono(
          letterSpacing: 1.2,
          color: AppColors.secondary,
        ),
      ),
    );
  }
}