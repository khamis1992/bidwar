import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import './controllers/auction_details_controller.dart';
import './widgets/auction_image_widget.dart';
import './widgets/auction_info_widget.dart';
import './widgets/bid_form_widget.dart';
import './widgets/bid_history_widget.dart';
import './widgets/countdown_timer_widget.dart';

/// Auction Details Screen - صفحة تفاصيل المزاد
///
/// تعرض تفاصيل المزاد مع Realtime updates
/// تتبع قواعد BidWar للتصميم والبنية
class AuctionDetailsScreen extends StatefulWidget {
  final String auctionId;

  const AuctionDetailsScreen({super.key, required this.auctionId});

  @override
  State<AuctionDetailsScreen> createState() => _AuctionDetailsScreenState();
}

class _AuctionDetailsScreenState extends State<AuctionDetailsScreen>
    with TickerProviderStateMixin {
  late AuctionDetailsController _controller;
  late AnimationController _pulseAnimationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AuctionDetailsController(auctionId: widget.auctionId);
    _setupAnimations();
    _initializeScreen();
  }

  void _setupAnimations() {
    _pulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _pulseAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _pulseAnimationController.repeat(reverse: true);
  }

  Future<void> _initializeScreen() async {
    try {
      await _controller.initialize();
      _controller.addListener(_onControllerUpdate);
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      _showError('Failed to load auction details: $e');
    }
  }

  void _onControllerUpdate() {
    if (mounted) {
      setState(() {});

      // إذا تم تحديث السعر، شغّل animation للإشارة للتحديث
      if (_controller.auction?.isLive == true) {
        _pulseAnimationController.forward().then((_) {
          _pulseAnimationController.reverse();
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    _pulseAnimationController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorLight,
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: () => _controller.refreshAuction(),
        ),
      ),
    );
  }

  void _showBidSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 2.w),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.successLight,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _handlePlaceBid(int bidAmount) async {
    try {
      final user = AuthService.instance.currentUser;
      if (user == null) {
        _showLoginRequiredDialog();
        return;
      }

      final result = await _controller.placeBid(
        bidderId: user.id,
        amount: bidAmount,
      );

      if (result.success) {
        _showBidSuccess(result.message);
      } else {
        _showError(result.message);
      }
    } catch (e) {
      _showError('Failed to place bid: $e');
    }
  }

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Login Required'),
        content: Text('You need to sign in to place a bid.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/auth');
            },
            child: Text('Sign In'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auction = _controller.auction;

    if (_controller.isLoading && auction == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Auction Details'),
          backgroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 15.w,
                height: 15.w,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.primaryLight,
                  ),
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                'Loading auction details...',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppTheme.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (auction == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Auction Details'),
          backgroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 20.w, color: AppTheme.errorLight),
              SizedBox(height: 3.h),
              Text(
                'Auction not found',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.errorLight,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                'The auction you\'re looking for doesn\'t exist or has been removed.',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppTheme.textSecondaryLight,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4.h),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          'Auction Details',
          style: TextStyle(
            color: AppTheme.primaryLight,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          // Watchlist Toggle
          IconButton(
            onPressed: () => _controller.toggleWatchlist(),
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                _controller.isInWatchlist
                    ? Icons.bookmark
                    : Icons.bookmark_border,
                key: ValueKey(_controller.isInWatchlist),
                color: _controller.isInWatchlist
                    ? AppTheme.secondaryLight
                    : AppTheme.textSecondaryLight,
              ),
            ),
          ),

          // Share Button
          IconButton(
            onPressed: _shareAuction,
            icon: Icon(Icons.share, color: AppTheme.textSecondaryLight),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _controller.refreshAuction,
        color: AppTheme.primaryLight,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // صورة المزاد
              AuctionImageWidget(auction: auction),

              // معلومات أساسية
              Padding(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // عنوان ووصف
                    AuctionInfoWidget(auction: auction),

                    SizedBox(height: 4.h),

                    // السعر الحالي مع Animation
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: auction.isLive ? _pulseAnimation.value : 1.0,
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(4.w),
                            decoration: BoxDecoration(
                              color: auction.isLive
                                  ? AppTheme.successLight.withValues(
                                      alpha: 0.1,
                                    )
                                  : AppTheme.borderLight.withValues(
                                      alpha: 0.3,
                                    ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: auction.isLive
                                    ? AppTheme.successLight
                                    : AppTheme.borderLight,
                                width: 2,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Current Bid',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: AppTheme.textSecondaryLight,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      '\$${auction.currentPrice}',
                                      style: TextStyle(
                                        fontSize: 24.sp,
                                        color: AppTheme.primaryLight,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                                if (auction.isLive)
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 3.w,
                                      vertical: 1.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.successLight,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.flash_on,
                                          color: Colors.white,
                                          size: 4.w,
                                        ),
                                        SizedBox(width: 1.w),
                                        Text(
                                          'LIVE',
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: 4.h),

                    // Countdown Timer (للمزادات النشطة)
                    if (auction.isLive || auction.isUpcoming)
                      CountdownTimerWidget(
                        auction: auction,
                        onTimeExpired: () => _controller.refreshAuction(),
                      ),

                    SizedBox(height: 4.h),

                    // Bid Form (للمزادات النشطة فقط)
                    if (auction.canBid && AuthService.instance.isLoggedIn)
                      BidFormWidget(
                        auction: auction,
                        isLoading: _controller.isBidding,
                        onPlaceBid: _handlePlaceBid,
                      ),

                    // Login prompt للمستخدمين غير المسجلين
                    if (auction.canBid && !AuthService.instance.isLoggedIn)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: AppTheme.warningLight.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.warningLight.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.login,
                              size: 8.w,
                              color: AppTheme.warningLight,
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'Sign in to place a bid',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.warningLight,
                              ),
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              'Join BidWar to participate in this auction',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppTheme.textSecondaryLight,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 3.h),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () =>
                                    Navigator.pushNamed(context, '/auth'),
                                child: Text('Sign In / Sign Up'),
                              ),
                            ),
                          ],
                        ),
                      ),

                    SizedBox(height: 4.h),

                    // Bid History
                    BidHistoryWidget(
                      bids: _controller.bids,
                      isLoading: _controller.isLoadingBids,
                      onRefresh: _controller.refreshBids,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // Floating Action Button للمزايدة السريعة
      floatingActionButton: auction.canBid && AuthService.instance.isLoggedIn
          ? FloatingActionButton.extended(
              onPressed: () => _showQuickBidDialog(),
              backgroundColor: AppTheme.secondaryLight,
              foregroundColor: Colors.white,
              icon: Icon(Icons.gavel),
              label: Text('Quick Bid'),
            )
          : null,
    );
  }

  void _showQuickBidDialog() {
    final auction = _controller.auction!;
    final quickBidAmount = auction.nextMinimumBid;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Quick Bid'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Place a bid for the minimum amount?',
              style: TextStyle(fontSize: 14.sp),
            ),
            SizedBox(height: 3.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    'Bid Amount',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppTheme.textSecondaryLight,
                    ),
                  ),
                  Text(
                    '\$${quickBidAmount}',
                    style: TextStyle(
                      fontSize: 20.sp,
                      color: AppTheme.primaryLight,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _controller.isBidding
                ? null
                : () {
                    Navigator.pop(context);
                    _handlePlaceBid(quickBidAmount);
                  },
            child: _controller.isBidding
                ? SizedBox(
                    width: 4.w,
                    height: 4.w,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text('Place Bid'),
          ),
        ],
      ),
    );
  }

  void _shareAuction() {
    // TODO: تنفيذ مشاركة المزاد
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Share feature coming soon')));
  }
}
