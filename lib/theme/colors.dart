import 'package:flutter/material.dart';

abstract final class HgColors {
  // Brand palette
  static const Color navy = Color(0xFF203C6B);
  static const Color coral = Color(0xFFD8685B);
  static const Color coralPress = Color(0xFFC95A4D);
  static const Color blush = Color(0xFFF7E1DE);
  static const Color shell = Color(0xFFF6F0F0);
  static const Color cream = Color(0xFFFBEFE6);

  // Sunrise gradient stops
  static const Color sunrise1 = Color(0xFFECC99A);
  static const Color sunrise2 = Color(0xFFE8A07A);
  static const Color sunrise3 = Color(0xFFD4778A);
  static const Color sunrise4 = Color(0xFF8B6B9E);

  // Night gradient stops
  static const Color night1 = Color(0xFF1A2B4A);
  static const Color night2 = Color(0xFF203C6B);
  static const Color night3 = Color(0xFF2D1B4E);

  // Ink (navy) alpha ramp
  static Color get ink100 => navy;
  static Color get ink80 => navy.withValues(alpha: 0.80);
  static Color get ink60 => navy.withValues(alpha: 0.60);
  static Color get ink40 => navy.withValues(alpha: 0.40);
  static Color get ink20 => navy.withValues(alpha: 0.20);
  static Color get ink12 => navy.withValues(alpha: 0.12);

  // Blush alpha ramp
  static Color get blush80 => blush.withValues(alpha: 0.80);
  static Color get blush60 => blush.withValues(alpha: 0.60);
  static Color get blush40 => blush.withValues(alpha: 0.40);
  static Color get blush20 => blush.withValues(alpha: 0.20);

  // Shadows
  static const Color shadowCard = Color(0x29925428);
  static const Color shadowCta = Color(0x59D8685B);

  // Gradients
  static const LinearGradient sunriseGradient = LinearGradient(
    begin: Alignment(-0.57, -0.82),
    end: Alignment(0.57, 0.82),
    colors: [sunrise1, sunrise2, sunrise3, sunrise4],
    stops: [0.0, 0.35, 0.65, 1.0],
  );

  static const LinearGradient nightGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [night1, night2, night3],
  );
}
