import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../features/auctions/domain/entities/auction_entity.dart';

/// Countdown Timer Widget
///
/// عداد تنازلي للوقت المتبقي في المزاد
/// يتبع قواعد BidWar للتصميم
class CountdownTimerWidget extends StatefulWidget {
  final AuctionEntity auction;
  final VoidCallback onTimeExpired;

  const CountdownTimerWidget({
    super.key,
    required this.auction,
    required this.onTimeExpired,
  });

  @override
  State<CountdownTimerWidget> createState() => _CountdownTimerWidgetState();
}

class _CountdownTimerWidgetState extends State<CountdownTimerWidget>
    with TickerProviderStateMixin {
  Timer? _timer;
  Duration _timeRemaining = Duration.zero;
  late AnimationController _urgentAnimationController;
  late Animation<Color?> _urgentColorAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startTimer();
  }

  void _setupAnimations() {
    _urgentAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _urgentColorAnimation = ColorTween(
      begin: AppTheme.errorLight,
      end: AppTheme.errorLight.withValues(alpha: 0.3),
    ).animate(
      CurvedAnimation(
        parent: _urgentAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _startTimer() {
    _updateTimeRemaining();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTimeRemaining();

      // إذا انتهى الوقت
      if (_timeRemaining.inSeconds <= 0) {
        timer.cancel();
        widget.onTimeExpired();
        return;
      }

      // إذا كان الوقت قريب من الانتهاء، شغّل animation
      if (_timeRemaining.inMinutes <= 5 && widget.auction.isLive) {
        if (!_urgentAnimationController.isAnimating) {
          _urgentAnimationController.repeat(reverse: true);
        }
      } else {
        _urgentAnimationController.stop();
      }
    });
  }

  void _updateTimeRemaining() {
    setState(() {
      _timeRemaining = widget.auction.timeRemaining;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _urgentAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isUrgent = _timeRemaining.inMinutes <= 5 && widget.auction.isLive;
    final isVeryUrgent = _timeRemaining.inMinutes <= 1 && widget.auction.isLive;

    return AnimatedBuilder(
      animation: _urgentColorAnimation,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color:
                isUrgent
                    ? _urgentColorAnimation.value?.withValues(alpha: 0.1)
                    : widget.auction.isLive
                    ? AppTheme.successLight.withValues(alpha: 0.1)
                    : AppTheme.warningLight.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  isUrgent
                      ? AppTheme.errorLight
                      : widget.auction.isLive
                      ? AppTheme.successLight
                      : AppTheme.warningLight,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.auction.isLive ? Icons.timer : Icons.schedule,
                    color:
                        isUrgent
                            ? AppTheme.errorLight
                            : widget.auction.isLive
                            ? AppTheme.successLight
                            : AppTheme.warningLight,
                    size: 5.w,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    widget.auction.isLive ? 'Time Remaining' : 'Starts In',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color:
                          isUrgent
                              ? AppTheme.errorLight
                              : widget.auction.isLive
                              ? AppTheme.successLight
                              : AppTheme.warningLight,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 2.h),

              // Countdown Display
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildTimeUnit(
                    value: _timeRemaining.inDays,
                    label: 'Days',
                    isUrgent: isUrgent,
                  ),
                  _buildTimeUnit(
                    value: _timeRemaining.inHours % 24,
                    label: 'Hours',
                    isUrgent: isUrgent,
                  ),
                  _buildTimeUnit(
                    value: _timeRemaining.inMinutes % 60,
                    label: 'Minutes',
                    isUrgent: isUrgent,
                  ),
                  _buildTimeUnit(
                    value: _timeRemaining.inSeconds % 60,
                    label: 'Seconds',
                    isUrgent: isVeryUrgent,
                  ),
                ],
              ),

              // Progress Bar
              if (widget.auction.isLive) ...[
                SizedBox(height: 3.h),
                LinearProgressIndicator(
                  value: widget.auction.timeProgressPercentage,
                  backgroundColor: AppTheme.borderLight,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isUrgent ? AppTheme.errorLight : AppTheme.successLight,
                  ),
                  minHeight: 1.h,
                ),

                SizedBox(height: 1.h),

                Text(
                  '${(widget.auction.timeProgressPercentage * 100).toStringAsFixed(1)}% completed',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: AppTheme.textSecondaryLight,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],

              // Urgent Warning
              if (isVeryUrgent) ...[
                SizedBox(height: 2.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: AppTheme.errorLight.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.errorLight, width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.warning,
                        color: AppTheme.errorLight,
                        size: 4.w,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Auction ending very soon!',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppTheme.errorLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimeUnit({
    required int value,
    required String label,
    required bool isUrgent,
  }) {
    return Column(
      children: [
        Container(
          width: 15.w,
          height: 15.w,
          decoration: BoxDecoration(
            color:
                isUrgent
                    ? AppTheme.errorLight
                    : widget.auction.isLive
                    ? AppTheme.successLight
                    : AppTheme.warningLight,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: (isUrgent
                        ? AppTheme.errorLight
                        : widget.auction.isLive
                        ? AppTheme.successLight
                        : AppTheme.warningLight)
                    .withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              value.toString().padLeft(2, '0'),
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),

        SizedBox(height: 1.h),

        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            color: AppTheme.textSecondaryLight,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
