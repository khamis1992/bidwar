import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../routes/app_routes.dart';
import '../../services/admin_service.dart';
import '../../services/auth_service.dart';
import '../admin_dashboard_overview/widgets/activity_chart_widget.dart';
import '../admin_dashboard_overview/widgets/admin_sidebar_widget.dart';
import '../admin_dashboard_overview/widgets/quick_actions_widget.dart';
import '../admin_dashboard_overview/widgets/stats_card_widget.dart';
import '../admin_dashboard_overview/widgets/system_health_widget.dart';

class AdminDashboardOverview extends StatefulWidget {
  const AdminDashboardOverview({Key? key}) : super(key: key);

  @override
  State<AdminDashboardOverview> createState() => _AdminDashboardOverviewState();
}

class _AdminDashboardOverviewState extends State<AdminDashboardOverview> {
  final AdminService _adminService = AdminService.instance;
  final AuthService _authService = AuthService.instance;

  Map<String, dynamic>? dashboardStats;
  List<Map<String, dynamic>> auctionAnalytics = [];
  List<Map<String, dynamic>> userEngagement = [];
  bool isLoading = true;
  bool isAuthorized = false;
  String? error;

  @override
  void initState() {
    super.initState();
    _checkAdminAccess();
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

      await _loadDashboardData();
    } catch (e) {
      setState(() {
        error = 'Authentication check failed: ${e.toString()}';
        isLoading = false;
        isAuthorized = false;
      });
    }
  }

  Future<void> _loadDashboardData() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final futures = await Future.wait([
        _adminService.getDashboardStats(),
        _adminService.getAuctionAnalytics(),
        _adminService.getUserEngagementMetrics(),
      ]);

      setState(() {
        dashboardStats = futures[0] as Map<String, dynamic>;
        auctionAnalytics = futures[1] as List<Map<String, dynamic>>;
        userEngagement = futures[2] as List<Map<String, dynamic>>;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load dashboard data: ${e.toString()}';
        isLoading = false;
      });
    }
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
            currentRoute: AppRoutes.adminDashboardOverview,
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
                'You need administrator privileges to access this dashboard.',
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
          if (isLoading) _buildLoadingWidget(),
          if (!isLoading && error == null) _buildDashboardContent(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final now = DateTime.now();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'BidWar Admin Dashboard',
              style: GoogleFonts.inter(
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1E3D),
              ),
            ),
            SizedBox(height: 0.5.h),
            Text(
              '${now.day}/${now.month}/${now.year} - Real-time Overview',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              onPressed: _loadDashboardData,
              icon: const Icon(Icons.refresh),
              style: IconButton.styleFrom(
                backgroundColor: Colors.blue.shade50,
                foregroundColor: Colors.blue.shade600,
              ),
            ),
            SizedBox(width: 2.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    'System Online',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
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
              'Loading Dashboard Data...',
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

  Widget _buildDashboardContent() {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // KPI Cards Row
            Row(
              children: [
                Expanded(
                  child: StatsCardWidget(
                    title: 'Active Auctions',
                    value:
                        dashboardStats?['active_auctions']?.toString() ?? '0',
                    icon: Icons.gavel,
                    color: Colors.blue,
                    change: '+5.2%',
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: StatsCardWidget(
                    title: 'Total Users',
                    value: dashboardStats?['total_users']?.toString() ?? '0',
                    icon: Icons.people,
                    color: Colors.green,
                    change: '+12.3%',
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: StatsCardWidget(
                    title: 'Daily Revenue',
                    value:
                        '\$${dashboardStats?['daily_revenue']?.toString() ?? '0'}',
                    icon: Icons.attach_money,
                    color: Colors.orange,
                    change: '+8.7%',
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: StatsCardWidget(
                    title: 'Upcoming Auctions',
                    value:
                        dashboardStats?['upcoming_auctions']?.toString() ?? '0',
                    icon: Icons.schedule,
                    color: Colors.purple,
                    change: '+2.1%',
                  ),
                ),
              ],
            ),
            SizedBox(height: 3.h),
            // Charts and Analytics Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: ActivityChartWidget(
                    auctionData: auctionAnalytics,
                    userEngagementData: userEngagement,
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Column(
                    children: [
                      SystemHealthWidget(),
                      SizedBox(height: 2.h),
                      QuickActionsWidget(),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
