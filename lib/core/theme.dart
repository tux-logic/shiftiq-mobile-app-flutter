import 'package:flutter/material.dart';

/// Semantic Design Tokens for ShiftIQ
/// Based on ShiftIQ Style Guide (Report Chapter 3 - Table 14 & 19)
class ShiftIQColors {
  ShiftIQColors._();

  static const Color primaryBlue = Color(0xFF1E3A8A);
  static const Color accentSkyBlue = Color(0xFF60A5FA);
  static const Color secondaryTeal = Color(0xFF0FB5BA);
  static const Color preventiveGreen = Color(0xFF3DBE6C);
  static const Color severityCrimson = Color(0xFFDC2626);
  static const Color severityOrange = Color(0xFFF97316);
  static const Color severityAmber = Color(0xFFFBBF24);
  static const Color graphiteText = Color(0xFF1E293B);
  static const Color warmNeutral = Color(0xFFF8FAFC);
  static const Color borderSlate = Color(0xFFCBD5E1);
  static const Color surfaceVariant = Color(0xFFF1F5F9);
}

/// Material Design 3 Theme configuration following easyrecipe architecture
class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: ShiftIQColors.primaryBlue,
      onPrimary: Colors.white,
      primaryContainer: ShiftIQColors.accentSkyBlue,
      onPrimaryContainer: ShiftIQColors.primaryBlue,
      secondary: ShiftIQColors.secondaryTeal,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFBCECE7),
      onSecondaryContainer: Color(0xFF003735),
      tertiary: ShiftIQColors.preventiveGreen,
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFC7F5D7),
      onTertiaryContainer: Color(0xFF0D3E1E),
      error: ShiftIQColors.severityCrimson,
      onError: Colors.white,
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF93000A),
      surface: ShiftIQColors.warmNeutral,
      onSurface: ShiftIQColors.graphiteText,
      onSurfaceVariant: Color(0xFF475569),
      outline: ShiftIQColors.borderSlate,
      outlineVariant: Color(0xFFE2E8F0),
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: ShiftIQColors.graphiteText,
      onInverseSurface: Colors.white,
      inversePrimary: ShiftIQColors.accentSkyBlue,
    );
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: ShiftIQColors.accentSkyBlue,
      onPrimary: ShiftIQColors.primaryBlue,
      primaryContainer: ShiftIQColors.primaryBlue,
      onPrimaryContainer: Colors.white,
      secondary: ShiftIQColors.secondaryTeal,
      onSecondary: Color(0xFF003735),
      secondaryContainer: Color(0xFF004F4C),
      onSecondaryContainer: Color(0xFFBCECE7),
      tertiary: ShiftIQColors.preventiveGreen,
      onTertiary: Color(0xFF0D3E1E),
      tertiaryContainer: Color(0xFF1E5B33),
      onTertiaryContainer: Color(0xFFC7F5D7),
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
      errorContainer: ShiftIQColors.severityCrimson,
      onErrorContainer: Color(0xFFFFDAD6),
      surface: Color(0xFF0F172A),
      onSurface: Color(0xFFF1F5F9),
      onSurfaceVariant: Color(0xFF94A3B8),
      outline: Color(0xFF475569),
      outlineVariant: Color(0xFF334155),
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: ShiftIQColors.warmNeutral,
      onInverseSurface: ShiftIQColors.graphiteText,
      inversePrimary: ShiftIQColors.primaryBlue,
    );
  }

  ThemeData light() {
    return _buildTheme(lightScheme());
  }

  ThemeData dark() {
    return _buildTheme(darkScheme());
  }

  ThemeData _buildTheme(ColorScheme colorScheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme.apply(
        bodyColor: colorScheme.onSurface,
        displayColor: colorScheme.onSurface,
      ),
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: colorScheme.onPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: colorScheme.outline, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primaryContainer.withAlpha(80),
        elevation: 3,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return textTheme.labelSmall?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            );
          }
          return textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: colorScheme.primary);
          }
          return IconThemeData(color: colorScheme.onSurfaceVariant);
        }),
      ),
    );
  }
}
