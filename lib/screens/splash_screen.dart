import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../widgets/ambient_background.dart';
import '../widgets/particle_wave.dart';
import '../widgets/wordmark.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AmbientBackground(
        mode: ParticleMode.stars,
        child: SafeArea(
          child: Stack(
            children: [
              // Centered wordmark
              Center(
                child: HgWordmark(
                  size: 44,
                  color: HgColors.cream,
                  glow: true,
                  showTagline: true,
                ),
              ),

              // Bottom breathe prompt
              Positioned(
                bottom: 48,
                left: 0,
                right: 0,
                child: Text(
                  'breathe in…',
                  textAlign: TextAlign.center,
                  style: HgText.caption(
                    color: HgColors.cream.withValues(alpha: 0.55),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
