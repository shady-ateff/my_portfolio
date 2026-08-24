import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBg,
      primaryColor: AppColors.neonCyan,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.neonCyan,
        secondary: AppColors.neonPurple,
        surface: AppColors.darkSurface,
      ),
      textTheme: _buildTextTheme(Brightness.dark),
      useMaterial3: true,
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBg,
      primaryColor: AppColors.neonCyan,
      colorScheme: const ColorScheme.light(
        primary: AppColors.neonCyan,
        secondary: AppColors.neonPurple,
        surface: AppColors.lightSurface,
      ),
      textTheme: _buildTextTheme(Brightness.light),
      useMaterial3: true,
    );
  }

  static TextTheme _buildTextTheme(Brightness brightness) {
    final baseColor = brightness == Brightness.dark 
        ? AppColors.textDarkPrimary 
        : AppColors.textLightPrimary;

    // Use Fira Code for a code-like developer aesthetic
    return GoogleFonts.firaCodeTextTheme().copyWith(
      displayLarge: GoogleFonts.firaCode(
        color: baseColor,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: GoogleFonts.firaCode(
        color: baseColor,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: GoogleFonts.firaCode(
        color: baseColor,
        fontWeight: FontWeight.bold,
      ),
      headlineLarge: GoogleFonts.firaCode(
        color: baseColor,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: GoogleFonts.firaCode(
        color: baseColor,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: GoogleFonts.firaCode(
        color: baseColor,
        fontWeight: FontWeight.w600,
      ),
    ).apply(
      bodyColor: baseColor,
      displayColor: baseColor,
    );
  }
}
