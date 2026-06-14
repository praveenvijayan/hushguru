import 'dart:ui';
import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double radius;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.radius = 32,
  });

  @override
  Widget build(BuildContext context) {
    // RepaintBoundary stops markNeedsPaint() propagation from BackdropFilter
    // (alwaysNeedsCompositing=true) reaching unlaid-out ClipRRect ancestors
    // when this card is inserted into a Stack mid-frame, preventing the
    // !semantics.parentDataDirty assertion cycle.
    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: const Color(0xB3FFFBF8),
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.6),
                width: 1,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
