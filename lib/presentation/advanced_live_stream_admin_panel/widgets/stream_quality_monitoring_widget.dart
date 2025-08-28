import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class StreamQualityMonitoringWidget extends StatefulWidget {
  const StreamQualityMonitoringWidget({Key? key}) : super(key: key);

  @override
  State<StreamQualityMonitoringWidget> createState() =>
      _StreamQualityMonitoringWidgetState();
}

class _StreamQualityMonitoringWidgetState
    extends State<StreamQualityMonitoringWidget> {
  List<Map<String, dynamic>> _qualityMetrics = [];
  List<Map<String, dynamic>> _activeStreams = [];
  String _selectedTimeframe = '1h';

  @override
  void initState() {
    super.initState();
    _loadQualityData();
  }

  void _loadQualityData() {
    // Mock quality monitoring data
    _qualityMetrics = [
      {
        'metric': 'Average Bitrate',
        'value': '2.4 Mbps',
        'status': 'good',
        'target': '2.0 Mbps',
        'trend': 'up',
      },
      {
        'metric': 'Frame Rate',
        'value': '29.8 fps',
        'status': 'excellent',
        'target': '30 fps',
        'trend': 'stable',
      },
      {
        'metric': 'Latency',
        'value': '180ms',
        'status': 'warning',
        'target': '<150ms',
        'trend': 'up',
      },
      {
        'metric': 'Packet Loss',
        'value': '0.2%',
        'status': 'good',
        'target': '<0.5%',
        'trend': 'down',
      },
    ];

    _activeStreams = [
      {
        'stream_id': 'stream_001',
        'title': 'Vintage Watch Auction',
        'streamer': 'John Doe',
        'quality_score': 9.2,
        'resolution': '1080p',
        'bitrate': 2800,
        'fps': 30,
        'latency': 120,
        'viewers': 845,
        'issues': [],
      },
      {
        'stream_id': 'stream_002',
        'title': 'Art Collection Live',
        'streamer': 'Jane Smith',
        'quality_score': 7.8,
        'resolution': '720p',
        'bitrate': 1800,
        'fps': 28,
        'latency': 250,
        'viewers': 432,
        'issues': ['High Latency'],
      },
      {
        'stream_id': 'stream_003',
        'title': 'Electronics Clearance',
        'streamer': 'Mike Johnson',
        'quality_score': 6.5,
        'resolution': '1080p',
        'bitrate': 1200,
        'fps': 25,
        'latency': 180,
        'viewers': 623,
        'issues': ['Low Bitrate', 'Frame Drops'],
      },
    ];

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildQualityOverview(),
        const SizedBox(height: 16),
        _buildQualityChart(),
        const SizedBox(height: 16),
        Expanded(
          child: _buildActiveStreamsList(),
        ),
      ],
    );
  }

  Widget _buildQualityOverview() {
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
                'Quality Monitoring Dashboard',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              DropdownButton<String>(
                value: _selectedTimeframe,
                items: const [
                  DropdownMenuItem(value: '1h', child: Text('Last Hour')),
                  DropdownMenuItem(value: '6h', child: Text('Last 6 Hours')),
                  DropdownMenuItem(value: '24h', child: Text('Last 24 Hours')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedTimeframe = value!;
                  });
                  _loadQualityData();
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 4,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 2,
            children: _qualityMetrics.map((metric) {
              return _buildQualityMetricCard(metric);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildQualityMetricCard(Map<String, dynamic> metric) {
    Color statusColor = _getStatusColor(metric['status']);
    IconData trendIcon = _getTrendIcon(metric['trend']);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withAlpha(26),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withAlpha(77)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(trendIcon, color: statusColor, size: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(51),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  metric['status'].toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Text(
            metric['value'],
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                metric['metric'],
                style:
                    const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
              ),
              Text(
                'Target: ${metric['target']}',
                style: TextStyle(
                  fontSize: 8,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQualityChart() {
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
          const Text(
            'Quality Trends Over Time',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text('${value.toInt()}');
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text('${value.toInt()}m');
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
                  // Quality Score Line
                  LineChartBarData(
                    spots: [
                      FlSpot(0, 8.2),
                      FlSpot(10, 8.5),
                      FlSpot(20, 7.8),
                      FlSpot(30, 8.9),
                      FlSpot(40, 8.1),
                      FlSpot(50, 8.7),
                      FlSpot(60, 8.4),
                    ],
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 3,
                    dotData: FlDotData(show: false),
                  ),
                  // Latency Line (scaled)
                  LineChartBarData(
                    spots: [
                      FlSpot(0, 1.8),
                      FlSpot(10, 1.5),
                      FlSpot(20, 2.2),
                      FlSpot(30, 1.4),
                      FlSpot(40, 1.9),
                      FlSpot(50, 1.6),
                      FlSpot(60, 1.8),
                    ],
                    isCurved: true,
                    color: Colors.orange,
                    barWidth: 2,
                    dotData: FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildChartLegend('Quality Score', Colors.blue),
              const SizedBox(width: 20),
              _buildChartLegend('Latency (x100ms)', Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 2,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildActiveStreamsList() {
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
            'Active Streams Quality Monitor',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _activeStreams.length,
              itemBuilder: (context, index) {
                final stream = _activeStreams[index];
                return _buildStreamQualityCard(stream);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreamQualityCard(Map<String, dynamic> stream) {
    double qualityScore = stream['quality_score'];
    Color scoreColor = _getScoreColor(qualityScore);
    List<String> issues = List<String>.from(stream['issues'] ?? []);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stream['title'],
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        stream['streamer'],
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: scoreColor.withAlpha(26),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: scoreColor.withAlpha(128)),
                      ),
                      child: Text(
                        '${qualityScore.toStringAsFixed(1)}/10',
                        style: TextStyle(
                          color: scoreColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${stream['viewers']} viewers',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildQualityBadge('${stream['resolution']}', Colors.blue),
                _buildQualityBadge(
                    '${(stream['bitrate'] / 1000).toStringAsFixed(1)} Mbps',
                    Colors.green),
                _buildQualityBadge('${stream['fps']} fps', Colors.orange),
                _buildQualityBadge('${stream['latency']}ms', Colors.purple),
              ],
            ),
            if (issues.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: issues.map((issue) {
                  return Chip(
                    label: Text(
                      issue,
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: Colors.red.withAlpha(26),
                    side: BorderSide(color: Colors.red.withAlpha(77)),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () => _showDetailedMetrics(stream),
                  icon: const Icon(Icons.analytics, size: 16),
                  label: const Text('View Details'),
                ),
                Row(
                  children: [
                    if (issues.isNotEmpty)
                      TextButton.icon(
                        onPressed: () => _resolveIssues(stream['stream_id']),
                        icon: const Icon(Icons.build,
                            size: 16, color: Colors.orange),
                        label: const Text('Fix Issues'),
                        style: TextButton.styleFrom(
                            foregroundColor: Colors.orange),
                      ),
                    TextButton.icon(
                      onPressed: () => _optimizeStream(stream['stream_id']),
                      icon: const Icon(Icons.tune, size: 16),
                      label: const Text('Optimize'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQualityBadge(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(77)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'excellent':
        return Colors.green;
      case 'good':
        return Colors.blue;
      case 'warning':
        return Colors.orange;
      case 'error':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getScoreColor(double score) {
    if (score >= 8.5) return Colors.green;
    if (score >= 7.0) return Colors.blue;
    if (score >= 5.5) return Colors.orange;
    return Colors.red;
  }

  IconData _getTrendIcon(String trend) {
    switch (trend) {
      case 'up':
        return Icons.trending_up;
      case 'down':
        return Icons.trending_down;
      case 'stable':
        return Icons.trending_flat;
      default:
        return Icons.remove;
    }
  }

  void _showDetailedMetrics(Map<String, dynamic> stream) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detailed Metrics - ${stream['title']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Stream ID: ${stream['stream_id']}'),
              const SizedBox(height: 8),
              Text('Quality Score: ${stream['quality_score']}/10'),
              const SizedBox(height: 8),
              Text('Resolution: ${stream['resolution']}'),
              const SizedBox(height: 8),
              Text('Bitrate: ${stream['bitrate']} kbps'),
              const SizedBox(height: 8),
              Text('Frame Rate: ${stream['fps']} fps'),
              const SizedBox(height: 8),
              Text('Latency: ${stream['latency']}ms'),
              const SizedBox(height: 8),
              Text('Current Viewers: ${stream['viewers']}'),
              if (stream['issues'].isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Issues: ${(stream['issues'] as List).join(', ')}'),
              ],
            ],
          ),
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

  void _resolveIssues(String streamId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Attempting to resolve issues for stream $streamId'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _optimizeStream(String streamId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Optimizing stream settings for $streamId'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
