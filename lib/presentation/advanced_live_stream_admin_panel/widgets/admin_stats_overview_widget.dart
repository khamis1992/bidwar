import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AdminStatsOverviewWidget extends StatelessWidget {
  final Map<String, dynamic> metrics;
  final int activeStreamsCount;

  const AdminStatsOverviewWidget({
    Key? key,
    required this.metrics,
    required this.activeStreamsCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(26),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Platform Overview',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'LIVE',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Active Streams',
                  activeStreamsCount.toString(),
                  Icons.live_tv,
                  Colors.red,
                  '↑ 12% from yesterday',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Total Viewers',
                  _formatNumber(metrics['totalViewers'] ?? 0),
                  Icons.people,
                  Colors.blue,
                  '↑ 8% from yesterday',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Revenue Today',
                  '\$${_formatNumber(metrics['revenueToday'] ?? 0)}',
                  Icons.monetization_on,
                  Colors.green,
                  '↑ 15% from yesterday',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'System Health',
                  '${metrics['systemHealth'] ?? 99}%',
                  Icons.health_and_safety,
                  Colors.orange,
                  'All systems operational',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildActivityChart(),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildAlertsList(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String trend,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(77)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            trend,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityChart() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Stream Activity (Last 24h)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: _generateChartData(),
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.blue.withAlpha(26),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsList() {
    final alerts = [
      {
        'type': 'warning',
        'message': 'High viewer count on Stream #123',
        'time': '2 min ago'
      },
      {'type': 'info', 'message': 'New stream started', 'time': '5 min ago'},
      {
        'type': 'success',
        'message': 'System backup completed',
        'time': '1 hour ago'
      },
    ];

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Alerts',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: alerts.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final alert = alerts[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _getAlertColor(alert['type']!).withAlpha(77),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _getAlertIcon(alert['type']!),
                            color: _getAlertColor(alert['type']!),
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              alert['message']!,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        alert['time']!,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _generateChartData() {
    return [
      const FlSpot(0, 10),
      const FlSpot(1, 15),
      const FlSpot(2, 12),
      const FlSpot(3, 20),
      const FlSpot(4, 18),
      const FlSpot(5, 25),
      const FlSpot(6, 22),
      const FlSpot(7, 30),
      const FlSpot(8, 28),
      const FlSpot(9, 35),
      const FlSpot(10, 32),
      const FlSpot(11, 40),
    ];
  }

  Color _getAlertColor(String type) {
    switch (type) {
      case 'warning':
        return Colors.orange;
      case 'error':
        return Colors.red;
      case 'success':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  IconData _getAlertIcon(String type) {
    switch (type) {
      case 'warning':
        return Icons.warning;
      case 'error':
        return Icons.error;
      case 'success':
        return Icons.check_circle;
      default:
        return Icons.info;
    }
  }

  String _formatNumber(dynamic number) {
    if (number == null) return '0';
    final num value = number is num ? number : 0;
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    } else {
      return value.toString();
    }
  }
}
