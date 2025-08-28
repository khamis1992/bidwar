import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../models/auction_item.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_image_widget.dart';

class RegularAuctionCardWidget extends StatelessWidget {
  final AuctionItem auction;
  final VoidCallback onTap;

  const RegularAuctionCardWidget({
    super.key,
    required this.auction,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isEnding = _isEndingSoon();

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image with status indicators
              Stack(
                children: [
                  SizedBox(
                    height: 18.h,
                    width: double.infinity,
                    child: CustomImageWidget(
                      imageUrl: auction.images.isNotEmpty
                          ? auction.images.first
                          : 'https://images.unsplash.com/photo-1560472354-b33ff0c44a43',
                      fit: BoxFit.cover,
                    ),
                  ),

                  // Status badge
                  Positioned(
                    top: 2.h,
                    left: 3.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 2.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: _getStatusColor().withAlpha(230),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        _getStatusText(),
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  // Featured star
                  if (auction.featured)
                    Positioned(
                      top: 2.h,
                      right: 3.w,
                      child: Container(
                        padding: EdgeInsets.all(1.w),
                        decoration: BoxDecoration(
                          color: Colors.orange.withAlpha(230),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.star,
                          color: Colors.white,
                          size: 14.sp,
                        ),
                      ),
                    ),

                  // Time remaining
                  Positioned(
                    bottom: 1.h,
                    right: 3.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 2.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: isEnding
                            ? Colors.red.withAlpha(230)
                            : Colors.black.withAlpha(179),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getTimeRemaining(),
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Auction details
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        auction.title,
                        style:
                            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      SizedBox(height: 1.h),

                      // Price info
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  auction.currentHighestBid > 0
                                      ? 'Current Bid'
                                      : 'Starting Price',
                                  style: AppTheme.lightTheme.textTheme.bodySmall
                                      ?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                Text(
                                  '\$${_formatPrice(auction.currentHighestBid > 0 ? auction.currentHighestBid : auction.startingPrice)}',
                                  style: AppTheme
                                      .lightTheme.textTheme.titleMedium
                                      ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        AppTheme.lightTheme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Bid count
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 2.w, vertical: 0.5.h),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.gavel,
                                  size: 12.sp,
                                  color: Colors.grey.shade600,
                                ),
                                SizedBox(width: 1.w),
                                Text(
                                  '${auction.bidCount ?? 0}',
                                  style: AppTheme.lightTheme.textTheme.bodySmall
                                      ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 1.h),

                      // Category and condition
                      Row(
                        children: [
                          Icon(
                            Icons.category,
                            size: 12.sp,
                            color: Colors.grey.shade500,
                          ),
                          SizedBox(width: 1.w),
                          Expanded(
                            child: Text(
                              (auction.category as String?) ?? 'General',
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (auction.condition != null) ...[
                            Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade400,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              auction.condition!,
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (auction.status) {
      case 'live':
        return Colors.green;
      case 'upcoming':
        return Colors.orange;
      case 'ended':
        return Colors.grey;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText() {
    switch (auction.status) {
      case 'live':
        return 'LIVE';
      case 'upcoming':
        return 'UPCOMING';
      case 'ended':
        return 'ENDED';
      case 'cancelled':
        return 'CANCELLED';
      default:
        return 'UNKNOWN';
    }
  }

  bool _isEndingSoon() {
    final now = DateTime.now();
    final difference = auction.endTime.difference(now);
    return difference.inHours <= 24 && difference.inMinutes > 0;
  }

  String _formatPrice(int price) {
    if (price >= 1000000) {
      return '${(price / 1000000).toStringAsFixed(1)}M';
    } else if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(1)}K';
    }
    return price.toString();
  }

  String _getTimeRemaining() {
    final now = DateTime.now();
    final endTime = auction.endTime;

    if (endTime.isBefore(now)) {
      return 'Ended';
    }

    final difference = endTime.difference(now);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ${difference.inHours % 24}h';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ${difference.inMinutes % 60}m';
    } else {
      return '${difference.inMinutes}m';
    }
  }
}