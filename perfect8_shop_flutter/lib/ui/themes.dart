// =============================================================
// File: lib/ui/themes.dart
// Purpose: 3 cohesive design systems (Material 3) — Nordic Light,
//          Dark Pro, and Storefront Pop — each with light & dark.
// =============================================================
import 'package:flutter/material.dart';
import '../app.dart';

class Themes {
  // ——— Palette seeds ———
  static const _nordicSeed = Color(0xFF2A7F62); // pine green
  static const _nordicSecondary = Color(0xFF3A506B); // steel blue
  static const _nordicTertiary = Color(0xFFBC6C25); // bronze

  static const _darkProSeed = Color(0xFF7BA2FF); // cool blue
  static const _darkProSecondary = Color(0xFF64D2FF); // cyan
  static const _darkProTertiary = Color(0xFFFFB86C); // amber

  static const _storeSeed = Color(0xFFFF5A5F); // coral red
  static const _storeSecondary = Color(0xFF00A699); // teal
  static const _storeTertiary = Color(0xFFFFC145); // sun

  static ThemeData forStyle(UIStyle style, Brightness b) {
    switch (style) {
      case UIStyle.nordicLight:
        return _nordic(b);
      case UIStyle.darkPro:
        return _darkPro(b);
      case UIStyle.storefrontPop:
        return _storefront(b);
    }
  }

  // Nordic Light — calm, airy, portfolio‑friendly.
  static ThemeData _nordic(Brightness b) {
    final isDark = b == Brightness.dark;
    final base = ColorScheme.fromSeed(
      seedColor: _nordicSeed,
      brightness: b,
    ).copyWith(
      secondary: _nordicSecondary,
      tertiary: _nordicTertiary,
    );
    return _material3(base, isDark);
  }

  // Dark Pro — developer/admin‑friendly dark theme.
  static ThemeData _darkPro(Brightness b) {
    final isDark = b == Brightness.dark;
    final base = ColorScheme.fromSeed(
      seedColor: _darkProSeed,
      brightness: b,
    ).copyWith(
      secondary: _darkProSecondary,
      tertiary: _darkProTertiary,
      surface: isDark ? const Color(0xFF11151C) : null,
      background: isDark ? const Color(0xFF0B0E14) : null,
    );
    return _material3(base, isDark);
  }

  // Storefront Pop — friendly consumer shop.
  static ThemeData _storefront(Brightness b) {
    final base = ColorScheme.fromSeed(
      seedColor: _storeSeed,
      brightness: b,
    ).copyWith(
      secondary: _storeSecondary,
      tertiary: _storeTertiary,
    );
    return _material3(base, b == Brightness.dark);
  }

  static ThemeData _material3(ColorScheme scheme, bool isDark) {
    final radius = 16.0;
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      visualDensity: VisualDensity.standard,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
      ),
      cardTheme: CardTheme(
        elevation: isDark ? 0 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }
}