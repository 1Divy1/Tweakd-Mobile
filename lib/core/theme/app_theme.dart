import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final colorScheme = const ColorScheme.light(
      primary: AppColors.accent,
      onPrimary: Colors.white,
      secondary: AppColors.accent,
      onSecondary: Colors.white,
      surface: AppColors.surface,
      onSurface: AppColors.ink,
      error: Color(0xFFB3261E),
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.bg,
      canvasColor: AppColors.bg,
      dividerColor: AppColors.line,
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w800),
        displayMedium: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w800),
        headlineLarge: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w800),
        headlineMedium: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w800),
        headlineSmall: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w700),
        titleLarge: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w700),
        titleMedium: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w700),
        titleSmall: TextStyle(color: AppColors.ink2, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: AppColors.ink, fontSize: 16),
        bodyMedium: TextStyle(color: AppColors.ink2, fontSize: 14),
        bodySmall: TextStyle(color: AppColors.mute, fontSize: 12),
        labelLarge: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w700, letterSpacing: 0.4),
        labelMedium: TextStyle(color: AppColors.ink2, fontWeight: FontWeight.w600),
        labelSmall: TextStyle(
          color: AppColors.mute,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.4,
        ),
      ),
      iconTheme: const IconThemeData(color: AppColors.ink),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(color: AppColors.muteSoft, fontSize: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.line),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.muteSoft,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.4,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink,
          backgroundColor: AppColors.surface,
          side: const BorderSide(color: AppColors.line),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.line),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.ink,
        elevation: 0,
      ),
    );
  }
}
