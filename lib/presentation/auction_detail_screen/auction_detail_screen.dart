import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../models/auction_item.dart';
import '../../services/auction_service.dart';
import '../../services/auth_service.dart';
import './widgets/auction_image_carousel.dart';
import './widgets/auction_price_timer.dart';
import './widgets/bid_history_list.dart';
import './widgets/bidding_section.dart';
import './widgets/product_specifications.dart';

class AuctionDetailScreen extends StatefulWidget {
  const AuctionDetailScreen({super.key});

  @override
  State<AuctionDetailScreen> createState() => _AuctionDetailScreenState();
}

class _AuctionDetailScreenState extends State<AuctionDetailScreen> {
  final AuctionService _auctionService = AuctionService.instance;
  String? _auctionId;
  AuctionItem? _auction;
  bool _isLoading = true;
  bool _isInWatchlist = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _auctionId = ModalRoute.of(context)!.settings.arguments as String?;
    if (_auctionId != null) {
      _loadAuctionDetails();
      _checkWatchlistStatus();
    }
  }

  Future<void> _loadAuctionDetails() async {
    try {
      final response = await _auctionService.getAuctionItem(_auctionId!);
      if (response != null) {
        setState(() {
          _auction = AuctionItem.fromMap(response);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Failed to load auction details: ${e.toString()}');
    }
  }

  Future<void> _checkWatchlistStatus() async {
    if (!AuthService.instance.isLoggedIn) return;

    try {
      final isInWatchlist = await _auctionService.isInWatchlist(_auctionId!);
      setState(() => _isInWatchlist = isInWatchlist);
    } catch (e) {
      // Silent fail for watchlist status
    }
  }

  Future<void> _toggleWatchlist() async {
    if (!AuthService.instance.isLoggedIn) {
      _showError('Please sign in to manage your watchlist');
      return;
    }

    try {
      if (_isInWatchlist) {
        await _auctionService.removeFromWatchlist(_auctionId!);
        setState(() => _isInWatchlist = false);
        _showSuccess('Removed from watchlist');
      } else {
        await _auctionService.addToWatchlist(_auctionId!);
        setState(() => _isInWatchlist = true);
        _showSuccess('Added to watchlist');
      }
    } catch (e) {
      _showError('Failed to update watchlist: ${e.toString()}');
    }
  }

  void _onBidPlaced() {
    // Refresh auction details after successful bid
    _loadAuctionDetails();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_auction == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: Text('Auction not found'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _auction!.title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _toggleWatchlist,
            icon: Icon(
              _isInWatchlist ? Icons.favorite : Icons.favorite_border,
              color: _isInWatchlist ? Colors.red : null,
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'share':
                  // TODO: Implement share functionality
                  break;
                case 'report':
                  // TODO: Implement report functionality
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'share',
                child: ListTile(
                  leading: Icon(Icons.share),
                  title: Text('Share'),
                  dense: true,
                ),
              ),
              const PopupMenuItem(
                value: 'report',
                child: ListTile(
                  leading: Icon(Icons.report),
                  title: Text('Report'),
                  dense: true,
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image carousel
            AuctionImageCarousel(images: _auction!.images, productTitle: _auction!.title),

            // Price and timer section
            AuctionPriceTimer(
              currentPrice: _auction!.currentPrice.toDouble(),
              endTime: _auction!.endTime,
              isActive: _auction!.isLive,
            ),

            // Basic info
            Container(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and category
                  Text(
                    _auction!.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 1.h),

                  Row(
                    children: [
                      Chip(
                        label: Text(_auction!.categoryName),
                        backgroundColor:
                            Theme.of(context).colorScheme.primary.withAlpha(26),
                      ),
                      SizedBox(width: 2.w),
                      if (_auction!.condition != null)
                        Chip(
                          label: Text('Condition: ${_auction!.condition}'),
                          backgroundColor: Colors.grey[100],
                        ),
                      SizedBox(width: 2.w),
                      if (_auction!.featured)
                        Chip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star,
                                  size: 16.sp, color: Colors.orange),
                              SizedBox(width: 1.w),
                              const Text('Featured'),
                            ],
                          ),
                          backgroundColor: Colors.orange.withAlpha(26),
                        ),
                    ],
                  ),

                  SizedBox(height: 2.h),

                  // Description
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    _auction!.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),

                  SizedBox(height: 2.h),

                  // Seller info
                  Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundImage: NetworkImage(
                            _auction!.seller?['profile_picture_url'] ??
                                'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100&h=100&fit=crop&crop=face',
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    _auction!.sellerName,
                                    style: Theme.of(context).textTheme.titleMedium
                                        ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (_auction!.seller?['is_verified'] ==
                                      true) ...[
                                    SizedBox(width: 1.w),
                                    Icon(
                                      Icons.verified,
                                      size: 16.sp,
                                      color: Colors.blue,
                                    ),
                                  ],
                                ],
                              ),
                              Text(
                                'Seller',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // TODO: Navigate to seller profile
                          },
                          child: const Text('View Profile'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Specifications
            if (_auction!.brand != null ||
                _auction!.model != null ||
                _auction!.specifications != null)
              ProductSpecifications(productData: {
                'title': _auction!.title,
                'condition': _auction!.condition,
                'category': _auction!.categoryName,
                'description': _auction!.description,
                'specifications': _auction!.specifications ?? {},
                'retailValue': _auction!.estimatedValue ?? 0.0,
                'currentPrice': _auction!.currentPrice,
              }),

            // Bidding section
            if (_auction!.isLive || _auction!.isUpcoming)
              BiddingSection(
                userCredits: 50, // placeholder value
                currentPrice: _auction!.currentPrice.toDouble(),
                isAuctionActive: _auction!.isLive,
                isUserWinning: false, // placeholder value
                onBidPlaced: _onBidPlaced,
                isWatchlisted: _isInWatchlist,
              ),

            // Bid history
            BidHistoryList(bidHistory: _auction!.bidHistory ?? []),

            SizedBox(height: 10.h), // Bottom spacing
          ],
        ),
      ),
    );
  }
}