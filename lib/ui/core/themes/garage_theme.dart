import 'package:flutter/material.dart';

// Tala Garage Design System Theme
final ThemeData garageTheme = ThemeData(
  // Colors
  primaryColor: const Color(0xFF2C2C2E),
  primaryColorLight: const Color(0xFF48484A),
  scaffoldBackgroundColor: const Color(0xFFF5F3EE),
  cardColor: const Color(0xFFFAFAF8),
  colorScheme: ColorScheme(
    brightness: Brightness.light,
    primary: const Color(0xFF2C2C2E),
    onPrimary: const Color(0xFFF5F3EE),
    secondary: const Color(0xFFB8860B),
    onSecondary: const Color(0xFF2C2C2E),
    background: const Color(0xFFF5F3EE),
    onBackground: const Color(0xFF2C2C2E),
    surface: const Color(0xFFFAFAF8),
    onSurface: const Color(0xFF2C2C2E),
    error: const Color(0xFFC41E3A),
    onError: const Color(0xFFF5F3EE),
  ),

  // Typography
  fontFamily: 'Inter',
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      fontFamily: 'DINCondensed',
      fontSize: 48,
      fontWeight: FontWeight.bold,
      height: 1.17,
      color: Color(0xFF2C2C2E),
    ),
    displayMedium: TextStyle(
      fontFamily: 'DINCondensed',
      fontSize: 36,
      fontWeight: FontWeight.bold,
      height: 1.22,
      color: Color(0xFF2C2C2E),
    ),
    displaySmall: TextStyle(
      fontFamily: 'DINCondensed',
      fontSize: 28,
      fontWeight: FontWeight.bold,
      height: 1.29,
      color: Color(0xFF2C2C2E),
    ),
    headlineLarge: TextStyle(
      fontFamily: 'DINCondensed',
      fontSize: 24,
      fontWeight: FontWeight.bold,
      height: 1.33,
      color: Color(0xFF2C2C2E),
    ),
    headlineMedium: TextStyle(
      fontFamily: 'DINCondensed',
      fontSize: 20,
      fontWeight: FontWeight.w600,
      height: 1.4,
      color: Color(0xFF2C2C2E),
    ),
    headlineSmall: TextStyle(
      fontFamily: 'Inter',
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.5,
      color: Color(0xFF2C2C2E),
    ),
    bodyLarge: TextStyle(
      fontFamily: 'Inter',
      fontSize: 16,
      fontWeight: FontWeight.normal,
      height: 1.5,
      color: Color(0xFF2C2C2E),
    ),
    bodyMedium: TextStyle(
      fontFamily: 'Inter',
      fontSize: 14,
      fontWeight: FontWeight.normal,
      height: 1.43,
      color: Color(0xFF3A3A3C),
    ),
    bodySmall: TextStyle(
      fontFamily: 'Inter',
      fontSize: 12,
      fontWeight: FontWeight.normal,
      height: 1.33,
      color: Color(0xFF48484A),
    ),
    labelLarge: TextStyle(
      fontFamily: 'Inter',
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      height: 1.33,
      color: Color(0xFF2C2C2E),
    ),
    labelSmall: TextStyle(
      fontFamily: 'Inter',
      fontSize: 11,
      fontWeight: FontWeight.normal,
      height: 1.27,
      color: Color(0xFF2C2C2E),
    ),
  ),

  // Button Theme
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.disabled)) {
          return const Color(0xFF48484A).withValues(alpha: 0.4);
        }
        if (states.contains(WidgetState.pressed)) {
          return const Color(0xFF9A7209);
        }
        if (states.contains(WidgetState.hovered)) {
          return const Color(0xFFD4A017);
        }
        return const Color(0xFFB8860B);
      }),
      foregroundColor: WidgetStateProperty.all(const Color(0xFF2C2C2E)),
      textStyle: WidgetStateProperty.all(
        const TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: Color(0xFF2C2C2E),
        ),
      ),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
      ),
      padding: WidgetStateProperty.all(
        const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
  ),

  // Input Decoration
  inputDecorationTheme: const InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(2)),
      borderSide: BorderSide(color: Color(0xFFC8C6C1)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(2)),
      borderSide: BorderSide(color: Color(0xFF1B4965), width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(2)),
      borderSide: BorderSide(color: Color(0xFFC41E3A)),
    ),
    filled: true,
    fillColor: Colors.white,
    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
  ),

  // Card Theme
  cardTheme: const CardThemeData(
    color: Color(0xFFFAFAF8),
    elevation: 1,
    margin: EdgeInsets.all(0),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(2)),
      side: BorderSide(color: Color(0xFFE0DED9)),
    ),
  ),

  // Checkbox Theme
  checkboxTheme: CheckboxThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
    side: const BorderSide(color: Color(0xFF3A3A3C), width: 2),
    fillColor: WidgetStateProperty.resolveWith<Color>((states) {
      if (states.contains(WidgetState.selected)) {
        return const Color(0xFFB8860B);
      }
      return Colors.white;
    }),
    checkColor: WidgetStateProperty.all(const Color(0xFF2C2C2E)),
  ),

  // Radio Theme
  radioTheme: RadioThemeData(
    fillColor: WidgetStateProperty.resolveWith<Color>((states) {
      if (states.contains(WidgetState.selected)) {
        return const Color(0xFFB8860B);
      }
      return Colors.white;
    }),
  ),

  // AppBar Theme
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF2C2C2E),
    foregroundColor: Color(0xFFF5F3EE),
    elevation: 0,
    titleTextStyle: TextStyle(
      fontFamily: 'DINCondensed',
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: Color(0xFFF5F3EE),
    ),
    toolbarHeight: 64,
    iconTheme: IconThemeData(color: Color(0xFFF5F3EE)),
  ),

  // Divider Theme
  dividerTheme: const DividerThemeData(color: Color(0xFFE0DED9), thickness: 1),

  // Icon Theme
  iconTheme: const IconThemeData(color: Color(0xFF3A3A3C), size: 20),

  // Other customizations as needed...
);
