import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';


class CompetitorDiscoveryWidget extends StatefulWidget {
  final Map<String, dynamic>? selectedCompetitor;
  final String invitationMessage;
  final Function(Map<String, dynamic>) onCompetitorSelected;
  final Function(String) onMessageChanged;

  const CompetitorDiscoveryWidget({
    super.key,
    required this.selectedCompetitor,
    required this.invitationMessage,
    required this.onCompetitorSelected,
    required this.onMessageChanged,
  });

  @override
  State<CompetitorDiscoveryWidget> createState() =>
      _CompetitorDiscoveryWidgetState();
}

class _CompetitorDiscoveryWidgetState extends State<CompetitorDiscoveryWidget>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  late TabController _discoveryTabController;

  List<Map<String, dynamic>> _allCompetitors = [];
  List<Map<String, dynamic>> _friendCompetitors = [];
  List<Map<String, dynamic>> _nearbyCompetitors = [];
  List<Map<String, dynamic>> _randomCompetitors = [];

  bool _isLoading = false;
  int _selectedDiscoveryMode = 0;

  @override
  void initState() {
    super.initState();
    _discoveryTabController = TabController(length: 4, vsync: this);
    _messageController.text = widget.invitationMessage.isEmpty
        ? 'Ready to battle? I challenge you to an epic showdown!'
        : widget.invitationMessage;
    _loadCompetitors();
  }

  @override
  void dispose() {
    _discoveryTabController.dispose();
    _searchController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadCompetitors() async {
    setState(() => _isLoading = true);

    try {
      final competitors = _generateMockCompetitors(_searchController.text.trim());

      setState(() {
        _allCompetitors = competitors;
        _friendCompetitors =
            competitors.where((c) => c['role'] == 'seller').toList();
        _nearbyCompetitors = competitors.take(20).toList();
        _randomCompetitors =
            (competitors.toList()..shuffle()).take(15).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load competitors: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<Map<String, dynamic>> _generateMockCompetitors(String query) {
    List<Map<String, dynamic>> mockCompetitors = [
      {
        'id': '1',
        'full_name': 'John Doe',
        'profile_picture_url': null,
        'credit_balance': 5000,
        'role': 'seller'
      },
      {
        'id': '2',
        'full_name': 'Jane Smith',
        'profile_picture_url': null,
        'credit_balance': 12000,
        'role': 'buyer'
      },
      {
        'id': '3',
        'full_name': 'Mike Johnson',
        'profile_picture_url': null,
        'credit_balance': 800,
        'role': 'seller'
      },
    ];

    if (query.isEmpty) return mockCompetitors;
    
    return mockCompetitors.where((competitor) {
      final name = competitor['full_name']?.toString().toLowerCase() ?? '';
      return name.contains(query.toLowerCase());
    }).toList();
  }

  List<Map<String, dynamic>> get currentCompetitors {
    switch (_selectedDiscoveryMode) {
      case 0:
        return _friendCompetitors;
      case 1:
        return _nearbyCompetitors;
      case 2:
        return _randomCompetitors;
      case 3:
        return _allCompetitors;
      default:
        return _allCompetitors;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Find Your Opponent',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Choose who you want to challenge in this epic battle',
            style: TextStyle(
              color: Colors.grey[300],
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 4.h),

          // Discovery Mode Tabs
          Container(
            height: 6.h,
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(25),
            ),
            child: TabBar(
              controller: _discoveryTabController,
              onTap: (index) {
                setState(() => _selectedDiscoveryMode = index);
              },
              indicator: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(25),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: [
                Tab(text: 'Friends'),
                Tab(text: 'Nearby'),
                Tab(text: 'Random'),
                Tab(text: 'Search'),
              ],
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey[400],
              labelStyle: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: 3.h),

          // Search Bar (for search mode)
          if (_selectedDiscoveryMode == 3) ...[
            TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search by username or email...',
                hintStyle: TextStyle(color: Colors.grey[500]),
                prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.orange, width: 2),
                ),
              ),
              onChanged: (value) {
                // Debounce search
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (_searchController.text == value) {
                    _loadCompetitors();
                  }
                });
              },
            ),
            SizedBox(height: 3.h),
          ],

          // Competitors List
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
              ),
            )
          else if (currentCompetitors.isEmpty)
            _buildEmptyState()
          else ...[
            Text(
              _getDiscoveryModeTitle(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: currentCompetitors.length,
              itemBuilder: (context, index) {
                final competitor = currentCompetitors[index];
                final isSelected =
                    widget.selectedCompetitor?['id'] == competitor['id'];

                return Padding(
                  padding: EdgeInsets.only(bottom: 2.h),
                  child: GestureDetector(
                    onTap: () => widget.onCompetitorSelected(competitor),
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? Colors.orange : Colors.grey[700]!,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Avatar
                          CircleAvatar(
                            radius: 6.w,
                            backgroundColor: Colors.grey[700],
                            backgroundImage:
                                competitor['profile_picture_url'] != null
                                    ? NetworkImage(
                                        competitor['profile_picture_url'])
                                    : null,
                            child: competitor['profile_picture_url'] == null
                                ? Icon(
                                    Icons.person,
                                    color: Colors.grey[400],
                                    size: 6.w,
                                  )
                                : null,
                          ),
                          SizedBox(width: 4.w),

                          // Competitor Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  competitor['full_name'] ?? 'Unknown User',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14.sp,
                                  ),
                                ),
                                SizedBox(height: 0.5.h),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      color: Colors.orange,
                                      size: 14.sp,
                                    ),
                                    SizedBox(width: 1.w),
                                    Text(
                                      _getCompetitorLevel(competitor),
                                      style: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                    SizedBox(width: 4.w),
                                    Icon(
                                      Icons.account_balance_wallet,
                                      color: Colors.green,
                                      size: 14.sp,
                                    ),
                                    SizedBox(width: 1.w),
                                    Text(
                                      '${competitor['credit_balance'] ?? 0} credits',
                                      style: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Selection indicator
                          if (isSelected)
                            Container(
                              padding: EdgeInsets.all(2.w),
                              decoration: const BoxDecoration(
                                color: Colors.orange,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 18.sp,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],

          SizedBox(height: 4.h),

          // Invitation Message
          Text(
            'Challenge Message',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          TextField(
            controller: _messageController,
            style: const TextStyle(color: Colors.white),
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Customize your battle invitation...',
              hintStyle: TextStyle(color: Colors.grey[500]),
              filled: true,
              fillColor: Colors.grey[900],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.orange, width: 2),
              ),
            ),
            onChanged: widget.onMessageChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(8.w),
      child: Column(
        children: [
          Icon(
            Icons.people_outline,
            size: 15.w,
            color: Colors.grey[600],
          ),
          SizedBox(height: 2.h),
          Text(
            'No competitors found',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 16.sp,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            _getEmptyStateMessage(),
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12.sp,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getDiscoveryModeTitle() {
    switch (_selectedDiscoveryMode) {
      case 0:
        return 'Your Friends (${currentCompetitors.length})';
      case 1:
        return 'Nearby Competitors (${currentCompetitors.length})';
      case 2:
        return 'Random Matches (${currentCompetitors.length})';
      case 3:
        return 'Search Results (${currentCompetitors.length})';
      default:
        return 'Competitors';
    }
  }

  String _getEmptyStateMessage() {
    switch (_selectedDiscoveryMode) {
      case 0:
        return 'Connect with friends to battle them';
      case 1:
        return 'No competitors found nearby';
      case 2:
        return 'Try refreshing for new random matches';
      case 3:
        return 'Try a different search term';
      default:
        return 'No competitors available';
    }
  }

  String _getCompetitorLevel(Map<String, dynamic> competitor) {
    final credits = competitor['credit_balance'] ?? 0;
    if (credits > 10000) return 'Pro Level';
    if (credits > 5000) return 'Advanced';
    if (credits > 1000) return 'Intermediate';
    return 'Beginner';
  }
}