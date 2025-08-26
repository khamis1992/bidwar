import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class BiddingSection extends StatefulWidget {
  final int userCredits;
  final double currentPrice;
  final bool isAuctionActive;
  final bool isUserWinning;
  final VoidCallback? onBidPlaced;
  final VoidCallback? onWatchlistToggle;
  final bool isWatchlisted;

  const BiddingSection({
    super.key,
    required this.userCredits,
    required this.currentPrice,
    required this.isAuctionActive,
    required this.isUserWinning,
    this.onBidPlaced,
    this.onWatchlistToggle,
    this.isWatchlisted = false,
  });

  @override
  State<BiddingSection> createState() => _BiddingSectionState();
}

class _BiddingSectionState extends State<BiddingSection>
    with TickerProviderStateMixin {
  bool _isBidding = false;
  bool _showTimerExtension = false;
  late AnimationController _bidButtonController;
  late AnimationController _successController;
  late AnimationController _timerExtensionController;
  late Animation<double> _bidButtonAnimation;
  late Animation<double> _successAnimation;
  late Animation<double> _timerExtensionAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _bidButtonController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );

    _successController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _timerExtensionController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _bidButtonAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _bidButtonController,
      curve: Curves.easeInOut,
    ));

    _successAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _successController,
      curve: Curves.elasticOut,
    ));

    _timerExtensionAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _timerExtensionController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _bidButtonController.dispose();
    _successController.dispose();
    _timerExtensionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Timer extension notification
              if (_showTimerExtension)
                _buildTimerExtensionNotification(theme, colorScheme),

              // Credits and watchlist row
              _buildCreditsAndWatchlistRow(theme, colorScheme),

              SizedBox(height: 2.h),

              // Bid button
              _buildBidButton(theme, colorScheme),

              SizedBox(height: 1.h),

              // Status message
              _buildStatusMessage(theme, colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimerExtensionNotification(
      ThemeData theme, ColorScheme colorScheme) {
    return AnimatedBuilder(
      animation: _timerExtensionAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _timerExtensionAnimation.value) * -50),
          child: Opacity(
            opacity: _timerExtensionAnimation.value,
            child: Container(
              margin: EdgeInsets.only(bottom: 2.h),
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: colorScheme.tertiary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.tertiary.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: 'timer',
                    size: 20,
                    color: colorScheme.tertiary,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    '+15 seconds added',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colorScheme.tertiary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCreditsAndWatchlistRow(
      ThemeData theme, ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Credits display
        Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomIconWidget(
                iconName: 'account_balance_wallet',
                size: 20,
                color: colorScheme.primary,
              ),
              SizedBox(width: 2.w),
              Text(
                '${widget.userCredits} Credits',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        // Action buttons
        Row(
          children: [
            // Share button
            _buildActionButton(
              icon: 'share',
              onTap: _handleShare,
              theme: theme,
              colorScheme: colorScheme,
            ),

            SizedBox(width: 3.w),

            // Watchlist button
            _buildActionButton(
              icon: widget.isWatchlisted ? 'favorite' : 'favorite_border',
              onTap: widget.onWatchlistToggle,
              theme: theme,
              colorScheme: colorScheme,
              isActive: widget.isWatchlisted,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String icon,
    required VoidCallback? onTap,
    required ThemeData theme,
    required ColorScheme colorScheme,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        if (onTap != null) onTap();
      },
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: isActive
              ? colorScheme.secondary.withValues(alpha: 0.1)
              : colorScheme.outline.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive
                ? colorScheme.secondary.withValues(alpha: 0.3)
                : colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: CustomIconWidget(
          iconName: icon,
          size: 24,
          color: isActive ? colorScheme.secondary : colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildBidButton(ThemeData theme, ColorScheme colorScheme) {
    final canBid =
        widget.isAuctionActive && widget.userCredits > 0 && !_isBidding;
    final nextBidAmount = widget.currentPrice + 0.01;

    return AnimatedBuilder(
      animation: _bidButtonAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _bidButtonAnimation.value,
          child: GestureDetector(
            onTapDown: canBid ? (_) => _bidButtonController.forward() : null,
            onTapUp: canBid ? (_) => _bidButtonController.reverse() : null,
            onTapCancel: canBid ? () => _bidButtonController.reverse() : null,
            onTap: canBid ? _handleBidPlacement : null,
            child: Container(
              width: double.infinity,
              height: 7.h,
              decoration: BoxDecoration(
                gradient: canBid
                    ? LinearGradient(
                        colors: [
                          colorScheme.secondary,
                          colorScheme.secondaryContainer,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color:
                    canBid ? null : colorScheme.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
                boxShadow: canBid
                    ? [
                        BoxShadow(
                          color: colorScheme.secondary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: _isBidding
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 5.w,
                            height: 5.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                colorScheme.onSecondary,
                              ),
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Text(
                            'Placing Bid...',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: colorScheme.onSecondary,
                              fontWeight: FontWeight.w700,
                              fontSize: 18.sp,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomIconWidget(
                            iconName: 'gavel',
                            size: 24,
                            color: canBid
                                ? colorScheme.onSecondary
                                : colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                          SizedBox(width: 3.w),
                          Text(
                            canBid
                                ? 'BID NOW - \$${nextBidAmount.toStringAsFixed(2)}'
                                : _getBidButtonDisabledText(),
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: canBid
                                  ? colorScheme.onSecondary
                                  : colorScheme.onSurface
                                      .withValues(alpha: 0.5),
                              fontWeight: FontWeight.w700,
                              fontSize: 18.sp,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusMessage(ThemeData theme, ColorScheme colorScheme) {
    String message;
    Color messageColor;
    String icon;

    if (!widget.isAuctionActive) {
      message = 'Auction has ended';
      messageColor = colorScheme.error;
      icon = 'timer_off';
    } else if (widget.userCredits == 0) {
      message = 'Insufficient credits - Purchase more to bid';
      messageColor = colorScheme.tertiary;
      icon = 'account_balance_wallet';
    } else if (widget.isUserWinning) {
      message = 'You are currently winning this auction!';
      messageColor = colorScheme.secondary;
      icon = 'emoji_events';
    } else {
      message = 'Each bid costs 1 credit and increases price by \$0.01';
      messageColor = colorScheme.onSurface.withValues(alpha: 0.7);
      icon = 'info';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomIconWidget(
          iconName: icon,
          size: 16,
          color: messageColor,
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: messageColor,
              fontWeight: FontWeight.w500,
              fontSize: 12.sp,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _getBidButtonDisabledText() {
    if (!widget.isAuctionActive) {
      return 'AUCTION ENDED';
    } else if (widget.userCredits == 0) {
      return 'NO CREDITS';
    } else {
      return 'BID NOW';
    }
  }

  Future<void> _handleBidPlacement() async {
    if (!widget.isAuctionActive || widget.userCredits == 0 || _isBidding) {
      return;
    }

    setState(() {
      _isBidding = true;
    });

    // Haptic feedback for bid action
    HapticFeedback.mediumImpact();

    try {
      // Simulate bid processing delay
      await Future.delayed(Duration(milliseconds: 1500));

      // Show success animation
      _successController.forward();

      // Show timer extension notification
      setState(() {
        _showTimerExtension = true;
      });
      _timerExtensionController.forward();

      // Hide timer extension after delay
      Future.delayed(Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _showTimerExtension = false;
          });
          _timerExtensionController.reset();
        }
      });

      // Call the bid placed callback
      if (widget.onBidPlaced != null) {
        widget.onBidPlaced!();
      }

      // Success haptic feedback
      HapticFeedback.heavyImpact();
    } catch (e) {
      // Handle bid error
      HapticFeedback.lightImpact();
      _showErrorMessage('Failed to place bid. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isBidding = false;
        });
      }
    }
  }

  void _handleShare() {
    // Implement share functionality
    HapticFeedback.lightImpact();
    // This would typically open the native share sheet
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
