import 'package:flutter/material.dart';
import 'dart:math' as math;

class BattleEffectsOverlayWidget extends StatefulWidget {
  final AnimationController supportEffectController;
  final AnimationController celebrationController;
  final AnimationController shakeController;

  const BattleEffectsOverlayWidget({
    super.key,
    required this.supportEffectController,
    required this.celebrationController,
    required this.shakeController,
  });

  @override
  State<BattleEffectsOverlayWidget> createState() =>
      _BattleEffectsOverlayWidgetState();
}

class _BattleEffectsOverlayWidgetState extends State<BattleEffectsOverlayWidget>
    with TickerProviderStateMixin {
  final List<ParticleData> _particles = [];
  late AnimationController _particleController;

  @override
  void initState() {
    super.initState();

    _particleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Listen to support effect to trigger particles
    widget.supportEffectController.addListener(() {
      if (widget.supportEffectController.value > 0.1 &&
          widget.supportEffectController.value < 0.2) {
        _createParticleExplosion();
      }
    });

    // Listen to celebration to trigger confetti
    widget.celebrationController.addListener(() {
      if (widget.celebrationController.value > 0.1 &&
          widget.celebrationController.value < 0.2) {
        _createConfettiExplosion();
      }
    });
  }

  void _createParticleExplosion() {
    final random = math.Random();
    _particles.clear();

    // Create heart particles
    for (int i = 0; i < 15; i++) {
      _particles.add(ParticleData(
        x: MediaQuery.of(context).size.width / 2 +
            (random.nextDouble() - 0.5) * 100,
        y: MediaQuery.of(context).size.height / 2 +
            (random.nextDouble() - 0.5) * 100,
        velocityX: (random.nextDouble() - 0.5) * 200,
        velocityY: -random.nextDouble() * 150 - 50,
        color: Colors.red,
        icon: Icons.favorite,
        size: random.nextDouble() * 20 + 15,
      ));
    }

    _particleController.forward().then((_) {
      _particles.clear();
      _particleController.reset();
    });
  }

  void _createConfettiExplosion() {
    final random = math.Random();
    _particles.clear();

    final colors = [
      Colors.red,
      Colors.blue,
      Colors.yellow,
      Colors.green,
      Colors.purple,
      Colors.orange,
    ];

    // Create confetti particles
    for (int i = 0; i < 30; i++) {
      _particles.add(ParticleData(
        x: MediaQuery.of(context).size.width / 2 +
            (random.nextDouble() - 0.5) * 200,
        y: 50 + random.nextDouble() * 100,
        velocityX: (random.nextDouble() - 0.5) * 300,
        velocityY: random.nextDouble() * 200 + 100,
        color: colors[random.nextInt(colors.length)],
        icon: Icons.star,
        size: random.nextDouble() * 15 + 10,
      ));
    }

    _particleController.forward().then((_) {
      _particles.clear();
      _particleController.reset();
    });
  }

  @override
  void dispose() {
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          // Screen shake effect
          AnimatedBuilder(
            animation: widget.shakeController,
            builder: (context, child) {
              final shakeOffset =
                  math.sin(widget.shakeController.value * math.pi * 10) * 5;
              return Transform.translate(
                offset: Offset(shakeOffset, 0),
                child: Container(), // Invisible container for shake effect
              );
            },
          ),

          // Support effect particles
          AnimatedBuilder(
            animation: _particleController,
            builder: (context, child) {
              return Stack(
                children: _particles.map((particle) {
                  final progress = _particleController.value;
                  final currentX = particle.x + (particle.velocityX * progress);
                  final currentY = particle.y +
                      (particle.velocityY * progress) +
                      (980 * progress * progress / 2); // Gravity

                  return Positioned(
                    left: currentX,
                    top: currentY,
                    child: Opacity(
                      opacity: 1.0 - progress,
                      child: Transform.rotate(
                        angle: progress * math.pi * 4,
                        child: Icon(
                          particle.icon,
                          color: particle.color,
                          size: particle.size * (1.0 - progress * 0.5),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),

          // Support wave effect
          AnimatedBuilder(
            animation: widget.supportEffectController,
            builder: (context, child) {
              if (widget.supportEffectController.value == 0) {
                return const SizedBox();
              }

              return Positioned.fill(
                child: CustomPaint(
                  painter: WaveEffectPainter(
                    progress: widget.supportEffectController.value,
                  ),
                ),
              );
            },
          ),

          // Celebration fireworks
          AnimatedBuilder(
            animation: widget.celebrationController,
            builder: (context, child) {
              if (widget.celebrationController.value == 0) {
                return const SizedBox();
              }

              return Positioned.fill(
                child: CustomPaint(
                  painter: FireworksPainter(
                    progress: widget.celebrationController.value,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class ParticleData {
  final double x;
  final double y;
  final double velocityX;
  final double velocityY;
  final Color color;
  final IconData icon;
  final double size;

  ParticleData({
    required this.x,
    required this.y,
    required this.velocityX,
    required this.velocityY,
    required this.color,
    required this.icon,
    required this.size,
  });
}

class WaveEffectPainter extends CustomPainter {
  final double progress;

  WaveEffectPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.3 * (1 - progress))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = progress * size.width * 0.8;

    canvas.drawCircle(center, radius, paint);

    // Multiple wave rings
    for (int i = 1; i <= 3; i++) {
      final ringPaint = Paint()
        ..color = Colors.white.withOpacity(0.2 * (1 - progress) / i)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawCircle(center, radius * (1 + i * 0.3), ringPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class FireworksPainter extends CustomPainter {
  final double progress;

  FireworksPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    final random = math.Random(42); // Fixed seed for consistent animation

    // Draw multiple firework bursts
    for (int burst = 0; burst < 5; burst++) {
      final centerX = size.width * (0.2 + random.nextDouble() * 0.6);
      final centerY = size.height * (0.2 + random.nextDouble() * 0.4);

      // Each burst has multiple sparks
      for (int spark = 0; spark < 12; spark++) {
        final angle = (spark / 12) * 2 * math.pi;
        final distance = progress * 100 * (0.5 + random.nextDouble() * 0.5);

        final x = centerX + math.cos(angle) * distance;
        final y = centerY + math.sin(angle) * distance;

        paint.color = HSLColor.fromAHSL(
          1.0 - progress,
          (spark * 30 + burst * 72) % 360 / 360,
          1.0,
          0.5,
        ).toColor();

        canvas.drawCircle(
          Offset(x, y),
          (1.0 - progress) * 5 + 2,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}