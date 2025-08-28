import 'package:flutter/material.dart';

class EmergencyControlsWidget extends StatefulWidget {
  final Function(String) onEmergencyShutdown;
  final List<Map<String, dynamic>> activeStreams;

  const EmergencyControlsWidget({
    Key? key,
    required this.onEmergencyShutdown,
    required this.activeStreams,
  }) : super(key: key);

  @override
  State<EmergencyControlsWidget> createState() =>
      _EmergencyControlsWidgetState();
}

class _EmergencyControlsWidgetState extends State<EmergencyControlsWidget> {
  bool _showEmergencyControls = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: ExpansionTile(
        leading: Icon(
          Icons.emergency,
          color: Colors.red[700],
        ),
        title: Text(
          'Emergency Controls',
          style: TextStyle(
            color: Colors.red[700],
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: const Text('Critical stream management tools'),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildEmergencyButton(
                        'Emergency Stop All',
                        'Immediately terminate all active streams',
                        Icons.stop_circle,
                        Colors.red,
                        () => _showEmergencyStopAllDialog(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildEmergencyButton(
                        'Platform Maintenance',
                        'Put platform in maintenance mode',
                        Icons.build_circle,
                        Colors.orange,
                        () => _showMaintenanceModeDialog(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildEmergencyButton(
                        'Broadcast Alert',
                        'Send system-wide notification',
                        Icons.campaign,
                        Colors.amber,
                        () => _showBroadcastAlertDialog(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildEmergencyButton(
                        'Resource Monitor',
                        'View system resource usage',
                        Icons.monitor_heart,
                        Colors.blue,
                        () => _showResourceMonitorDialog(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Individual Stream Controls',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ...widget.activeStreams
                    .map((stream) => _buildStreamControl(stream)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyButton(
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStreamControl(Map<String, dynamic> stream) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.red,
          child: const Icon(Icons.live_tv, color: Colors.white, size: 20),
        ),
        title: Text(
          stream['title'] ?? 'Unknown Stream',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Viewers: ${stream['viewer_count'] ?? 0}'),
            Text('Duration: ${_formatDuration(stream['actual_start'])}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.warning, color: Colors.orange),
              onPressed: () => _showStreamWarningDialog(stream),
              tooltip: 'Send Warning',
            ),
            IconButton(
              icon: const Icon(Icons.stop, color: Colors.red),
              onPressed: () => _showEmergencyStopDialog(stream),
              tooltip: 'Emergency Stop',
            ),
          ],
        ),
      ),
    );
  }

  void _showEmergencyStopAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red[700]),
            const SizedBox(width: 8),
            const Text('Emergency Stop All Streams'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This will immediately terminate ALL active streams on the platform.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('Active streams: ${widget.activeStreams.length}'),
            Text('Total viewers affected: ${_calculateTotalViewers()}'),
            const SizedBox(height: 16),
            const Text(
              'This action cannot be undone. Please confirm your decision.',
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              _executeEmergencyStopAll();
            },
            child: const Text('STOP ALL STREAMS'),
          ),
        ],
      ),
    );
  }

  void _showEmergencyStopDialog(Map<String, dynamic> stream) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Emergency Stop Stream'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Stream: ${stream['title']}'),
            Text('Viewers: ${stream['viewer_count'] ?? 0}'),
            const SizedBox(height: 16),
            const Text(
              'This will immediately terminate the stream and notify all viewers.',
              style: TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Reason for termination',
                hintText: 'Enter reason...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onChanged: (value) {
                // Store reason
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              widget.onEmergencyShutdown(stream['id']);
            },
            child: const Text('STOP STREAM'),
          ),
        ],
      ),
    );
  }

  void _showMaintenanceModeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Platform Maintenance Mode'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Enable maintenance mode to:'),
            SizedBox(height: 12),
            Text('• Prevent new streams from starting'),
            Text('• Display maintenance message to users'),
            Text('• Allow existing streams to finish naturally'),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Maintenance message',
                hintText: 'Platform is under maintenance...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Maintenance mode activated'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text('Enable Maintenance'),
          ),
        ],
      ),
    );
  }

  void _showBroadcastAlertDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Broadcast System Alert'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Alert Title',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Alert Message',
                hintText: 'Enter your message...',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CheckboxListTile(
                    title: Text('Show to streamers'),
                    value: true,
                    onChanged: null,
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ),
                Expanded(
                  child: CheckboxListTile(
                    title: Text('Show to viewers'),
                    value: true,
                    onChanged: null,
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Alert broadcasted to all users'),
                ),
              );
            },
            child: const Text('Broadcast'),
          ),
        ],
      ),
    );
  }

  void _showResourceMonitorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('System Resource Monitor'),
        content: SizedBox(
          width: 400,
          height: 300,
          child: Column(
            children: [
              _buildResourceIndicator('CPU Usage', 65, Colors.blue),
              _buildResourceIndicator('Memory Usage', 78, Colors.green),
              _buildResourceIndicator('Bandwidth Usage', 45, Colors.orange),
              _buildResourceIndicator('Storage Usage', 32, Colors.purple),
              const SizedBox(height: 16),
              const Text(
                'Server Load Distribution',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView(
                  children: [
                    ListTile(
                      title: const Text('Stream Server 1'),
                      subtitle: const Text('Active streams: 15'),
                      trailing: Text('CPU: 45%'),
                    ),
                    ListTile(
                      title: const Text('Stream Server 2'),
                      subtitle: const Text('Active streams: 12'),
                      trailing: Text('CPU: 38%'),
                    ),
                    ListTile(
                      title: const Text('Stream Server 3'),
                      subtitle: const Text('Active streams: 8'),
                      trailing: Text('CPU: 25%'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Optimize Resources'),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceIndicator(String label, double percentage, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label),
              Text('${percentage.toInt()}%'),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      ),
    );
  }

  void _showStreamWarningDialog(Map<String, dynamic> stream) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Stream Warning'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Send warning to: ${stream['title']}'),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Warning message',
                hintText: 'Enter warning message...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Warning sent to streamer')),
              );
            },
            child: const Text('Send Warning'),
          ),
        ],
      ),
    );
  }

  void _executeEmergencyStopAll() {
    for (final stream in widget.activeStreams) {
      widget.onEmergencyShutdown(stream['id']);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Emergency stop executed for ${widget.activeStreams.length} streams'),
        backgroundColor: Colors.red,
      ),
    );
  }

  int _calculateTotalViewers() {
    return widget.activeStreams.fold<int>(
      0,
      (sum, stream) => sum + ((stream['viewer_count'] as int?) ?? 0),
    );
  }

  String _formatDuration(String? startTime) {
    if (startTime == null) return 'Unknown';

    try {
      final start = DateTime.parse(startTime);
      final duration = DateTime.now().difference(start);

      if (duration.inHours > 0) {
        return '${duration.inHours}h ${duration.inMinutes % 60}m';
      } else {
        return '${duration.inMinutes}m';
      }
    } catch (e) {
      return 'Unknown';
    }
  }
}
