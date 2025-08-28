import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../routes/app_routes.dart';
import '../../services/admin_service.dart';
import '../../services/auth_service.dart';
import '../admin_dashboard_overview/widgets/admin_sidebar_widget.dart';
import '../auction_management_panel/widgets/auction_filters_widget.dart';
import '../auction_management_panel/widgets/auction_table_widget.dart';
import '../auction_management_panel/widgets/bulk_actions_widget.dart';
import '../auction_management_panel/widgets/create_auction_dialog.dart';

class AuctionManagementPanel extends StatefulWidget {
  const AuctionManagementPanel({Key? key}) : super(key: key);

  @override
  State<AuctionManagementPanel> createState() => _AuctionManagementPanelState();
}

class _AuctionManagementPanelState extends State<AuctionManagementPanel>
    with TickerProviderStateMixin {
  final AdminService _adminService = AdminService.instance;
  final AuthService _authService = AuthService.instance;

  late TabController _tabController;
  List<Map<String, dynamic>> auctions = [];
  List<Map<String, dynamic>> filteredAuctions = [];
  List<String> selectedAuctionIds = [];

  bool isLoading = true;
  bool isAuthorized = false;
  String? error;
  String searchQuery = '';
  String selectedStatus = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);
    _checkAdminAccess();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      final statuses = ['All', 'live', 'upcoming', 'ended'];
      setState(() {
        selectedStatus = statuses[_tabController.index];
      });
      _loadAuctions();
    }
  }

  Future<void> _checkAdminAccess() async {
    try {
      final isAdmin = await _adminService.isCurrentUserAdmin();

      if (!isAdmin) {
        setState(() {
          isAuthorized = false;
          isLoading = false;
        });
        return;
      }

      setState(() {
        isAuthorized = true;
      });

      await _loadAuctions();
    } catch (e) {
      setState(() {
        error = 'Authentication check failed: ${e.toString()}';
        isLoading = false;
        isAuthorized = false;
      });
    }
  }

  Future<void> _loadAuctions() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final status = selectedStatus == 'All' ? null : selectedStatus;
      final auctionsData =
          await _adminService.getAuctions(status: status, limit: 100);

      setState(() {
        auctions = auctionsData;
        _filterAuctions();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load auctions: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  void _filterAuctions() {
    setState(() {
      if (searchQuery.isEmpty) {
        filteredAuctions = auctions;
      } else {
        filteredAuctions = auctions.where((auction) {
          final title = auction['title']?.toString().toLowerCase() ?? '';
          final sellerName = auction['user_profiles']?['full_name']
                  ?.toString()
                  .toLowerCase() ??
              '';
          final query = searchQuery.toLowerCase();
          return title.contains(query) || sellerName.contains(query);
        }).toList();
      }
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      searchQuery = query;
    });
    _filterAuctions();
  }

  void _onSelectionChanged(List<String> selectedIds) {
    setState(() {
      selectedAuctionIds = selectedIds;
    });
  }

  Future<void> _updateAuctionStatus(String auctionId, String newStatus) async {
    try {
      await _adminService.updateAuctionStatus(auctionId, newStatus);
      await _loadAuctions();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Auction status updated to $newStatus'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update auction status: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteAuction(String auctionId) async {
    try {
      await _adminService.deleteAuction(auctionId);
      await _loadAuctions();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Auction deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete auction: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showCreateAuctionDialog() {
    showDialog(
      context: context,
      builder: (context) => CreateAuctionDialog(
        onAuctionCreated: _loadAuctions,
      ),
    );
  }

  Future<void> _signOut() async {
    try {
      await _authService.signOut();
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isAuthorized && !isLoading) {
      return _buildUnauthorizedAccess();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Row(
        children: [
          // Sidebar
          AdminSidebarWidget(
            currentRoute: AppRoutes.auctionManagement,
            onSignOut: _signOut,
          ),
          // Main Content
          Expanded(
            child: _buildMainContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildUnauthorizedAccess() {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Unauthorized Access',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.red.shade50,
        foregroundColor: Colors.red.shade700,
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(4.w),
          margin: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.shade200),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.security,
                size: 60,
                color: Colors.red.shade400,
              ),
              SizedBox(height: 2.h),
              Text(
                'Admin Access Required',
                style: GoogleFonts.inter(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.red.shade700,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                'You need administrator privileges to access this panel.',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: Colors.red.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 3.h),
              ElevatedButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, AppRoutes.login),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  padding:
                      EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
                ),
                child: Text(
                  'Back to Login',
                  style: GoogleFonts.inter(fontSize: 14.sp),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Container(
      padding: EdgeInsets.all(3.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          SizedBox(height: 2.h),
          if (error != null) _buildErrorWidget(),
          if (!isLoading && error == null) _buildContent(),
          if (isLoading) _buildLoadingWidget(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Auction Management',
              style: GoogleFonts.inter(
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1E3D),
              ),
            ),
            SizedBox(height: 0.5.h),
            Text(
              'Monitor and control all auction activities',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: _showCreateAuctionDialog,
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Create Auction'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
              ),
            ),
            SizedBox(width: 2.w),
            IconButton(
              onPressed: _loadAuctions,
              icon: const Icon(Icons.refresh),
              style: IconButton.styleFrom(
                backgroundColor: Colors.grey.shade100,
                foregroundColor: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(3.w),
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade600),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(
              error!,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: Colors.red.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            SizedBox(height: 2.h),
            Text(
              'Loading Auctions...',
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Expanded(
      child: Column(
        children: [
          // Filters and Search
          AuctionFiltersWidget(
            searchQuery: searchQuery,
            onSearchChanged: _onSearchChanged,
          ),
          SizedBox(height: 2.h),
          // Tabs
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(13),
                  blurRadius: 10,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.all_inclusive, size: 16),
                      SizedBox(width: 1.w),
                      const Text('All Auctions'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.play_circle, size: 16),
                      SizedBox(width: 1.w),
                      const Text('Live'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.schedule, size: 16),
                      SizedBox(width: 1.w),
                      const Text('Upcoming'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle, size: 16),
                      SizedBox(width: 1.w),
                      const Text('Ended'),
                    ],
                  ),
                ),
              ],
              labelColor: Colors.blue.shade600,
              unselectedLabelColor: Colors.grey.shade600,
              indicatorColor: Colors.blue.shade600,
              labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ),
          // Bulk Actions
          if (selectedAuctionIds.isNotEmpty)
            Container(
              color: Colors.blue.shade50,
              child: BulkActionsWidget(
                selectedCount: selectedAuctionIds.length,
                onBulkAction: (action) {
                  // TODO: Implement bulk actions
                },
              ),
            ),
          // Auction Table
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: const Radius.circular(16),
                  bottomRight: const Radius.circular(16),
                  topLeft: selectedAuctionIds.isEmpty
                      ? Radius.zero
                      : const Radius.circular(16),
                  topRight: selectedAuctionIds.isEmpty
                      ? Radius.zero
                      : const Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(13),
                    blurRadius: 10,
                    spreadRadius: 0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: AuctionTableWidget(
                auctions: filteredAuctions,
                selectedIds: selectedAuctionIds,
                onSelectionChanged: _onSelectionChanged,
                onUpdateStatus: _updateAuctionStatus,
                onDelete: _deleteAuction,
              ),
            ),
          ),
        ],
      ),
    );
  }
}