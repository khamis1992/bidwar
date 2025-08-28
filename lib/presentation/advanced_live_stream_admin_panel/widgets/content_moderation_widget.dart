import 'package:flutter/material.dart';

class ContentModerationWidget extends StatefulWidget {
  const ContentModerationWidget({Key? key}) : super(key: key);

  @override
  State<ContentModerationWidget> createState() =>
      _ContentModerationWidgetState();
}

class _ContentModerationWidgetState extends State<ContentModerationWidget> {
  List<Map<String, dynamic>> _flaggedContent = [];
  List<Map<String, dynamic>> _moderationQueue = [];
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadModerationData();
  }

  void _loadModerationData() {
    // Mock moderation data
    _flaggedContent = [
      {
        'id': '1',
        'type': 'chat_message',
        'content': 'Inappropriate language detected',
        'stream_id': 'stream_123',
        'stream_title': 'Vintage Watch Auction',
        'reported_by': 'user_456',
        'severity': 'high',
        'timestamp': DateTime.now().subtract(Duration(minutes: 5)),
        'status': 'pending',
      },
      {
        'id': '2',
        'type': 'stream_content',
        'content': 'Potential fake product',
        'stream_id': 'stream_789',
        'stream_title': 'Designer Bag Collection',
        'reported_by': 'user_789',
        'severity': 'medium',
        'timestamp': DateTime.now().subtract(Duration(minutes: 15)),
        'status': 'under_review',
      },
    ];

    _moderationQueue = [
      {
        'id': '3',
        'type': 'user_report',
        'content': 'Seller not responding to questions',
        'stream_id': 'stream_456',
        'stream_title': 'Electronics Sale',
        'reported_by': 'user_321',
        'severity': 'low',
        'timestamp': DateTime.now().subtract(Duration(hours: 1)),
        'status': 'new',
      },
    ];

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildModerationHeader(),
        _buildFilterTabs(),
        Expanded(
          child: _buildModerationList(),
        ),
      ],
    );
  }

  Widget _buildModerationHeader() {
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
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
                'Flagged Items', _flaggedContent.length, Colors.red),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
                'In Queue', _moderationQueue.length, Colors.orange),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard('Resolved Today', 12, Colors.green),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: () => _showModerationSettings(),
            icon: const Icon(Icons.settings),
            label: const Text('Settings'),
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
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    final filters = ['all', 'high_priority', 'pending', 'under_review'];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: filters.map((filter) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(_getFilterLabel(filter)),
              selected: _selectedFilter == filter,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = selected ? filter : 'all';
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getFilterLabel(String filter) {
    switch (filter) {
      case 'high_priority':
        return 'High Priority';
      case 'pending':
        return 'Pending';
      case 'under_review':
        return 'Under Review';
      default:
        return 'All';
    }
  }

  Widget _buildModerationList() {
    final allItems = [..._flaggedContent, ..._moderationQueue];
    final filteredItems = allItems.where((item) {
      if (_selectedFilter == 'all') return true;
      if (_selectedFilter == 'high_priority') return item['severity'] == 'high';
      return item['status'] == _selectedFilter;
    }).toList();

    return ListView.builder(
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        final item = filteredItems[index];
        return _buildModerationItem(item);
      },
    );
  }

  Widget _buildModerationItem(Map<String, dynamic> item) {
    Color severityColor = _getSeverityColor(item['severity']);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 4,
          height: 60,
          decoration: BoxDecoration(
            color: severityColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        title: Text(item['stream_title']),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item['content']),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  _formatTimestamp(item['timestamp']),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(width: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: severityColor.withAlpha(51),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item['severity'].toUpperCase(),
                    style: TextStyle(
                      color: severityColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => _approveContent(item['id']),
              icon: const Icon(Icons.check, color: Colors.green),
              tooltip: 'Approve',
            ),
            IconButton(
              onPressed: () => _rejectContent(item['id']),
              icon: const Icon(Icons.close, color: Colors.red),
              tooltip: 'Reject',
            ),
            IconButton(
              onPressed: () => _viewDetails(item),
              icon: const Icon(Icons.visibility),
              tooltip: 'View Details',
            ),
          ],
        ),
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.yellow[700]!;
      default:
        return Colors.grey;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }

  void _approveContent(String itemId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Content approved'),
        backgroundColor: Colors.green,
      ),
    );
    // Remove from lists and update state
    _flaggedContent.removeWhere((item) => item['id'] == itemId);
    _moderationQueue.removeWhere((item) => item['id'] == itemId);
    setState(() {});
  }

  void _rejectContent(String itemId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Content rejected'),
        backgroundColor: Colors.red,
      ),
    );
    // Remove from lists and update state
    _flaggedContent.removeWhere((item) => item['id'] == itemId);
    _moderationQueue.removeWhere((item) => item['id'] == itemId);
    setState(() {});
  }

  void _viewDetails(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Moderation Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Stream: ${item['stream_title']}'),
              const SizedBox(height: 8),
              Text('Content: ${item['content']}'),
              const SizedBox(height: 8),
              Text('Severity: ${item['severity']}'),
              const SizedBox(height: 8),
              Text('Status: ${item['status']}'),
              const SizedBox(height: 8),
              Text('Reported by: ${item['reported_by']}'),
              const SizedBox(height: 8),
              Text('Time: ${item['timestamp']}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _approveContent(item['id']);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Approve'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _rejectContent(item['id']);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  void _showModerationSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Moderation Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Auto-moderate explicit content'),
              value: true,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: const Text('Flag potential scams'),
              value: true,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: const Text('Review reported content'),
              value: false,
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
