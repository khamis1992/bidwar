import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class StatisticsCardsWidget extends StatelessWidget {
  final Map<String, dynamic> statistics;

  const StatisticsCardsWidget({
    super.key,
    required this.statistics,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Auction Statistics",
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _StatisticCard(
                  icon: 'gavel',
                  title: "Total Bids",
                  value: "${statistics["totalBids"] ?? 0}",
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _StatisticCard(
                  icon: 'emoji_events',
                  title: "Auctions Won",
                  value: "${statistics["auctionsWon"] ?? 0}",
                  color: AppTheme.lightTheme.colorScheme.secondary,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.w),
          Row(
            children: [
              Expanded(
                child: _StatisticCard(
                  icon: 'trending_up',
                  title: "Success Rate",
                  value: "${statistics["successRate"] ?? 0}%",
                  color: Colors.green,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _StatisticCard(
                  icon: 'savings',
                  title: "Total Savings",
                  value: "\$${statistics["totalSavings"] ?? 0}",
                  color: Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatisticCard extends StatelessWidget {
  final String icon;
  final String title;
  final String value;
  final Color color;

  const _StatisticCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: icon,
              color: color,
              size: 5.w,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            value,
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            title,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
