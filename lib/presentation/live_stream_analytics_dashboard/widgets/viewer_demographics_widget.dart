import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class ViewerDemographicsWidget extends StatelessWidget {
  final Map<String, dynamic> demographicsData;

  const ViewerDemographicsWidget({
    super.key,
    required this.demographicsData,
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
            'Viewer Demographics',
            style: TextStyle(
              fontSize: 18.h,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),
          _buildGeographicDistribution(),
          SizedBox(height: 16.h),
          _buildDeviceTypes(),
          SizedBox(height: 16.h),
          _buildRetentionPatterns(),
        ],
      ),
    );
  }

  Widget _buildGeographicDistribution() {
    final geographic = demographicsData['geographic'] as List<dynamic>? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Geographic Distribution',
          style: TextStyle(
            fontSize: 16.h,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 12.h),
        if (geographic.isEmpty)
          _buildEmptyState('No geographic data available')
        else
          ...geographic.take(5).map((location) => _buildLocationItem(location)),
      ],
    );
  }

  Widget _buildLocationItem(Map<String, dynamic> location) {
    final country = location['country'] ?? 'Unknown';
    final count = location['count'] ?? 0;
    final percentage = location['percentage'] ?? 0.0;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Text(
            _getCountryFlag(country),
            style: TextStyle(fontSize: 18.h),
          ),
          SizedBox(width: 8.h),
          Expanded(
            child: Text(
              country,
              style: TextStyle(fontSize: 14.h),
            ),
          ),
          Container(
            width: 100.h,
            height: 6.h,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(3.h),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(3.h),
                ),
              ),
            ),
          ),
          SizedBox(width: 8.h),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 12.h,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceTypes() {
    final devices = demographicsData['devices'] as List<dynamic>? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Device Types',
          style: TextStyle(
            fontSize: 16.h,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 12.h),
        if (devices.isEmpty)
          _buildEmptyState('No device data available')
        else
          Row(
            children: devices
                .map((device) => Expanded(
                      child: _buildDeviceItem(device),
                    ))
                .toList(),
          ),
      ],
    );
  }

  Widget _buildDeviceItem(Map<String, dynamic> device) {
    final type = device['type'] ?? 'Unknown';
    final count = device['count'] ?? 0;
    final percentage = device['percentage'] ?? 0.0;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.h),
      padding: EdgeInsets.all(12.h),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8.h),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(
            _getDeviceIcon(type),
            size: 24.h,
            color: Colors.blue,
          ),
          SizedBox(height: 8.h),
          Text(
            '${percentage.toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 16.h,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            type,
            style: TextStyle(
              fontSize: 12.h,
              color: Colors.grey[600],
            ),
          ),
          Text(
            '($count)',
            style: TextStyle(
              fontSize: 10.h,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRetentionPatterns() {
    final retention = demographicsData['retention'] ?? {};
    final avgViewTime = retention['average_view_time'] ?? 0;
    final retentionRate = retention['retention_rate'] ?? 0.0;
    final dropoffPoints = retention['dropoff_points'] as List<dynamic>? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Audience Retention',
          style: TextStyle(
            fontSize: 16.h,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _buildRetentionMetric(
                'Avg. View Time',
                _formatDuration(avgViewTime),
                Icons.schedule,
              ),
            ),
            Expanded(
              child: _buildRetentionMetric(
                'Retention Rate',
                '${retentionRate.toStringAsFixed(1)}%',
                Icons.people,
              ),
            ),
          ],
        ),
        if (dropoffPoints.isNotEmpty) ...[
          SizedBox(height: 12.h),
          Text(
            'Major Drop-off Points',
            style: TextStyle(
              fontSize: 14.h,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          ...dropoffPoints.take(3).map((point) => _buildDropoffItem(point)),
        ],
      ],
    );
  }

  Widget _buildRetentionMetric(String title, String value, IconData icon) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.h),
      padding: EdgeInsets.all(12.h),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8.h),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 20.h,
            color: Colors.grey[600],
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
      ),
    );
  }

  Widget _buildDropoffItem(Map<String, dynamic> dropoff) {
    final time = dropoff['time_point'] ?? 0;
    final percentage = dropoff['percentage'] ?? 0.0;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        children: [
          Icon(
            Icons.trending_down,
            size: 16.h,
            color: Colors.red[400],
          ),
          SizedBox(width: 8.h),
          Text(
            '${_formatDuration(time)} - ${percentage.toStringAsFixed(1)}% dropped',
            style: TextStyle(
              fontSize: 12.h,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: EdgeInsets.all(24.h),
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 14.h,
          ),
        ),
      ),
    );
  }

  String _getCountryFlag(String country) {
    // Simple country to flag emoji mapping
    final flagMap = {
      'United States': '🇺🇸',
      'United Kingdom': '🇬🇧',
      'Canada': '🇨🇦',
      'Australia': '🇦🇺',
      'Germany': '🇩🇪',
      'France': '🇫🇷',
      'Japan': '🇯🇵',
      'India': '🇮🇳',
      'Brazil': '🇧🇷',
      'Mexico': '🇲🇽',
    };
    return flagMap[country] ?? '🌍';
  }

  IconData _getDeviceIcon(String deviceType) {
    switch (deviceType.toLowerCase()) {
      case 'mobile':
        return Icons.phone_android;
      case 'desktop':
        return Icons.computer;
      case 'tablet':
        return Icons.tablet;
      default:
        return Icons.device_unknown;
    }
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
