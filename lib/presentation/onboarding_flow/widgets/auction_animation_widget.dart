import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class AuctionAnimationWidget extends StatefulWidget {
  final String animationType;

  const AuctionAnimationWidget({
    super.key,
    required this.animationType,
  });

  @override
  State<AuctionAnimationWidget> createState() => _AuctionAnimationWidgetState();
}

class _AuctionAnimationWidgetState extends State<AuctionAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _priceController;
  late AnimationController _timerController;
  late AnimationController _bidController;

  late Animation<double> _priceAnimation;
  late Animation<double> _timerAnimation;
  late Animation<double> _bidAnimation;

  double currentPrice = 12.47;
  int timerSeconds = 30;

  @override
  void initState() {
    super.initState();

    _priceController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _timerController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _bidController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _priceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _priceController, curve: Curves.elasticOut),
    );

    _timerAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _timerController, curve: Curves.easeInOut),
    );

    _bidAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _bidController, curve: Curves.elasticOut),
    );

    // Start animations based on type
    _startAnimations();
  }

  void _startAnimations() {
    _priceController.repeat(period: const Duration(seconds: 3));
    _timerController.repeat(period: const Duration(seconds: 5));
  }

  @override
  void dispose() {
    _priceController.dispose();
    _timerController.dispose();
    _bidController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80.w,
      height: 35.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
            AppTheme.lightTheme.colorScheme.secondary.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: _buildAnimationContent(),
    );
  }

  Widget _buildAnimationContent() {
    switch (widget.animationType) {
      case 'auction_work':
        return _buildAuctionWorkAnimation();
      case 'credit_timer':
        return _buildCreditTimerAnimation();
      case 'winning_strategy':
        return _buildWinningStrategyAnimation();
      default:
        return _buildAuctionWorkAnimation();
    }
  }

  Widget _buildAuctionWorkAnimation() {
    return AnimatedBuilder(
      animation: Listenable.merge([_priceAnimation, _bidAnimation]),
      builder: (context, child) {
        return Stack(
          children: [
            // Background pattern
            Positioned.fill(
              child: CustomPaint(
                painter: AuctionPatternPainter(),
              ),
            ),

            // Central content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Auction hammer icon
                  Transform.scale(
                    scale: 1.0 + (_bidAnimation.value - 1.0) * 0.3,
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.lightTheme.colorScheme.primary
                                .withValues(alpha: 0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.gavel,
                        size: 8.w,
                        color: AppTheme.lightTheme.colorScheme.onPrimary,
                      ),
                    ),
                  ),

                  SizedBox(height: 3.h),

                  // Price display
                  Transform.scale(
                    scale: 1.0 + _priceAnimation.value * 0.1,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.lightTheme.colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        '\$${(12.47 + _priceAnimation.value * 2.53).toStringAsFixed(2)}',
                        style: AppTheme.lightTheme.textTheme.headlineSmall
                            ?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.lightTheme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 2.h),

                  // +$0.01 indicator
                  AnimatedOpacity(
                    opacity: _priceAnimation.value > 0.5 ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 3.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.secondary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '+\$0.01',
                        style:
                            AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Floating bid indicators
            ..._buildFloatingBidIndicators(),
          ],
        );
      },
    );
  }

  Widget _buildCreditTimerAnimation() {
    return AnimatedBuilder(
      animation: Listenable.merge([_timerAnimation, _priceAnimation]),
      builder: (context, child) {
        final remainingTime = (30 * (1 - _timerAnimation.value)).round();

        return Stack(
          children: [
            // Background gradient
            Positioned.fill(
              child: CustomPaint(
                painter: TimerPatternPainter(),
              ),
            ),

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Credit coin stack
                  Stack(
                    alignment: Alignment.center,
                    children: List.generate(3, (index) {
                      return Transform.translate(
                        offset: Offset(0, -index * 0.5.h),
                        child: Container(
                          width: 12.w,
                          height: 12.w,
                          decoration: BoxDecoration(
                            color: AppTheme.lightTheme.colorScheme.secondary
                                .withValues(alpha: 0.8 - index * 0.2),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.lightTheme.colorScheme.primary,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'C',
                              style: AppTheme.lightTheme.textTheme.titleMedium
                                  ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.lightTheme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),

                  SizedBox(height: 4.h),

                  // Timer display
                  Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: remainingTime < 10
                          ? Colors.red.withValues(alpha: 0.1)
                          : AppTheme.lightTheme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: remainingTime < 10
                            ? Colors.red
                            : AppTheme.lightTheme.colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.timer,
                          color: remainingTime < 10
                              ? Colors.red
                              : AppTheme.lightTheme.colorScheme.primary,
                          size: 6.w,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          '${remainingTime}s',
                          style: AppTheme.lightTheme.textTheme.headlineSmall
                              ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: remainingTime < 10
                                ? Colors.red
                                : AppTheme.lightTheme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 2.h),

                  // Credit cost indicator
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.primary
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.lightTheme.colorScheme.primary
                            .withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      '1 Credit = 1 Bid',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.lightTheme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildWinningStrategyAnimation() {
    return AnimatedBuilder(
      animation: Listenable.merge([_priceAnimation, _bidAnimation]),
      builder: (context, child) {
        return Stack(
          children: [
            // Background pattern
            Positioned.fill(
              child: CustomPaint(
                painter: StrategyPatternPainter(),
              ),
            ),

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Trophy icon
                  Transform.scale(
                    scale: 1.0 + _bidAnimation.value * 0.2,
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.amber,
                            Colors.orange,
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber.withValues(alpha: 0.4),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.emoji_events,
                        size: 8.w,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  SizedBox(height: 3.h),

                  // Strategy steps
                  ...List.generate(3, (index) {
                    final stepOpacity =
                        _priceAnimation.value > (index * 0.33) ? 1.0 : 0.3;
                    final stepLabels = ['WATCH', 'TIME', 'WIN!'];
                    final stepColors = [
                      Colors.blue,
                      Colors.orange,
                      Colors.green,
                    ];

                    return Padding(
                      padding: EdgeInsets.only(bottom: 1.h),
                      child: AnimatedOpacity(
                        opacity: stepOpacity,
                        duration: const Duration(milliseconds: 300),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 6.w,
                              height: 6.w,
                              decoration: BoxDecoration(
                                color: stepColors[index]
                                    .withValues(alpha: stepOpacity),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: AppTheme
                                      .lightTheme.textTheme.labelSmall
                                      ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 3.w),
                            Text(
                              stepLabels[index],
                              style: AppTheme.lightTheme.textTheme.titleMedium
                                  ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: stepColors[index]
                                    .withValues(alpha: stepOpacity),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildFloatingBidIndicators() {
    return List.generate(3, (index) {
      return Positioned(
        left: 10.w + index * 20.w,
        top: 5.h + index * 8.h,
        child: AnimatedBuilder(
          animation: _priceAnimation,
          builder: (context, child) {
            final offset = _priceAnimation.value * 50;
            return Transform.translate(
              offset: Offset(0, -offset),
              child: AnimatedOpacity(
                opacity: 1.0 - _priceAnimation.value,
                duration: Duration.zero,
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.secondary,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.lightTheme.colorScheme.secondary
                            .withValues(alpha: 0.3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Text(
                    'BID',
                    style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }
}

// Custom painters for background patterns
class AuctionPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw auction-themed pattern (gavel strikes)
    for (int i = 0; i < 5; i++) {
      final x = (i + 1) * size.width / 6;
      final y = size.height / 2 + (i.isEven ? -20 : 20);

      canvas.drawLine(
        Offset(x - 10, y - 10),
        Offset(x + 10, y + 10),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class TimerPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.lightTheme.colorScheme.secondary.withValues(alpha: 0.1)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw clock-like pattern
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.3;

    for (int i = 0; i < 12; i++) {
      final angle = (i * 30) * 3.14159 / 180;
      final startX = center.dx + (radius - 10) * math.cos(angle);
      final startY = center.dy + (radius - 10) * math.sin(angle);
      final endX = center.dx + radius * math.cos(angle);
      final endY = center.dy + radius * math.sin(angle);

      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class StrategyPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.amber.withValues(alpha: 0.1)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw strategy arrows
    final path = Path();
    path.moveTo(size.width * 0.1, size.height * 0.8);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.2,
      size.width * 0.9,
      size.height * 0.8,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
