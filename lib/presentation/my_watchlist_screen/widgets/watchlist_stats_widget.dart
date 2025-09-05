import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Watchlist Stats Widget
///
/// يعرض إحصائيات قائمة المتابعة
/// يتبع قواعد BidWar للتصميم
class WatchlistStatsWidget extends StatelessWidget {
  final int totalItems;
  final int activeItems;
  final int endingSoonCount;

  const WatchlistStatsWidget({
    super.key,
    required this.totalItems,
    required this.activeItems,
    required this.endingSoonCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.borderLight,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Total Items
          Expanded(
            child: _buildStatItem(
              icon: Icons.bookmark,
              value: totalItems.toString(),
              label: 'Total',
              color: AppTheme.primaryLight,
            ),
          ),

          // Vertical Divider
          Container(
            height: 8.h,
            width: 1,
            color: AppTheme.borderLight,
            margin: EdgeInsets.symmetric(horizontal: 2.w),
          ),

          // Active Items
          Expanded(
            child: _buildStatItem(
              icon: Icons.flash_on,
              value: activeItems.toString(),
              label: 'Active',
              color: AppTheme.successLight,
            ),
          ),

          // Vertical Divider
          Container(
            height: 8.h,
            width: 1,
            color: AppTheme.borderLight,
            margin: EdgeInsets.symmetric(horizontal: 2.w),
          ),

          // Ending Soon
          Expanded(
            child: _buildStatItem(
              icon: Icons.access_time,
              value: endingSoonCount.toString(),
              label: 'Ending Soon',
              color: endingSoonCount > 0
                  ? AppTheme.warningLight
                  : AppTheme.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 6.w,
            color: color,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            color: AppTheme.textSecondaryLight,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
