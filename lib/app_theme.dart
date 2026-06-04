import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // ── Light Theme Colors ─────────────────────────────────────────
  static const Color lightBackground = Color(0xFFEBEBF0); // Slightly darker grey for contrast
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightPrimary = Color(0xFF1D1D1F);
  static const Color lightSecondary = Color(0xFF6E6E73);
  static const Color lightTertiary = Color(0xFF86868B);
  static const Color lightSeparator = Color(0xFFD1D1D6);

  // ── Dark Theme Colors ──────────────────────────────────────────
  static const Color darkBackground = Color(0xFF000000); // Pure black
  static const Color darkSurface = Color(0xFF111111); // Neutral very dark grey
  static const Color darkPrimary = Color(0xFFFFFFFF); // Pure white
  static const Color darkSecondary = Color(0xFFAAAAAA);
  static const Color darkTertiary = Color(0xFF666666);
  static const Color darkSeparator = Color(0xFF222222);

  // ── Shared Colors & Gradients ──────────────────────────────────
  static const Color success = Color(0xFF34C759);
  static const Color warning = Color(0xFFFF9F0A);
  static const Color error = Color(0xFFFF453A);


  // Premium Gradients
  static const LinearGradient premiumGradientDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF222222), Color(0xFF111111)],
  );

  static const LinearGradient premiumGradientLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF111111), Color(0xFF000000)],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF30D158), Color(0xFF248A3D)], // Vibrant Greens
  );

  // ── Border Radius ───────────────────────────────────────────
  static const double radiusS = 12.0;
  static const double radiusM = 16.0;
  static const double radiusL = 24.0;
  static const double radiusXL = 32.0;

  // ── Shadows ─────────────────────────────────────────────────
  static List<BoxShadow> lightShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> darkShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.4),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  // ── ThemeData ───────────────────────────────────────────────
  static ThemeData get lightTheme {
    final textTheme = GoogleFonts.interTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBackground,
      colorScheme: const ColorScheme.light(
        primary: lightPrimary,
        onPrimary: Colors.white,
        secondary: lightSecondary,
        surface: lightSurface,
        onSurface: lightPrimary,
        error: error,
        outline: lightSeparator,
      ),
      textTheme: _buildTextTheme(textTheme, lightPrimary, lightSecondary, lightTertiary),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: lightBackground.withValues(alpha: 0.8),
        foregroundColor: lightPrimary,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: lightPrimary,
          letterSpacing: -0.5,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        selectedItemColor: lightPrimary,
        unselectedItemColor: lightTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
      ),
      elevatedButtonTheme: _buildElevatedButtonTheme(lightPrimary, Colors.white),
      outlinedButtonTheme: _buildOutlinedButtonTheme(lightPrimary, lightSeparator),
      inputDecorationTheme: _buildInputDecorationTheme(lightSurface, lightSeparator, lightPrimary, lightTertiary),
      cardTheme: CardThemeData(
        elevation: 0,
        color: lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusL),
          side: const BorderSide(color: lightSeparator, width: 0.5),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      dividerTheme: const DividerThemeData(color: lightSeparator, thickness: 0.5, space: 0),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusXL)),
        backgroundColor: lightSurface,
      ),
    );
  }

  static ThemeData get darkTheme {
    final textTheme = GoogleFonts.interTextTheme(ThemeData.dark().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: darkPrimary,
        onPrimary: Colors.black,
        secondary: darkSecondary,
        surface: darkSurface,
        onSurface: darkPrimary,
        error: error,
        outline: darkSeparator,
      ),
      textTheme: _buildTextTheme(textTheme, darkPrimary, darkSecondary, darkTertiary),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: darkBackground.withValues(alpha: 0.8),
        foregroundColor: darkPrimary,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: darkPrimary,
          letterSpacing: -0.5,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: darkSurface.withValues(alpha: 0.9),
        selectedItemColor: darkPrimary,
        unselectedItemColor: darkTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
      ),
      elevatedButtonTheme: _buildElevatedButtonTheme(darkPrimary, Colors.black),
      outlinedButtonTheme: _buildOutlinedButtonTheme(darkPrimary, darkSeparator),
      inputDecorationTheme: _buildInputDecorationTheme(darkSurface, darkSeparator, darkPrimary, darkTertiary),
      cardTheme: CardThemeData(
        elevation: 0,
        color: darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusL),
          side: const BorderSide(color: darkSeparator, width: 0.5),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      dividerTheme: const DividerThemeData(color: darkSeparator, thickness: 0.5, space: 0),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusXL)),
        backgroundColor: darkSurface,
      ),
    );
  }

  static TextTheme _buildTextTheme(TextTheme base, Color primary, Color secondary, Color tertiary) {
    return base.copyWith(
      headlineLarge: base.headlineLarge?.copyWith(fontWeight: FontWeight.w800, color: primary, fontSize: 32, letterSpacing: -1.0),
      headlineMedium: base.headlineMedium?.copyWith(fontWeight: FontWeight.w700, color: primary, fontSize: 24, letterSpacing: -0.5),
      headlineSmall: base.headlineSmall?.copyWith(fontWeight: FontWeight.w700, color: primary, fontSize: 20, letterSpacing: -0.3),
      titleLarge: base.titleLarge?.copyWith(fontWeight: FontWeight.w600, color: primary, fontSize: 18, letterSpacing: -0.2),
      titleMedium: base.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: primary, fontSize: 16),
      bodyLarge: base.bodyLarge?.copyWith(color: primary, fontSize: 16, height: 1.5),
      bodyMedium: base.bodyMedium?.copyWith(color: secondary, fontSize: 14, height: 1.4),
      bodySmall: base.bodySmall?.copyWith(color: tertiary, fontSize: 13),
      labelLarge: base.labelLarge?.copyWith(fontWeight: FontWeight.w600, fontSize: 15),
    );
  }

  static ElevatedButtonThemeData _buildElevatedButtonTheme(Color bg, Color fg) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: fg,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusM)),
        textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  static OutlinedButtonThemeData _buildOutlinedButtonTheme(Color fg, Color border) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: fg,
        side: BorderSide(color: border),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusM)),
      ),
    );
  }

  static InputDecorationTheme _buildInputDecorationTheme(Color fill, Color border, Color focus, Color hint) {
    return InputDecorationTheme(
      filled: true,
      fillColor: fill,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(radiusM), borderSide: BorderSide(color: border, width: 0.5)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(radiusM), borderSide: BorderSide(color: border, width: 0.5)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(radiusM), borderSide: BorderSide(color: focus, width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      hintStyle: GoogleFonts.inter(color: hint, fontSize: 15),
    );
  }
}
