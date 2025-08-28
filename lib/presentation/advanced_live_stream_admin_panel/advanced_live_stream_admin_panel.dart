import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../services/live_stream_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/admin_stats_overview_widget.dart';
import './widgets/content_moderation_widget.dart';
import './widgets/emergency_controls_widget.dart';
import './widgets/financial_oversight_widget.dart';
import './widgets/stream_analytics_widget.dart';
import './widgets/stream_monitoring_widget.dart';
import './widgets/stream_quality_monitoring_widget.dart';
import './widgets/stream_scheduling_widget.dart';
import './widgets/user_management_integration_widget.dart';

class AdvancedLiveStreamAdminPanel extends StatefulWidget {
  const AdvancedLiveStreamAdminPanel({Key? key}) : super(key: key);

  @override
  State<AdvancedLiveStreamAdminPanel> createState() =>
      _AdvancedLiveStreamAdminPanelState();
}

class _AdvancedLiveStreamAdminPanelState
    extends State<AdvancedLiveStreamAdminPanel> with TickerProviderStateMixin {
  late TabController _tabController;
  final LiveStreamService _liveStreamService = LiveStreamService();
  final AuthService _authService = AuthService.instance;

  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _activeStreams = [];
  Map<String, dynamic> _platformMetrics = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 8, vsync: this);
    _initializeAdminPanel();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initializeAdminPanel() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Mock admin permissions check
      final isAdmin =
          true; // Replace with actual admin check when AuthService is available
      if (!isAdmin) {
        setState(() {
          _errorMessage = 'Access denied. Admin privileges required.';
          _isLoading = false;
        });
        return;
      }

      // Load initial data with mock implementations
      final streams = await _mockGetActiveStreamsForAdmin();
      final metrics = await _mockGetPlatformMetrics();

      setState(() {
        _activeStreams = streams;
        _platformMetrics = metrics;
        _isLoading = false;
      });

      // Set up real-time updates
      _setupRealTimeUpdates();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load admin panel: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _setupRealTimeUpdates() {
    // Mock real-time updates
    Future.delayed(Duration(seconds: 30), () {
      if (mounted) {
        setState(() {
          // Mock stream updates
        });
      }
    });
  }

  Future<void> _handleEmergencyStreamShutdown(String streamId) async {
    try {
      // Mock emergency shutdown
      await Future.delayed(Duration(seconds: 1));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Stream terminated successfully'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to terminate stream: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Mock methods to replace missing service methods
  Future<List<Map<String, dynamic>>> _mockGetActiveStreamsForAdmin() async {
    return []; // Return empty list for now
  }

  Future<Map<String, dynamic>> _mockGetPlatformMetrics() async {
    return {}; // Return empty map for now
  }

  Future<void> _refreshData() async {
    await _initializeAdminPanel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(
        title: 'Advanced Live Stream Admin Panel',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export',
                child: Text('Export Reports'),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Text('Panel Settings'),
              ),
              const PopupMenuItem(
                value: 'alerts',
                child: Text('Alert Configuration'),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case 'export':
                  _exportReports();
                  break;
                case 'settings':
                  _showPanelSettings();
                  break;
                case 'alerts':
                  _showAlertConfiguration();
                  break;
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading admin panel...'),
                ],
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _initializeAdminPanel,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Stats Overview
                    AdminStatsOverviewWidget(
                      metrics: _platformMetrics,
                      activeStreamsCount: _activeStreams.length,
                    ),

                    // Emergency Controls
                    EmergencyControlsWidget(
                      onEmergencyShutdown: _handleEmergencyStreamShutdown,
                      activeStreams: _activeStreams,
                    ),

                    // Tab Bar
                    Container(
                      color: Colors.white,
                      child: TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        indicatorColor: Colors.blue,
                        labelColor: Colors.blue,
                        unselectedLabelColor: Colors.grey,
                        tabs: const [
                          Tab(text: 'Live Monitoring'),
                          Tab(text: 'Analytics'),
                          Tab(text: 'Content Moderation'),
                          Tab(text: 'Stream Scheduling'),
                          Tab(text: 'Financial Oversight'),
                          Tab(text: 'User Management'),
                          Tab(text: 'Quality Monitoring'),
                          Tab(text: 'Reports'),
                        ],
                      ),
                    ),

                    // Tab Views
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          StreamMonitoringWidget(
                            activeStreams: _activeStreams,
                            onRefresh: _refreshData,
                          ),
                          StreamAnalyticsWidget(),
                          ContentModerationWidget(),
                          StreamSchedulingWidget(),
                          FinancialOversightWidget(),
                          UserManagementIntegrationWidget(),
                          StreamQualityMonitoringWidget(),
                          _buildReportsTab(),
                        ],
                      ),
                    ),
                  ],
                ),
      bottomNavigationBar: const CustomBottomBar(
        currentIndex: 0,
      ),
    );
  }

  Widget _buildPlaceholderTab(String tabName) {
    Widget getTabWidget(String tabName) {
      switch (tabName) {
        case 'Analytics':
          return StreamAnalyticsWidget();
        case 'Content Moderation':
          return ContentModerationWidget();
        case 'Stream Scheduling':
          return StreamSchedulingWidget();
        case 'Financial Oversight':
          return FinancialOversightWidget();
        case 'User Management':
          return UserManagementIntegrationWidget();
        case 'Quality Monitoring':
          return StreamQualityMonitoringWidget();
        default:
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.construction, size: 64, color: Colors.grey[400]),
                SizedBox(height: 16),
                Text(
                  tabName,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'This section is under development',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
      }
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: getTabWidget(tabName),
    );
  }

  Widget _buildReportsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Business Intelligence Reports',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildReportCard(
                  'Platform Performance',
                  'Comprehensive performance metrics',
                  Icons.analytics,
                  Colors.blue,
                  () => _generateReport('performance'),
                ),
                _buildReportCard(
                  'Revenue Analytics',
                  'Financial performance and trends',
                  Icons.monetization_on,
                  Colors.green,
                  () => _generateReport('revenue'),
                ),
                _buildReportCard(
                  'User Engagement',
                  'User behavior and engagement metrics',
                  Icons.people,
                  Colors.orange,
                  () => _generateReport('engagement'),
                ),
                _buildReportCard(
                  'Compliance Report',
                  'Regulatory compliance status',
                  Icons.security,
                  Colors.purple,
                  () => _generateReport('compliance'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [color.withAlpha(26), color.withAlpha(51)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: color,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
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

  void _exportReports() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Reports'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.file_download),
              title: Text('Export as PDF'),
              subtitle: Text('Comprehensive report in PDF format'),
            ),
            ListTile(
              leading: Icon(Icons.table_chart),
              title: Text('Export as Excel'),
              subtitle: Text('Data export for analysis'),
            ),
            ListTile(
              leading: Icon(Icons.code),
              title: Text('Export as JSON'),
              subtitle: Text('Raw data in JSON format'),
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
              // Implement export functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Reports export started'),
                ),
              );
            },
            child: const Text('Export All'),
          ),
        ],
      ),
    );
  }

  void _showPanelSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Panel Settings'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Configure admin panel preferences'),
            SizedBox(height: 16),
            SwitchListTile(
              title: Text('Real-time Updates'),
              subtitle: Text('Enable live data refresh'),
              value: true,
              onChanged: null,
            ),
            SwitchListTile(
              title: Text('Alert Notifications'),
              subtitle: Text('Push notifications for alerts'),
              value: true,
              onChanged: null,
            ),
            SwitchListTile(
              title: Text('Auto-refresh Dashboard'),
              subtitle: Text('Automatically refresh every 30 seconds'),
              value: false,
              onChanged: null,
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

  void _showAlertConfiguration() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alert Configuration'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('High Viewer Count Alert'),
                subtitle: Text('Alert when viewer count exceeds 1000'),
                trailing: Switch(value: true, onChanged: null),
              ),
              ListTile(
                title: Text('Stream Quality Alert'),
                subtitle: Text('Alert for poor stream quality'),
                trailing: Switch(value: true, onChanged: null),
              ),
              ListTile(
                title: Text('Inappropriate Content Alert'),
                subtitle: Text('Alert for flagged content'),
                trailing: Switch(value: true, onChanged: null),
              ),
              ListTile(
                title: Text('Revenue Milestone Alert'),
                subtitle: Text('Alert for revenue thresholds'),
                trailing: Switch(value: false, onChanged: null),
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
            onPressed: () => Navigator.pop(context),
            child: const Text('Save Configuration'),
          ),
        ],
      ),
    );
  }

  void _generateReport(String reportType) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Generating $reportType report...'),
        action: SnackBarAction(
          label: 'View',
          onPressed: () {
            // Navigate to report details
          },
        ),
      ),
    );
  }
}
