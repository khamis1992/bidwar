import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import './controllers/my_watchlist_controller.dart';
import './widgets/watchlist_item_widget.dart';
import './widgets/watchlist_stats_widget.dart';

/// My Watchlist Screen - صفحة قائمة المتابعة
///
/// تعرض المزادات المتابعة مع إحصائيات
/// تتبع قواعد BidWar للتصميم والبنية
class MyWatchlistScreen extends StatefulWidget {
  const MyWatchlistScreen({super.key});

  @override
  State<MyWatchlistScreen> createState() => _MyWatchlistScreenState();
}

class _MyWatchlistScreenState extends State<MyWatchlistScreen>
    with SingleTickerProviderStateMixin {
  late MyWatchlistController _controller;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _controller = MyWatchlistController();
    _tabController = TabController(length: 2, vsync: this);
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    // التحقق من تسجيل الدخول
    if (!AuthService.instance.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showLoginRequiredDialog();
      });
      return;
    }

    try {
      await _controller.initialize();
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      _showError('Failed to load watchlist: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _tabController.dispose();
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
          onPressed: () => _controller.refreshWatchlist(),
        ),
      ),
    );
  }

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Login Required'),
        content: Text('You need to sign in to view your watchlist.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // العودة للصفحة السابقة
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/auth');
            },
            child: Text('Sign In'),
          ),
        ],
      ),
    );
  }

  void _onTabChanged() {
    final index = _tabController.index;
    switch (index) {
      case 0:
        _controller.loadActiveWatchlist();
        break;
      case 1:
        _controller.loadAllWatchlist();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          'My Watchlist',
          style: TextStyle(
            color: AppTheme.primaryLight,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          // Clear All Button
          if (_controller.watchlistItems.isNotEmpty)
            TextButton.icon(
              onPressed: _showClearAllDialog,
              icon: Icon(Icons.clear_all, size: 4.w),
              label: Text('Clear'),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.errorLight,
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Stats Widget
          WatchlistStatsWidget(
            totalItems: _controller.watchlistItems.length,
            activeItems: _controller.activeWatchlistItems.length,
            endingSoonCount: _controller.endingSoonCount,
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
                      Text('Active'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 4.w),
                      SizedBox(width: 1.w),
                      Text('All'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Watchlist Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Active Watchlist
                _buildWatchlistTab(
                  items: _controller.activeWatchlistItems,
                  emptyMessage: 'No active auctions in your watchlist',
                  emptyIcon: Icons.flash_off,
                ),

                // All Watchlist
                _buildWatchlistTab(
                  items: _controller.watchlistItems,
                  emptyMessage: 'Your watchlist is empty',
                  emptyIcon: Icons.bookmark_border,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWatchlistTab({
    required List<dynamic> items, // WatchlistEntity
    required String emptyMessage,
    required IconData emptyIcon,
  }) {
    if (_controller.isLoading && items.isEmpty) {
      return _buildLoadingState();
    }

    if (items.isEmpty) {
      return _buildEmptyState(emptyMessage, emptyIcon);
    }

    return RefreshIndicator(
      onRefresh: _controller.refreshWatchlist,
      color: AppTheme.primaryLight,
      child: ListView.builder(
        padding: EdgeInsets.all(4.w),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final watchlistItem = items[index];

          return Padding(
            padding: EdgeInsets.only(bottom: 3.h),
            child: WatchlistItemWidget(
              watchlistItem: watchlistItem,
              onTap: () =>
                  _navigateToAuctionDetail(watchlistItem.auctionItemId),
              onRemove: () =>
                  _controller.removeFromWatchlist(watchlistItem.auctionItemId),
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
            width: 15.w,
            height: 15.w,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryLight),
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            'Loading your watchlist...',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppTheme.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 25.w,
            height: 25.w,
            decoration: BoxDecoration(
              color: AppTheme.borderLight.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              size: 12.w,
              color: AppTheme.textSecondaryLight,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            message,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2.h),
          Text(
            'Start adding auctions to your watchlist by tapping the heart icon on any auction.',
            style: TextStyle(
              fontSize: 12.sp,
              color: AppTheme.textSecondaryLight.withValues(alpha: 0.7),
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 6.h),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/home'),
            icon: Icon(Icons.explore),
            label: Text('Browse Auctions'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
            ),
          ),
        ],
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

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear Watchlist'),
        content: Text(
          'Are you sure you want to remove all items from your watchlist? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _controller.clearWatchlist();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Watchlist cleared successfully'),
                    backgroundColor: AppTheme.successLight,
                  ),
                );
              } catch (e) {
                _showError('Failed to clear watchlist: $e');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorLight,
            ),
            child: Text('Clear All'),
          ),
        ],
      ),
    );
  }
}
