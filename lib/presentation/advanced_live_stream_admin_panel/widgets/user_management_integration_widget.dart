import 'package:flutter/material.dart';

class UserManagementIntegrationWidget extends StatefulWidget {
  const UserManagementIntegrationWidget({Key? key}) : super(key: key);

  @override
  State<UserManagementIntegrationWidget> createState() =>
      _UserManagementIntegrationWidgetState();
}

class _UserManagementIntegrationWidgetState
    extends State<UserManagementIntegrationWidget> {
  String _searchQuery = '';
  String _selectedFilter = 'all';
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _recentActions = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    // Mock user data
    _users = [
      {
        'id': 'user_001',
        'name': 'John Doe',
        'email': 'john.doe@email.com',
        'role': 'seller',
        'status': 'active',
        'join_date': DateTime.now().subtract(Duration(days: 30)),
        'streams_count': 15,
        'total_revenue': 12500.00,
        'last_stream': DateTime.now().subtract(Duration(days: 2)),
        'reputation_score': 4.8,
        'violations': 0,
      },
      {
        'id': 'user_002',
        'name': 'Jane Smith',
        'email': 'jane.smith@email.com',
        'role': 'bidder',
        'status': 'active',
        'join_date': DateTime.now().subtract(Duration(days: 45)),
        'streams_count': 0,
        'total_revenue': 0.0,
        'last_activity': DateTime.now().subtract(Duration(hours: 6)),
        'reputation_score': 4.9,
        'violations': 0,
      },
      {
        'id': 'user_003',
        'name': 'Mike Johnson',
        'email': 'mike.johnson@email.com',
        'role': 'seller',
        'status': 'suspended',
        'join_date': DateTime.now().subtract(Duration(days: 60)),
        'streams_count': 8,
        'total_revenue': 3200.00,
        'last_stream': DateTime.now().subtract(Duration(days: 15)),
        'reputation_score': 3.2,
        'violations': 3,
      },
      {
        'id': 'user_004',
        'name': 'Sarah Wilson',
        'email': 'sarah.wilson@email.com',
        'role': 'seller',
        'status': 'pending_verification',
        'join_date': DateTime.now().subtract(Duration(days: 3)),
        'streams_count': 0,
        'total_revenue': 0.0,
        'last_activity': DateTime.now().subtract(Duration(hours: 12)),
        'reputation_score': 0.0,
        'violations': 0,
      },
    ];

    _recentActions = [
      {
        'id': 'action_001',
        'user_id': 'user_003',
        'user_name': 'Mike Johnson',
        'action': 'User Suspended',
        'reason': 'Multiple policy violations',
        'timestamp': DateTime.now().subtract(Duration(minutes: 30)),
        'admin': 'Admin User',
      },
      {
        'id': 'action_002',
        'user_id': 'user_001',
        'user_name': 'John Doe',
        'action': 'Stream Permission Granted',
        'reason': 'Verification completed',
        'timestamp': DateTime.now().subtract(Duration(hours: 2)),
        'admin': 'Admin User',
      },
      {
        'id': 'action_003',
        'user_id': 'user_004',
        'user_name': 'Sarah Wilson',
        'action': 'Account Created',
        'reason': 'New user registration',
        'timestamp': DateTime.now().subtract(Duration(hours: 12)),
        'admin': 'System',
      },
    ];

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildUserManagementHeader(),
        const SizedBox(height: 16),
        _buildSearchAndFilters(),
        const SizedBox(height: 16),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: _buildUsersList(),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildRecentActions(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserManagementHeader() {
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
            'User Management Integration',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildUserStatsCard(
                    'Total Users', _users.length, Colors.blue),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildUserStatsCard(
                    'Active Sellers', _getActiveSellerCount(), Colors.green),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildUserStatsCard('Pending Verification',
                    _getPendingVerificationCount(), Colors.orange),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildUserStatsCard(
                    'Suspended', _getSuspendedCount(), Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserStatsCard(String title, int count, Color color) {
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

  Widget _buildSearchAndFilters() {
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
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search users by name or email...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          const SizedBox(width: 16),
          DropdownButton<String>(
            value: _selectedFilter,
            items: const [
              DropdownMenuItem(value: 'all', child: Text('All Users')),
              DropdownMenuItem(value: 'sellers', child: Text('Sellers Only')),
              DropdownMenuItem(value: 'bidders', child: Text('Bidders Only')),
              DropdownMenuItem(value: 'active', child: Text('Active')),
              DropdownMenuItem(value: 'suspended', child: Text('Suspended')),
              DropdownMenuItem(
                  value: 'pending', child: Text('Pending Verification')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedFilter = value!;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUsersList() {
    List<Map<String, dynamic>> filteredUsers = _getFilteredUsers();

    return Container(
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Users (${filteredUsers.length})',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredUsers.length,
              itemBuilder: (context, index) {
                final user = filteredUsers[index];
                return _buildUserCard(user);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    Color statusColor = _getStatusColor(user['status']);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                        user['name'],
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        user['email'],
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withAlpha(26),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: statusColor.withAlpha(128)),
                      ),
                      child: Text(
                        user['status'].toUpperCase().replaceAll('_', ' '),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user['role'].toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (user['role'] == 'seller') ...[
                  _buildUserInfoChip(
                      '${user['streams_count']} streams', Colors.blue),
                  _buildUserInfoChip(
                      '\$${user['total_revenue'].toStringAsFixed(0)} revenue',
                      Colors.green),
                ],
                _buildUserInfoChip(
                    '${user['reputation_score'].toStringAsFixed(1)}⭐',
                    Colors.orange),
                if (user['violations'] > 0)
                  _buildUserInfoChip(
                      '${user['violations']} violations', Colors.red),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Joined ${_formatDate(user['join_date'])}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (user['status'] == 'pending_verification')
                      TextButton.icon(
                        onPressed: () => _verifyUser(user['id']),
                        icon: const Icon(Icons.verified, size: 16),
                        label: const Text('Verify'),
                        style:
                            TextButton.styleFrom(foregroundColor: Colors.green),
                      ),
                    if (user['status'] == 'active')
                      TextButton.icon(
                        onPressed: () => _suspendUser(user['id']),
                        icon: const Icon(Icons.block, size: 16),
                        label: const Text('Suspend'),
                        style:
                            TextButton.styleFrom(foregroundColor: Colors.red),
                      ),
                    if (user['status'] == 'suspended')
                      TextButton.icon(
                        onPressed: () => _reactivateUser(user['id']),
                        icon: const Icon(Icons.check_circle, size: 16),
                        label: const Text('Reactivate'),
                        style:
                            TextButton.styleFrom(foregroundColor: Colors.green),
                      ),
                  ],
                ),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () => _viewUserDetails(user),
                      icon: const Icon(Icons.visibility, size: 16),
                      label: const Text('Details'),
                    ),
                    TextButton.icon(
                      onPressed: () => _editUser(user),
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Edit'),
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

  Widget _buildUserInfoChip(String text, Color color) {
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
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildRecentActions() {
    return Container(
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
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Recent Actions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _recentActions.length,
              itemBuilder: (context, index) {
                final action = _recentActions[index];
                return _buildActionItem(action);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(Map<String, dynamic> action) {
    IconData actionIcon = _getActionIcon(action['action']);
    Color actionColor = _getActionColor(action['action']);

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: actionColor.withAlpha(26),
          shape: BoxShape.circle,
        ),
        child: Icon(actionIcon, color: actionColor, size: 16),
      ),
      title: Text(
        action['action'],
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(action['user_name'], style: const TextStyle(fontSize: 12)),
          Text(action['reason'], style: const TextStyle(fontSize: 11)),
          Text(
            '${_formatTimestamp(action['timestamp'])} by ${action['admin']}',
            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredUsers() {
    List<Map<String, dynamic>> filtered = _users;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((user) {
        return user['name'].toLowerCase().contains(_searchQuery) ||
            user['email'].toLowerCase().contains(_searchQuery);
      }).toList();
    }

    // Apply category filter
    switch (_selectedFilter) {
      case 'sellers':
        filtered = filtered.where((user) => user['role'] == 'seller').toList();
        break;
      case 'bidders':
        filtered = filtered.where((user) => user['role'] == 'bidder').toList();
        break;
      case 'active':
        filtered =
            filtered.where((user) => user['status'] == 'active').toList();
        break;
      case 'suspended':
        filtered =
            filtered.where((user) => user['status'] == 'suspended').toList();
        break;
      case 'pending':
        filtered = filtered
            .where((user) => user['status'] == 'pending_verification')
            .toList();
        break;
    }

    return filtered;
  }

  int _getActiveSellerCount() {
    return _users
        .where((user) => user['role'] == 'seller' && user['status'] == 'active')
        .length;
  }

  int _getPendingVerificationCount() {
    return _users
        .where((user) => user['status'] == 'pending_verification')
        .length;
  }

  int _getSuspendedCount() {
    return _users.where((user) => user['status'] == 'suspended').length;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'suspended':
        return Colors.red;
      case 'pending_verification':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getActionIcon(String action) {
    if (action.contains('Suspended')) return Icons.block;
    if (action.contains('Permission')) return Icons.verified;
    if (action.contains('Created')) return Icons.person_add;
    return Icons.info;
  }

  Color _getActionColor(String action) {
    if (action.contains('Suspended')) return Colors.red;
    if (action.contains('Permission') || action.contains('Granted'))
      return Colors.green;
    if (action.contains('Created')) return Colors.blue;
    return Colors.grey;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;

    if (diff == 0) return 'today';
    if (diff == 1) return 'yesterday';
    if (diff < 30) return '$diff days ago';
    if (diff < 365) return '${(diff / 30).round()} months ago';
    return '${(diff / 365).round()} years ago';
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  void _verifyUser(String userId) {
    setState(() {
      final user = _users.firstWhere((u) => u['id'] == userId);
      user['status'] = 'active';
    });

    _addRecentAction(userId, 'User Verified', 'Manual verification completed');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('User verified successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _suspendUser(String userId) {
    setState(() {
      final user = _users.firstWhere((u) => u['id'] == userId);
      user['status'] = 'suspended';
    });

    _addRecentAction(userId, 'User Suspended', 'Manual admin action');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('User suspended'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _reactivateUser(String userId) {
    setState(() {
      final user = _users.firstWhere((u) => u['id'] == userId);
      user['status'] = 'active';
    });

    _addRecentAction(userId, 'User Reactivated', 'Account suspension lifted');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('User reactivated successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _addRecentAction(String userId, String action, String reason) {
    final user = _users.firstWhere((u) => u['id'] == userId);
    _recentActions.insert(0, {
      'id': 'action_${DateTime.now().millisecondsSinceEpoch}',
      'user_id': userId,
      'user_name': user['name'],
      'action': action,
      'reason': reason,
      'timestamp': DateTime.now(),
      'admin': 'Admin User',
    });

    if (_recentActions.length > 10) {
      _recentActions.removeLast();
    }
  }

  void _viewUserDetails(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('User Details - ${user['name']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('ID: ${user['id']}'),
              const SizedBox(height: 8),
              Text('Email: ${user['email']}'),
              const SizedBox(height: 8),
              Text('Role: ${user['role']}'),
              const SizedBox(height: 8),
              Text('Status: ${user['status']}'),
              const SizedBox(height: 8),
              Text('Reputation: ${user['reputation_score']}/5.0'),
              const SizedBox(height: 8),
              Text('Joined: ${user['join_date']}'),
              if (user['role'] == 'seller') ...[
                const SizedBox(height: 8),
                Text('Streams: ${user['streams_count']}'),
                const SizedBox(height: 8),
                Text('Revenue: \$${user['total_revenue'].toStringAsFixed(2)}'),
              ],
              const SizedBox(height: 8),
              Text('Violations: ${user['violations']}'),
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

  void _editUser(Map<String, dynamic> user) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit user: ${user['name']}')),
    );
  }
}
