import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class HgWordmark extends StatelessWidget {
  final double size;
  final Color color;
  final bool glow;
  final bool showTagline;

  const HgWordmark({
    super.key,
    this.size = 32,
    this.color = HgColors.cream,
    this.glow = false,
    this.showTagline = false,
  });

  @override
  Widget build(BuildContext context) {
    final wordmarkStyle = HgText.wordmark(size: size, color: color);

    final wordmarkWidget = glow
        ? Text(
            'hushguru',
            style: wordmarkStyle.copyWith(
              shadows: [
                Shadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 24,
                ),
                Shadow(
                  color: color.withValues(alpha: 0.2),
                  blurRadius: 48,
                ),
              ],
            ),
          )
        : Text('hushguru', style: wordmarkStyle);

    if (!showTagline) return wordmarkWidget;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        wordmarkWidget,
        const SizedBox(height: 14),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '— ' * 1,
              style: HgText.eyebrow(color: color.withValues(alpha: 0.6)),
            ),
            const SizedBox(width: 8),
            Text(
              'AI YOGA',
              style: HgText.eyebrow(color: color.withValues(alpha: 0.75)),
            ),
            const SizedBox(width: 8),
            Text(
              ' —',
              style: HgText.eyebrow(color: color.withValues(alpha: 0.6)),
            ),
          ],
        ),
      ],
    );
  }
}
