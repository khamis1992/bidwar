import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import '../../services/battle_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/battle_card_widget.dart';
import './widgets/category_filter_widget.dart';
import './widgets/featured_battle_widget.dart';
import './widgets/quick_actions_widget.dart';

class BattleRoomsHub extends StatefulWidget {
  const BattleRoomsHub({super.key});

  @override
  State<BattleRoomsHub> createState() => _BattleRoomsHubState();
}

class _BattleRoomsHubState extends State<BattleRoomsHub>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  List<Map<String, dynamic>> _battleRooms = [];
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _featuredBattles = [];

  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _selectedCategory;
  String _sortBy = 'most_popular';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _loadData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!_isRefreshing) {
      setState(() => _isLoading = true);
    }

    try {
      final results = await Future.wait([
        BattleService.getActiveBattles(),
        // Mock categories for now - replace with actual service
        Future.value([
          {
            'id': 'electronics',
            'name': 'Electronics',
            'icon': Icons.phone_android
          },
          {'id': 'fashion', 'name': 'Fashion', 'icon': Icons.checkroom},
          {'id': 'gaming', 'name': 'Gaming', 'icon': Icons.games},
          {'id': 'luxury', 'name': 'Luxury', 'icon': Icons.diamond},
        ]),
      ]);

      final battleRooms = results[0];

      setState(() {
        _battleRooms = battleRooms;
        _categories = results[1];
        _featuredBattles = battleRooms
            .where((battle) =>
                battle['status'] == 'active' && battle['viewer_count'] > 100)
            .take(3)
            .toList();
        _isLoading = false;
        _isRefreshing = false;
      });

      _animationController.forward();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isRefreshing = false;
      });
      _showError('Failed to load battle rooms: ${e.toString()}');
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: _loadData,
          ),
        ),
      );
    }
  }

  Future<void> _onRefresh() async {
    setState(() => _isRefreshing = true);
    await _loadData();
  }

  void _onCategorySelected(String? categoryId) {
    setState(() => _selectedCategory = categoryId);
    _loadData();
  }

  void _onSearch(String query) {
    _loadData();
  }

  void _onBattleTap(Map<String, dynamic> battle) {
    Navigator.pushNamed(
      context,
      AppRoutes.liveAuctionStream,
      arguments: battle['id'],
    );
  }

  void _createBattle() {
    if (!AuthService.instance.isLoggedIn) {
      Navigator.pushNamed(context, AppRoutes.login);
      return;
    }

    Navigator.pushNamed(context, AppRoutes.battleCreationCompetitorInvitation);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: CustomAppBar(
        title: 'Battle Hub',
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () => _showSearchDialog(),
          ),
        ],
      ),
      body: _isLoading && !_isRefreshing
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
              ),
            )
          : RefreshIndicator(
              onRefresh: _onRefresh,
              color: Colors.orange,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: CustomScrollView(
                  slivers: [
                    // Search and filters section
                    SliverToBoxAdapter(
                      child: Container(
                        padding: EdgeInsets.all(4.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Welcome header
                            Text(
                              'Live Battle Arena',
                              style: AppTheme
                                  .lightTheme.textTheme.headlineMedium
                                  ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                height: 1.2,
                              ),
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              'Watch epic duels between competitors and support your favorites!',
                              style: AppTheme.lightTheme.textTheme.bodyLarge
                                  ?.copyWith(
                                color: Colors.grey[300],
                                height: 1.4,
                              ),
                            ),
                            SizedBox(height: 3.h),

                            // Quick actions
                            QuickActionsWidget(
                              onCreateBattle: _createBattle,
                              onViewInvitations: () => Navigator.pushNamed(
                                  context, '/battle-invitations'),
                              onJoinRandom: () => _joinRandomBattle(),
                            ),
                            SizedBox(height: 3.h),

                            // Category filters
                            CategoryFilterWidget(
                              categories: _categories,
                              selectedCategory: _selectedCategory,
                              onCategorySelected: _onCategorySelected,
                            ),
                            SizedBox(height: 3.h),
                          ],
                        ),
                      ),
                    ),

                    // Featured battles section
                    if (_featuredBattles.isNotEmpty) ...[
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Featured Battles',
                                style: AppTheme.lightTheme.textTheme.titleLarge
                                    ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 3.w, vertical: 0.5.h),
                                decoration: BoxDecoration(
                                  color: Colors.red.withAlpha(51),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: Colors.red.withAlpha(77)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    SizedBox(width: 2.w),
                                    Text(
                                      'LIVE',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 10.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: 25.h,
                          child: ListView.builder(
                            padding: EdgeInsets.symmetric(horizontal: 4.w),
                            scrollDirection: Axis.horizontal,
                            itemCount: _featuredBattles.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: EdgeInsets.only(right: 4.w),
                                child: FeaturedBattleWidget(
                                  battle: _featuredBattles[index],
                                  onTap: () =>
                                      _onBattleTap(_featuredBattles[index]),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(child: SizedBox(height: 4.h)),
                    ],

                    // All battles section
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 4.w, vertical: 2.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'All Battles',
                              style: AppTheme.lightTheme.textTheme.titleLarge
                                  ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 3.w, vertical: 1.h),
                              decoration: BoxDecoration(
                                color: Colors.grey[900],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${_battleRooms.length} battles',
                                style: TextStyle(
                                  color: Colors.grey[300],
                                  fontSize: 12.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Battle cards list
                    if (_battleRooms.isEmpty && !_isLoading)
                      SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.w),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.sports_kabaddi,
                                  size: 15.w,
                                  color: Colors.grey[600],
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  'No active battles right now',
                                  style: AppTheme
                                      .lightTheme.textTheme.titleMedium
                                      ?.copyWith(
                                    color: Colors.grey[400],
                                  ),
                                ),
                                SizedBox(height: 1.h),
                                Text(
                                  'Be the first to start an epic battle!',
                                  style: AppTheme
                                      .lightTheme.textTheme.bodyMedium
                                      ?.copyWith(
                                    color: Colors.grey[500],
                                  ),
                                ),
                                SizedBox(height: 3.h),
                                ElevatedButton.icon(
                                  onPressed: _createBattle,
                                  icon: const Icon(Icons.add_circle_outline),
                                  label: const Text('Create Battle'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                      vertical: 1.5.h,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    else
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final battle = _battleRooms[index];
                            return Padding(
                              padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 2.h),
                              child: BattleCardWidget(
                                battle: battle,
                                onTap: () => _onBattleTap(battle),
                                onShare: () => _shareBattle(battle),
                              ),
                            );
                          },
                          childCount: _battleRooms.length,
                        ),
                      ),

                    // Bottom padding
                    SliverToBoxAdapter(
                      child: SizedBox(height: 10.h),
                    ),
                  ],
                ),
              ),
            ),
      floatingActionButton: AuthService.instance.isLoggedIn
          ? FloatingActionButton(
              onPressed: _createBattle,
              backgroundColor: Colors.orange,
              child: const Icon(Icons.add, color: Colors.white),
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

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title:
            const Text('Search Battles', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Enter battle name or description...',
            hintStyle: TextStyle(color: Colors.grey),
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          onSubmitted: (value) {
            Navigator.pop(context);
            _onSearch(value);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _onSearch(_searchController.text);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  void _joinRandomBattle() {
    if (_battleRooms.isNotEmpty) {
      final randomBattle = (_battleRooms..shuffle()).first;
      _onBattleTap(randomBattle);
    }
  }

  void _shareBattle(Map<String, dynamic> battle) {
    // Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality coming soon!')),
    );
  }
}