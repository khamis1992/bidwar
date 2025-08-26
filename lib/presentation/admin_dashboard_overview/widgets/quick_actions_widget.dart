import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../routes/app_routes.dart';

class QuickActionsWidget extends StatelessWidget {
  const QuickActionsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1E3D),
            ),
          ),
          SizedBox(height: 2.h),
          _buildActionButton(
            context,
            'Manage Auctions',
            Icons.gavel,
            Colors.blue,
            () =>
                Navigator.pushNamed(context, AppRoutes.auctionManagementPanel),
          ),
          SizedBox(height: 1.h),
          _buildActionButton(
            context,
            'View Reports',
            Icons.analytics,
            Colors.green,
            () {
              // TODO: Navigate to reports screen
            },
          ),
          SizedBox(height: 1.h),
          _buildActionButton(
            context,
            'User Management',
            Icons.people,
            Colors.orange,
            () {
              // TODO: Navigate to user management screen
            },
          ),
          SizedBox(height: 1.h),
          _buildActionButton(
            context,
            'System Alerts',
            Icons.warning,
            Colors.red,
            () {
              // TODO: Navigate to system alerts screen
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: color.withAlpha(26),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(51)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(1.5.w),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
            ),
            SizedBox(width: 3.w),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: color.withAlpha(204),
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              color: color.withAlpha(153),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
