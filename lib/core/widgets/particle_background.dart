// lib/core/widgets/particle_background.dart
import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class Particle {
  late double x;
  late double y;
  late double radius;
  late double speed;
  late double opacity;
  late double angle;
  late Color color;

  Particle(Random random, Size size) {
    reset(random, size);
  }

  void reset(Random random, Size size) {
    x = random.nextDouble() * size.width;
    y = random.nextDouble() * size.height;
    radius = random.nextDouble() * 3 + 1;
    speed = random.nextDouble() * 0.5 + 0.2;
    opacity = random.nextDouble() * 0.5 + 0.1;
    angle = random.nextDouble() * 2 * pi;
    final colors = [
      DarkColors.accent,
      DarkColors.primary,
      DarkColors.primary,
      Colors.white,
    ];
    color = colors[random.nextInt(colors.length)];
  }

  void update(Size size, Random random) {
    y -= speed;
    x += sin(angle) * 0.5;
    if (y < -radius) {
      reset(random, size);
      y = size.height + radius;
    }
  }
}

class ParticleBackground extends StatefulWidget {
  final Widget child;
  final int particleCount;
  // ✅ isDark parameter removed — was unused

  const ParticleBackground({
    super.key,
    required this.child,
    this.particleCount = 50,
  });

  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Particle> _particles;
  final Random _random = Random();
  Size _size = Size.zero;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    _particles = [];
  }

  void _initParticles(Size size) {
    if (_particles.isEmpty || _size != size) {
      _size = size;
      _particles = List.generate(
        widget.particleCount,
        (_) => Particle(_random, size),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        _initParticles(size);
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            for (final p in _particles) {
              p.update(size, _random);
            }
            return CustomPaint(
              painter: _ParticlePainter(_particles),
              child: widget.child,
            );
          },
        );
      },
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  _ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final paint = Paint()
        // ✅ withOpacity → withValues
        ..color = p.color.withValues(alpha: p.opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      canvas.drawCircle(Offset(p.x, p.y), p.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ── Animated wave painter ─────────────────────────────────────────
class WavePainter extends CustomPainter {
  final double animationValue;
  final Color color;

  WavePainter({required this.animationValue, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      // ✅ withOpacity → withValues
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.7);
    for (double i = 0; i <= size.width; i++) {
      path.lineTo(
        i,
        size.height * 0.7 +
            sin((i / size.width * 2 * pi) + animationValue * 2 * pi) * 20,
      );
    }
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, paint);

    // Second wave
    final path2 = Path();
    path2.moveTo(0, size.height * 0.75);
    for (double i = 0; i <= size.width; i++) {
      path2.lineTo(
        i,
        size.height * 0.75 +
            sin((i / size.width * 2 * pi) +
                    animationValue * 2 * pi +
                    pi / 2) *
                15,
      );
    }
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();
    // ✅ withOpacity → withValues
    canvas.drawPath(path2, paint..color = color.withValues(alpha: 0.1));
  }

  @override
  bool shouldRepaint(covariant WavePainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}
