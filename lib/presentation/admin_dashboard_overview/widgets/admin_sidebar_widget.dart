import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../routes/app_routes.dart';

class AdminSidebarWidget extends StatelessWidget {
  final String currentRoute;
  final VoidCallback onSignOut;

  const AdminSidebarWidget({
    Key? key,
    required this.currentRoute,
    required this.onSignOut,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1E3D),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _buildNavigationMenu(context),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(26),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.admin_panel_settings,
              color: Colors.white,
              size: 32,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            'BidWar',
            style: GoogleFonts.inter(
              fontSize: 20.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          Text(
            'Admin Dashboard',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              color: Colors.white.withAlpha(179),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationMenu(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w),
      child: Column(
        children: [
          _buildMenuSection('Overview', [
            _buildMenuItem(
              context,
              'Dashboard',
              Icons.dashboard,
              AppRoutes.adminDashboardOverview,
            ),
          ]),
          SizedBox(height: 2.h),
          _buildMenuSection('Management', [
            _buildMenuItem(
              context,
              'Auctions',
              Icons.gavel,
              AppRoutes.auctionManagementPanel,
            ),
            _buildMenuItem(
              context,
              'Users',
              Icons.people,
              AppRoutes
                  .adminDashboardOverview, // TODO: Replace with user management route
            ),
            _buildMenuItem(
              context,
              'Financial',
              Icons.account_balance_wallet,
              AppRoutes
                  .adminDashboardOverview, // TODO: Replace with financial route
            ),
          ]),
          SizedBox(height: 2.h),
          _buildMenuSection('Analytics', [
            _buildMenuItem(
              context,
              'Reports',
              Icons.analytics,
              AppRoutes
                  .adminDashboardOverview, // TODO: Replace with reports route
            ),
            _buildMenuItem(
              context,
              'Statistics',
              Icons.show_chart,
              AppRoutes
                  .adminDashboardOverview, // TODO: Replace with statistics route
            ),
          ]),
          SizedBox(height: 2.h),
          _buildMenuSection('System', [
            _buildMenuItem(
              context,
              'Settings',
              Icons.settings,
              AppRoutes
                  .adminDashboardOverview, // TODO: Replace with settings route
            ),
            _buildMenuItem(
              context,
              'Notifications',
              Icons.notifications,
              AppRoutes
                  .adminDashboardOverview, // TODO: Replace with notifications route
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildMenuSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.w),
          child: Text(
            title.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white.withAlpha(128),
              letterSpacing: 1.2,
            ),
          ),
        ),
        SizedBox(height: 1.h),
        ...items,
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String title,
    IconData icon,
    String route,
  ) {
    final isSelected = currentRoute == route;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (route != currentRoute) {
              Navigator.pushReplacementNamed(context, route);
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
            decoration: BoxDecoration(
              color:
                  isSelected ? Colors.white.withAlpha(26) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color:
                      isSelected ? Colors.white : Colors.white.withAlpha(179),
                  size: 20,
                ),
                SizedBox(width: 3.w),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color:
                        isSelected ? Colors.white : Colors.white.withAlpha(179),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.all(3.w),
      child: Column(
        children: [
          Divider(color: Colors.white.withAlpha(26)),
          SizedBox(height: 1.h),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onSignOut,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
                child: Row(
                  children: [
                    Icon(
                      Icons.logout,
                      color: Colors.red.shade300,
                      size: 20,
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      'Sign Out',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.red.shade300,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
