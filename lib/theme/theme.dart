import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

ThemeData buildHushGuruTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: HgColors.coral,
      primary: HgColors.coral,
      secondary: HgColors.navy,
      surface: HgColors.shell,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: HgColors.shell,
    textTheme: GoogleFonts.jostTextTheme().apply(
      bodyColor: HgColors.navy,
      displayColor: HgColors.navy,
    ),
  );

  return base.copyWith(
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: HgColors.ink20),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: HgColors.ink20),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: HgColors.coral, width: 1.5),
      ),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.7),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );
}
