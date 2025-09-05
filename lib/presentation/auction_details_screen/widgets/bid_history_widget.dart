import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../features/bids/domain/entities/bid_entity.dart';

/// Bid History Widget
///
/// يعرض تاريخ المزايدات مع Realtime updates
/// يتبع قواعد BidWar للتصميم
class BidHistoryWidget extends StatelessWidget {
  final List<BidEntity> bids;
  final bool isLoading;
  final VoidCallback onRefresh;

  const BidHistoryWidget({
    super.key,
    required this.bids,
    required this.isLoading,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.history, color: AppTheme.primaryLight, size: 5.w),
                SizedBox(width: 2.w),
                Text(
                  'Bid History',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryLight,
                  ),
                ),
              ],
            ),

            if (bids.isNotEmpty)
              Text(
                '${bids.length} bid${bids.length != 1 ? 's' : ''}',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppTheme.textSecondaryLight,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),

        SizedBox(height: 2.h),

        // Bid List
        if (isLoading && bids.isEmpty)
          _buildLoadingState()
        else if (bids.isEmpty)
          _buildEmptyState()
        else
          _buildBidList(),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Container(
      width: double.infinity,
      height: 20.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderLight, width: 1),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 8.w,
              height: 8.w,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryLight,
                ),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Loading bid history...',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppTheme.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderLight, width: 1),
      ),
      child: Column(
        children: [
          Icon(Icons.gavel_outlined, size: 15.w, color: AppTheme.borderLight),
          SizedBox(height: 2.h),
          Text(
            'No bids yet',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondaryLight,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Be the first to place a bid on this auction!',
            style: TextStyle(
              fontSize: 12.sp,
              color: AppTheme.textSecondaryLight,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBidList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderLight, width: 1),
      ),
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.borderLight.withValues(alpha: 0.3),
              borderRadius: BorderRadius.vertical(top: Radius.circular(11)),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Bidder',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondaryLight,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Amount',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondaryLight,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Text(
                    'Time',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondaryLight,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),

          // Bid Items
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount:
                bids.length > 10 ? 10 : bids.length, // عرض آخر 10 مزايدات
            separatorBuilder:
                (context, index) =>
                    Divider(height: 1, color: AppTheme.borderLight),
            itemBuilder: (context, index) {
              final bid = bids[index];
              final isHighest = index == 0; // أعلى مزايدة

              return Container(
                padding: EdgeInsets.all(3.w),
                color:
                    isHighest
                        ? AppTheme.successLight.withValues(alpha: 0.1)
                        : Colors.transparent,
                child: Row(
                  children: [
                    // Bidder Info
                    Expanded(
                      flex: 2,
                      child: Row(
                        children: [
                          // Highest Bid Crown
                          if (isHighest)
                            Icon(
                              Icons.emoji_events,
                              color: AppTheme.warningLight,
                              size: 4.w,
                            ),
                          if (isHighest) SizedBox(width: 1.w),

                          // Bidder Avatar
                          Container(
                            width: 6.w,
                            height: 6.w,
                            decoration: BoxDecoration(
                              color: AppTheme.borderLight,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Icon(
                              Icons.person,
                              size: 3.w,
                              color: AppTheme.textSecondaryLight,
                            ),
                          ),

                          SizedBox(width: 2.w),

                          Expanded(
                            child: Text(
                              bid.bidderName,
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight:
                                    isHighest
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                color:
                                    isHighest
                                        ? AppTheme.successLight
                                        : AppTheme.primaryLight,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Bid Amount
                    Expanded(
                      child: Text(
                        '\$${bid.bidAmount}',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color:
                              isHighest
                                  ? AppTheme.successLight
                                  : AppTheme.primaryLight,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    // Time
                    Expanded(
                      child: Text(
                        _formatBidTime(bid.placedAt),
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: AppTheme.textSecondaryLight,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Show More Button (إذا كان هناك مزايدات أكثر)
          if (bids.length > 10)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: AppTheme.borderLight.withValues(alpha: 0.2),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(11),
                ),
              ),
              child: TextButton(
                onPressed: onRefresh,
                child: Text(
                  'View all ${bids.length} bids',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppTheme.primaryLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatBidTime(DateTime bidTime) {
    final now = DateTime.now();
    final difference = now.difference(bidTime);

    if (difference.inMinutes < 1) {
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
