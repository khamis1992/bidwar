import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../features/auctions/domain/entities/auction_entity.dart';

/// Auction Card Widget
///
/// بطاقة المزاد في القائمة مع Watchlist toggle
/// تتبع قواعد BidWar للتصميم
class AuctionCardWidget extends StatefulWidget {
  final AuctionEntity auction;
  final VoidCallback onTap;
  final VoidCallback onWatchlistToggle;
  final bool isInWatchlist;

  const AuctionCardWidget({
    super.key,
    required this.auction,
    required this.onTap,
    required this.onWatchlistToggle,
    this.isInWatchlist = false,
  });

  @override
  State<AuctionCardWidget> createState() => _AuctionCardWidgetState();
}

class _AuctionCardWidgetState extends State<AuctionCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _favoriteAnimationController;
  late Animation<double> _favoriteScaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _favoriteAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _favoriteScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _favoriteAnimationController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _favoriteAnimationController.dispose();
    super.dispose();
  }

  void _handleWatchlistToggle() {
    // تشغيل animation
    _favoriteAnimationController.forward().then((_) {
      _favoriteAnimationController.reverse();
    });

    widget.onWatchlistToggle();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header مع الحالة والمتابعة
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatusBadge(),
                  AnimatedBuilder(
                    animation: _favoriteScaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _favoriteScaleAnimation.value,
                        child: IconButton(
                          onPressed: _handleWatchlistToggle,
                          icon: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Icon(
                              widget.isInWatchlist
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              key: ValueKey(widget.isInWatchlist),
                              color: widget.isInWatchlist
                                  ? AppTheme.secondaryLight
                                  : AppTheme.textSecondaryLight,
                              size: 5.w,
                            ),
                          ),
                          tooltip: widget.isInWatchlist
                              ? 'Remove from watchlist'
                              : 'Add to watchlist',
                        ),
                      );
                    },
                  ),
                ],
              ),

              // صورة المزاد
              Container(
                width: double.infinity,
                height: 25.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage(widget.auction.mainImage),
                    fit: BoxFit.cover,
                    onError: (exception, stackTrace) {
                      // TODO: معالجة خطأ تحميل الصورة
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

                    // Featured badge
                    if (widget.auction.featured)
                      Positioned(
                        top: 2.w,
                        right: 2.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 2.w,
                            vertical: 1.w,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.warningLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star, size: 3.w, color: Colors.white),
                              SizedBox(width: 1.w),
                              Text(
                                'Featured',
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

                    // Time remaining (للمزادات المباشرة)
                    if (widget.auction.isLive)
                      Positioned(
                        bottom: 2.w,
                        left: 2.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 2.w,
                            vertical: 1.w,
                          ),
                          decoration: BoxDecoration(
                            color: widget.auction.isEndingSoon
                                ? AppTheme.errorLight
                                : AppTheme.successLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.timer, size: 3.w, color: Colors.white),
                              SizedBox(width: 1.w),
                              Text(
                                _formatTimeRemaining(
                                    widget.auction.timeRemaining),
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
                  ],
                ),
              ),

              SizedBox(height: 3.w),

              // عنوان المزاد
              Text(
                widget.auction.title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryLight,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              SizedBox(height: 2.w),

              // معلومات البائع والفئة
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 4.w,
                    color: AppTheme.textSecondaryLight,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    widget.auction.sellerName,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppTheme.textSecondaryLight,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Icon(
                    Icons.category_outlined,
                    size: 4.w,
                    color: AppTheme.textSecondaryLight,
                  ),
                  SizedBox(width: 1.w),
                  Expanded(
                    child: Text(
                      widget.auction.categoryName,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppTheme.textSecondaryLight,
                        fontWeight: FontWeight.w400,
                      ),
                      overflow: TextOverflow.ellipsis,
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
                        'Current Bid',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: AppTheme.textSecondaryLight,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        '\$${widget.auction.currentPrice}',
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
                        '${widget.auction.totalBids}',
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
              if (widget.auction.isLive) ...[
                SizedBox(height: 3.w),
                LinearProgressIndicator(
                  value: widget.auction.timeProgressPercentage,
                  backgroundColor: AppTheme.borderLight,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    widget.auction.isEndingSoon
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

    switch (widget.auction.status) {
      case AuctionStatus.live:
        badgeColor = AppTheme.successLight;
        statusText = 'LIVE';
        break;
      case AuctionStatus.upcoming:
        badgeColor = AppTheme.warningLight;
        statusText = 'UPCOMING';
        break;
      case AuctionStatus.ended:
        badgeColor = AppTheme.textSecondaryLight;
        statusText = 'ENDED';
        break;
      case AuctionStatus.cancelled:
        badgeColor = AppTheme.errorLight;
        statusText = 'CANCELLED';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.w),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: badgeColor.withValues(alpha: 0.3), width: 1),
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
}
