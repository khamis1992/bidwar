import 'package:flutter/material.dart';

class StreamMonitoringWidget extends StatefulWidget {
  final List<Map<String, dynamic>> activeStreams;
  final VoidCallback onRefresh;

  const StreamMonitoringWidget({
    Key? key,
    required this.activeStreams,
    required this.onRefresh,
  }) : super(key: key);

  @override
  State<StreamMonitoringWidget> createState() => _StreamMonitoringWidgetState();
}

class _StreamMonitoringWidgetState extends State<StreamMonitoringWidget> {
  String _selectedView = 'grid';
  String _sortBy = 'viewers';
  String _filterStatus = 'all';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildControlPanel(),
          const SizedBox(height: 16),
          Expanded(
            child:
                _selectedView == 'grid' ? _buildGridView() : _buildListView(),
          ),
        ],
      ),
    );
  }

  Widget _buildControlPanel() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Real-time Stream Monitoring',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                // View Toggle
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildToggleButton(
                        'Grid',
                        Icons.grid_view,
                        _selectedView == 'grid',
                        () => setState(() => _selectedView = 'grid'),
                      ),
                      _buildToggleButton(
                        'List',
                        Icons.list,
                        _selectedView == 'list',
                        () => setState(() => _selectedView = 'list'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),

                // Sort Options
                SizedBox(
                  width: 150,
                  child: DropdownButtonFormField<String>(
                    value: _sortBy,
                    decoration: const InputDecoration(
                      labelText: 'Sort by',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: 'viewers', child: Text('Viewer Count')),
                      DropdownMenuItem(
                          value: 'duration', child: Text('Duration')),
                      DropdownMenuItem(
                          value: 'revenue', child: Text('Revenue')),
                      DropdownMenuItem(
                          value: 'quality', child: Text('Stream Quality')),
                    ],
                    onChanged: (value) => setState(() => _sortBy = value!),
                  ),
                ),
                const SizedBox(width: 16),

                // Filter Options
                SizedBox(
                  width: 120,
                  child: DropdownButtonFormField<String>(
                    value: _filterStatus,
                    decoration: const InputDecoration(
                      labelText: 'Filter',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: 'all', child: Text('All Streams')),
                      DropdownMenuItem(value: 'live', child: Text('Live Only')),
                      DropdownMenuItem(
                          value: 'issues', child: Text('With Issues')),
                      DropdownMenuItem(
                          value: 'high_traffic', child: Text('High Traffic')),
                    ],
                    onChanged: (value) =>
                        setState(() => _filterStatus = value!),
                  ),
                ),
                const Spacer(),

                // Refresh Button
                ElevatedButton.icon(
                  onPressed: widget.onRefresh,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Quick Stats
            Row(
              children: [
                _buildQuickStat('Total Streams',
                    widget.activeStreams.length.toString(), Colors.blue),
                const SizedBox(width: 20),
                _buildQuickStat(
                  'Total Viewers',
                  _calculateTotalViewers().toString(),
                  Colors.green,
                ),
                const SizedBox(width: 20),
                _buildQuickStat(
                  'Avg Duration',
                  _calculateAverageDuration(),
                  Colors.orange,
                ),
                const SizedBox(width: 20),
                _buildQuickStat(
                  'Revenue/Hour',
                  '\$${_calculateRevenuePerHour()}',
                  Colors.purple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButton(
      String label, IconData icon, bool selected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? Colors.white : Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildGridView() {
    final filteredStreams = _getFilteredStreams();

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: filteredStreams.length,
      itemBuilder: (context, index) {
        final stream = filteredStreams[index];
        return _buildStreamCard(stream);
      },
    );
  }

  Widget _buildListView() {
    final filteredStreams = _getFilteredStreams();

    return ListView.builder(
      itemCount: filteredStreams.length,
      itemBuilder: (context, index) {
        final stream = filteredStreams[index];
        return _buildStreamListItem(stream);
      },
    );
  }

  Widget _buildStreamCard(Map<String, dynamic> stream) {
    return Card(
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(8)),
                color: Colors.grey[200],
              ),
              child: Stack(
                children: [
                  // Thumbnail placeholder
                  Center(
                    child: Icon(
                      Icons.live_tv,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                  ),

                  // Live indicator
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'LIVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // Viewer count
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.visibility,
                              color: Colors.white, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            '${stream['viewer_count'] ?? 0}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Quality indicator
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: _getQualityColor(stream),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Icon(
                        Icons.signal_cellular_4_bar,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stream['title'] ?? 'Unknown Stream',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Duration: ${_formatDuration(stream['actual_start'])}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildHealthIndicator(stream),
                      PopupMenuButton(
                        icon: const Icon(Icons.more_vert, size: 16),
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'view_details',
                            child: Text('View Details'),
                          ),
                          const PopupMenuItem(
                            value: 'send_warning',
                            child: Text('Send Warning'),
                          ),
                          const PopupMenuItem(
                            value: 'emergency_stop',
                            child: Text('Emergency Stop'),
                          ),
                        ],
                        onSelected: (value) =>
                            _handleStreamAction(value, stream),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreamListItem(Map<String, dynamic> stream) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Container(
          width: 80,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            children: [
              Center(
                child: Icon(
                  Icons.live_tv,
                  color: Colors.grey[400],
                ),
              ),
              Positioned(
                top: 4,
                left: 4,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'LIVE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        title: Text(
          stream['title'] ?? 'Unknown Stream',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Duration: ${_formatDuration(stream['actual_start'])}'),
            Text('Channel: ${stream['agora_channel_id'] ?? 'Unknown'}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.visibility, size: 16),
                    const SizedBox(width: 4),
                    Text('${stream['viewer_count'] ?? 0}'),
                  ],
                ),
                const SizedBox(height: 4),
                _buildHealthIndicator(stream),
              ],
            ),
            const SizedBox(width: 16),
            PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'view_details',
                  child: Text('View Details'),
                ),
                const PopupMenuItem(
                  value: 'send_warning',
                  child: Text('Send Warning'),
                ),
                const PopupMenuItem(
                  value: 'emergency_stop',
                  child: Text('Emergency Stop'),
                ),
              ],
              onSelected: (value) => _handleStreamAction(value, stream),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthIndicator(Map<String, dynamic> stream) {
    final health = _calculateStreamHealth(stream);
    Color color;
    String label;

    if (health >= 80) {
      color = Colors.green;
      label = 'Good';
    } else if (health >= 60) {
      color = Colors.orange;
      label = 'Fair';
    } else {
      color = Colors.red;
      label = 'Poor';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(77)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredStreams() {
    List<Map<String, dynamic>> filtered = List.from(widget.activeStreams);

    // Apply filters
    switch (_filterStatus) {
      case 'live':
        filtered = filtered.where((s) => s['status'] == 'live').toList();
        break;
      case 'issues':
        filtered =
            filtered.where((s) => _calculateStreamHealth(s) < 60).toList();
        break;
      case 'high_traffic':
        filtered =
            filtered.where((s) => (s['viewer_count'] ?? 0) > 100).toList();
        break;
    }

    // Apply sorting
    switch (_sortBy) {
      case 'viewers':
        filtered.sort((a, b) => ((b['viewer_count'] ?? 0) as int)
            .compareTo((a['viewer_count'] ?? 0) as int));
        break;
      case 'duration':
        filtered.sort(
            (a, b) => _compareDuration(a['actual_start'], b['actual_start']));
        break;
      case 'quality':
        filtered.sort((a, b) =>
            _calculateStreamHealth(b).compareTo(_calculateStreamHealth(a)));
        break;
    }

    return filtered;
  }

  Color _getQualityColor(Map<String, dynamic> stream) {
    final health = _calculateStreamHealth(stream);
    if (health >= 80) return Colors.green;
    if (health >= 60) return Colors.orange;
    return Colors.red;
  }

  int _calculateStreamHealth(Map<String, dynamic> stream) {
    // Simulate stream health calculation based on various factors
    final viewerCount = stream['viewer_count'] ?? 0;
    final maxViewers = stream['max_viewers'] ?? 1;
    final duration = _parseDuration(stream['actual_start']);

    int health = 90;

    // Penalize for low viewer retention
    if (maxViewers > 0 && viewerCount < maxViewers * 0.5) {
      health -= 20;
    }

    // Penalize for very long streams (potential issues)
    if (duration > 4) {
      health -= 10;
    }

    return health.clamp(0, 100);
  }

  int _calculateTotalViewers() {
    return widget.activeStreams.fold<int>(
      0,
      (sum, stream) => sum + ((stream['viewer_count'] as int?) ?? 0),
    );
  }

  String _calculateAverageDuration() {
    if (widget.activeStreams.isEmpty) return '0h';

    final totalMinutes = widget.activeStreams.fold<int>(
      0,
      (sum, stream) =>
          sum + (_parseDuration(stream['actual_start']) * 60).round(),
    );

    final avgMinutes = totalMinutes ~/ widget.activeStreams.length;
    final hours = avgMinutes ~/ 60;
    final minutes = avgMinutes % 60;

    return '${hours}h ${minutes}m';
  }

  String _calculateRevenuePerHour() {
    // Simulate revenue calculation
    final totalViewers = _calculateTotalViewers();
    final revenue = totalViewers * 0.05; // $0.05 per viewer per hour
    return revenue.toStringAsFixed(2);
  }

  double _parseDuration(String? startTime) {
    if (startTime == null) return 0;

    try {
      final start = DateTime.parse(startTime);
      final duration = DateTime.now().difference(start);
      return duration.inMinutes / 60.0;
    } catch (e) {
      return 0;
    }
  }

  String _formatDuration(String? startTime) {
    final hours = _parseDuration(startTime);

    if (hours >= 1) {
      return '${hours.toInt()}h ${((hours % 1) * 60).toInt()}m';
    } else {
      return '${(hours * 60).toInt()}m';
    }
  }

  int _compareDuration(String? a, String? b) {
    final durationA = _parseDuration(a);
    final durationB = _parseDuration(b);
    return durationB.compareTo(durationA);
  }

  void _handleStreamAction(String action, Map<String, dynamic> stream) {
    switch (action) {
      case 'view_details':
        _showStreamDetails(stream);
        break;
      case 'send_warning':
        _sendWarning(stream);
        break;
      case 'emergency_stop':
        _emergencyStop(stream);
        break;
    }
  }

  void _showStreamDetails(Map<String, dynamic> stream) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Stream Details: ${stream['title']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Stream ID', stream['id']),
              _buildDetailRow('Channel ID', stream['agora_channel_id']),
              _buildDetailRow('Status', stream['status']),
              _buildDetailRow('Viewers', '${stream['viewer_count'] ?? 0}'),
              _buildDetailRow('Max Viewers', '${stream['max_viewers'] ?? 0}'),
              _buildDetailRow(
                  'Started', _formatTimestamp(stream['actual_start'])),
              _buildDetailRow(
                  'Health Score', '${_calculateStreamHealth(stream)}%'),
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

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value ?? 'N/A'),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(String? timestamp) {
    if (timestamp == null) return 'Unknown';

    try {
      final dateTime = DateTime.parse(timestamp);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Invalid date';
    }
  }

  void _sendWarning(Map<String, dynamic> stream) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Warning sent to ${stream['title']}'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _emergencyStop(Map<String, dynamic> stream) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Emergency Stop'),
        content: Text('Are you sure you want to stop "${stream['title']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Stream "${stream['title']}" stopped'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Stop Stream'),
          ),
        ],
      ),
    );
  }
}
