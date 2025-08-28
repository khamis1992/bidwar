import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/creator_tier.dart';
import '../../models/product_selection.dart';
import '../../models/user_profile.dart';
import '../../services/auth_service.dart';
import '../../services/credit_service.dart';
import '../../services/product_service.dart';
import './widgets/commission_balance_widget.dart';
import './widgets/commission_transaction_item_widget.dart';
import './widgets/earnings_chart_widget.dart';
import './widgets/performance_insights_widget.dart';
import './widgets/tier_progression_widget.dart';

class CreatorCommissionDashboard extends StatefulWidget {
  const CreatorCommissionDashboard({Key? key}) : super(key: key);

  @override
  State<CreatorCommissionDashboard> createState() => _CreatorCommissionDashboardState();
}

class _CreatorCommissionDashboardState extends State<CreatorCommissionDashboard>
    with SingleTickerProviderStateMixin {
  UserProfile? _currentUser;
  CreatorTier? _currentTier;
  List<ProductSelection> _selections = [];
  List<Map<String, dynamic>> _commissionEarnings = [];
  List<Map<String, dynamic>> _creditTransactions = [];
  bool _isLoading = true;
  
  late TabController _tabController;

  // Dashboard stats
  int _totalEarnings = 0;
  int _pendingCommissions = 0;
  int _successfulAuctions = 0;
  double _averageCommission = 0.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      setState(() => _isLoading = true);

      // Load user profile
      final authService = AuthService.instance;
      _currentUser = await authService.getCurrentUserProfile();

      if (_currentUser != null) {
        // Load current tier
        _currentTier = await ProductService.getCreatorTierInfo(_currentUser!.creditBalance);

        // Load product selections
        _selections = await ProductService.getCreatorProductSelections(limit: 100);

        // Load commission earnings
        _commissionEarnings = await ProductService.getCreatorCommissionEarnings(limit: 100);

        // Load credit transactions
        final creditService = CreditService.instance;
        _creditTransactions = await creditService.getUserTransactionHistory(limit: 100);

        // Calculate dashboard stats
        _calculateDashboardStats();
      }
    } catch (error) {
      _showError('Failed to load dashboard data: $error');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _calculateDashboardStats() {
    _totalEarnings = _commissionEarnings
        .where((earning) => earning['commission_status'] == 'paid')
        .map<int>((earning) => earning['commission_amount'] as int? ?? 0)
        .fold(0, (sum, amount) => sum + amount);

    _pendingCommissions = _commissionEarnings
        .where((earning) => earning['commission_status'] == 'pending')
        .map<int>((earning) => earning['commission_amount'] as int? ?? 0)
        .fold(0, (sum, amount) => sum + amount);

    _successfulAuctions = _commissionEarnings.length;

    _averageCommission = _successfulAuctions > 0
        ? (_totalEarnings / _successfulAuctions)
        : 0.0;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
      ),
    );
  }

  Future<void> _refreshData() async {
    await _loadDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Commission Dashboard',
          style: GoogleFonts.inter(
            fontSize: 20.0,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _refreshData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue.shade600,
          unselectedLabelColor: Colors.grey.shade600,
          indicatorColor: Colors.blue.shade600,
          labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Earnings'),
            Tab(text: 'History'),
            Tab(text: 'Insights'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshData,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(),
                  _buildEarningsTab(),
                  _buildHistoryTab(),
                  _buildInsightsTab(),
                ],
              ),
            ),
    );
  }

  Widget _buildOverviewTab() {
    if (_currentUser == null || _currentTier == null) {
      return const Center(child: Text('Unable to load user data'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Commission balance header
          CommissionBalanceWidget(
            totalEarnings: _totalEarnings,
            pendingCommissions: _pendingCommissions,
            currentTier: _currentTier!,
          ),

          const SizedBox(height: 20.0),

          // Quick stats cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Successful Auctions',
                  _successfulAuctions.toString(),
                  Icons.gavel,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: _buildStatCard(
                  'Avg Commission',
                  '${_averageCommission.toInt()} credits',
                  Icons.trending_up,
                  Colors.blue,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20.0),

          // Tier progression
          TierProgressionWidget(
            currentUser: _currentUser!,
            currentTier: _currentTier!,
          ),

          const SizedBox(height: 20.0),

          // Recent earnings chart
          if (_commissionEarnings.isNotEmpty) ...[
            Text(
              'Recent Earnings Trend',
              style: GoogleFonts.inter(
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12.0),
            EarningsChartWidget(
              earnings: _commissionEarnings,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEarningsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Earnings summary
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade600, Colors.green.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Commission Earned',
                  style: GoogleFonts.inter(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withAlpha(230),
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  '${_totalEarnings.toString()} credits',
                  style: GoogleFonts.inter(
                    fontSize: 32.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20.0),

          // Commission earnings list
          Text(
            'Commission History',
            style: GoogleFonts.inter(
              fontSize: 18.0,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12.0),

          if (_commissionEarnings.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(40.0),
              child: Column(
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 64.0,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    'No commission earnings yet',
                    style: GoogleFonts.inter(
                      fontSize: 16.0,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            )
          else
            ..._commissionEarnings.map((earning) => 
              CommissionTransactionItemWidget(
                earning: earning,
              ),
            ).toList(),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Product Selection History',
            style: GoogleFonts.inter(
              fontSize: 18.0,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12.0),

          if (_selections.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(40.0),
              child: Column(
                children: [
                  Icon(
                    Icons.history,
                    size: 64.0,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    'No products selected yet',
                    style: GoogleFonts.inter(
                      fontSize: 16.0,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            )
          else
            ..._selections.map((selection) => 
              _buildSelectionHistoryCard(selection),
            ).toList(),
        ],
      ),
    );
  }

  Widget _buildInsightsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PerformanceInsightsWidget(
            selections: _selections,
            earnings: _commissionEarnings,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: color.withAlpha(26),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20.0,
                ),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12.0),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12.0,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionHistoryCard(ProductSelection selection) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Product image
          Container(
            width: 60.0,
            height: 60.0,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: selection.productImages.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      selection.productImages.first,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.image_not_supported,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  )
                : Icon(
                    Icons.inventory_2,
                    color: Colors.grey.shade400,
                  ),
          ),
          
          const SizedBox(width: 12.0),
          
          // Product info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selection.productTitle,
                  style: GoogleFonts.inter(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4.0),
                Text(
                  selection.brandModel,
                  style: GoogleFonts.inter(
                    fontSize: 14.0,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  selection.statusDisplayText,
                  style: GoogleFonts.inter(
                    fontSize: 12.0,
                    color: _getStatusColor(selection.status),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          // Commission info
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${selection.potentialCommission.toString()} credits',
                style: GoogleFonts.inter(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade600,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                selection.commissionRateText,
                style: GoogleFonts.inter(
                  fontSize: 12.0,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'selected':
        return Colors.blue.shade600;
      case 'live':
        return Colors.orange.shade600;
      case 'completed':
        return Colors.green.shade600;
      case 'cancelled':
        return Colors.red.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}