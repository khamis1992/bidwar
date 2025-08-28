import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'dart:math' as math;

class EngagementChartWidget extends StatelessWidget {
  final Map<String, dynamic> engagementData;

  const EngagementChartWidget({
    super.key,
    required this.engagementData,
  });

  @override
  Widget build(BuildContext context) {
    final timelineData = engagementData['timeline'] as List<dynamic>? ?? [];

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
        children: [
          Text(
            'Engagement Timeline',
            style: TextStyle(
              fontSize: 18.h,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),
          timelineData.isNotEmpty
              ? _buildEngagementChart(timelineData)
              : _buildNoDataState(),
          SizedBox(height: 16.h),
          _buildEngagementMetrics(),
        ],
      ),
    );
  }

  Widget _buildEngagementChart(List<dynamic> timelineData) {
    return Container(
      height: 200.h,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          width: math.max(timelineData.length * 40.0, 300.0),
          child: CustomPaint(
            painter: EngagementChartPainter(timelineData),
          ),
        ),
      ),
    );
  }

  Widget _buildNoDataState() {
    return Container(
      height: 200.h,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.timeline,
              size: 48.h,
              color: Colors.grey[400],
            ),
            SizedBox(height: 8.h),
            Text(
              'No engagement data available',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14.h,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEngagementMetrics() {
    return Row(
      children: [
        Expanded(
          child: _buildMetricItem(
            'Chat Messages',
            '${engagementData['total_chat_messages'] ?? 0}',
            Colors.blue,
          ),
        ),
        Expanded(
          child: _buildMetricItem(
            'Active Bidders',
            '${engagementData['active_bidders'] ?? 0}',
            Colors.green,
          ),
        ),
        Expanded(
          child: _buildMetricItem(
            'Bid Frequency',
            '${engagementData['bid_frequency'] ?? 0}/min',
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricItem(String title, String value, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8.h),
          decoration: BoxDecoration(
            color: color.withAlpha(26),
            shape: BoxShape.circle,
          ),
          child: Container(
            width: 8.h,
            height: 8.h,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 16.h,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 12.h,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class EngagementChartPainter extends CustomPainter {
  final List<dynamic> timelineData;

  EngagementChartPainter(this.timelineData);

  @override
  void paint(Canvas canvas, Size size) {
    if (timelineData.isEmpty) return;

    final chatPaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final bidPaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final viewerPaint = Paint()
      ..color = Colors.orange
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Find max values for normalization
    double maxChat = 0, maxBids = 0, maxViewers = 0;
    for (final point in timelineData) {
      final chatCount = point['chat_count'] ?? 0;
      final bidCount = point['bid_count'] ?? 0;
      final viewerCount = point['viewer_count'] ?? 0;

      if (chatCount > maxChat) maxChat = chatCount.toDouble();
      if (bidCount > maxBids) maxBids = bidCount.toDouble();
      if (viewerCount > maxViewers) maxViewers = viewerCount.toDouble();
    }

    if (maxChat == 0 && maxBids == 0 && maxViewers == 0) return;

    // Draw lines
    final chatPath = Path();
    final bidPath = Path();
    final viewerPath = Path();

    for (int i = 0; i < timelineData.length; i++) {
      final point = timelineData[i];
      final x = (i / (timelineData.length - 1)) * size.width;

      final chatY = size.height -
          ((point['chat_count'] ?? 0) /
              (maxChat == 0 ? 1 : maxChat) *
              size.height *
              0.8);
      final bidY = size.height -
          ((point['bid_count'] ?? 0) /
              (maxBids == 0 ? 1 : maxBids) *
              size.height *
              0.8);
      final viewerY = size.height -
          ((point['viewer_count'] ?? 0) /
              (maxViewers == 0 ? 1 : maxViewers) *
              size.height *
              0.8);

      if (i == 0) {
        chatPath.moveTo(x, chatY);
        bidPath.moveTo(x, bidY);
        viewerPath.moveTo(x, viewerY);
      } else {
        chatPath.lineTo(x, chatY);
        bidPath.lineTo(x, bidY);
        viewerPath.lineTo(x, viewerY);
      }
    }

    canvas.drawPath(chatPath, chatPaint);
    canvas.drawPath(bidPath, bidPaint);
    canvas.drawPath(viewerPath, viewerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
