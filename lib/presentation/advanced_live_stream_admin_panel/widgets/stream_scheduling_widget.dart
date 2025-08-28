import 'package:flutter/material.dart';

class StreamSchedulingWidget extends StatefulWidget {
  const StreamSchedulingWidget({Key? key}) : super(key: key);

  @override
  State<StreamSchedulingWidget> createState() => _StreamSchedulingWidgetState();
}

class _StreamSchedulingWidgetState extends State<StreamSchedulingWidget> {
  List<Map<String, dynamic>> _scheduledStreams = [];
  String _selectedView = 'upcoming';
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadScheduledStreams();
  }

  void _loadScheduledStreams() {
    // Mock scheduled streams data
    _scheduledStreams = [
      {
        'id': 'schedule_001',
        'title': 'Luxury Watch Collection Preview',
        'streamer': 'John Doe',
        'streamer_id': 'user_123',
        'scheduled_time': DateTime.now().add(Duration(hours: 2)),
        'expected_duration': 90,
        'category': 'Watches',
        'status': 'confirmed',
        'estimated_viewers': 500,
        'auction_items_count': 12,
        'notification_sent': true,
      },
      {
        'id': 'schedule_002',
        'title': 'Vintage Electronics Auction',
        'streamer': 'Jane Smith',
        'streamer_id': 'user_456',
        'scheduled_time': DateTime.now().add(Duration(hours: 6)),
        'expected_duration': 120,
        'category': 'Electronics',
        'status': 'pending_approval',
        'estimated_viewers': 300,
        'auction_items_count': 8,
        'notification_sent': false,
      },
      {
        'id': 'schedule_003',
        'title': 'Art and Collectibles Show',
        'streamer': 'Mike Johnson',
        'streamer_id': 'user_789',
        'scheduled_time': DateTime.now().add(Duration(days: 1)),
        'expected_duration': 150,
        'category': 'Art',
        'status': 'confirmed',
        'estimated_viewers': 750,
        'auction_items_count': 25,
        'notification_sent': false,
      },
      {
        'id': 'schedule_004',
        'title': 'Fashion Accessories Live Sale',
        'streamer': 'Sarah Wilson',
        'streamer_id': 'user_321',
        'scheduled_time': DateTime.now().subtract(Duration(hours: 2)),
        'expected_duration': 60,
        'category': 'Fashion',
        'status': 'completed',
        'estimated_viewers': 200,
        'auction_items_count': 15,
        'notification_sent': true,
      },
    ];

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSchedulingHeader(),
        _buildViewToggle(),
        Expanded(
          child: _buildStreamsList(),
        ),
      ],
    );
  }

  Widget _buildSchedulingHeader() {
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
                'Stream Scheduling Management',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: _showCreateStreamDialog,
                icon: const Icon(Icons.add),
                label: const Text('Schedule Stream'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                    'Scheduled Today', _getScheduledTodayCount(), Colors.blue),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard('Pending Approval',
                    _getPendingApprovalCount(), Colors.orange),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                    'This Week', _getScheduledWeekCount(), Colors.green),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                    'Completed', _getCompletedCount(), Colors.purple),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, int count, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(77)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
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

  Widget _buildViewToggle() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          _buildViewTab('upcoming', 'Upcoming'),
          _buildViewTab('pending', 'Pending Approval'),
          _buildViewTab('completed', 'Completed'),
          _buildViewTab('all', 'All'),
        ],
      ),
    );
  }

  Widget _buildViewTab(String view, String label) {
    bool isSelected = _selectedView == view;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedView = view;
          });
        },
        backgroundColor: isSelected ? Colors.blue : Colors.grey[100],
        selectedColor: Colors.blue.withAlpha(51),
        checkmarkColor: Colors.blue,
      ),
    );
  }

  Widget _buildStreamsList() {
    List<Map<String, dynamic>> filteredStreams = _getFilteredStreams();

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
          Text(
            '${_selectedView.toUpperCase()} STREAMS',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: filteredStreams.length,
              itemBuilder: (context, index) {
                final stream = filteredStreams[index];
                return _buildStreamCard(stream);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreamCard(Map<String, dynamic> stream) {
    Color statusColor = _getStatusColor(stream['status']);
    bool isUpcoming = DateTime.now().isBefore(stream['scheduled_time']);

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
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'by ${stream['streamer']}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(26),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor.withAlpha(128)),
                  ),
                  child: Text(
                    stream['status'].toUpperCase().replaceAll('_', ' '),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  _formatDateTime(stream['scheduled_time']),
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(width: 20),
                Icon(Icons.timer, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${stream['expected_duration']} min',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(width: 20),
                Icon(Icons.category, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  stream['category'],
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildInfoChip(
                    '${stream['estimated_viewers']} viewers', Colors.blue),
                _buildInfoChip(
                    '${stream['auction_items_count']} items', Colors.green),
                if (stream['notification_sent'])
                  _buildInfoChip('Notified', Colors.purple),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (isUpcoming && stream['status'] == 'pending_approval')
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: () => _approveStream(stream['id']),
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text('Approve'),
                        style:
                            TextButton.styleFrom(foregroundColor: Colors.green),
                      ),
                      TextButton.icon(
                        onPressed: () => _rejectStream(stream['id']),
                        icon: const Icon(Icons.close, size: 16),
                        label: const Text('Reject'),
                        style:
                            TextButton.styleFrom(foregroundColor: Colors.red),
                      ),
                    ],
                  ),
                Row(
                  children: [
                    if (isUpcoming && !stream['notification_sent'])
                      TextButton.icon(
                        onPressed: () => _sendNotification(stream['id']),
                        icon: const Icon(Icons.notifications, size: 16),
                        label: const Text('Send Notification'),
                      ),
                    TextButton.icon(
                      onPressed: () => _editStream(stream),
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Edit'),
                    ),
                    if (isUpcoming)
                      TextButton.icon(
                        onPressed: () => _rescheduleStream(stream),
                        icon: const Icon(Icons.schedule, size: 16),
                        label: const Text('Reschedule'),
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

  Widget _buildInfoChip(String text, Color color) {
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

  List<Map<String, dynamic>> _getFilteredStreams() {
    switch (_selectedView) {
      case 'upcoming':
        return _scheduledStreams.where((stream) {
          return DateTime.now().isBefore(stream['scheduled_time']) &&
              stream['status'] != 'completed';
        }).toList();
      case 'pending':
        return _scheduledStreams
            .where((stream) => stream['status'] == 'pending_approval')
            .toList();
      case 'completed':
        return _scheduledStreams
            .where((stream) => stream['status'] == 'completed')
            .toList();
      default:
        return _scheduledStreams;
    }
  }

  int _getScheduledTodayCount() {
    final today = DateTime.now();
    return _scheduledStreams.where((stream) {
      final streamDate = stream['scheduled_time'] as DateTime;
      return streamDate.year == today.year &&
          streamDate.month == today.month &&
          streamDate.day == today.day;
    }).length;
  }

  int _getPendingApprovalCount() {
    return _scheduledStreams
        .where((stream) => stream['status'] == 'pending_approval')
        .length;
  }

  int _getScheduledWeekCount() {
    final today = DateTime.now();
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final weekEnd = weekStart.add(Duration(days: 6));

    return _scheduledStreams.where((stream) {
      final streamDate = stream['scheduled_time'] as DateTime;
      return streamDate.isAfter(weekStart) &&
          streamDate.isBefore(weekEnd.add(Duration(days: 1)));
    }).length;
  }

  int _getCompletedCount() {
    return _scheduledStreams
        .where((stream) => stream['status'] == 'completed')
        .length;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmed':
        return Colors.green;
      case 'pending_approval':
        return Colors.orange;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = dateTime.difference(now);

    if (diff.inDays == 0) {
      // Today
      return 'Today at ${_formatTime(dateTime)}';
    } else if (diff.inDays == 1) {
      // Tomorrow
      return 'Tomorrow at ${_formatTime(dateTime)}';
    } else if (diff.inDays > 0) {
      // Future
      return '${dateTime.day}/${dateTime.month} at ${_formatTime(dateTime)}';
    } else {
      // Past
      return '${dateTime.day}/${dateTime.month} at ${_formatTime(dateTime)}';
    }
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _showCreateStreamDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Schedule New Stream'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Stream Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Streamer ID',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Expected Duration (minutes)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items:
                    ['Watches', 'Electronics', 'Art', 'Fashion', 'Collectibles']
                        .map((category) => DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            ))
                        .toList(),
                onChanged: (value) {},
              ),
            ],
          ),
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
                const SnackBar(content: Text('Stream scheduled successfully')),
              );
            },
            child: const Text('Schedule'),
          ),
        ],
      ),
    );
  }

  void _approveStream(String streamId) {
    setState(() {
      final stream = _scheduledStreams.firstWhere((s) => s['id'] == streamId);
      stream['status'] = 'confirmed';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Stream approved successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _rejectStream(String streamId) {
    setState(() {
      final stream = _scheduledStreams.firstWhere((s) => s['id'] == streamId);
      stream['status'] = 'cancelled';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Stream rejected'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _sendNotification(String streamId) {
    setState(() {
      final stream = _scheduledStreams.firstWhere((s) => s['id'] == streamId);
      stream['notification_sent'] = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notifications sent to followers')),
    );
  }

  void _editStream(Map<String, dynamic> stream) {
    // Navigate to edit screen or show edit dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit stream: ${stream['title']}')),
    );
  }

  void _rescheduleStream(Map<String, dynamic> stream) {
    // Show reschedule dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Reschedule stream: ${stream['title']}')),
    );
  }
}
