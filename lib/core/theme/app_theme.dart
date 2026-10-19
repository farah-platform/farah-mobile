import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData appTheme = ThemeData(
  useMaterial3: true,
  fontFamily: GoogleFonts.tajawal().fontFamily,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF7B2146),
    primary: const Color(0xFF7B2146),
    secondary: const Color.fromARGB(255, 146, 115, 14),
    surface: Colors.white,
  ),

  scaffoldBackgroundColor: Colors.white,

  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: Color(0xFF7B2146),
    elevation: 0,
    centerTitle: true,
  ),

  textTheme: GoogleFonts.tajawalTextTheme().copyWith(
    displayLarge: GoogleFonts.tajawal(fontSize: 16),
    displayMedium: GoogleFonts.tajawal(fontSize: 16),
    displaySmall: GoogleFonts.tajawal(fontSize: 14),

    headlineLarge: GoogleFonts.tajawal(fontSize: 20),
    headlineMedium: GoogleFonts.tajawal(fontSize: 18),
    headlineSmall: GoogleFonts.tajawal(fontSize: 14),

    titleLarge: GoogleFonts.tajawal(fontSize: 16),
    titleMedium: GoogleFonts.tajawal(fontSize: 16),
    titleSmall: GoogleFonts.tajawal(fontSize: 10),

    bodyLarge: GoogleFonts.tajawal(fontSize: 15),
    bodyMedium: GoogleFonts.tajawal(fontSize: 10),
    bodySmall: GoogleFonts.tajawal(fontSize: 12),

    labelLarge: GoogleFonts.tajawal(fontSize: 14),
    labelMedium: GoogleFonts.tajawal(fontSize: 12),
    labelSmall: GoogleFonts.tajawal(fontSize: 11),
  ),

  inputDecorationTheme: InputDecorationTheme(
    isDense: true,
    constraints: const BoxConstraints(minHeight: 48, maxHeight: 48),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: const BorderSide(color: Color(0xFF7B2146), width: 1.5),
    ),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF7B2146),
      foregroundColor: Colors.white,
      minimumSize: const Size(double.infinity, 55),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 0,
    ),
  ),

  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: const Color(0xFF7B2146),
      minimumSize: const Size(double.infinity, 55),
      side: const BorderSide(color: Color(0xFF7B2146), width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    ),
  ),
);
