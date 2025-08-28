import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';


class AnalyticsOverviewWidget extends StatelessWidget {
  final Map<String, dynamic> analyticsData;

  const AnalyticsOverviewWidget({
    super.key,
    required this.analyticsData,
  });

  @override
  Widget build(BuildContext context) {
    final overview = analyticsData['overview'] ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Metrics',
          style: TextStyle(
            fontSize: 20.h,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16.h),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.5,
          crossAxisSpacing: 12.h,
          mainAxisSpacing: 12.h,
          children: [
            _buildMetricCard(
              'Total Viewers',
              '${overview['total_viewers'] ?? 0}',
              Icons.visibility,
              Colors.blue,
              _getTrendIcon(overview['viewers_trend']),
            ),
            _buildMetricCard(
              'Peak Concurrent',
              '${overview['peak_concurrent'] ?? 0}',
              Icons.people,
              Colors.green,
              _getTrendIcon(overview['peak_trend']),
            ),
            _buildMetricCard(
              'Avg. Watch Time',
              _formatDuration(overview['avg_watch_time'] ?? 0),
              Icons.schedule,
              Colors.orange,
              _getTrendIcon(overview['watch_time_trend']),
            ),
            _buildMetricCard(
              'Conversion Rate',
              '${(overview['conversion_rate'] ?? 0.0).toStringAsFixed(1)}%',
              Icons.trending_up,
              Colors.purple,
              _getTrendIcon(overview['conversion_trend']),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
    Widget? trendIcon,
  ) {
    return Container(
      padding: EdgeInsets.all(16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.h),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.h),
                decoration: BoxDecoration(
                  color: color.withAlpha(26),
                  borderRadius: BorderRadius.circular(8.h),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20.h,
                ),
              ),
              const Spacer(),
              if (trendIcon != null) trendIcon,
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 20.h,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12.h,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget? _getTrendIcon(dynamic trend) {
    if (trend == null) return null;

    final trendValue =
        trend is String ? double.tryParse(trend) : trend.toDouble();
    if (trendValue == null || trendValue == 0) return null;

    final isPositive = trendValue > 0;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.h, vertical: 2.h),
      decoration: BoxDecoration(
        color:
            isPositive ? Colors.green.withAlpha(26) : Colors.red.withAlpha(26),
        borderRadius: BorderRadius.circular(4.h),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? Icons.trending_up : Icons.trending_down,
            size: 12.h,
            color: isPositive ? Colors.green : Colors.red,
          ),
          SizedBox(width: 2.h),
          Text(
            '${trendValue.abs().toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 10.h,
              color: isPositive ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) {
      return '${seconds}s';
    } else if (seconds < 3600) {
      return '${(seconds / 60).round()}m';
    } else {
      final hours = (seconds / 3600).floor();
      final minutes = ((seconds % 3600) / 60).round();
      return '${hours}h ${minutes}m';
    }
  }
}
