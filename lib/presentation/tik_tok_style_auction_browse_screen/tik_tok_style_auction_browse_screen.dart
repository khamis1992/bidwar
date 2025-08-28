import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../models/auction_item.dart';
import '../../routes/app_routes.dart';
import '../../services/auction_service.dart';
import '../../services/auth_service.dart';
import './widgets/auction_info_overlay_widget.dart';
import './widgets/side_action_panel_widget.dart';
import './widgets/tik_tok_auction_page_widget.dart';

class TikTokStyleAuctionBrowseScreen extends StatefulWidget {
  const TikTokStyleAuctionBrowseScreen({super.key});

  @override
  State<TikTokStyleAuctionBrowseScreen> createState() =>
      _TikTokStyleAuctionBrowseScreenState();
}

class _TikTokStyleAuctionBrowseScreenState
    extends State<TikTokStyleAuctionBrowseScreen>
    with TickerProviderStateMixin {
  final AuctionService _auctionService = AuctionService.instance;
  final PageController _pageController = PageController();

  List<AuctionItem> _auctions = [];
  bool _isLoading = true;
  int _currentIndex = 0;
  bool _isLoadingMore = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadAuctions();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
  }

  Future<void> _loadAuctions() async {
    setState(() => _isLoading = true);

    try {
      final response = await _auctionService.getAuctionItems(
        status: null, // Show all statuses for variety
        limit: 20,
        offset: 0,
      );

      final auctions =
          response.map((item) => AuctionItem.fromMap(item)).toList();

      setState(() {
        _auctions = auctions;
        _isLoading = false;
      });

      _animationController.forward();
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Failed to load auctions: ${e.toString()}');
    }
  }

  Future<void> _loadMoreAuctions() async {
    if (_isLoadingMore) return;

    setState(() => _isLoadingMore = true);

    try {
      final response = await _auctionService.getAuctionItems(
        status: null,
        limit: 10,
        offset: _auctions.length,
      );

      final newAuctions =
          response.map((item) => AuctionItem.fromMap(item)).toList();

      setState(() {
        _auctions.addAll(newAuctions);
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() => _isLoadingMore = false);
      _showError('Failed to load more auctions');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
      ),
    );
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);

    // Load more auctions when approaching the end
    if (index >= _auctions.length - 3) {
      _loadMoreAuctions();
    }

    // Haptic feedback for page changes
    HapticFeedback.selectionClick();
  }

  Future<void> _handleBid(AuctionItem auction) async {
    if (!AuthService.instance.isLoggedIn) {
      _showLoginPrompt();
      return;
    }

    _showBiddingDialog(auction);
  }

  void _showLoginPrompt() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Required'),
        content: const Text('Please log in to place bids on auctions.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.login);
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  void _showBiddingDialog(AuctionItem auction) {
    final TextEditingController bidController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 50.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.sp),
            topRight: Radius.circular(20.sp),
          ),
        ),
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            Container(
              width: 10.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10.sp),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Place Bid',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              auction.title,
              style: TextStyle(fontSize: 16.sp),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10.sp),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Current Highest Bid:'),
                      Text(
                        '\$${auction.currentHighestBid}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Minimum Bid:'),
                      Text(
                        '\$${auction.nextMinimumBid}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 3.h),
            TextField(
              controller: bidController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Your Bid Amount',
                prefixText: '\$ ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.sp),
                ),
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _placeBid(auction, bidController.text),
                    child: const Text('Place Bid'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _placeBid(AuctionItem auction, String bidText) async {
    final bidAmount = int.tryParse(bidText);
    if (bidAmount == null || bidAmount < auction.nextMinimumBid) {
      _showError('Invalid bid amount');
      return;
    }

    try {
      Navigator.pop(context); // Close dialog

      await _auctionService.placeBid(
        auctionItemId: auction.id,
        bidAmount: bidAmount,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bid placed successfully!'),
          backgroundColor: Colors.green.shade600,
        ),
      );

      // Refresh current auction data
      _refreshCurrentAuction();
    } catch (e) {
      _showError('Failed to place bid: ${e.toString()}');
    }
  }

  Future<void> _refreshCurrentAuction() async {
    if (_auctions.isEmpty || _currentIndex >= _auctions.length) return;

    try {
      final auction = _auctions[_currentIndex];
      final updatedAuction = await _auctionService.getAuctionItem(auction.id);

      if (updatedAuction != null) {
        setState(() {
          _auctions[_currentIndex] = AuctionItem.fromMap(updatedAuction);
        });
      }
    } catch (e) {
      // Silent fail for refresh
    }
  }

  Future<void> _toggleWatchlist(AuctionItem auction) async {
    if (!AuthService.instance.isLoggedIn) {
      _showLoginPrompt();
      return;
    }

    try {
      final isInWatchlist = await _auctionService.isInWatchlist(auction.id);

      if (isInWatchlist) {
        await _auctionService.removeFromWatchlist(auction.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Removed from watchlist')),
        );
      } else {
        await _auctionService.addToWatchlist(auction.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Added to watchlist')),
        );
      }

      HapticFeedback.lightImpact();
    } catch (e) {
      _showError('Failed to update watchlist');
    }
  }

  void _viewAuctionDetails(AuctionItem auction) {
    Navigator.pushNamed(
      context,
      AppRoutes.auctionDetail,
      arguments: auction.id,
    );
  }

  void _shareAuction(AuctionItem auction) {
    // Basic share functionality - in production you'd use share_plus package
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing: ${auction.title}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 2.h),
              Text(
                'Loading Auctions...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_auctions.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.gavel_outlined,
                size: 80.sp,
                color: Colors.white54,
              ),
              SizedBox(height: 2.h),
              Text(
                'No auctions available',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                'Check back later for new auctions',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: PageView.builder(
          controller: _pageController,
          scrollDirection: Axis.vertical,
          onPageChanged: _onPageChanged,
          itemCount: _auctions.length,
          itemBuilder: (context, index) {
            final auction = _auctions[index];

            return Stack(
              fit: StackFit.expand,
              children: [
                // Main auction content
                TikTokAuctionPageWidget(
                  auction: auction,
                  onDoubleTap: () => _handleBid(auction),
                ),

                // Side action panel (right side)
                Positioned(
                  right: 2.w,
                  bottom: 20.h,
                  child: SideActionPanelWidget(
                    auction: auction,
                    onBid: () => _handleBid(auction),
                    onWatchlist: () => _toggleWatchlist(auction),
                    onShare: () => _shareAuction(auction),
                    onViewDetails: () => _viewAuctionDetails(auction),
                  ),
                ),

                // Auction info overlay (bottom)
                Positioned(
                  left: 3.w,
                  right: 15.w, // Leave space for side panel
                  bottom: 10.h,
                  child: AuctionInfoOverlayWidget(
                    auction: auction,
                  ),
                ),

                // Top safe area with back button
                SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(4.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: EdgeInsets.all(2.w),
                            decoration: BoxDecoration(
                              color: Colors.black.withAlpha(77),
                              borderRadius: BorderRadius.circular(20.sp),
                            ),
                            child: Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 24.sp,
                            ),
                          ),
                        ),
                        Text(
                          'Auctions',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 40), // Balance the back button
                      ],
                    ),
                  ),
                ),

                // Loading more indicator
                if (_isLoadingMore && index >= _auctions.length - 1)
                  Positioned(
                    bottom: 5.h,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 1.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(179),
                          borderRadius: BorderRadius.circular(20.sp),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 4.w,
                              height: 4.w,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              'Loading more...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}