import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdultColors {
  // Classical Islamic Palette
  static const Color primaryGreen = Color(0xFF0F5132); // Deep emerald
  static const Color primaryGreenLight = Color(0xFF1E7E4E);
  static const Color goldAccent = Color(0xFFC59B27); // Classical gold
  static const Color goldAccentLight = Color(0xFFE2B743);
  static const Color parchmentBackground = Color(0xFFFAF7F0); // Antique book page
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1A261D);
  static const Color textSecondary = Color(0xFF556B5D);
  static const Color borderLight = Color(0xFFE5DECF);
  static const Color highlightBg = Color(0xFFFFF7E6);
  static const Color completedGreen = Color(0xFF2E7D32);
  static const Color missedRed = Color(0xFFC62828);
  static const Color pendingOrange = Color(0xFFEF6C00);

  // Dark variant
  static const Color darkBackground = Color(0xFF0D1410);
  static const Color darkSurface = Color(0xFF17221C);
  static const Color darkBorder = Color(0xFF2C3D32);
  static const Color darkTextPrimary = Color(0xFFF1F5F2);
  static const Color darkTextSecondary = Color(0xFFA2B5A8);
}

class KidsColors {
  // Vibrant, high-contrast gamified pastels
  static const Color primaryPurple = Color(0xFF7B2CBF);
  static const Color playfulSky = Color(0xFF00B4D8);
  static const Color sunnyOrange = Color(0xFFFF9E00);
  static const Color grassGreen = Color(0xFF38B000);
  static const Color berryPink = Color(0xFFFF5D8F);
  static const Color softBackground = Color(0xFFFDFBF7);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color cardShadow = Color(0x1F7B2CBF);
  static const Color gardenStage1 = Color(0xFF8B5A2B); // Seed / Earth
  static const Color gardenStage2 = Color(0xFF90BE6D); // Sprout
  static const Color gardenStage3 = Color(0xFF43AA8B); // Sapling
  static const Color gardenStage4 = Color(0xFFF9C74F); // Blossoming
  static const Color gardenStage5 = Color(0xFFFFD166); // Golden Fruit
  static const Color starGold = Color(0xFFFFB703);
}

class AppTheme {
  // ADULT CLASSICAL THEME
  static ThemeData adultTheme({bool isDark = false}) {
    final base = isDark ? ThemeData.dark() : ThemeData.light();
    final bgColor = isDark ? AdultColors.darkBackground : AdultColors.parchmentBackground;
    final surfaceColor = isDark ? AdultColors.darkSurface : AdultColors.surfaceCard;
    final textColor = isDark ? AdultColors.darkTextPrimary : AdultColors.textPrimary;
    final secondaryTextColor = isDark ? AdultColors.darkTextSecondary : AdultColors.textSecondary;
    final borderColor = isDark ? AdultColors.darkBorder : AdultColors.borderLight;

    return base.copyWith(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: bgColor,
      primaryColor: AdultColors.primaryGreen,
      colorScheme: ColorScheme(
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: AdultColors.primaryGreen,
        onPrimary: Colors.white,
        secondary: AdultColors.goldAccent,
        onSecondary: Colors.white,
        error: AdultColors.missedRed,
        onError: Colors.white,
        surface: surfaceColor,
        onSurface: textColor,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: textColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.amiri(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
      cardTheme: CardTheme(
        color: surfaceColor,
        elevation: 1.5,
        shadowColor: Colors.black.withOpacity(0.06),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: borderColor, width: 0.8),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.amiri(fontSize: 32, fontWeight: FontWeight.bold, color: textColor),
        displayMedium: GoogleFonts.amiri(fontSize: 26, fontWeight: FontWeight.bold, color: textColor),
        titleLarge: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w700, color: textColor),
        titleMedium: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w600, color: textColor),
        bodyLarge: GoogleFonts.amiri(fontSize: 19, height: 1.9, color: textColor),
        bodyMedium: GoogleFonts.cairo(fontSize: 14, color: secondaryTextColor),
        labelLarge: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AdultColors.primaryGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
      dividerTheme: DividerThemeData(color: borderColor, thickness: 1),
    );
  }

  // KIDS PLAYFUL THEME (KIDS FUN THEME)
  static ThemeData kidsFunTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: KidsColors.softBackground,
      primaryColor: KidsColors.primaryPurple,
      colorScheme: const ColorScheme.light(
        primary: KidsColors.primaryPurple,
        onPrimary: Colors.white,
        secondary: KidsColors.sunnyOrange,
        onSecondary: Colors.white,
        tertiary: KidsColors.playfulSky,
        surface: KidsColors.cardBg,
        onSurface: Color(0xFF2B2D42),
        error: KidsColors.berryPink,
        onError: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: KidsColors.primaryPurple,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: KidsColors.primaryPurple,
        ),
      ),
      cardTheme: CardTheme(
        color: KidsColors.cardBg,
        elevation: 4,
        shadowColor: KidsColors.cardShadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0xFFF0E6FF), width: 2),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.cairo(fontSize: 30, fontWeight: FontWeight.w900, color: KidsColors.primaryPurple),
        displayMedium: GoogleFonts.cairo(fontSize: 24, fontWeight: FontWeight.w800, color: KidsColors.primaryPurple),
        titleLarge: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF2B2D42)),
        titleMedium: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF4A4E69)),
        bodyLarge: GoogleFonts.amiri(fontSize: 22, height: 2.0, color: const Color(0xFF1D2D44)),
        bodyMedium: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF6C757D)),
        labelLarge: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: KidsColors.sunnyOrange,
          foregroundColor: Colors.white,
          elevation: 5,
          shadowColor: KidsColors.sunnyOrange.withOpacity(0.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
    );
  }
}
