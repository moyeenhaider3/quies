import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Palette
  static const Color deepVoid = Color(0xFF0F172A);
  static const Color nebula = Color(0xFF312E81);
  static const Color starlight = Color(0xFFF8FAFC);
  static const Color calmTeal = Color(0xFF2DD4BF);
  static const Color softGlass = Color(0x33FFFFFF); // 20% White

  // Light palette
  static const Color lightBg = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightOnSurface = Color(0xFF1E293B);

  /// Font families available for quotes
  static const List<String> availableFonts = [
    'Playfair Display',
    'Merriweather',
    'Lora',
    'EB Garamond',
    'Crimson Text',
  ];

  static TextStyle quoteTextStyle({
    String fontFamily = 'Playfair Display',
    double fontSize = 32,
    Color color = Colors.white,
  }) {
    switch (fontFamily) {
      case 'Merriweather':
        return GoogleFonts.merriweather(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: color,
          height: 1.3,
          letterSpacing: 0.5,
        );
      case 'Lora':
        return GoogleFonts.lora(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: color,
          height: 1.3,
          letterSpacing: 0.5,
        );
      case 'EB Garamond':
        return GoogleFonts.ebGaramond(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: color,
          height: 1.3,
          letterSpacing: 0.5,
        );
      case 'Crimson Text':
        return GoogleFonts.crimsonText(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: color,
          height: 1.3,
          letterSpacing: 0.5,
        );
      default:
        return GoogleFonts.playfairDisplay(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: color,
          height: 1.3,
          letterSpacing: 0.5,
        );
    }
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: deepVoid,
      colorScheme: const ColorScheme.dark(
        primary: calmTeal,
        secondary: nebula,
        surface: deepVoid,
        onSurface: starlight,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.playfairDisplay(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: starlight,
          letterSpacing: 1.2,
        ),
        displayMedium: GoogleFonts.playfairDisplay(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: starlight,
        ),
        bodyLarge: GoogleFonts.outfit(
          fontSize: 18,
          color: starlight.withValues(alpha: 0.9),
          letterSpacing: 0.5,
        ),
        bodyMedium: GoogleFonts.outfit(
          fontSize: 16,
          color: starlight.withValues(alpha: 0.8),
        ),
        labelLarge: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: deepVoid,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: softGlass,
        labelStyle: GoogleFonts.outfit(color: starlight),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide.none,
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBg,
      colorScheme: const ColorScheme.light(
        primary: calmTeal,
        secondary: nebula,
        surface: lightSurface,
        onSurface: lightOnSurface,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.playfairDisplay(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: lightOnSurface,
          letterSpacing: 1.2,
        ),
        displayMedium: GoogleFonts.playfairDisplay(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: lightOnSurface,
        ),
        bodyLarge: GoogleFonts.outfit(
          fontSize: 18,
          color: lightOnSurface.withValues(alpha: 0.9),
          letterSpacing: 0.5,
        ),
        bodyMedium: GoogleFonts.outfit(
          fontSize: 16,
          color: lightOnSurface.withValues(alpha: 0.8),
        ),
        labelLarge: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: lightOnSurface,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0x1A000000),
        labelStyle: GoogleFonts.outfit(color: lightOnSurface),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide.none,
      ),
    );
  }
}
