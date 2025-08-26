import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class BidHistoryList extends StatefulWidget {
  final List<Map<String, dynamic>> bidHistory;
  final bool isLiveUpdating;

  const BidHistoryList({
    super.key,
    required this.bidHistory,
    this.isLiveUpdating = true,
  });

  @override
  State<BidHistoryList> createState() => _BidHistoryListState();
}

class _BidHistoryListState extends State<BidHistoryList>
    with TickerProviderStateMixin {
  late AnimationController _newBidController;
  late Animation<double> _newBidAnimation;
  String? _latestBidId;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    if (widget.bidHistory.isNotEmpty) {
      _latestBidId = widget.bidHistory.first['id'] as String?;
    }
  }

  void _initializeAnimations() {
    _newBidController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _newBidAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _newBidController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void didUpdateWidget(BidHistoryList oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check for new bids
    if (widget.bidHistory.isNotEmpty && oldWidget.bidHistory.isNotEmpty) {
      final newLatestBidId = widget.bidHistory.first['id'] as String?;
      if (newLatestBidId != _latestBidId) {
        _latestBidId = newLatestBidId;
        _newBidController.reset();
        _newBidController.forward();
      }
    }
  }

  @override
  void dispose() {
    _newBidController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (widget.bidHistory.isEmpty) {
      return _buildEmptyState(theme, colorScheme);
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(theme, colorScheme),
          _buildBidList(theme, colorScheme),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'history',
                size: 20,
                color: colorScheme.primary,
              ),
              SizedBox(width: 2.w),
              Text(
                'Bid History',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          if (widget.isLiveUpdating)
            Row(
              children: [
                Container(
                  width: 2.w,
                  height: 2.w,
                  decoration: BoxDecoration(
                    color: colorScheme.secondary,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 2.w),
                Text(
                  'Live',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.secondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildBidList(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: 30.h,
      ),
      child: ListView.separated(
        padding: EdgeInsets.all(4.w),
        itemCount:
            widget.bidHistory.length > 10 ? 10 : widget.bidHistory.length,
        separatorBuilder: (context, index) => SizedBox(height: 1.h),
        itemBuilder: (context, index) {
          final bid = widget.bidHistory[index];
          final isLatest = index == 0;

          return AnimatedBuilder(
            animation: _newBidAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: isLatest && _latestBidId == bid['id']
                    ? _newBidAnimation.value
                    : 1.0,
                child: _buildBidItem(bid, isLatest, theme, colorScheme),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBidItem(Map<String, dynamic> bid, bool isLatest, ThemeData theme,
      ColorScheme colorScheme) {
    final bidder = bid['bidder'] as String? ?? 'Anonymous';
    final amount = bid['amount'] as double? ?? 0.0;
    final timestamp = bid['timestamp'] as DateTime? ?? DateTime.now();
    final isWinning = bid['isWinning'] as bool? ?? false;

    final timeAgo = _formatTimeAgo(timestamp);

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: isLatest
            ? colorScheme.secondary.withValues(alpha: 0.1)
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLatest
              ? colorScheme.secondary.withValues(alpha: 0.3)
              : colorScheme.outline.withValues(alpha: 0.1),
          width: isLatest ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // Bidder avatar
          Container(
            width: 10.w,
            height: 10.w,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: isWinning
                    ? colorScheme.secondary
                    : colorScheme.primary.withValues(alpha: 0.3),
                width: isWinning ? 2 : 1,
              ),
            ),
            child: Center(
              child: Text(
                bidder.isNotEmpty ? bidder[0].toUpperCase() : 'A',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          SizedBox(width: 3.w),

          // Bid details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        bidder,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isWinning)
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: colorScheme.secondary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'WINNING',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSecondary,
                            fontWeight: FontWeight.w700,
                            fontSize: 8.sp,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 0.5.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${amount.toStringAsFixed(2)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 16.sp,
                      ),
                    ),
                    Text(
                      timeAgo,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Latest bid indicator
          if (isLatest)
            Container(
              margin: EdgeInsets.only(left: 2.w),
              child: CustomIconWidget(
                iconName: 'fiber_new',
                size: 20,
                color: colorScheme.secondary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: 'gavel',
            size: 48,
            color: colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          SizedBox(height: 2.h),
          Text(
            'No Bids Yet',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Be the first to place a bid on this auction!',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
