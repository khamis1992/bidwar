import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:animations/animations.dart';

import '../../../models/auction_item.dart';
import './live_auction_card_widget.dart';
import './regular_auction_card_widget.dart';

enum AuctionDisplayType { all, regular, live }

class EnhancedAuctionGridWidget extends StatelessWidget {
  final List<AuctionItem> auctions;
  final List<AuctionItem> liveAuctions;
  final AuctionDisplayType displayType;
  final Function(AuctionItem) onAuctionTap;
  final bool isLoading;

  const EnhancedAuctionGridWidget({
    super.key,
    required this.auctions,
    required this.liveAuctions,
    required this.displayType,
    required this.onAuctionTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingGrid();
    }

    final displayAuctions = _getDisplayAuctions();

    if (displayAuctions.isEmpty) {
      return _buildEmptyState();
    }

    return GridView.builder(
      padding: EdgeInsets.all(4.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 3.w,
        mainAxisSpacing: 2.h,
      ),
      itemCount: displayAuctions.length,
      itemBuilder: (context, index) {
        final auction = displayAuctions[index];
        final isLiveAuction = _isLiveAuction(auction);

        return PageTransitionSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
            return FadeThroughTransition(
              animation: primaryAnimation,
              secondaryAnimation: secondaryAnimation,
              child: child,
            );
          },
          child: isLiveAuction
              ? LiveAuctionCardWidget(
                  key: ValueKey('live_${auction.id}'),
                  auction: auction,
                  onTap: () => onAuctionTap(auction),
                  viewerCount: _getViewerCount(auction),
                  streamStatus: _getStreamStatus(auction),
                )
              : RegularAuctionCardWidget(
                  key: ValueKey('regular_${auction.id}'),
                  auction: auction,
                  onTap: () => onAuctionTap(auction),
                ),
        );
      },
    );
  }

  List<AuctionItem> _getDisplayAuctions() {
    switch (displayType) {
      case AuctionDisplayType.regular:
        return auctions;
      case AuctionDisplayType.live:
        return liveAuctions;
      case AuctionDisplayType.all:
        // Combine and sort by priority (live auctions first)
        final combined = <AuctionItem>[...liveAuctions, ...auctions];
        combined.sort((a, b) {
          final aIsLive = _isLiveAuction(a);
          final bIsLive = _isLiveAuction(b);

          if (aIsLive && !bIsLive) return -1;
          if (!aIsLive && bIsLive) return 1;

          return b.createdAt.compareTo(a.createdAt);
        });
        return combined;
    }
  }

  bool _isLiveAuction(AuctionItem auction) {
    return liveAuctions.any((live) => live.id == auction.id);
  }

  int? _getViewerCount(AuctionItem auction) {
    // In real implementation, this would come from the live stream data
    // For now, we'll use mock data based on auction popularity
    if (auction.viewCount > 100) {
      return 45 + (auction.viewCount % 50);
    }
    return null;
  }

  String? _getStreamStatus(AuctionItem auction) {
    // In real implementation, this would come from the live stream status
    final now = DateTime.now();
    if (auction.startTime.isBefore(now) && auction.endTime.isAfter(now)) {
      return 'live';
    }
    return 'upcoming';
  }

  Widget _buildLoadingGrid() {
    return GridView.builder(
      padding: EdgeInsets.all(4.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 3.w,
        mainAxisSpacing: 2.h,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade200,
            ),
            child: Column(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: EdgeInsets.all(3.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Container(
                          height: 12,
                          width: 60.w,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    String message;
    IconData icon;

    switch (displayType) {
      case AuctionDisplayType.regular:
        message = 'No regular auctions found';
        icon = Icons.gavel;
        break;
      case AuctionDisplayType.live:
        message = 'No live auctions right now';
        icon = Icons.live_tv;
        break;
      case AuctionDisplayType.all:
        message = 'No auctions found';
        icon = Icons.search_off;
        break;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64.sp,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 2.h),
          Text(
            message,
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Try adjusting your search or filters',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}
