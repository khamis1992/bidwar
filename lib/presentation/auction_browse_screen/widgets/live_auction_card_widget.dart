import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:shimmer/shimmer.dart';

import '../../../models/auction_item.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_image_widget.dart';

class LiveAuctionCardWidget extends StatelessWidget {
  final AuctionItem auction;
  final VoidCallback onTap;
  final bool showLiveBadge;
  final int? viewerCount;
  final String? streamStatus;

  const LiveAuctionCardWidget({
    super.key,
    required this.auction,
    required this.onTap,
    this.showLiveBadge = true,
    this.viewerCount,
    this.streamStatus,
  });

  @override
  Widget build(BuildContext context) {
    final isLive = streamStatus == 'live';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isLive
                  ? Colors.red.withAlpha(76)
                  : Colors.black.withAlpha(25),
              blurRadius: isLive ? 12 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: isLive
                ? const BorderSide(color: Colors.red, width: 2)
                : BorderSide.none,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image with live overlay
                Stack(
                  children: [
                    SizedBox(
                      height: 20.h,
                      width: double.infinity,
                      child: CustomImageWidget(
                        imageUrl: auction.images.isNotEmpty
                            ? auction.images.first
                            : 'https://images.unsplash.com/photo-1560472354-b33ff0c44a43',
                        fit: BoxFit.cover,
                      ),
                    ),

                    // Live indicator shimmer effect
                    if (isLive)
                      Positioned(
                        top: 2.h,
                        left: 3.w,
                        child: Shimmer.fromColors(
                          baseColor: Colors.red,
                          highlightColor: Colors.red.shade300,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 3.w, vertical: 1.h),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withAlpha(102),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 1.w),
                                Text(
                                  'LIVE',
                                  style: AppTheme.lightTheme.textTheme.bodySmall
                                      ?.copyWith(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    // Viewer count
                    if (viewerCount != null && viewerCount! > 0)
                      Positioned(
                        top: 2.h,
                        right: 3.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 2.w, vertical: 0.5.h),
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(179),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.visibility,
                                color: Colors.white,
                                size: 14,
                              ),
                              SizedBox(width: 1.w),
                              Text(
                                _formatViewerCount(viewerCount!),
                                style: AppTheme.lightTheme.textTheme.bodySmall
                                    ?.copyWith(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Time remaining overlay
                    Positioned(
                      bottom: 1.h,
                      left: 3.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(179),
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
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        SizedBox(height: 1.h),

                        // Current bid with live indicator
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Current Bid',
                                    style: AppTheme
                                        .lightTheme.textTheme.bodySmall
                                        ?.copyWith(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  Text(
                                    '\$${_formatPrice(auction.currentHighestBid)}',
                                    style: AppTheme
                                        .lightTheme.textTheme.titleMedium
                                        ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: isLive ? Colors.red : null,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isLive)
                              Icon(
                                Icons.trending_up,
                                color: Colors.red,
                                size: 18.sp,
                              ),
                          ],
                        ),

                        SizedBox(height: 1.h),

                        // Stream info row
                        Row(
                          children: [
                            Icon(
                              isLive ? Icons.play_circle : Icons.schedule,
                              size: 14.sp,
                              color: isLive ? Colors.red : Colors.orange,
                            ),
                            SizedBox(width: 1.w),
                            Expanded(
                              child: Text(
                                isLive ? 'Broadcasting Live' : 'Starts Soon',
                                style: AppTheme.lightTheme.textTheme.bodySmall
                                    ?.copyWith(
                                  color: isLive ? Colors.red : Colors.orange,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
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
      ),
    );
  }

  String _formatPrice(int price) {
    if (price >= 1000000) {
      return '${(price / 1000000).toStringAsFixed(1)}M';
    } else if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(1)}K';
    }
    return price.toString();
  }

  String _formatViewerCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
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