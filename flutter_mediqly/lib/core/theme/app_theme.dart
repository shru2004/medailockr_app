// ─── App Theme ─────────────────────────────────────────────────────────────
// Mirrors the CSS variables and Inter font configuration from index.css

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryBlue,
          surface: AppColors.bgColor,
          primary: AppColors.primaryBlue,
          secondary: AppColors.primaryPurple,
          error: AppColors.dangerRed,
        ),
        scaffoldBackgroundColor: AppColors.bgColor,
        textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).copyWith(
          bodyLarge:     const TextStyle(color: AppColors.textPrimary,   fontSize: 16, fontWeight: FontWeight.w400),
          bodyMedium:    const TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w400),
          bodySmall:     const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w400),
          titleLarge:    const TextStyle(color: AppColors.textPrimary,   fontSize: 22, fontWeight: FontWeight.w600),
          titleMedium:   const TextStyle(color: AppColors.textPrimary,   fontSize: 18, fontWeight: FontWeight.w600),
          titleSmall:    const TextStyle(color: AppColors.textPrimary,   fontSize: 16, fontWeight: FontWeight.w500),
          labelSmall:    const TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.w500),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.cardBg,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
          scrolledUnderElevation: 0,
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.borderColor,
          thickness: 1,
          space: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.inputBg,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
          labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        cardTheme: CardThemeData(
          color: AppColors.cardBg,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.cardBg,
          selectedItemColor: AppColors.primaryBlue,
          unselectedItemColor: AppColors.textSecondary,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
          selectedLabelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
          unselectedLabelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w400),
        ),
      );
}
