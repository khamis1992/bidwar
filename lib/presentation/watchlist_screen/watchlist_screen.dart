import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../models/auction_item.dart';
import '../../routes/app_routes.dart';
import '../../services/auction_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../auction_browse_screen/widgets/auction_card_widget.dart';

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  final AuctionService _auctionService = AuctionService.instance;
  List<AuctionItem> _watchlistedAuctions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWatchlist();
  }

  Future<void> _loadWatchlist() async {
    setState(() => _isLoading = true);

    try {
      final response = await _auctionService.getUserWatchlist();
      final auctions =
          response.map((item) => AuctionItem.fromMap(item['auction_item'])).toList();
      setState(() {
        _watchlistedAuctions = auctions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Failed to load watchlist: ${e.toString()}');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _removeFromWatchlist(String auctionId) async {
    try {
      await _auctionService.removeFromWatchlist(auctionId);
      setState(() {
        _watchlistedAuctions.removeWhere((auction) => auction.id == auctionId);
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Removed from watchlist')));
    } catch (e) {
      _showError('Failed to remove from watchlist: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Watchlist'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        foregroundColor: AppTheme.lightTheme.colorScheme.onSurface,
        automaticallyImplyLeading: false,
        actions: [
          if (_watchlistedAuctions.isNotEmpty)
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: const Text('Clear Watchlist'),
                        content: const Text(
                          'Are you sure you want to remove all items from your watchlist?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              setState(() {
                                _watchlistedAuctions.clear();
                              });
                            },
                            child: const Text('Clear All'),
                          ),
                        ],
                      ),
                );
              },
              child: const Text('Clear All'),
            ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _watchlistedAuctions.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                onRefresh: _loadWatchlist,
                child: ListView.builder(
                  padding: EdgeInsets.all(4.w),
                  itemCount: _watchlistedAuctions.length,
                  itemBuilder: (context, index) {
                    final auction = _watchlistedAuctions[index];
                    return Padding(
                      padding: EdgeInsets.only(bottom: 3.h),
                      child: Dismissible(
                        key: Key(auction.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        onDismissed: (direction) {
                          _removeFromWatchlist(auction.id);
                        },
                        child: AuctionCardWidget(
                          auction: auction,
                          onTap:
                              () => Navigator.pushNamed(
                                context,
                                AppRoutes.auctionDetail,
                                arguments: auction.id,
                              ),
                        ),
                      ),
                    );
                  },
                ),
              ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: 1, // Watchlist tab index
        onTap: (index) {
          HapticFeedback.lightImpact();
          switch (index) {
            case 0:
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.auctionBrowse,
                (route) => false,
              );
              break;
            case 1:
              // Already on watchlist screen
              break;
            case 2:
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.creditManagement,
                (route) => false,
              );
              break;
            case 3:
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.userProfile,
                (route) => false,
              );
              break;
          }
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 64.sp, color: Colors.grey),
          SizedBox(height: 2.h),
          Text(
            'Your watchlist is empty',
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Save auctions you\'re interested in to keep track of them',
            textAlign: TextAlign.center,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 3.h),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.auctionBrowse,
                (route) => false,
              );
            },
            child: const Text('Browse Auctions'),
          ),
        ],
      ),
    );
  }
}