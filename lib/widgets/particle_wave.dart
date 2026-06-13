import 'dart:math' as math;
import 'package:flutter/material.dart';

enum ParticleMode { stars, wave }

class ParticleWave extends StatefulWidget {
  final ParticleMode mode;

  const ParticleWave({super.key, this.mode = ParticleMode.stars});

  @override
  State<ParticleWave> createState() => _ParticleWaveState();
}

class _ParticleWaveState extends State<ParticleWave>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(hours: 24),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return CustomPaint(
          painter: _ParticlePainter(
            t: _ctrl.value * 86400.0,
            mode: widget.mode,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

// ─── Data classes ────────────────────────────────────────────────────────────

class _Star {
  final double x;
  final double y;
  final double r;
  final double speed;
  final double phase;
  final Color color;
  final double twinkleSpeed;
  final double twinklePhase;

  const _Star({
    required this.x,
    required this.y,
    required this.r,
    required this.speed,
    required this.phase,
    required this.color,
    required this.twinkleSpeed,
    required this.twinklePhase,
  });
}

class _Band {
  final int n;
  final double amp;
  final double freq;
  final double speed;
  final Color color;
  final double alpha;

  const _Band({
    required this.n,
    required this.amp,
    required this.freq,
    required this.speed,
    required this.color,
    required this.alpha,
  });
}

// ─── Painter ─────────────────────────────────────────────────────────────────

class _ParticlePainter extends CustomPainter {
  final double t;
  final ParticleMode mode;

  _ParticlePainter({required this.t, required this.mode});

  static List<_Star>? _stars;
  static List<_Band>? _bands;

  List<_Star> _buildStars() {
    final rng = math.Random(42);
    return List.generate(110, (i) {
      final baseColors = [
        const Color(0xFFFBEFE6), // cream
        const Color(0xFFF5D6A0), // gold
        const Color(0xFFE8B56A), // amber
      ];
      return _Star(
        x: rng.nextDouble(),
        y: rng.nextDouble(),
        r: 0.8 + rng.nextDouble() * 2.2,
        speed: 0.003 + rng.nextDouble() * 0.012,
        phase: rng.nextDouble() * math.pi * 2,
        color: baseColors[rng.nextInt(baseColors.length)],
        twinkleSpeed: 0.5 + rng.nextDouble() * 1.5,
        twinklePhase: rng.nextDouble() * math.pi * 2,
      );
    });
  }

  List<_Band> _buildBands() {
    return const [
      _Band(
        n: 60,
        amp: 0.08,
        freq: 1.8,
        speed: 0.35,
        color: Color(0xFFF7E1DE), // blush
        alpha: 0.55,
      ),
      _Band(
        n: 45,
        amp: 0.06,
        freq: 2.4,
        speed: 0.52,
        color: Color(0xFFD8685B), // coral
        alpha: 0.38,
      ),
      _Band(
        n: 35,
        amp: 0.05,
        freq: 3.1,
        speed: 0.71,
        color: Color(0xFFECC99A), // sunrise1
        alpha: 0.28,
      ),
    ];
  }

  void _paintStars(Canvas canvas, Size size) {
    _stars ??= _buildStars();
    final paint = Paint()..style = PaintingStyle.fill;

    // Breathing halo behind all stars
    final breathe = 0.65 + 0.35 * math.sin(t * 0.4);
    final haloPaint = Paint()
      ..color = const Color(0xFFF7E1DE).withValues(alpha: 0.06 * breathe)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80);
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.45),
      size.width * 0.55,
      haloPaint,
    );

    for (final star in _stars!) {
      // Stars drift upward and wrap
      final yOffset = (star.y - star.speed * t * 0.01) % 1.0;
      final x = star.x * size.width;
      final y = yOffset * size.height;

      // Twinkle
      final twinkle =
          0.45 + 0.55 * math.sin(t * star.twinkleSpeed + star.twinklePhase);

      paint.color = star.color.withValues(alpha: twinkle * 0.85);
      canvas.drawCircle(Offset(x, y), star.r, paint);

      // Glitter halo on brighter stars
      if (star.r > 2.0 && twinkle > 0.7) {
        final haloPaint2 = Paint()
          ..color = star.color.withValues(alpha: twinkle * 0.25)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
        canvas.drawCircle(Offset(x, y), star.r * 2.5, haloPaint2);
      }
    }
  }

  void _paintWave(Canvas canvas, Size size) {
    _bands ??= _buildBands();

    final breathe = 0.72 + 0.34 * math.sin(t * 0.55) * math.sin(t * 0.21 + 1.3);
    final centerY = size.height * 0.5;
    final paint = Paint()..style = PaintingStyle.fill;

    for (final band in _bands!) {
      paint.color = band.color.withValues(alpha: band.alpha * breathe);

      final path = Path();
      final step = size.width / band.n;

      path.moveTo(0, centerY);

      for (int i = 0; i <= band.n; i++) {
        final x = i * step;
        final norm = i / band.n;
        final y =
            centerY +
            size.height *
                band.amp *
                breathe *
                math.sin(norm * math.pi * 2 * band.freq - t * band.speed);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }

      // Ribbon: go back along a shifted wave
      for (int i = band.n; i >= 0; i--) {
        final x = i * step;
        final norm = i / band.n;
        final ribbonThick = size.height * 0.12 * breathe;
        final y =
            centerY +
            size.height *
                band.amp *
                breathe *
                math.sin(norm * math.pi * 2 * band.freq - t * band.speed) +
            ribbonThick;
        path.lineTo(x, y);
      }

      path.close();

      // Soft blur via MaskFilter on a layer
      canvas.saveLayer(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
      );
      canvas.drawPath(path, paint);
      canvas.restore();
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (mode == ParticleMode.stars) {
      _paintStars(canvas, size);
    } else {
      _paintWave(canvas, size);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.t != t || old.mode != mode;
}
