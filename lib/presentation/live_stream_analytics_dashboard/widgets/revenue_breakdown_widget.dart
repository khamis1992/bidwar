import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'dart:math' as math;

class RevenueBreakdownWidget extends StatelessWidget {
  final Map<String, dynamic> revenueData;

  const RevenueBreakdownWidget({
    super.key,
    required this.revenueData,
  });

  @override
  Widget build(BuildContext context) {
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
            'Revenue Breakdown',
            style: TextStyle(
              fontSize: 18.h,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),
          _buildRevenueCards(),
          SizedBox(height: 16.h),
          _buildCommissionBreakdown(),
          SizedBox(height: 16.h),
          _buildSalesList(),
        ],
      ),
    );
  }

  Widget _buildRevenueCards() {
    final totalSales = revenueData['total_sales'] ?? 0.0;
    final avgBidValue = revenueData['average_bid_value'] ?? 0.0;
    final totalItems = revenueData['total_items_sold'] ?? 0;

    return Row(
      children: [
        Expanded(
          child: _buildRevenueCard(
            'Total Sales',
            '\$${totalSales.toStringAsFixed(2)}',
            Icons.monetization_on,
            Colors.green,
          ),
        ),
        SizedBox(width: 12.h),
        Expanded(
          child: _buildRevenueCard(
            'Avg. Bid Value',
            '\$${avgBidValue.toStringAsFixed(2)}',
            Icons.trending_up,
            Colors.blue,
          ),
        ),
        SizedBox(width: 12.h),
        Expanded(
          child: _buildRevenueCard(
            'Items Sold',
            totalItems.toString(),
            Icons.shopping_cart,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildRevenueCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(12.h),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(8.h),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: 24.h,
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 18.h,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12.h,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommissionBreakdown() {
    final commissionDetails = revenueData['commission_details'] ?? {};
    final platformFee = commissionDetails['platform_fee'] ?? 0.0;
    final paymentFee = commissionDetails['payment_fee'] ?? 0.0;
    final netRevenue = commissionDetails['net_revenue'] ?? 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Commission Details',
          style: TextStyle(
            fontSize: 16.h,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.all(12.h),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8.h),
          ),
          child: Column(
            children: [
              _buildCommissionRow(
                  'Gross Sales', revenueData['total_sales'] ?? 0.0),
              _buildCommissionRow('Platform Fee', -platformFee,
                  isNegative: true),
              _buildCommissionRow('Payment Processing', -paymentFee,
                  isNegative: true),
              Divider(height: 16.h),
              _buildCommissionRow('Net Revenue', netRevenue, isBold: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCommissionRow(String title, double amount,
      {bool isNegative = false, bool isBold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14.h,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isNegative ? Colors.red[600] : Colors.black,
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 14.h,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isNegative
                  ? Colors.red[600]
                  : (isBold ? Colors.green[600] : Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesList() {
    final recentSales = revenueData['recent_sales'] as List<dynamic>? ?? [];

    if (recentSales.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Sales',
            style: TextStyle(
              fontSize: 16.h,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(32.h),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8.h),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 48.h,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'No recent sales data',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14.h,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Sales',
          style: TextStyle(
            fontSize: 16.h,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8.h),
          ),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: math.min(recentSales.length, 5),
            itemBuilder: (context, index) {
              final sale = recentSales[index];
              return _buildSaleItem(sale, index < recentSales.length - 1);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSaleItem(Map<String, dynamic> sale, bool showDivider) {
    final itemTitle = sale['item_title'] ?? 'Unknown Item';
    final finalPrice = sale['final_price'] ?? 0.0;
    final bidderName = sale['bidder_name'] ?? 'Anonymous';
    final saleDate = sale['sale_date'] ?? '';

    return Container(
      padding: EdgeInsets.all(12.h),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      itemTitle,
                      style: TextStyle(
                        fontSize: 14.h,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Sold to $bidderName',
                      style: TextStyle(
                        fontSize: 12.h,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${finalPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16.h,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[600],
                    ),
                  ),
                  Text(
                    saleDate,
                    style: TextStyle(
                      fontSize: 12.h,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (showDivider) Divider(height: 16.h),
        ],
      ),
    );
  }
}
