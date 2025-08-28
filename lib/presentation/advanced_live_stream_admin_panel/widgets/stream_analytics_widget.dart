import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class StreamAnalyticsWidget extends StatefulWidget {
  const StreamAnalyticsWidget({Key? key}) : super(key: key);

  @override
  State<StreamAnalyticsWidget> createState() => _StreamAnalyticsWidgetState();
}

class _StreamAnalyticsWidgetState extends State<StreamAnalyticsWidget> {
  String _selectedPeriod = '7d';
  String _selectedMetric = 'viewers';
  Map<String, dynamic> _analyticsData = {};

  @override
  void initState() {
    super.initState();
    _loadAnalyticsData();
  }

  void _loadAnalyticsData() {
    // Mock analytics data
    _analyticsData = {
      'total_streams': 125,
      'active_streams': 8,
      'total_viewers': 12500,
      'peak_viewers': 2850,
      'avg_watch_time': 18.5,
      'engagement_rate': 72.3,
      'viewer_growth': 15.2,
      'stream_quality_avg': 8.5,
      'top_streams': [
        {
          'title': 'Vintage Watch Collection',
          'viewers': 1250,
          'duration': 120,
          'revenue': 8500.00,
        },
        {
          'title': 'Designer Handbag Auction',
          'viewers': 980,
          'duration': 95,
          'revenue': 6200.00,
        },
        {
          'title': 'Antique Furniture Sale',
          'viewers': 750,
          'duration': 140,
          'revenue': 4800.00,
        },
      ],
      'hourly_data': List.generate(
          24,
          (index) => {
                'hour': index,
                'viewers': 200 + (index * 50) + (index > 12 ? 300 : 0),
                'streams': 2 + (index ~/ 4),
                'engagement': 60 + (index * 2),
              }),
    };

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildAnalyticsHeader(),
        const SizedBox(height: 16),
        _buildMetricsChart(),
        const SizedBox(height: 16),
        Expanded(
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildTopStreams(),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildRealTimeMetrics(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(26),
            spreadRadius: 1,
            blurRadius: 4,
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
                'Stream Analytics',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  DropdownButton<String>(
                    value: _selectedMetric,
                    items: const [
                      DropdownMenuItem(
                          value: 'viewers', child: Text('Viewers')),
                      DropdownMenuItem(
                          value: 'engagement', child: Text('Engagement')),
                      DropdownMenuItem(
                          value: 'revenue', child: Text('Revenue')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedMetric = value!;
                      });
                    },
                  ),
                  const SizedBox(width: 16),
                  DropdownButton<String>(
                    value: _selectedPeriod,
                    items: const [
                      DropdownMenuItem(
                          value: '24h', child: Text('Last 24 hours')),
                      DropdownMenuItem(value: '7d', child: Text('Last 7 days')),
                      DropdownMenuItem(
                          value: '30d', child: Text('Last 30 days')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedPeriod = value!;
                      });
                      _loadAnalyticsData();
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 4,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 2.5,
            children: [
              _buildMetricCard(
                'Total Streams',
                '${_analyticsData['total_streams'] ?? 0}',
                Icons.play_circle,
                Colors.blue,
                '${_analyticsData['active_streams'] ?? 0} active',
              ),
              _buildMetricCard(
                'Total Viewers',
                '${_formatNumber(_analyticsData['total_viewers'] ?? 0)}',
                Icons.people,
                Colors.green,
                'Peak: ${_formatNumber(_analyticsData['peak_viewers'] ?? 0)}',
              ),
              _buildMetricCard(
                'Avg. Watch Time',
                '${(_analyticsData['avg_watch_time'] ?? 0).toStringAsFixed(1)}m',
                Icons.schedule,
                Colors.orange,
                '+${(_analyticsData['viewer_growth'] ?? 0).toStringAsFixed(1)}%',
              ),
              _buildMetricCard(
                'Engagement Rate',
                '${(_analyticsData['engagement_rate'] ?? 0).toStringAsFixed(1)}%',
                Icons.favorite,
                Colors.purple,
                'Quality: ${(_analyticsData['stream_quality_avg'] ?? 0).toStringAsFixed(1)}/10',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
      String title, String value, IconData icon, Color color, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(77)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 20),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 10,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsChart() {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(26),
            spreadRadius: 1,
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_selectedMetric.toUpperCase()} - ${_selectedPeriod}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text('${value.toInt()}h');
                      },
                    ),
                  ),
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: true),
                lineBarsData: [
                  LineChartBarData(
                    spots: _getChartSpots(),
                    isCurved: true,
                    color: _getMetricColor(),
                    barWidth: 3,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: _getMetricColor().withAlpha(26),
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

  List<FlSpot> _getChartSpots() {
    final hourlyData = _analyticsData['hourly_data'] as List<dynamic>? ?? [];
    return hourlyData.map<FlSpot>((data) {
      double value;
      switch (_selectedMetric) {
        case 'engagement':
          value = (data['engagement'] ?? 0).toDouble();
          break;
        case 'revenue':
          value =
              (data['viewers'] ?? 0).toDouble() * 5; // Mock revenue calculation
          break;
        default:
          value = (data['viewers'] ?? 0).toDouble();
      }
      return FlSpot((data['hour'] ?? 0).toDouble(), value);
    }).toList();
  }

  Color _getMetricColor() {
    switch (_selectedMetric) {
      case 'engagement':
        return Colors.purple;
      case 'revenue':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  Widget _buildTopStreams() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(26),
            spreadRadius: 1,
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top Performing Streams',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount:
                  (_analyticsData['top_streams'] as List<dynamic>?)?.length ??
                      0,
              itemBuilder: (context, index) {
                final stream =
                    (_analyticsData['top_streams'] as List<dynamic>)[index];
                return _buildTopStreamItem(stream, index + 1);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopStreamItem(Map<String, dynamic> stream, int rank) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: _getRankColor(rank),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$rank',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        title: Text(
          stream['title'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${stream['viewers']} viewers • ${stream['duration']}min'),
            Text(
              'Revenue: \$${stream['revenue'].toStringAsFixed(2)}',
              style: TextStyle(
                  color: Colors.green[600], fontWeight: FontWeight.w500),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _showStreamDetails(stream),
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey[400]!;
      case 3:
        return Colors.orange[700]!;
      default:
        return Colors.blue;
    }
  }

  Widget _buildRealTimeMetrics() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(26),
            spreadRadius: 1,
            blurRadius: 4,
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
                'Real-Time Metrics',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Column(
              children: [
                _buildRealTimeMetricItem(
                    'Active Streams', '8', Icons.play_circle, Colors.blue),
                _buildRealTimeMetricItem(
                    'Current Viewers', '1,247', Icons.people, Colors.green),
                _buildRealTimeMetricItem(
                    'Bids/Min', '15.3', Icons.gavel, Colors.orange),
                _buildRealTimeMetricItem(
                    'Chat Messages', '342/min', Icons.chat, Colors.purple),
                _buildRealTimeMetricItem(
                    'Avg Quality', '8.7/10', Icons.hd, Colors.red),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRealTimeMetricItem(
      String title, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(26),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  void _showStreamDetails(Map<String, dynamic> stream) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Stream Details'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Title: ${stream['title']}'),
            const SizedBox(height: 8),
            Text('Viewers: ${stream['viewers']}'),
            const SizedBox(height: 8),
            Text('Duration: ${stream['duration']} minutes'),
            const SizedBox(height: 8),
            Text('Revenue: \$${stream['revenue'].toStringAsFixed(2)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
