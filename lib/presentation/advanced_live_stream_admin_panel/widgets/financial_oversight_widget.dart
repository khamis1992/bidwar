import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class FinancialOversightWidget extends StatefulWidget {
  const FinancialOversightWidget({Key? key}) : super(key: key);

  @override
  State<FinancialOversightWidget> createState() =>
      _FinancialOversightWidgetState();
}

class _FinancialOversightWidgetState extends State<FinancialOversightWidget> {
  String _selectedPeriod = '7d';
  List<Map<String, dynamic>> _transactions = [];
  Map<String, dynamic> _financialMetrics = {};

  @override
  void initState() {
    super.initState();
    _loadFinancialData();
  }

  void _loadFinancialData() {
    // Mock financial data
    _financialMetrics = {
      'total_revenue': 125000.00,
      'platform_fees': 6250.00,
      'payment_fees': 3625.00,
      'net_revenue': 115125.00,
      'pending_payouts': 45000.00,
      'completed_payouts': 70125.00,
      'refunds': 2500.00,
      'chargebacks': 500.00,
      'revenue_growth': 15.5,
      'transaction_count': 1250,
    };

    _transactions = [
      {
        'id': 'txn_001',
        'type': 'sale',
        'amount': 850.00,
        'seller': 'John Doe',
        'buyer': 'Jane Smith',
        'item': 'Vintage Watch',
        'status': 'completed',
        'timestamp': DateTime.now().subtract(Duration(minutes: 15)),
        'platform_fee': 42.50,
        'payment_fee': 24.65,
      },
      {
        'id': 'txn_002',
        'type': 'refund',
        'amount': -250.00,
        'seller': 'Mike Johnson',
        'buyer': 'Sarah Wilson',
        'item': 'Antique Vase',
        'status': 'processed',
        'timestamp': DateTime.now().subtract(Duration(hours: 2)),
        'platform_fee': -12.50,
        'payment_fee': -7.25,
      },
    ];

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildFinancialOverview(),
        const SizedBox(height: 16),
        _buildRevenueChart(),
        const SizedBox(height: 16),
        _buildTransactionsList(),
      ],
    );
  }

  Widget _buildFinancialOverview() {
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
                'Financial Overview',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              DropdownButton<String>(
                value: _selectedPeriod,
                items: const [
                  DropdownMenuItem(value: '7d', child: Text('Last 7 days')),
                  DropdownMenuItem(value: '30d', child: Text('Last 30 days')),
                  DropdownMenuItem(value: '90d', child: Text('Last 90 days')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedPeriod = value!;
                  });
                  _loadFinancialData();
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 4,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 2,
            children: [
              _buildMetricCard(
                'Total Revenue',
                '\$${(_financialMetrics['total_revenue'] ?? 0).toStringAsFixed(2)}',
                Icons.attach_money,
                Colors.green,
                '+${(_financialMetrics['revenue_growth'] ?? 0).toStringAsFixed(1)}%',
              ),
              _buildMetricCard(
                'Platform Fees',
                '\$${(_financialMetrics['platform_fees'] ?? 0).toStringAsFixed(2)}',
                Icons.business,
                Colors.blue,
                '5.0% avg',
              ),
              _buildMetricCard(
                'Pending Payouts',
                '\$${(_financialMetrics['pending_payouts'] ?? 0).toStringAsFixed(2)}',
                Icons.schedule,
                Colors.orange,
                '${(_financialMetrics['transaction_count'] ?? 0)} txns',
              ),
              _buildMetricCard(
                'Net Revenue',
                '\$${(_financialMetrics['net_revenue'] ?? 0).toStringAsFixed(2)}',
                Icons.trending_up,
                Colors.purple,
                'After fees',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
      String title, String value, IconData icon, Color color, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(77)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 20),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
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

  Widget _buildRevenueChart() {
    return Container(
      height: 300,
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
            'Revenue Trends',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true),
                  ),
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: true),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      FlSpot(0, 3000),
                      FlSpot(1, 4500),
                      FlSpot(2, 3800),
                      FlSpot(3, 5200),
                      FlSpot(4, 4800),
                      FlSpot(5, 6100),
                      FlSpot(6, 5500),
                    ],
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 3,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.blue.withAlpha(26),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList() {
    return Expanded(
      child: Container(
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
                  'Recent Transactions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => _exportTransactions(),
                  child: const Text('Export'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _transactions.length,
                itemBuilder: (context, index) {
                  final transaction = _transactions[index];
                  return _buildTransactionItem(transaction);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction) {
    Color statusColor =
        transaction['type'] == 'sale' ? Colors.green : Colors.red;
    IconData statusIcon = transaction['type'] == 'sale'
        ? Icons.arrow_upward
        : Icons.arrow_downward;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withAlpha(26),
          child: Icon(statusIcon, color: statusColor),
        ),
        title: Text('${transaction['item']} - ${transaction['id']}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${transaction['seller']} → ${transaction['buyer']}'),
            Text(
              _formatTimestamp(transaction['timestamp']),
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '\$${transaction['amount'].abs().toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: statusColor,
                fontSize: 16,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withAlpha(26),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                transaction['status'],
                style: TextStyle(
                  color: statusColor,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
        onTap: () => _showTransactionDetails(transaction),
      ),
    );
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

  void _showTransactionDetails(Map<String, dynamic> transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Transaction Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('ID: ${transaction['id']}'),
              const SizedBox(height: 8),
              Text('Item: ${transaction['item']}'),
              const SizedBox(height: 8),
              Text(
                  'Amount: \$${transaction['amount'].abs().toStringAsFixed(2)}'),
              const SizedBox(height: 8),
              Text(
                  'Platform Fee: \$${transaction['platform_fee'].abs().toStringAsFixed(2)}'),
              const SizedBox(height: 8),
              Text(
                  'Payment Fee: \$${transaction['payment_fee'].abs().toStringAsFixed(2)}'),
              const SizedBox(height: 8),
              Text('Status: ${transaction['status']}'),
              const SizedBox(height: 8),
              Text('Date: ${transaction['timestamp']}'),
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

  void _exportTransactions() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exporting transaction data...'),
      ),
    );
  }
}
