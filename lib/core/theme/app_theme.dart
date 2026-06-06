import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Brand
  static const background   = Color(0xFF0A0F1E);
  static const surface      = Color(0xFF111827);
  static const surfaceCard  = Color(0xFF1A2235);
  static const primary      = Color(0xFF00E5A0); // Electric Mint
  static const primaryDark  = Color(0xFF00B87A);
  static const accent       = Color(0xFF00B4FF); // Cyan
  static const accentWarm   = Color(0xFFFF6B35); // Orange (warning/rep flash)

  // Skeleton overlay colours
  static const formGood    = Color(0xFF00E5A0);
  static const formWarn    = Color(0xFFFFD60A);
  static const formBad     = Color(0xFFFF3B3B);

  // Text
  static const textPrimary   = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFF8B9DC3);
  static const textMuted     = Color(0xFF4A5568);

  // Gradients
  static const gradientStart = Color(0xFF0A0F1E);
  static const gradientMid   = Color(0xFF0D1B35);
  static const gradientEnd   = Color(0xFF091428);
}

class AppTheme {
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surface,
        onPrimary: AppColors.background,
        onSecondary: AppColors.textPrimary,
        onSurface: AppColors.textPrimary,
        error: AppColors.formBad,
      ),
      textTheme: GoogleFonts.interTextTheme(
        const TextTheme(
          displayLarge: TextStyle(
            fontSize: 48, fontWeight: FontWeight.w800,
            color: AppColors.textPrimary, letterSpacing: -1.5,
          ),
          displayMedium: TextStyle(
            fontSize: 36, fontWeight: FontWeight.w700,
            color: AppColors.textPrimary, letterSpacing: -1,
          ),
          displaySmall: TextStyle(
            fontSize: 28, fontWeight: FontWeight.w700,
            color: AppColors.textPrimary, letterSpacing: -0.5,
          ),
          headlineMedium: TextStyle(
            fontSize: 22, fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          headlineSmall: TextStyle(
            fontSize: 18, fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          bodyLarge: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w400,
            color: AppColors.textPrimary, height: 1.6,
          ),
          bodyMedium: TextStyle(
            fontSize: 14, fontWeight: FontWeight.w400,
            color: AppColors.textSecondary, height: 1.5,
          ),
          labelLarge: TextStyle(
            fontSize: 15, fontWeight: FontWeight.w600,
            color: AppColors.textPrimary, letterSpacing: 0.3,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF1E2D48), width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.background,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.inter(
            fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.3,
          ),
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF1E2D48)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF1E2D48)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        hintStyle: const TextStyle(color: AppColors.textMuted),
      ),
    );
  }
}
