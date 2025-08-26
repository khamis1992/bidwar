import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../models/auction_item.dart';

class AuctionCardWidget extends StatelessWidget {
  final AuctionItem auction;
  final VoidCallback onTap;

  const AuctionCardWidget({
    super.key,
    required this.auction,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  // Main image
                  Container(
                    width: double.infinity,
                    child: CachedNetworkImage(
                      imageUrl: auction.mainImage,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.error),
                      ),
                    ),
                  ),

                  // Status badge
                  Positioned(
                    top: 1.w,
                    left: 1.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 2.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: _getStatusColor(auction.status),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        auction.status.toUpperCase(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ),

                  // Featured badge
                  if (auction.featured)
                    Positioned(
                      top: 1.w,
                      right: 1.w,
                      child: Container(
                        padding: EdgeInsets.all(1.w),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.star,
                          color: Colors.white,
                          size: 14.sp,
                        ),
                      ),
                    ),

                  // Time remaining overlay
                  if (auction.isLive || auction.isUpcoming)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 1.h),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withAlpha(204),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: Text(
                          _formatTimeRemaining(auction.timeRemaining),
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Content section
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(2.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      auction.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 0.5.h),

                    // Category
                    if (auction.categoryName.isNotEmpty)
                      Text(
                        auction.categoryName,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),

                    const Spacer(),

                    // Price section
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                auction.currentHighestBid > 0
                                    ? 'Current Bid'
                                    : 'Starting Price',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                              ),
                              Text(
                                '${auction.currentHighestBid > 0 ? auction.currentHighestBid : auction.startingPrice} Credits',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                              ),
                            ],
                          ),
                        ),

                        // Bid count
                        if (auction.bidCount != null && auction.bidCount! > 0)
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 2.w, vertical: 0.5.h),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withAlpha(26),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${auction.bidCount} bids',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
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
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'live':
        return Colors.green;
      case 'upcoming':
        return Colors.blue;
      case 'ended':
        return Colors.grey;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatTimeRemaining(Duration duration) {
    if (duration.isNegative) return 'Ended';

    final days = duration.inDays;
    final hours = duration.inHours.remainder(24);
    final minutes = duration.inMinutes.remainder(60);

    if (days > 0) {
      return '${days}d ${hours}h left';
    } else if (hours > 0) {
      return '${hours}h ${minutes}m left';
    } else if (minutes > 0) {
      return '${minutes}m left';
    } else {
      return 'Ending soon';
    }
  }
}
