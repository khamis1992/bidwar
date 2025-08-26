import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class AuctionPriceTimer extends StatefulWidget {
  final double currentPrice;
  final DateTime endTime;
  final bool isActive;
  final VoidCallback? onTimerExpired;

  const AuctionPriceTimer({
    super.key,
    required this.currentPrice,
    required this.endTime,
    required this.isActive,
    this.onTimerExpired,
  });

  @override
  State<AuctionPriceTimer> createState() => _AuctionPriceTimerState();
}

class _AuctionPriceTimerState extends State<AuctionPriceTimer>
    with TickerProviderStateMixin {
  Timer? _timer;
  Duration _timeRemaining = Duration.zero;
  late AnimationController _pulseController;
  late AnimationController _priceController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _priceAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startTimer();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    _priceController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _priceAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _priceController,
      curve: Curves.elasticOut,
    ));

    if (widget.isActive) {
      _pulseController.repeat(reverse: true);
    }
  }

  void _startTimer() {
    _updateTimeRemaining();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _updateTimeRemaining();
      if (_timeRemaining.inSeconds <= 0) {
        timer.cancel();
        if (widget.onTimerExpired != null) {
          widget.onTimerExpired!();
        }
      }
    });
  }

  void _updateTimeRemaining() {
    final now = DateTime.now();
    final remaining = widget.endTime.difference(now);

    setState(() {
      _timeRemaining = remaining.isNegative ? Duration.zero : remaining;
    });

    // Animate price changes
    if (mounted) {
      _priceController.reset();
      _priceController.forward();
    }
  }

  @override
  void didUpdateWidget(AuctionPriceTimer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.currentPrice != widget.currentPrice) {
      _priceController.reset();
      _priceController.forward();
    }

    if (oldWidget.isActive != widget.isActive) {
      if (widget.isActive) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isUrgent = _timeRemaining.inMinutes < 5;
    final isCritical = _timeRemaining.inMinutes < 1;

    return Container(
      padding: EdgeInsets.all(4.w),
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCritical
              ? colorScheme.error
              : isUrgent
                  ? colorScheme.tertiary
                  : colorScheme.outline.withValues(alpha: 0.2),
          width: isCritical ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Current price
          AnimatedBuilder(
            animation: _priceAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _priceAnimation.value,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '\$',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 20.sp,
                      ),
                    ),
                    Text(
                      widget.currentPrice.toStringAsFixed(2),
                      style: theme.textTheme.displaySmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 32.sp,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          SizedBox(height: 2.h),

          // Timer display
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: widget.isActive ? _pulseAnimation.value : 1.0,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: isCritical
                        ? colorScheme.error.withValues(alpha: 0.1)
                        : isUrgent
                            ? colorScheme.tertiary.withValues(alpha: 0.1)
                            : colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isCritical
                          ? colorScheme.error
                          : isUrgent
                              ? colorScheme.tertiary
                              : colorScheme.primary,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Time Remaining',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                          fontSize: 12.sp,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      _buildTimerDisplay(
                          theme, colorScheme, isUrgent, isCritical),
                    ],
                  ),
                ),
              );
            },
          ),

          // Status indicator
          if (!widget.isActive)
            Container(
              margin: EdgeInsets.only(top: 2.h),
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: colorScheme.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: 'timer_off',
                    size: 16,
                    color: colorScheme.error,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Auction Ended',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTimerDisplay(ThemeData theme, ColorScheme colorScheme,
      bool isUrgent, bool isCritical) {
    if (_timeRemaining.inSeconds <= 0) {
      return Text(
        '00:00:00',
        style: theme.textTheme.headlineSmall?.copyWith(
          color: colorScheme.error,
          fontWeight: FontWeight.w700,
          fontSize: 24.sp,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
      );
    }

    final hours = _timeRemaining.inHours;
    final minutes = _timeRemaining.inMinutes.remainder(60);
    final seconds = _timeRemaining.inSeconds.remainder(60);

    final timeColor = isCritical
        ? colorScheme.error
        : isUrgent
            ? colorScheme.tertiary
            : colorScheme.primary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTimeUnit(
            hours.toString().padLeft(2, '0'), 'HRS', theme, timeColor),
        _buildTimeSeparator(theme, timeColor),
        _buildTimeUnit(
            minutes.toString().padLeft(2, '0'), 'MIN', theme, timeColor),
        _buildTimeSeparator(theme, timeColor),
        _buildTimeUnit(
            seconds.toString().padLeft(2, '0'), 'SEC', theme, timeColor),
      ],
    );
  }

  Widget _buildTimeUnit(
      String value, String label, ThemeData theme, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 20.sp,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: color.withValues(alpha: 0.7),
            fontSize: 8.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSeparator(ThemeData theme, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 2.w),
      child: Text(
        ':',
        style: theme.textTheme.headlineSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 20.sp,
        ),
      ),
    );
  }
}
