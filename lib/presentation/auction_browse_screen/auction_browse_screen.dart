import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../models/auction_item.dart';
import '../../services/auction_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/auction_grid_widget.dart';
import './widgets/category_chip_widget.dart';
import './widgets/search_bar_widget.dart';

class AuctionBrowseScreen extends StatefulWidget {
  const AuctionBrowseScreen({super.key});

  @override
  State<AuctionBrowseScreen> createState() => _AuctionBrowseScreenState();
}

class _AuctionBrowseScreenState extends State<AuctionBrowseScreen> {
  final AuctionService _auctionService = AuctionService.instance;
  final TextEditingController _searchController = TextEditingController();

  List<AuctionItem> _auctions = [];
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = true;
  String? _selectedCategory;
  String _selectedStatus = 'all';
  bool _showFeaturedOnly = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Load categories and auctions in parallel
      final results = await Future.wait([
        _auctionService.getCategories(),
        _loadAuctions(),
      ]);

      setState(() {
        _categories = results[0] as List<Map<String, dynamic>>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Failed to load data: ${e.toString()}');
    }
  }

  Future<List<AuctionItem>> _loadAuctions() async {
    try {
      final response = await _auctionService.getAuctionItems(
        categoryId: _selectedCategory,
        status: _selectedStatus == 'all' ? null : _selectedStatus,
        search: _searchController.text.trim(),
        featured: _showFeaturedOnly ? true : null,
        limit: 50,
      );

      final auctions =
          response.map((item) => AuctionItem.fromMap(item)).toList();
      setState(() => _auctions = auctions);
      return auctions;
    } catch (e) {
      _showError('Failed to load auctions: ${e.toString()}');
      return [];
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _onSearch(String query) {
    _loadAuctions();
  }

  void _onCategorySelected(String? categoryId) {
    setState(() => _selectedCategory = categoryId);
    _loadAuctions();
  }

  void _onStatusChanged(String status) {
    setState(() => _selectedStatus = status);
    _loadAuctions();
  }

  void _toggleFeaturedOnly() {
    setState(() => _showFeaturedOnly = !_showFeaturedOnly);
    _loadAuctions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'BidWar Auctions',
          style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        foregroundColor: AppTheme.lightTheme.colorScheme.onSurface,
        automaticallyImplyLeading: false,
        actions: [
          if (AuthService.instance.isLoggedIn)
            IconButton(
              onPressed:
                  () => Navigator.pushNamed(context, AppRoutes.userProfile),
              icon: const Icon(Icons.account_circle),
            ),
        ],
      ),
      body: Column(
        children: [
          // Search and filters section
          Container(
            padding: EdgeInsets.all(2.w),
            color: AppTheme.lightTheme.colorScheme.surface,
            child: Column(
              children: [
                // Search bar
                SearchBarWidget(
                  controller: _searchController,
                  onSearch: _onSearch,
                ),
                SizedBox(height: 1.h),

                // Status filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildStatusChip('All', 'all'),
                      SizedBox(width: 2.w),
                      _buildStatusChip('Live', 'live'),
                      SizedBox(width: 2.w),
                      _buildStatusChip('Upcoming', 'upcoming'),
                      SizedBox(width: 2.w),
                      _buildStatusChip('Ended', 'ended'),
                      SizedBox(width: 2.w),
                      _buildFeaturedChip(),
                    ],
                  ),
                ),
                SizedBox(height: 1.h),

                // Category chips
                if (_categories.isNotEmpty) ...[
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        CategoryChipWidget(
                          label: 'All Categories',
                          isSelected: _selectedCategory == null,
                          onSelected: () => _onCategorySelected(null),
                        ),
                        ..._categories.map(
                          (category) => Padding(
                            padding: EdgeInsets.only(left: 2.w),
                            child: CategoryChipWidget(
                              label: category['name'],
                              isSelected: _selectedCategory == category['id'],
                              onSelected:
                                  () => _onCategorySelected(category['id']),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Auctions grid
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _auctions.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                      onRefresh: _loadData,
                      child: AuctionGridWidget(
                        auctions: _auctions,
                        onAuctionTap:
                            (auction) => Navigator.pushNamed(
                              context,
                              AppRoutes.auctionDetail,
                              arguments: auction.id,
                            ),
                      ),
                    ),
          ),
        ],
      ),
      floatingActionButton:
          AuthService.instance.isLoggedIn
              ? FloatingActionButton.extended(
                onPressed:
                    () => Navigator.pushNamed(context, '/create-auction'),
                icon: const Icon(Icons.add),
                label: const Text('Create Auction'),
              )
              : null,
      bottomNavigationBar: CustomBottomBar(
        currentIndex: 0, // Auctions tab index
        onTap: (index) {
          HapticFeedback.lightImpact();
          switch (index) {
            case 0:
              // Already on auctions screen
              break;
            case 1:
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.watchlist,
                (route) => false,
              );
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

  Widget _buildStatusChip(String label, String value) {
    final isSelected = _selectedStatus == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) => _onStatusChanged(value),
      selectedColor: AppTheme.lightTheme.colorScheme.primary.withAlpha(51),
      checkmarkColor: AppTheme.lightTheme.colorScheme.primary,
    );
  }

  Widget _buildFeaturedChip() {
    return FilterChip(
      label: const Text('Featured Only'),
      selected: _showFeaturedOnly,
      onSelected: (selected) => _toggleFeaturedOnly(),
      selectedColor: Colors.orange.withAlpha(51),
      checkmarkColor: Colors.orange,
      avatar: Icon(
        Icons.star,
        size: 16.sp,
        color: _showFeaturedOnly ? Colors.orange : null,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64.sp, color: Colors.grey),
          SizedBox(height: 2.h),
          Text(
            'No auctions found',
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Try adjusting your search or filters',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 3.h),
          ElevatedButton(
            onPressed: () {
              _searchController.clear();
              setState(() {
                _selectedCategory = null;
                _selectedStatus = 'all';
                _showFeaturedOnly = false;
              });
              _loadAuctions();
            },
            child: const Text('Clear Filters'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
