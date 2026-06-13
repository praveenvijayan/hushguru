import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

abstract final class HgText {
  static TextStyle _jost({
    double size = 16,
    FontWeight weight = FontWeight.w300,
    Color color = HgColors.navy,
    double? height,
    double? letterSpacing,
  }) => GoogleFonts.jost(
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
    letterSpacing: letterSpacing,
  );

  // Display / wordmark
  static TextStyle wordmark({double size = 32, Color color = HgColors.navy}) =>
      _jost(
        size: size,
        weight: FontWeight.w300,
        color: color,
        letterSpacing: 3.52,
      );

  // Eyebrow caps
  static TextStyle eyebrow({Color color = HgColors.coral}) => _jost(
    size: 11,
    weight: FontWeight.w500,
    color: color,
    letterSpacing: 5.2,
  );

  // Headings
  static TextStyle h1({Color color = HgColors.navy}) =>
      _jost(size: 28, weight: FontWeight.w300, color: color, height: 1.25);

  static TextStyle h2({Color color = HgColors.navy}) =>
      _jost(size: 22, weight: FontWeight.w300, color: color, height: 1.3);

  static TextStyle h3({Color color = HgColors.navy}) =>
      _jost(size: 18, weight: FontWeight.w400, color: color, height: 1.35);

  // Body
  static TextStyle body({Color color = HgColors.navy}) =>
      _jost(size: 15, weight: FontWeight.w300, color: color, height: 1.6);

  static TextStyle bodySmall({Color color = HgColors.navy}) =>
      _jost(size: 13, weight: FontWeight.w300, color: color, height: 1.5);

  // Button
  static TextStyle button({Color color = HgColors.cream}) => _jost(
    size: 15,
    weight: FontWeight.w400,
    color: color,
    letterSpacing: 1.02,
  );

  // Caption
  static TextStyle caption({Color color = HgColors.navy}) =>
      _jost(size: 11, weight: FontWeight.w300, color: color, height: 1.4);

  // Status (dashboard live text)
  static TextStyle status({Color color = HgColors.cream}) =>
      _jost(size: 20, weight: FontWeight.w300, color: color, height: 1.5);
}
