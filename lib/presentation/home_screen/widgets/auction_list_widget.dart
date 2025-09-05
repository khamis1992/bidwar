import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../features/auctions/domain/entities/auction_entity.dart';
import './auction_card_widget.dart';

/// Auction List Widget
///
/// يعرض قائمة المزادات مع Pull-to-refresh وWatchlist
/// يتبع قواعد BidWar للتصميم
class AuctionListWidget extends StatelessWidget {
  final List<AuctionEntity> auctions;
  final bool isLoading;
  final Future<void> Function() onRefresh;
  final Function(String) onAuctionTap;
  final Function(String) onWatchlistToggle;
  final String emptyMessage;
  final IconData emptyIcon;
  final Set<String> watchlistAuctionIds;

  const AuctionListWidget({
    super.key,
    required this.auctions,
    required this.isLoading,
    required this.onRefresh,
    required this.onAuctionTap,
    required this.onWatchlistToggle,
    required this.emptyMessage,
    required this.emptyIcon,
    this.watchlistAuctionIds = const {},
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && auctions.isEmpty) {
      return _buildLoadingState();
    }

    if (auctions.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppTheme.primaryLight,
      child: ListView.builder(
        padding: EdgeInsets.all(4.w),
        itemCount: auctions.length,
        itemBuilder: (context, index) {
          final auction = auctions[index];
          final isInWatchlist = watchlistAuctionIds.contains(auction.id);

          return Padding(
            padding: EdgeInsets.only(bottom: 3.h),
            child: AuctionCardWidget(
              auction: auction,
              onTap: () => onAuctionTap(auction.id),
              onWatchlistToggle: () => onWatchlistToggle(auction.id),
              isInWatchlist: isInWatchlist,
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 12.w,
            height: 12.w,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryLight),
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            'Loading auctions...',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppTheme.textSecondaryLight,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 20.w,
            height: 20.w,
            decoration: BoxDecoration(
              color: AppTheme.borderLight,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              emptyIcon,
              size: 10.w,
              color: AppTheme.textSecondaryLight,
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            emptyMessage,
            style: TextStyle(
              fontSize: 16.sp,
              color: AppTheme.textSecondaryLight,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 1.h),
          Text(
            'Pull down to refresh or check other tabs',
            style: TextStyle(
              fontSize: 12.sp,
              color: AppTheme.textSecondaryLight.withValues(alpha: 0.7),
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          OutlinedButton.icon(
            onPressed: onRefresh,
            icon: Icon(Icons.refresh),
            label: Text('Refresh'),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
            ),
          ),
        ],
      ),
    );
  }
}
