import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Full-screen animated particle background.
/// Draws floating dots connected by faint lines when close together.
class ParticleBackground extends StatefulWidget {
  const ParticleBackground({super.key});

  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();
    final rng = math.Random(42);
    // Reduced particle count from 65 to 30 for massive performance boost on Web
    _particles = List.generate(30, (_) => _Particle.random(rng));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        for (final p in _particles) {
          p.update();
        }
        return CustomPaint(
          painter: _ParticlePainter(_particles),
          size: Size.infinite,
          isComplex: false,
          willChange: true,
        );
      },
    );
  }
}

class _Particle {
  double x, y;
  final double vx, vy, radius, opacity;

  _Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.radius,
    required this.opacity,
  });

  factory _Particle.random(math.Random rng) {
    return _Particle(
      x: rng.nextDouble(),
      y: rng.nextDouble(),
      vx: (rng.nextDouble() - 0.5) * 0.0001,
      vy: (rng.nextDouble() - 0.5) * 0.0001,
      radius: rng.nextDouble() * 1.6 + 0.5,
      opacity: rng.nextDouble() * 0.45 + 0.1,
    );
  }

  void update() {
    x = (x + vx) % 1.0;
    y = (y + vy) % 1.0;
    if (x < 0) x += 1.0;
    if (y < 0) y += 1.0;
  }
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  static const double _connectDist = 140.0;

  const _ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final dotPaint = Paint();
    final linePaint = Paint()..strokeWidth = 0.6;

    for (int i = 0; i < particles.length; i++) {
      final p = particles[i];
      final px = p.x * size.width;
      final py = p.y * size.height;

      // ignore: deprecated_member_use
      dotPaint.color = const Color(0xFF00F5FF).withOpacity(p.opacity);
      canvas.drawCircle(Offset(px, py), p.radius, dotPaint);

      for (int j = i + 1; j < particles.length; j++) {
        final q = particles[j];
        final qx = q.x * size.width;
        final qy = q.y * size.height;
        final dx = px - qx;
        final dy = py - qy;
        final distSq = dx * dx + dy * dy;
        if (distSq < _connectDist * _connectDist) {
          final dist = math.sqrt(distSq);
          final alpha = (1.0 - dist / _connectDist) * 0.13;
          // ignore: deprecated_member_use
          linePaint.color = const Color(0xFF00F5FF).withOpacity(alpha);
          canvas.drawLine(Offset(px, py), Offset(qx, qy), linePaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter _) => true;
}
