import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

enum HgButtonVariant { primary, outline, white }

class HgButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final HgButtonVariant variant;
  final bool fullWidth;

  const HgButton({
    super.key,
    required this.label,
    this.onTap,
    this.variant = HgButtonVariant.primary,
    this.fullWidth = true,
  });

  @override
  State<HgButton> createState() => _HgButtonState();
}

class _HgButtonState extends State<HgButton> {
  bool _pressed = false;

  BoxDecoration _decoration() {
    switch (widget.variant) {
      case HgButtonVariant.primary:
        return BoxDecoration(
          color: _pressed ? HgColors.coralPress : HgColors.coral,
          borderRadius: BorderRadius.circular(100),
          boxShadow: _pressed
              ? []
              : [
                  BoxShadow(
                    color: HgColors.shadowCta,
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
        );
      case HgButtonVariant.outline:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: _pressed ? HgColors.coralPress : HgColors.coral,
            width: 1.5,
          ),
        );
      case HgButtonVariant.white:
        return BoxDecoration(
          color: _pressed
              ? Colors.white.withValues(alpha: 0.85)
              : Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(100),
          boxShadow: _pressed
              ? []
              : [
                  BoxShadow(
                    color: HgColors.shadowCard,
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        );
    }
  }

  Color _labelColor() {
    switch (widget.variant) {
      case HgButtonVariant.primary:
        return HgColors.cream;
      case HgButtonVariant.outline:
        return _pressed ? HgColors.coralPress : HgColors.coral;
      case HgButtonVariant.white:
        return HgColors.navy;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        width: widget.fullWidth ? double.infinity : null,
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 32),
        decoration: _decoration(),
        alignment: Alignment.center,
        child: Text(widget.label, style: HgText.button(color: _labelColor())),
      ),
    );
  }
}
