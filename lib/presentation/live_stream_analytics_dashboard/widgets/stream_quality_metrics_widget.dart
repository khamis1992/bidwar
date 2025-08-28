import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class StreamQualityMetricsWidget extends StatelessWidget {
  final Map<String, dynamic> qualityData;

  const StreamQualityMetricsWidget({
    super.key,
    required this.qualityData,
  });

  @override
  Widget build(BuildContext context) {
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
            'Stream Quality Metrics',
            style: TextStyle(
              fontSize: 18.h,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),
          _buildQualityMetrics(),
          SizedBox(height: 16.h),
          _buildConnectionStability(),
          SizedBox(height: 16.h),
          _buildQualityTrends(),
        ],
      ),
    );
  }

  Widget _buildQualityMetrics() {
    final avgBitrate = qualityData['average_bitrate'] ?? 0;
    final avgLatency = qualityData['average_latency'] ?? 0;
    final qualityScore = qualityData['quality_score'] ?? 0.0;

    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            'Avg. Bitrate',
            '${avgBitrate} kbps',
            Icons.speed,
            _getBitrateColor(avgBitrate),
          ),
        ),
        SizedBox(width: 12.h),
        Expanded(
          child: _buildMetricCard(
            'Avg. Latency',
            '${avgLatency} ms',
            Icons.timer,
            _getLatencyColor(avgLatency),
          ),
        ),
        SizedBox(width: 12.h),
        Expanded(
          child: _buildMetricCard(
            'Quality Score',
            '${qualityScore.toStringAsFixed(1)}/10',
            Icons.star,
            _getQualityColor(qualityScore),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(12.h),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(8.h),
        border: Border.all(color: color.withAlpha(77)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 24.h,
            color: color,
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.h,
              fontWeight: FontWeight.bold,
              color: color,
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
      ),
    );
  }

  Widget _buildConnectionStability() {
    final stability = qualityData['stability'] ?? {};
    final dropoutCount = stability['dropout_count'] ?? 0;
    final reconnectionCount = stability['reconnection_count'] ?? 0;
    final avgConnectionTime = stability['average_connection_time'] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Connection Stability',
          style: TextStyle(
            fontSize: 16.h,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.all(12.h),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8.h),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildStabilityItem(
                  'Dropouts',
                  dropoutCount.toString(),
                  Icons.signal_wifi_bad,
                  Colors.red,
                ),
              ),
              Expanded(
                child: _buildStabilityItem(
                  'Reconnections',
                  reconnectionCount.toString(),
                  Icons.refresh,
                  Colors.orange,
                ),
              ),
              Expanded(
                child: _buildStabilityItem(
                  'Uptime',
                  _formatDuration(avgConnectionTime),
                  Icons.signal_wifi_4_bar,
                  Colors.green,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStabilityItem(
      String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20.h,
          color: color,
        ),
        SizedBox(height: 4.h),
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

  Widget _buildQualityTrends() {
    final trends = qualityData['trends'] as List<dynamic>? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quality Trends',
          style: TextStyle(
            fontSize: 16.h,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 12.h),
        if (trends.isEmpty) _buildNoTrendsData() else _buildTrendsChart(trends),
      ],
    );
  }

  Widget _buildNoTrendsData() {
    return Container(
      padding: EdgeInsets.all(24.h),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8.h),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.show_chart,
              size: 40.h,
              color: Colors.grey[400],
            ),
            SizedBox(height: 8.h),
            Text(
              'No trend data available',
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

  Widget _buildTrendsChart(List<dynamic> trends) {
    return Container(
      height: 120.h,
      padding: EdgeInsets.all(12.h),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8.h),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: CustomPaint(
        painter: QualityTrendsPainter(trends),
        child: Container(),
      ),
    );
  }

  Color _getBitrateColor(int bitrate) {
    if (bitrate >= 2000) return Colors.green;
    if (bitrate >= 1000) return Colors.orange;
    return Colors.red;
  }

  Color _getLatencyColor(int latency) {
    if (latency <= 100) return Colors.green;
    if (latency <= 300) return Colors.orange;
    return Colors.red;
  }

  Color _getQualityColor(double score) {
    if (score >= 8.0) return Colors.green;
    if (score >= 6.0) return Colors.orange;
    return Colors.red;
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

class QualityTrendsPainter extends CustomPainter {
  final List<dynamic> trends;

  QualityTrendsPainter(this.trends);

  @override
  void paint(Canvas canvas, Size size) {
    if (trends.isEmpty) return;

    final qualityPaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final bitratePaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Normalize data
    double maxQuality = 0, maxBitrate = 0;
    for (final trend in trends) {
      final quality = trend['quality_score'] ?? 0;
      final bitrate = trend['bitrate'] ?? 0;

      if (quality > maxQuality) maxQuality = quality.toDouble();
      if (bitrate > maxBitrate) maxBitrate = bitrate.toDouble();
    }

    if (maxQuality == 0 && maxBitrate == 0) return;

    // Draw quality line
    final qualityPath = Path();
    final bitratePath = Path();

    for (int i = 0; i < trends.length; i++) {
      final trend = trends[i];
      final x = (i / (trends.length - 1)) * size.width;

      final qualityY = size.height -
          ((trend['quality_score'] ?? 0) /
              (maxQuality == 0 ? 1 : maxQuality) *
              size.height *
              0.8);
      final bitrateY = size.height -
          ((trend['bitrate'] ?? 0) /
              (maxBitrate == 0 ? 1 : maxBitrate) *
              size.height *
              0.8);

      if (i == 0) {
        qualityPath.moveTo(x, qualityY);
        bitratePath.moveTo(x, bitrateY);
      } else {
        qualityPath.lineTo(x, qualityY);
        bitratePath.lineTo(x, bitrateY);
      }
    }

    canvas.drawPath(qualityPath, qualityPaint);
    canvas.drawPath(bitratePath, bitratePaint);

    // Draw legend
    final legendPaint = Paint()..style = PaintingStyle.fill;

    // Quality legend
    legendPaint.color = Colors.blue;
    canvas.drawCircle(Offset(20, 20), 4, legendPaint);

    // Bitrate legend
    legendPaint.color = Colors.green;
    canvas.drawCircle(Offset(20, 40), 4, legendPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
