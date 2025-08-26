import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class DailyBonusCard extends StatefulWidget {
  final int bonusCredits;
  final Duration timeUntilNextBonus;
  final bool canClaim;
  final VoidCallback onClaim;

  const DailyBonusCard({
    super.key,
    required this.bonusCredits,
    required this.timeUntilNextBonus,
    required this.canClaim,
    required this.onClaim,
  });

  @override
  State<DailyBonusCard> createState() => _DailyBonusCardState();
}

class _DailyBonusCardState extends State<DailyBonusCard>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    if (widget.canClaim) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(DailyBonusCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.canClaim != oldWidget.canClaim) {
      if (widget.canClaim) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _pulseController.reset();
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.canClaim ? _pulseAnimation.value : 1.0,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: widget.canClaim
                    ? [
                        colorScheme.tertiary,
                        colorScheme.tertiary.withValues(alpha: 0.8),
                      ]
                    : [
                        colorScheme.surface,
                        colorScheme.surface,
                      ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: widget.canClaim
                  ? null
                  : Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.2)),
              boxShadow: [
                BoxShadow(
                  color: widget.canClaim
                      ? colorScheme.tertiary.withValues(alpha: 0.3)
                      : colorScheme.shadow.withValues(alpha: 0.08),
                  blurRadius: widget.canClaim ? 12 : 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: widget.canClaim
                            ? colorScheme.onTertiary.withValues(alpha: 0.2)
                            : colorScheme.tertiary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: CustomIconWidget(
                        iconName: 'card_giftcard',
                        color: widget.canClaim
                            ? colorScheme.onTertiary
                            : colorScheme.tertiary,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Daily Bonus',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: widget.canClaim
                                  ? colorScheme.onTertiary
                                  : colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            'Get ${widget.bonusCredits} free credits daily',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: widget.canClaim
                                  ? colorScheme.onTertiary
                                      .withValues(alpha: 0.8)
                                  : colorScheme.onSurface
                                      .withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 3.h),
                widget.canClaim
                    ? SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            widget.onClaim();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.onTertiary,
                            foregroundColor: colorScheme.tertiary,
                            padding: EdgeInsets.symmetric(vertical: 2.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomIconWidget(
                                iconName: 'redeem',
                                color: colorScheme.tertiary,
                                size: 20,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                'Claim ${widget.bonusCredits} Credits',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Column(
                        children: [
                          Text(
                            'Next bonus in:',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color:
                                  colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            _formatDuration(widget.timeUntilNextBonus),
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colorScheme.tertiary,
                            ),
                          ),
                        ],
                      ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}
