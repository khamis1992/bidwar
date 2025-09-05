import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../features/watchlist/domain/entities/watchlist_entity.dart';

/// Watchlist Item Widget
///
/// عنصر في قائمة المتابعة
/// يتبع قواعد BidWar للتصميم
class WatchlistItemWidget extends StatelessWidget {
  final WatchlistEntity watchlistItem;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const WatchlistItemWidget({
    super.key,
    required this.watchlistItem,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header مع الحالة وزر الإزالة
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatusBadge(),
                  Row(
                    children: [
                      // Important Updates Badge
                      if (watchlistItem.hasImportantUpdates)
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 2.w, vertical: 0.5.h),
                          margin: EdgeInsets.only(right: 2.w),
                          decoration: BoxDecoration(
                            color: AppTheme.warningLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.notification_important,
                                size: 3.w,
                                color: Colors.white,
                              ),
                              SizedBox(width: 1.w),
                              Text(
                                'Update',
                                style: TextStyle(
                                  fontSize: 8.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Remove Button
                      IconButton(
                        onPressed: onRemove,
                        icon: Icon(
                          Icons.remove_circle_outline,
                          color: AppTheme.errorLight,
                          size: 5.w,
                        ),
                        tooltip: 'Remove from watchlist',
                      ),
                    ],
                  ),
                ],
              ),

              // صورة المزاد
              Container(
                width: double.infinity,
                height: 20.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage(watchlistItem.mainImage),
                    fit: BoxFit.cover,
                    onError: (exception, stackTrace) {
                      print('Error loading image: $exception');
                    },
                  ),
                ),
                child: Stack(
                  children: [
                    // Gradient overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.3),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Time remaining (للمزادات المباشرة)
                    if (watchlistItem.isLive)
                      Positioned(
                        bottom: 2.w,
                        left: 2.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 2.w, vertical: 1.w),
                          decoration: BoxDecoration(
                            color: watchlistItem.isEndingSoon
                                ? AppTheme.errorLight
                                : AppTheme.successLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.timer,
                                size: 3.w,
                                color: Colors.white,
                              ),
                              SizedBox(width: 1.w),
                              Text(
                                _formatTimeRemaining(
                                    watchlistItem.timeRemaining),
                                style: TextStyle(
                                  fontSize: 9.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Recently Added Badge
                    if (watchlistItem.isRecentlyAdded)
                      Positioned(
                        top: 2.w,
                        right: 2.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 2.w, vertical: 1.w),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'New',
                            style: TextStyle(
                              fontSize: 8.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              SizedBox(height: 3.w),

              // عنوان المزاد
              Text(
                watchlistItem.auctionTitle,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryLight,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              SizedBox(height: 2.w),

              // معلومات البائع
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 4.w,
                    color: AppTheme.textSecondaryLight,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    watchlistItem.sellerName,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppTheme.textSecondaryLight,
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  Spacer(),

                  // Added Date
                  Text(
                    'Added ${_formatAddedDate(watchlistItem.createdAt)}',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: AppTheme.textSecondaryLight.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 3.w),

              // معلومات السعر والمزايدات
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Price',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: AppTheme.textSecondaryLight,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        '\$${watchlistItem.currentPrice}',
                        style: TextStyle(
                          fontSize: 18.sp,
                          color: AppTheme.primaryLight,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Bids',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: AppTheme.textSecondaryLight,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        '${watchlistItem.bidCount}',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: AppTheme.secondaryLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Progress bar للوقت (للمزادات المباشرة)
              if (watchlistItem.isLive) ...[
                SizedBox(height: 3.w),
                LinearProgressIndicator(
                  value: watchlistItem.timeProgressPercentage,
                  backgroundColor: AppTheme.borderLight,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    watchlistItem.isEndingSoon
                        ? AppTheme.errorLight
                        : AppTheme.successLight,
                  ),
                  minHeight: 1.w,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color badgeColor;
    String statusText;

    if (watchlistItem.isLive) {
      badgeColor = AppTheme.successLight;
      statusText = 'LIVE';
    } else if (watchlistItem.isUpcoming) {
      badgeColor = AppTheme.warningLight;
      statusText = 'UPCOMING';
    } else if (watchlistItem.isEnded) {
      badgeColor = AppTheme.textSecondaryLight;
      statusText = 'ENDED';
    } else {
      badgeColor = AppTheme.errorLight;
      statusText = 'CANCELLED';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.w),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: badgeColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          fontSize: 9.sp,
          color: badgeColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatTimeRemaining(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  String _formatAddedDate(DateTime addedDate) {
    final now = DateTime.now();
    final difference = now.difference(addedDate);

    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${addedDate.day}/${addedDate.month}/${addedDate.year}';
    }
  }
}
