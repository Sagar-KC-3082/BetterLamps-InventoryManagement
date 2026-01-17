import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color brandBlue = Color(0xFF3B82F6);
  static const Color primaryAccent = Color(0xFF1A1A1A);

  // Light Theme Colors
  static const Color lightBackground = Color(0xFFF9FAFB); // Slightly cooler grey
  static const Color lightSurface = Colors.white;
  static const Color lightCardBg = Colors.white;
  static const Color lightTextPrimary = Color(0xFF111827); // Cool grey 900
  static const Color lightTextSecondary = Color(0xFF6B7280); // Cool grey 500
  static const Color lightDivider = Color(0xFFF3F4F6); // Cool grey 100
  static const Color lightBorder = Color(0xFFE5E7EB); // Cool grey 200

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF0F172A); // Slate 900
  static const Color darkSurface = Color(0xFF1E293B); // Slate 800
  static const Color darkCardBg = Color(0xFF1E293B); // Slate 800
  static const Color darkTextPrimary = Color(0xFFF9FAFB); // Gray 50
  static const Color darkTextSecondary = Color(0xFF9CA3AF); // Gray 400
  static const Color darkDivider = Color(0xFF334155); // Slate 700
  static const Color darkBorder = Color(0xFF334155); // Slate 700

  // Text theme mix
  static TextTheme get _textTheme {
    final base = GoogleFonts.interTextTheme();
    final headings = GoogleFonts.plusJakartaSansTextTheme();
    
    return base.copyWith(
      displayLarge: headings.displayLarge?.copyWith(fontWeight: FontWeight.w600),
      displayMedium: headings.displayMedium?.copyWith(fontWeight: FontWeight.w600),
      displaySmall: headings.displaySmall?.copyWith(fontWeight: FontWeight.w600),
      headlineLarge: headings.headlineLarge?.copyWith(fontWeight: FontWeight.w600),
      headlineMedium: headings.headlineMedium?.copyWith(fontWeight: FontWeight.w600),
      headlineSmall: headings.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
      titleLarge: headings.titleLarge?.copyWith(fontWeight: FontWeight.w600),
    );
  }

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    fontFamily: GoogleFonts.inter().fontFamily,
    textTheme: _textTheme.apply(
      bodyColor: lightTextPrimary,
      displayColor: lightTextPrimary,
    ),
    primaryColor: brandBlue,
    scaffoldBackgroundColor: lightBackground,
    colorScheme: const ColorScheme.light(
      primary: brandBlue,
      secondary: primaryAccent,
      surface: lightSurface,
      onSurface: lightTextPrimary,
      onPrimary: Colors.white,
      outline: lightBorder,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: lightCardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: lightBorder, width: 1),
      ),
    ),
    dividerColor: lightDivider,
    dividerTheme: const DividerThemeData(
      color: lightDivider,
      thickness: 1,
      space: 1,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      hoverColor: const Color(0xFFF3F4F6),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: lightBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: lightBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: brandBlue, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: TextStyle(color: lightTextSecondary.withOpacity(0.6), fontSize: 14),
      labelStyle: const TextStyle(color: lightTextSecondary, fontSize: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: brandBlue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          letterSpacing: 0.3,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: lightTextPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        side: BorderSide(color: lightBorder),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          letterSpacing: 0.3,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: lightTextSecondary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: lightCardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: lightBorder),
      ),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.06),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: lightCardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.1),
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: lightBorder),
        ),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    fontFamily: GoogleFonts.inter().fontFamily,
    textTheme: _textTheme.apply(
      bodyColor: darkTextPrimary,
      displayColor: darkTextPrimary,
    ),
    primaryColor: brandBlue,
    scaffoldBackgroundColor: darkBackground,
    colorScheme: const ColorScheme.dark(
      primary: brandBlue,
      secondary: Colors.white,
      surface: darkSurface,
      onSurface: darkTextPrimary,
      onPrimary: Colors.white,
      outline: darkBorder,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: darkCardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: darkBorder, width: 1),
      ),
    ),
    dividerColor: darkDivider,
    dividerTheme: const DividerThemeData(
      color: darkDivider,
      thickness: 1,
      space: 1,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkSurface,
      hoverColor: const Color(0xFF273548), // Slightly lighter state
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: darkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: brandBlue, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFF87171), width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: TextStyle(color: darkTextSecondary.withOpacity(0.6), fontSize: 14),
      labelStyle: const TextStyle(color: darkTextSecondary, fontSize: 14),
      floatingLabelStyle: const TextStyle(color: brandBlue),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: brandBlue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          letterSpacing: 0.3,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: darkTextPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        side: BorderSide(color: darkBorder),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          letterSpacing: 0.3,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: darkTextSecondary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: darkCardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: darkBorder),
      ),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.5),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: darkCardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.5),
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkBorder),
        ),
      ),
    ),
  );
}

extension AppThemeExtension on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  Color get backgroundColor => isDarkMode ? AppTheme.darkBackground : AppTheme.lightBackground;
  Color get surfaceColor => isDarkMode ? AppTheme.darkSurface : AppTheme.lightSurface;
  Color get cardColor => isDarkMode ? AppTheme.darkCardBg : AppTheme.lightCardBg;
  Color get textPrimary => isDarkMode ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;
  Color get textSecondary => isDarkMode ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary;
  Color get dividerColor => isDarkMode ? AppTheme.darkDivider : AppTheme.lightDivider;
  Color get borderColor => isDarkMode ? AppTheme.darkBorder : AppTheme.lightBorder;
  Color get primaryColor => AppTheme.brandBlue; // Using brand blue as primary for both

  // Minimal shadows
  List<BoxShadow> get subtleShadow => isDarkMode
      ? []
      : [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ];

  // Status colors - keeping them nice and vibrant but accessible
  Color get successColor => const Color(0xFF22C55E); // Green 500
  Color get successBgColor => isDarkMode ? const Color(0xFF052E16) : const Color(0xFFDCFCE7); // Green 950 / 100
  Color get warningColor => const Color(0xFFEAB308); // Yellow 500
  Color get warningBgColor => isDarkMode ? const Color(0xFF422006) : const Color(0xFFFEF9C3); // Yellow 950 / 100
  Color get errorColor => const Color(0xFFEF4444); // Red 500
  Color get errorBgColor => isDarkMode ? const Color(0xFF450A0A) : const Color(0xFFFEE2E2); // Red 950 / 100
}
