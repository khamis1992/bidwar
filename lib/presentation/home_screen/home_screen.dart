import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import './controllers/home_controller.dart';
import './widgets/auction_list_widget.dart';
import './widgets/home_app_bar_widget.dart';
import './widgets/home_bottom_bar_widget.dart';
import './widgets/search_filter_widget.dart';

/// Home Screen - قائمة المزادات الرئيسية
///
/// تعرض المزادات النشطة مع تبويبات
/// تتبع قواعد BidWar للتصميم والبنية
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late HomeController _controller;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _controller = HomeController();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    try {
      await _controller.initialize();
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      _showError('Failed to load auctions: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _controller.dispose();
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
          onPressed: () => _controller.refreshAuctions(),
        ),
      ),
    );
  }

  void _onTabChanged() {
    final index = _tabController.index;
    switch (index) {
      case 0:
        _controller.loadLiveAuctions();
        break;
      case 1:
        _controller.loadUpcomingAuctions();
        break;
      case 2:
        _controller.loadEndedAuctions();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: HomeAppBarWidget(
        onSearch: _controller.searchAuctions,
        onProfileTap: _navigateToProfile,
        onNotificationsTap: _navigateToNotifications,
      ),
      body: Column(
        children: [
          // Search & Filter Section
          SearchFilterWidget(
            onSearch: _controller.searchAuctions,
            onFilterChanged: _controller.applyFilters,
            categories: _controller.categories,
          ),

          // Tab Bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              onTap: (_) => _onTabChanged(),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.flash_on, size: 4.w),
                      SizedBox(width: 1.w),
                      Text('Live'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.schedule, size: 4.w),
                      SizedBox(width: 1.w),
                      Text('Upcoming'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 4.w),
                      SizedBox(width: 1.w),
                      Text('Ended'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Auction Lists
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Live Auctions
                AuctionListWidget(
                  auctions: _controller.liveAuctions,
                  isLoading: _controller.isLoading,
                  onRefresh: _controller.refreshAuctions,
                  onAuctionTap: _navigateToAuctionDetail,
                  onWatchlistToggle: _controller.toggleWatchlist,
                  watchlistAuctionIds: _controller.watchlistAuctionIds,
                  emptyMessage: 'No live auctions at the moment',
                  emptyIcon: Icons.flash_off,
                ),

                // Upcoming Auctions
                AuctionListWidget(
                  auctions: _controller.upcomingAuctions,
                  isLoading: _controller.isLoading,
                  onRefresh: _controller.refreshAuctions,
                  onAuctionTap: _navigateToAuctionDetail,
                  onWatchlistToggle: _controller.toggleWatchlist,
                  watchlistAuctionIds: _controller.watchlistAuctionIds,
                  emptyMessage: 'No upcoming auctions scheduled',
                  emptyIcon: Icons.schedule,
                ),

                // Ended Auctions
                AuctionListWidget(
                  auctions: _controller.endedAuctions,
                  isLoading: _controller.isLoading,
                  onRefresh: _controller.refreshAuctions,
                  onAuctionTap: _navigateToAuctionDetail,
                  onWatchlistToggle: _controller.toggleWatchlist,
                  watchlistAuctionIds: _controller.watchlistAuctionIds,
                  emptyMessage: 'No ended auctions to display',
                  emptyIcon: Icons.history,
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: HomeBottomBarWidget(
        currentIndex: 0, // Home is selected
        onTap: _onBottomNavTap,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCreateAuction,
        backgroundColor: AppTheme.secondaryLight,
        foregroundColor: Colors.white,
        icon: Icon(Icons.add),
        label: Text('Create Auction'),
      ),
    );
  }

  void _navigateToAuctionDetail(String auctionId) {
    Navigator.pushNamed(
      context,
      AppRoutes.auctionDetail,
      arguments: {'auctionId': auctionId},
    );
  }

  void _navigateToProfile() {
    Navigator.pushNamed(context, AppRoutes.userProfile);
  }

  void _navigateToNotifications() {
    // TODO: تنفيذ شاشة الإشعارات
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Notifications screen coming soon')));
  }

  void _navigateToCreateAuction() {
    if (!AuthService.instance.isLoggedIn) {
      _showLoginRequiredDialog();
      return;
    }

    Navigator.pushNamed(context, AppRoutes.createAuction);
  }

  void _onBottomNavTap(int index) {
    switch (index) {
      case 0:
        // Home - نحن هنا بالفعل
        break;
      case 1:
        Navigator.pushNamed(context, AppRoutes.myWatchlist);
        break;
      case 2:
        Navigator.pushNamed(context, AppRoutes.userProfile);
        break;
      case 3:
        Navigator.pushNamed(context, AppRoutes.creditManagement);
        break;
    }
  }

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Login Required'),
        content: Text('You need to sign in to create an auction.'),
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
}
