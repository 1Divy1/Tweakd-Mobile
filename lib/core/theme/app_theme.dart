import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import '../shared/layout/app_layout.dart';

class AppTheme {
  AppTheme._();

  /// Builds the theme for [brightness].
  ///
  /// There is deliberately no separate `light()`/`dark()` pair: [AppColors]
  /// already resolves every token against the active brightness, so the two
  /// themes are the same tree of widgets reading the same token names. Only
  /// the `brightness` flags and the `ColorScheme` base differ.
  ///
  /// Note this must be called *after* `AppColors.applyBrightness`, and the
  /// result must not be cached across a theme change — the tokens are read
  /// eagerly here, so a retained `ThemeData` holds the palette it was built
  /// with. `TweakdApp` rebuilds it on every theme change for that reason.
  static ThemeData of(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: AppColors.accent,
      onPrimary: AppColors.onAccent,
      secondary: AppColors.accent,
      onSecondary: AppColors.onAccent,
      surface: AppColors.surface,
      onSurface: AppColors.ink,
      error: AppColors.danger,
      onError: AppColors.onDanger,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.bg,
      canvasColor: AppColors.bg,
      dividerColor: AppColors.line,
      textTheme: TextTheme(
        displayLarge: TextStyle(
          color: AppColors.ink,
          fontWeight: FontWeight.w800,
        ),
        displayMedium: TextStyle(
          color: AppColors.ink,
          fontWeight: FontWeight.w800,
        ),
        headlineLarge: TextStyle(
          color: AppColors.ink,
          fontWeight: FontWeight.w800,
        ),
        headlineMedium: TextStyle(
          color: AppColors.ink,
          fontWeight: FontWeight.w800,
        ),
        headlineSmall: TextStyle(
          color: AppColors.ink,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: TextStyle(
          color: AppColors.ink,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: TextStyle(
          color: AppColors.ink,
          fontWeight: FontWeight.w700,
        ),
        titleSmall: TextStyle(
          color: AppColors.ink2,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(color: AppColors.ink, fontSize: 16),
        bodyMedium: TextStyle(color: AppColors.ink2, fontSize: 14),
        bodySmall: TextStyle(color: AppColors.mute, fontSize: 12),
        labelLarge: TextStyle(
          color: AppColors.ink,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
        labelMedium: TextStyle(
          color: AppColors.ink2,
          fontWeight: FontWeight.w600,
        ),
        labelSmall: TextStyle(
          color: AppColors.mute,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.4,
        ),
      ),
      iconTheme: IconThemeData(color: AppColors.ink),
      // No border by default: text fields across the app wrap their TextField
      // in a bordered Container and set `border: InputBorder.none` on the field.
      // A themed outline here would still paint through the enabled/focused
      // states, producing an ugly double ("inner") border. Fields that want a
      // border of their own (e.g. AuthTextField) set it explicitly.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: TextStyle(color: AppColors.muteSoft, fontSize: 15),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.onAccent,
          disabledBackgroundColor: AppColors.muteSoft,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
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
          side: BorderSide(color: AppColors.line),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.line),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.ink,
        elevation: 0,
        // The OS status bar icons have to invert with the theme, or they
        // disappear into the background on one of the two.
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),
      // Sheets and dialogs are "raised" surfaces, never the page ground.
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        // Flutter's default has no max width, so a confirmation spans the
        // whole screen on a tablet or unfolded foldable.
        constraints: const BoxConstraints(
          minWidth: 280,
          maxWidth: AppLayout.narrowWidth,
        ),
      ),
    );
  }
}
