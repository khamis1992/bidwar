import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../services/seller_rating_service.dart';
import '../../services/supabase_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/rating_breakdown_widget.dart';
import './widgets/review_filters_widget.dart';
import './widgets/reviews_list_widget.dart';
import './widgets/seller_profile_header_widget.dart';
import './widgets/write_review_dialog_widget.dart';

class SellerRatingReviewSystem extends StatefulWidget {
  const SellerRatingReviewSystem({super.key});

  @override
  State<SellerRatingReviewSystem> createState() =>
      _SellerRatingReviewSystemState();
}

class _SellerRatingReviewSystemState extends State<SellerRatingReviewSystem> {
  final _sellerRatingService = SellerRatingService();
  bool _isLoading = true;
  String? _error;
  String? _sellerId;

  Map<String, dynamic> _sellerData = {};
  Map<String, dynamic> _ratingStats = {};
  List<dynamic> _reviews = [];

  // Filter state
  String _selectedRating = 'all';
  String _selectedSort = 'recent';
  String _selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _extractArguments();
    });
  }

  void _extractArguments() {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      _sellerId = args['seller_id'] as String?;
    } else if (args is String) {
      _sellerId = args;
    }

    if (_sellerId != null) {
      _loadSellerData();
    } else {
      // Load current user's seller profile if no seller ID provided
      final currentUser = SupabaseService.instance.client.auth.currentUser;
      if (currentUser != null) {
        _sellerId = currentUser.id;
        _loadSellerData();
      } else {
        setState(() {
          _error = 'Authentication required';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadSellerData() async {
    if (_sellerId == null || !mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        _sellerRatingService.getSellerProfile(_sellerId!),
        _sellerRatingService.getSellerRatingStats(_sellerId!),
        _sellerRatingService.getSellerReviews(
          _sellerId!,
          rating: _selectedRating,
          sortBy: _selectedSort,
          category: _selectedCategory,
        ),
      ]);

      if (mounted) {
        setState(() {
          _sellerData = results[0] as Map<String, dynamic>;
          _ratingStats = results[1] as Map<String, dynamic>;
          _reviews = results[2] as List<dynamic>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load seller data: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshData() async {
    await _loadSellerData();
  }

  void _showWriteReviewDialog() {
    if (_sellerId == null) return;

    showDialog(
      context: context,
      builder: (context) => WriteReviewDialogWidget(
        sellerId: _sellerId!,
        onReviewSubmitted: () {
          Navigator.of(context).pop();
          _refreshData();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Review submitted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        },
      ),
    );
  }

  void _onFiltersChanged({
    String? rating,
    String? sort,
    String? category,
  }) {
    setState(() {
      _selectedRating = rating ?? _selectedRating;
      _selectedSort = sort ?? _selectedSort;
      _selectedCategory = category ?? _selectedCategory;
    });
    _loadSellerData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: const CustomBottomBar(currentIndex: 2),
      floatingActionButton: _buildWriteReviewFab(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return CustomAppBar(
      title: "Seller Reviews",
      centerTitle: true,
      backgroundColor: Theme.of(context).primaryColor,
      actions: [
        IconButton(
          onPressed: _refreshData,
          icon: const Icon(Icons.refresh, color: Colors.white),
        ),
      ],
    );
  }

  Widget? _buildWriteReviewFab() {
    final currentUser = SupabaseService.instance.client.auth.currentUser;
    if (currentUser == null || currentUser.id == _sellerId) {
      return null; // Don't show FAB if not authenticated or viewing own profile
    }

    return FloatingActionButton.extended(
      onPressed: _showWriteReviewDialog,
      icon: const Icon(Icons.rate_review),
      label: const Text('Write Review'),
      backgroundColor: Theme.of(context).primaryColor,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64.h,
              color: Colors.grey,
            ),
            SizedBox(height: 16.h),
            Text(
              _error!,
              style: TextStyle(
                fontSize: 16.h,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: _refreshData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SellerProfileHeaderWidget(
              sellerData: _sellerData,
              ratingStats: _ratingStats,
            ),
            SizedBox(height: 16.h),
            RatingBreakdownWidget(
              ratingStats: _ratingStats,
            ),
            SizedBox(height: 16.h),
            ReviewFiltersWidget(
              selectedRating: _selectedRating,
              selectedSort: _selectedSort,
              selectedCategory: _selectedCategory,
              onFiltersChanged: _onFiltersChanged,
            ),
            SizedBox(height: 16.h),
            ReviewsListWidget(
              reviews: _reviews,
              onReviewAction: (action, reviewId) {
                _handleReviewAction(action, reviewId);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleReviewAction(String action, String reviewId) async {
    try {
      switch (action) {
        case 'helpful':
          await _sellerRatingService.markReviewHelpful(reviewId);
          break;
        case 'report':
          await _sellerRatingService.reportReview(reviewId);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Review reported for moderation'),
              backgroundColor: Colors.orange,
            ),
          );
          break;
        case 'respond':
          _showRespondDialog(reviewId);
          break;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Action failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showRespondDialog(String reviewId) {
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Respond to Review'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Your response will be visible to all customers. Keep it professional and helpful.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: textController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Write your response...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (textController.text.trim().isEmpty) return;

              try {
                await _sellerRatingService.respondToReview(
                  reviewId,
                  textController.text.trim(),
                );
                Navigator.of(context).pop();
                _refreshData();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Response posted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to post response: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Post Response'),
          ),
        ],
      ),
    );
  }
}