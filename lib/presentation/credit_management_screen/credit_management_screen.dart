import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/credit_balance_header.dart';
import './widgets/credit_package_card.dart';
import './widgets/daily_bonus_card.dart';
import './widgets/payment_processing_dialog.dart';
import './widgets/referral_program_card.dart';
import './widgets/transaction_history_item.dart';

class CreditManagementScreen extends StatefulWidget {
  const CreditManagementScreen({super.key});

  @override
  State<CreditManagementScreen> createState() => _CreditManagementScreenState();
}

class _CreditManagementScreenState extends State<CreditManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _showTransactionHistory = false;
  int _currentCredits = 127;

  // Mock data for credit packages
  final List<Map<String, dynamic>> _creditPackages = [
    {'credits': 10, 'price': 5.0, 'badge': null, 'isPopular': false},
    {'credits': 50, 'price': 20.0, 'badge': 'Popular', 'isPopular': true},
    {'credits': 100, 'price': 35.0, 'badge': 'Best Value', 'isPopular': false},
    {'credits': 500, 'price': 150.0, 'badge': 'Premium', 'isPopular': false},
  ];

  // Mock transaction history
  final List<Map<String, dynamic>> _transactionHistory = [
    {
      'type': 'Purchase',
      'credits': 50,
      'amount': 20.0,
      'date': 'Aug 25, 2025 - 3:45 PM',
      'auctionTitle': null,
      'status': 'Completed',
    },
    {
      'type': 'Bid',
      'credits': 1,
      'amount': null,
      'date': 'Aug 25, 2025 - 2:30 PM',
      'auctionTitle': 'iPhone 15 Pro Max - 256GB',
      'status': 'Completed',
    },
    {
      'type': 'Bonus',
      'credits': 5,
      'amount': null,
      'date': 'Aug 25, 2025 - 12:00 PM',
      'auctionTitle': null,
      'status': 'Completed',
    },
    {
      'type': 'Bid',
      'credits': 1,
      'amount': null,
      'date': 'Aug 24, 2025 - 8:15 PM',
      'auctionTitle': 'MacBook Air M2 - 13 inch',
      'status': 'Completed',
    },
    {
      'type': 'Purchase',
      'credits': 100,
      'amount': 35.0,
      'date': 'Aug 24, 2025 - 6:00 PM',
      'auctionTitle': null,
      'status': 'Completed',
    },
    {
      'type': 'Bid',
      'credits': 1,
      'amount': null,
      'date': 'Aug 24, 2025 - 4:22 PM',
      'auctionTitle': 'Samsung Galaxy S24 Ultra',
      'status': 'Completed',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Credit Management',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: CustomIconWidget(
              iconName: 'help_outline',
              color: colorScheme.onSurface,
              size: 24,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              _showHelpDialog();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: colorScheme.primary,
        child: CustomScrollView(
          slivers: [
            // Credit Balance Header
            SliverToBoxAdapter(
              child: CreditBalanceHeader(
                currentCredits: _currentCredits,
                lastTransactionDate: 'Aug 25, 2025',
                lastTransactionType: 'Purchase',
              ),
            ),

            // Daily Bonus Card
            SliverToBoxAdapter(
              child: DailyBonusCard(
                bonusCredits: 5,
                timeUntilNextBonus: const Duration(hours: 8, minutes: 32),
                canClaim: DateTime.now().hour >= 12,
                onClaim: _claimDailyBonus,
              ),
            ),

            // Tab Bar
            SliverToBoxAdapter(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: colorScheme.onPrimary,
                  unselectedLabelColor: colorScheme.onSurface.withValues(
                    alpha: 0.7,
                  ),
                  labelStyle: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  tabs: const [Tab(text: 'Buy Credits'), Tab(text: 'History')],
                ),
              ),
            ),

            // Tab Content
            SliverFillRemaining(
              child: TabBarView(
                controller: _tabController,
                children: [_buildBuyCreditsTab(), _buildHistoryTab()],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: 2, // Credits tab index
        onTap: (index) {
          HapticFeedback.lightImpact();
          switch (index) {
            case 0:
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.auctionBrowse,
                (route) => false,
              );
              break;
            case 1:
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.watchlist,
                (route) => false,
              );
              break;
            case 2:
              // Already on credits screen
              break;
            case 3:
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.userProfile,
                (route) => false,
              );
              break;
          }
        },
      ),
    );
  }

  Widget _buildBuyCreditsTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Credit Packages
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _creditPackages.length,
            itemBuilder: (context, index) {
              final package = _creditPackages[index];
              return CreditPackageCard(
                credits: package['credits'] as int,
                price: package['price'] as double,
                badge: package['badge'] as String?,
                isPopular: package['isPopular'] as bool,
                onPurchase:
                    () => _purchaseCredits(
                      package['credits'] as int,
                      package['price'] as double,
                    ),
              );
            },
          ),

          SizedBox(height: 2.h),

          // Referral Program Card
          ReferralProgramCard(
            referralCredits: 10,
            totalReferrals: 3,
            referralCode: 'BIDWAR2025',
            onShare: _shareReferralCode,
          ),

          SizedBox(height: 4.h),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return Column(
      children: [
        // Filter options
        Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'filter_list',
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                        size: 20,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'All Transactions',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Transaction History
        Expanded(
          child: ListView.builder(
            itemCount: _transactionHistory.length,
            itemBuilder: (context, index) {
              final transaction = _transactionHistory[index];
              return TransactionHistoryItem(
                type: transaction['type'] as String,
                credits: transaction['credits'] as int,
                amount: transaction['amount'] as double?,
                date: transaction['date'] as String,
                auctionTitle: transaction['auctionTitle'] as String?,
                status: transaction['status'] as String,
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _refreshData() async {
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() {
        // Simulate data refresh
        _currentCredits = _currentCredits + (DateTime.now().millisecond % 5);
      });
    }
  }

  void _purchaseCredits(int credits, double amount) {
    HapticFeedback.mediumImpact();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => PaymentProcessingDialog(
            credits: credits,
            amount: amount,
            onSuccess: () {
              Navigator.of(context).pop();
              setState(() {
                _currentCredits += credits;
              });
              _showSuccessMessage('Credits purchased successfully!');
            },
            onError: () {
              Navigator.of(context).pop();
              _showErrorMessage('Payment failed. Please try again.');
            },
          ),
    );
  }

  void _claimDailyBonus() {
    HapticFeedback.mediumImpact();
    setState(() {
      _currentCredits += 5;
    });
    _showSuccessMessage('Daily bonus claimed! +5 credits');
  }

  void _shareReferralCode() {
    HapticFeedback.lightImpact();
    // Simulate native share sheet
    _showSuccessMessage('Referral code shared successfully!');
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Credit Management Help'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• Credits are used to place bids in auctions'),
                SizedBox(height: 1.h),
                Text('• Each bid costs 1 credit'),
                SizedBox(height: 1.h),
                Text('• Get 5 free credits daily'),
                SizedBox(height: 1.h),
                Text('• Earn 10 credits per friend referral'),
                SizedBox(height: 1.h),
                Text('• All payments are secure and encrypted'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Got it'),
              ),
            ],
          ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'check_circle',
              color: Theme.of(context).colorScheme.onTertiary,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'error',
              color: Theme.of(context).colorScheme.onError,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
