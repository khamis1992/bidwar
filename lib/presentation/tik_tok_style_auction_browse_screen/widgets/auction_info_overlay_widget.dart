import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';

import '../../../models/auction_item.dart';

class AuctionInfoOverlayWidget extends StatefulWidget {
  final AuctionItem auction;

  const AuctionInfoOverlayWidget({
    super.key,
    required this.auction,
  });

  @override
  State<AuctionInfoOverlayWidget> createState() =>
      _AuctionInfoOverlayWidgetState();
}

class _AuctionInfoOverlayWidgetState extends State<AuctionInfoOverlayWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initializePulseAnimation();
  }

  void _initializePulseAnimation() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Only pulse for live auctions
    if (widget.auction.isLive) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Auction title
        Text(
          widget.auction.title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.black.withAlpha(204),
                blurRadius: 4,
              ),
            ],
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        SizedBox(height: 1.h),

        // Auction description
        if (widget.auction.description.isNotEmpty)
          Text(
            widget.auction.description,
            style: TextStyle(
              color: Colors.white.withAlpha(230),
              fontSize: 14.sp,
              shadows: [
                Shadow(
                  color: Colors.black.withAlpha(204),
                  blurRadius: 4,
                ),
              ],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

        SizedBox(height: 2.h),

        // Price and bid info
        Row(
          children: [
            // Current price
            Expanded(
              child: _buildInfoCard(
                title: 'Current Bid',
                value:
                    '\$${NumberFormat('#,###').format(widget.auction.currentPrice)}',
                subtitle: widget.auction.bidCount != null
                    ? '${widget.auction.bidCount} bids'
                    : null,
                isPrimary: true,
              ),
            ),

            SizedBox(width: 3.w),

            // Time remaining or status
            Expanded(
              child: widget.auction.isLive
                  ? _buildTimeRemainingCard()
                  : _buildStatusCard(),
            ),
          ],
        ),

        SizedBox(height: 2.h),

        // Seller info and category
        Row(
          children: [
            // Seller info
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade600,
                      borderRadius: BorderRadius.circular(20.sp),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 16.sp,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.auction.sellerName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            shadows: [
                              Shadow(
                                color: Colors.black.withAlpha(204),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          widget.auction.categoryName,
                          style: TextStyle(
                            color: Colors.white.withAlpha(204),
                            fontSize: 10.sp,
                            shadows: [
                              Shadow(
                                color: Colors.black.withAlpha(204),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    String? subtitle,
    bool isPrimary = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        color: isPrimary
            ? Colors.white.withAlpha(38)
            : Colors.black.withAlpha(102),
        borderRadius: BorderRadius.circular(12.sp),
        border: isPrimary
            ? Border.all(color: Colors.white.withAlpha(77), width: 1)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withAlpha(204),
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (subtitle != null) ...[
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withAlpha(179),
                fontSize: 9.sp,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeRemainingCard() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
            decoration: BoxDecoration(
              color: Colors.red.withAlpha(204),
              borderRadius: BorderRadius.circular(12.sp),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withAlpha(77),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LIVE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  _formatTimeRemaining(widget.auction.timeRemaining),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'remaining',
                  style: TextStyle(
                    color: Colors.white.withAlpha(230),
                    fontSize: 9.sp,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusCard() {
    Color statusColor;
    String statusText;
    String statusLabel;

    switch (widget.auction.status) {
      case 'upcoming':
        statusColor = Colors.blue;
        statusText = 'UPCOMING';
        statusLabel = _formatTimeRemaining(widget.auction.timeRemaining);
        break;
      case 'ended':
        statusColor = Colors.grey;
        statusText = 'ENDED';
        statusLabel = 'Auction closed';
        break;
      case 'cancelled':
        statusColor = Colors.orange;
        statusText = 'CANCELLED';
        statusLabel = 'No longer active';
        break;
      default:
        statusColor = Colors.grey;
        statusText = widget.auction.status.toUpperCase();
        statusLabel = '';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        color: statusColor.withAlpha(204),
        borderRadius: BorderRadius.circular(12.sp),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            statusText,
            style: TextStyle(
              color: Colors.white,
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          if (statusLabel.isNotEmpty) ...[
            SizedBox(height: 0.5.h),
            Text(
              statusLabel,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
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
    } else if (duration.inSeconds > 0) {
      return '${duration.inSeconds}s';
    } else {
      return 'Ended';
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }
}
