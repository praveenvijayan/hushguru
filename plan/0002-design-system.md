---
title: "Implement HushGuru design system tokens and base widgets"
priority: high
blocked_by:
  - 0001-firebase-setup
---

Create the colour palette, typography scale, and shared widgets (HgButton,
HgInput, GlassCard, HgWordmark, AmbientBackground, ParticleWave) that all
screens depend on.

## Acceptance criteria
- [ ] `lib/theme/colors.dart` exports `HgColors` with all palette tokens
- [ ] `lib/theme/text_styles.dart` exports `HgText` using Jost font
- [ ] `lib/widgets/hg_button.dart` renders primary / outline / white variants
- [ ] `lib/widgets/glass_card.dart` renders frosted glass card with blur
- [ ] `lib/widgets/particle_wave.dart` animates stars and wave modes
- [ ] `lib/widgets/ambient_background.dart` stacks gradient + orbs + particles
- [ ] `flutter analyze` passes with zero issues
