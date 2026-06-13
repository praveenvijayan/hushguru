import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import 'particle_wave.dart';

class AmbientBackground extends StatelessWidget {
  final Widget child;
  final ParticleMode mode;

  const AmbientBackground({
    super.key,
    required this.child,
    this.mode = ParticleMode.stars,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Base sunrise gradient
        DecoratedBox(
          decoration: const BoxDecoration(gradient: HgColors.sunriseGradient),
        ),

        // Blur orbs
        _BlurOrb(
          left: -80,
          top: -60,
          size: 320,
          color: const Color(0xFFF5D6A0).withValues(alpha: 0.45),
        ),
        _BlurOrb(
          right: -60,
          top: 180,
          size: 260,
          color: const Color(0xFFD4778A).withValues(alpha: 0.35),
        ),
        _BlurOrb(
          left: 40,
          bottom: -80,
          size: 300,
          color: const Color(0xFF8B6B9E).withValues(alpha: 0.28),
        ),

        // Haze overlay
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withValues(alpha: 0.08),
                Colors.transparent,
                const Color(0xFF203C6B).withValues(alpha: 0.12),
              ],
            ),
          ),
        ),

        // Warm vignette
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.2,
              colors: [
                Colors.transparent,
                const Color(0xFF925428).withValues(alpha: 0.18),
              ],
            ),
          ),
        ),

        // Particles
        ParticleWave(mode: mode),

        // Content
        child,
      ],
    );
  }
}

class _BlurOrb extends StatelessWidget {
  final double? left;
  final double? right;
  final double? top;
  final double? bottom;
  final double size;
  final Color color;

  const _BlurOrb({
    this.left,
    this.right,
    this.top,
    this.bottom,
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
      ),
    );
  }
}
