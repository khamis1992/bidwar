import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../models/auction_item.dart';
import '../../services/auction_service.dart';
import '../../services/auth_service.dart';
import '../../services/live_stream_service.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/auction_type_tab_widget.dart';
import './widgets/category_chip_widget.dart';
import './widgets/enhanced_auction_grid_widget.dart';
import './widgets/search_bar_widget.dart';

class AuctionBrowseScreen extends StatefulWidget {
  const AuctionBrowseScreen({super.key});

  @override
  State<AuctionBrowseScreen> createState() => _AuctionBrowseScreenState();
}

class _AuctionBrowseScreenState extends State<AuctionBrowseScreen>
    with TickerProviderStateMixin {
  final AuctionService _auctionService = AuctionService.instance;
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;

  List<AuctionItem> _regularAuctions = [];
  List<AuctionItem> _liveAuctions = [];
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _liveStreams = [];

  bool _isLoading = true;
  String? _selectedCategory;
  String _selectedStatus = 'all';
  bool _showFeaturedOnly = false;
  AuctionDisplayType _currentDisplayType = AuctionDisplayType.all;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) return;

    setState(() {
      switch (_tabController.index) {
        case 0:
          _currentDisplayType = AuctionDisplayType.all;
          break;
        case 1:
          _currentDisplayType = AuctionDisplayType.regular;
          break;
        case 2:
          _currentDisplayType = AuctionDisplayType.live;
          break;
      }
    });
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Load all data in parallel
      final results = await Future.wait([
        _auctionService.getCategories(),
        _loadRegularAuctions(),
        _loadLiveAuctions(),
        LiveStreamService.getLiveStreams(status: 'live'),
      ]);

      setState(() {
        _categories = results[0] as List<Map<String, dynamic>>;
        _liveStreams = results[3] as List<Map<String, dynamic>>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Failed to load data: ${e.toString()}');
    }
  }

  Future<List<AuctionItem>> _loadRegularAuctions() async {
    try {
      final response = await _auctionService.getRegularAuctions(
        categoryId: _selectedCategory,
        status: _selectedStatus == 'all' ? null : _selectedStatus,
        search: _searchController.text.trim(),
        featured: _showFeaturedOnly ? true : null,
        limit: 50,
      );

      final auctions =
          response.map((item) => AuctionItem.fromMap(item)).toList();
      setState(() => _regularAuctions = auctions);
      return auctions;
    } catch (e) {
      _showError('Failed to load regular auctions: ${e.toString()}');
      return [];
    }
  }

  Future<List<AuctionItem>> _loadLiveAuctions() async {
    try {
      final response = await _auctionService.getLiveAuctions(
        categoryId: _selectedCategory,
        search: _searchController.text.trim(),
        limit: 50,
      );

      final auctions =
          response.map((item) => AuctionItem.fromMap(item)).toList();
      setState(() => _liveAuctions = auctions);
      return auctions;
    } catch (e) {
      _showError('Failed to load live auctions: ${e.toString()}');
      return [];
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _onSearch(String query) {
    _loadRegularAuctions();
    _loadLiveAuctions();
  }

  void _onCategorySelected(String? categoryId) {
    setState(() => _selectedCategory = categoryId);
    _loadRegularAuctions();
    _loadLiveAuctions();
  }

  void _onStatusChanged(String status) {
    setState(() => _selectedStatus = status);
    _loadRegularAuctions();
  }

  void _toggleFeaturedOnly() {
    setState(() => _showFeaturedOnly = !_showFeaturedOnly);
    _loadRegularAuctions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Container(
          padding: EdgeInsets.symmetric(vertical: 1.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'BidWar',
                style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  height: 0.9,
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
              Text(
                'AUCTIONS',
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2.0,
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        foregroundColor: AppTheme.lightTheme.colorScheme.onSurface,
        automaticallyImplyLeading: false,
        toolbarHeight: 80,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.lightTheme.colorScheme.surface,
                AppTheme.lightTheme.colorScheme.surface.withAlpha(245),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.lightTheme.colorScheme.shadow.withAlpha(25),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(16.h),
          child: Container(
            color: AppTheme.lightTheme.colorScheme.surface,
            child: Column(
              children: [
                SizedBox(height: 2.h),

                // Search and primary filters
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Column(
                    children: [
                      SearchBarWidget(
                        controller: _searchController,
                        onSearch: _onSearch,
                      ),
                      SizedBox(height: 2.h),

                      // Auction type tabs
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          AuctionTypeTabWidget(
                            label: 'All',
                            isSelected:
                                _currentDisplayType == AuctionDisplayType.all,
                            onTap: () {
                              _tabController.animateTo(0);
                              setState(() =>
                                  _currentDisplayType = AuctionDisplayType.all);
                            },
                            icon: Icons.apps,
                            badgeText:
                                '${_regularAuctions.length + _liveAuctions.length}',
                          ),
                          AuctionTypeTabWidget(
                            label: 'Regular',
                            isSelected: _currentDisplayType ==
                                AuctionDisplayType.regular,
                            onTap: () {
                              _tabController.animateTo(1);
                              setState(() => _currentDisplayType =
                                  AuctionDisplayType.regular);
                            },
                            icon: Icons.gavel,
                            accentColor:
                                AppTheme.lightTheme.colorScheme.primary,
                            badgeText: '${_regularAuctions.length}',
                          ),
                          AuctionTypeTabWidget(
                            label: 'Live',
                            isSelected:
                                _currentDisplayType == AuctionDisplayType.live,
                            onTap: () {
                              // Navigate to TikTok-style auction browse screen
                              Navigator.pushNamed(
                                context,
                                AppRoutes.tikTokStyleAuctionBrowse,
                              );
                            },
                            icon: Icons.live_tv,
                            accentColor: Colors.red,
                            badgeText: '${_liveAuctions.length}',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 2.h),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Secondary filters with improved spacing
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(13),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Status filters (only show for regular auctions)
                if (_currentDisplayType == AuctionDisplayType.regular ||
                    _currentDisplayType == AuctionDisplayType.all)
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

                if ((_currentDisplayType == AuctionDisplayType.regular ||
                        _currentDisplayType == AuctionDisplayType.all) &&
                    _categories.isNotEmpty)
                  SizedBox(height: 1.5.h),

                // Category chips
                if (_categories.isNotEmpty)
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
                              onSelected: () =>
                                  _onCategorySelected(category['id']),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Auctions display
          Expanded(
            child: PageTransitionSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
                return FadeThroughTransition(
                  animation: primaryAnimation,
                  secondaryAnimation: secondaryAnimation,
                  child: child,
                );
              },
              child: RefreshIndicator(
                key: ValueKey(_currentDisplayType),
                onRefresh: _loadData,
                child: EnhancedAuctionGridWidget(
                  auctions: _regularAuctions,
                  liveAuctions: _liveAuctions,
                  displayType: _currentDisplayType,
                  isLoading: _isLoading,
                  onAuctionTap: (auction) {
                    final isLive =
                        _liveAuctions.any((live) => live.id == auction.id);
                    if (isLive) {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.liveAuctionStream,
                        arguments: auction.id,
                      );
                    } else {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.auctionDetail,
                        arguments: auction.id,
                      );
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: AuthService.instance.isLoggedIn
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.pushNamed(context, '/create-auction'),
              icon: const Icon(Icons.add),
              label: const Text('Create Auction'),
              backgroundColor: AppTheme.lightTheme.colorScheme.primary,
            )
          : null,
      bottomNavigationBar: CustomBottomBar(
        currentIndex: 0,
        onTap: (index) {
          HapticFeedback.lightImpact();
          switch (index) {
            case 0:
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
}