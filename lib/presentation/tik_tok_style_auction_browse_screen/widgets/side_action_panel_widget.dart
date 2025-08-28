import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../models/auction_item.dart';

class SideActionPanelWidget extends StatelessWidget {
  final AuctionItem auction;
  final VoidCallback onBid;
  final VoidCallback onWatchlist;
  final VoidCallback onShare;
  final VoidCallback onViewDetails;

  const SideActionPanelWidget({
    super.key,
    required this.auction,
    required this.onBid,
    required this.onWatchlist,
    required this.onShare,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Bid button (primary action)
        _buildActionButton(
          icon: Icons.gavel,
          label: 'Bid',
          onTap: onBid,
          isPrimary: true,
          badge: auction.isLive ? 'LIVE' : null,
        ),

        SizedBox(height: 3.h),

        // Watchlist button
        _buildActionButton(
          icon: Icons.bookmark_border,
          label: 'Save',
          onTap: onWatchlist,
        ),

        SizedBox(height: 3.h),

        // Share button
        _buildActionButton(
          icon: Icons.share,
          label: 'Share',
          onTap: onShare,
        ),

        SizedBox(height: 3.h),

        // View details button
        _buildActionButton(
          icon: Icons.info_outline,
          label: 'Details',
          onTap: onViewDetails,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isPrimary = false,
    String? badge,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: isPrimary
                  ? Colors.red.withAlpha(230)
                  : Colors.black.withAlpha(153),
              borderRadius: BorderRadius.circular(25.sp),
              border:
                  isPrimary ? Border.all(color: Colors.white, width: 2) : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(77),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 24.sp,
                  ),
                ),

                // Badge for live auctions
                if (badge != null)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 1.5.w,
                        vertical: 0.3.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(8.sp),
                      ),
                      child: Text(
                        badge,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
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
    );
  }
}
