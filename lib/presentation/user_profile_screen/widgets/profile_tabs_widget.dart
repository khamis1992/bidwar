import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ProfileTabsWidget extends StatefulWidget {
  final List<Map<String, dynamic>> activeBids;
  final List<Map<String, dynamic>> wonAuctions;
  final List<Map<String, dynamic>> bidHistory;

  const ProfileTabsWidget({
    super.key,
    required this.activeBids,
    required this.wonAuctions,
    required this.bidHistory,
  });

  @override
  State<ProfileTabsWidget> createState() => _ProfileTabsWidgetState();
}

class _ProfileTabsWidgetState extends State<ProfileTabsWidget>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.h,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.2),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: AppTheme.lightTheme.colorScheme.primary,
              unselectedLabelColor: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.6),
              indicator: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: "Active Bids"),
                Tab(text: "Won Auctions"),
                Tab(text: "Bid History"),
              ],
            ),
          ),
          SizedBox(height: 2.h),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _ActiveBidsTab(activeBids: widget.activeBids),
                _WonAuctionsTab(wonAuctions: widget.wonAuctions),
                _BidHistoryTab(bidHistory: widget.bidHistory),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveBidsTab extends StatelessWidget {
  final List<Map<String, dynamic>> activeBids;

  const _ActiveBidsTab({required this.activeBids});

  @override
  Widget build(BuildContext context) {
    if (activeBids.isEmpty) {
      return _EmptyState(
        icon: 'gavel',
        title: "No Active Bids",
        subtitle: "Start bidding on auctions to see them here",
      );
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: activeBids.length,
      separatorBuilder: (context, index) => SizedBox(height: 2.h),
      itemBuilder: (context, index) {
        final bid = activeBids[index];
        return _ActiveBidCard(bid: bid);
      },
    );
  }
}

class _WonAuctionsTab extends StatelessWidget {
  final List<Map<String, dynamic>> wonAuctions;

  const _WonAuctionsTab({required this.wonAuctions});

  @override
  Widget build(BuildContext context) {
    if (wonAuctions.isEmpty) {
      return _EmptyState(
        icon: 'emoji_events',
        title: "No Won Auctions",
        subtitle: "Keep bidding to win your first auction!",
      );
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: wonAuctions.length,
      separatorBuilder: (context, index) => SizedBox(height: 2.h),
      itemBuilder: (context, index) {
        final auction = wonAuctions[index];
        return _WonAuctionCard(auction: auction);
      },
    );
  }
}

class _BidHistoryTab extends StatelessWidget {
  final List<Map<String, dynamic>> bidHistory;

  const _BidHistoryTab({required this.bidHistory});

  @override
  Widget build(BuildContext context) {
    if (bidHistory.isEmpty) {
      return _EmptyState(
        icon: 'history',
        title: "No Bid History",
        subtitle: "Your bidding activity will appear here",
      );
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: bidHistory.length,
      separatorBuilder: (context, index) => SizedBox(height: 1.h),
      itemBuilder: (context, index) {
        final bid = bidHistory[index];
        return _BidHistoryCard(bid: bid);
      },
    );
  }
}

class _ActiveBidCard extends StatelessWidget {
  final Map<String, dynamic> bid;

  const _ActiveBidCard({required this.bid});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CustomImageWidget(
              imageUrl: bid["image"] as String,
              width: 15.w,
              height: 15.w,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bid["title"] as String,
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 1.h),
                Row(
                  children: [
                    Text(
                      "Current: ${bid["currentPrice"]}",
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 2.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.secondary
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        bid["timeLeft"] as String,
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.h),
                ElevatedButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.pushNamed(context, '/auction-detail-screen');
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 5.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text("View Auction"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WonAuctionCard extends StatelessWidget {
  final Map<String, dynamic> auction;

  const _WonAuctionCard({required this.auction});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.green.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CustomImageWidget(
              imageUrl: auction["image"] as String,
              width: 15.w,
              height: 15.w,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'emoji_events',
                      color: Colors.green,
                      size: 4.w,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      "WON",
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 0.5.h),
                Text(
                  auction["title"] as String,
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 1.h),
                Row(
                  children: [
                    Text(
                      "Won for: ${auction["winPrice"]}",
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      "Saved: ${auction["savings"]}",
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurface
                            .withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                        },
                        style: OutlinedButton.styleFrom(
                          minimumSize: Size(double.infinity, 4.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text("Track Order"),
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 4.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text("Reorder"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BidHistoryCard extends StatelessWidget {
  final Map<String, dynamic> bid;

  const _BidHistoryCard({required this.bid});

  @override
  Widget build(BuildContext context) {
    final bool isWon = bid["status"] == "won";
    final bool isLost = bid["status"] == "lost";

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: CustomImageWidget(
              imageUrl: bid["image"] as String,
              width: 12.w,
              height: 12.w,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bid["title"] as String,
                  style: AppTheme.lightTheme.textTheme.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 0.5.h),
                Row(
                  children: [
                    Text(
                      "Bid: ${bid["bidAmount"]}",
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurface
                            .withValues(alpha: 0.7),
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 1.5.w, vertical: 0.2.h),
                      decoration: BoxDecoration(
                        color: isWon
                            ? Colors.green.withValues(alpha: 0.1)
                            : isLost
                                ? Colors.red.withValues(alpha: 0.1)
                                : AppTheme.lightTheme.colorScheme.primary
                                    .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        bid["status"] as String,
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: isWon
                              ? Colors.green
                              : isLost
                                  ? Colors.red
                                  : AppTheme.lightTheme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 0.5.h),
                Text(
                  bid["timestamp"] as String,
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary
                  .withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: CustomIconWidget(
              iconName: icon,
              color: AppTheme.lightTheme.colorScheme.primary
                  .withValues(alpha: 0.5),
              size: 12.w,
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            title,
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 1.h),
          Text(
            subtitle,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
