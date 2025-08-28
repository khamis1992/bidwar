import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../services/live_stream_service.dart';
import '../../services/supabase_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/analytics_overview_widget.dart';
import './widgets/engagement_chart_widget.dart';
import './widgets/revenue_breakdown_widget.dart';
import './widgets/stream_quality_metrics_widget.dart';
import './widgets/viewer_demographics_widget.dart';

class LiveStreamAnalyticsDashboard extends StatefulWidget {
  const LiveStreamAnalyticsDashboard({super.key});

  @override
  State<LiveStreamAnalyticsDashboard> createState() =>
      _LiveStreamAnalyticsDashboardState();
}

class _LiveStreamAnalyticsDashboardState
    extends State<LiveStreamAnalyticsDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _liveStreamService = LiveStreamService();
  bool _isLoading = true;
  String? _error;
  String _selectedPeriod = '7d';

  Map<String, dynamic> _analyticsData = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAnalyticsData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAnalyticsData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final currentUser = SupabaseService.instance.client.auth.currentUser;
      if (currentUser == null) {
        setState(() {
          _error = 'Authentication required';
          _isLoading = false;
        });
        return;
      }

      final data = await _liveStreamService.getSellerAnalytics(
        currentUser.id,
        period: _selectedPeriod,
      );

      if (mounted) {
        setState(() {
          _analyticsData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load analytics: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshData() async {
    await _loadAnalyticsData();
  }

  Future<void> _exportReport() async {
    try {
      await _liveStreamService.exportAnalyticsReport(_analyticsData);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report exported successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: const CustomBottomBar(currentIndex: 2),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return CustomAppBar(
      title: "Live Stream Analytics",
      centerTitle: true,
      backgroundColor: Theme.of(context).primaryColor,
      actions: [
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'export') {
              _exportReport();
            } else {
              setState(() {
                _selectedPeriod = value;
              });
              _loadAnalyticsData();
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'export',
              child: Row(
                children: [
                  Icon(Icons.download, size: 20.h),
                  SizedBox(width: 8.h),
                  const Text('Export Report'),
                ],
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              value: '7d',
              child: Text(
                'Last 7 Days',
                style: TextStyle(
                  fontWeight: _selectedPeriod == '7d'
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
            PopupMenuItem(
              value: '30d',
              child: Text(
                'Last 30 Days',
                style: TextStyle(
                  fontWeight: _selectedPeriod == '30d'
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
            PopupMenuItem(
              value: '90d',
              child: Text(
                'Last 90 Days',
                style: TextStyle(
                  fontWeight: _selectedPeriod == '90d'
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
          ],
          icon: const Icon(Icons.more_vert, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64.h,
              color: Colors.grey,
            ),
            SizedBox(height: 16.h),
            Text(
              _error!,
              style: TextStyle(
                fontSize: 16.h,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: _refreshData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Theme.of(context).primaryColor,
              tabs: const [
                Tab(
                  icon: Icon(Icons.dashboard),
                  text: 'Overview',
                ),
                Tab(
                  icon: Icon(Icons.timeline),
                  text: 'Engagement',
                ),
                Tab(
                  icon: Icon(Icons.monetization_on),
                  text: 'Revenue',
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildEngagementTab(),
                _buildRevenueTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnalyticsOverviewWidget(
            analyticsData: _analyticsData,
          ),
          SizedBox(height: 16.h),
          ViewerDemographicsWidget(
            demographicsData: _analyticsData['demographics'] ?? {},
          ),
          SizedBox(height: 16.h),
          StreamQualityMetricsWidget(
            qualityData: _analyticsData['quality_metrics'] ?? {},
          ),
        ],
      ),
    );
  }

  Widget _buildEngagementTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EngagementChartWidget(
            engagementData: _analyticsData['engagement'] ?? {},
          ),
          SizedBox(height: 16.h),
          _buildEngagementSummary(),
        ],
      ),
    );
  }

  Widget _buildRevenueTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RevenueBreakdownWidget(
            revenueData: _analyticsData['revenue'] ?? {},
          ),
          SizedBox(height: 16.h),
          _buildRevenueComparison(),
        ],
      ),
    );
  }

  Widget _buildEngagementSummary() {
    final engagement = _analyticsData['engagement'] ?? {};

    return Container(
      padding: EdgeInsets.all(16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.h),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Engagement Summary',
            style: TextStyle(
              fontSize: 18.h,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Peak Activity',
                  '${engagement['peak_hour'] ?? 'N/A'}:00',
                  Icons.schedule,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Avg. Chat Rate',
                  '${engagement['avg_chat_per_minute'] ?? 0}/min',
                  Icons.chat,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueComparison() {
    final revenue = _analyticsData['revenue'] ?? {};
    final previousRevenue = revenue['previous_period'] ?? 0;
    final currentRevenue = revenue['total_sales'] ?? 0;
    final growth = previousRevenue > 0
        ? ((currentRevenue - previousRevenue) / previousRevenue * 100)
        : 0.0;

    return Container(
      padding: EdgeInsets.all(16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.h),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Revenue Comparison',
            style: TextStyle(
              fontSize: 18.h,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _buildComparisonItem(
                  'Current Period',
                  '\$${currentRevenue.toStringAsFixed(0)}',
                  growth >= 0 ? Colors.green : Colors.red,
                  growth >= 0 ? Icons.trending_up : Icons.trending_down,
                ),
              ),
              Expanded(
                child: _buildComparisonItem(
                  'Growth',
                  '${growth.toStringAsFixed(1)}%',
                  growth >= 0 ? Colors.green : Colors.red,
                  growth >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String title, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16.h, color: Colors.grey),
            SizedBox(width: 4.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 12.h,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 16.h,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonItem(
      String title, String value, Color color, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12.h,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 4.h),
        Row(
          children: [
            Icon(icon, size: 16.h, color: color),
            SizedBox(width: 4.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 16.h,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }
}