import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/product_selection.dart';

class PerformanceInsightsWidget extends StatelessWidget {
  final List<ProductSelection> selections;
  final List<Map<String, dynamic>> earnings;

  const PerformanceInsightsWidget({
    Key? key,
    required this.selections,
    required this.earnings,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Performance Insights',
          style: GoogleFonts.inter(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16.0),

        // Success rate card
        _buildSuccessRateCard(),

        const SizedBox(height: 16.0),

        // Category performance
        _buildCategoryPerformanceCard(),

        const SizedBox(height: 16.0),

        // Optimal streaming times
        _buildOptimalTimesCard(),

        const SizedBox(height: 16.0),

        // Recommendations
        _buildRecommendationsCard(),
      ],
    );
  }

  Widget _buildSuccessRateCard() {
    final totalSelections = selections.length;
    final completedAuctions =
        selections.where((s) => s.status == 'completed').length;
    final successRate =
        totalSelections > 0 ? (completedAuctions / totalSelections * 100) : 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
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
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Icon(
                  Icons.trending_up,
                  color: Colors.green.shade600,
                  size: 20.0,
                ),
              ),
              const SizedBox(width: 12.0),
              Text(
                'Success Rate',
                style: GoogleFonts.inter(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${successRate.toStringAsFixed(1)}%',
                      style: GoogleFonts.inter(
                        fontSize: 32.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade600,
                      ),
                    ),
                    Text(
                      'Auctions completed successfully',
                      style: GoogleFonts.inter(
                        fontSize: 14.0,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$completedAuctions / $totalSelections',
                    style: GoogleFonts.inter(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    'Completed',
                    style: GoogleFonts.inter(
                      fontSize: 12.0,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryPerformanceCard() {
    final categoryData = _getCategoryPerformance();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
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
          Text(
            'Top Performing Categories',
            style: GoogleFonts.inter(
              fontSize: 18.0,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16.0),
          if (categoryData.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.pie_chart_outline,
                      size: 48.0,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'No category data available',
                      style: GoogleFonts.inter(
                        fontSize: 14.0,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...categoryData
                .take(3)
                .map((category) => _buildCategoryItem(category))
                .toList(),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(Map<String, dynamic> category) {
    final name = category['name'] as String;
    final earnings = category['earnings'] as int;
    final count = category['count'] as int;
    final percentage = category['percentage'] as double;

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        children: [
          Container(
            width: 40.0,
            height: 40.0,
            decoration: BoxDecoration(
              color: _getCategoryColor(name).withAlpha(26),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Icon(
              _getCategoryIcon(name),
              color: _getCategoryColor(name),
              size: 20.0,
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.inter(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Text(
                  '$count auctions • ${earnings.toString()} credits',
                  style: GoogleFonts.inter(
                    fontSize: 12.0,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${percentage.toStringAsFixed(0)}%',
            style: GoogleFonts.inter(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: _getCategoryColor(name),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptimalTimesCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
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
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Icon(
                  Icons.access_time,
                  color: Colors.blue.shade600,
                  size: 20.0,
                ),
              ),
              const SizedBox(width: 12.0),
              Text(
                'Optimal Streaming Times',
                style: GoogleFonts.inter(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Row(
            children: [
              Expanded(
                child:
                    _buildTimeSlotItem('Peak Hours', '7PM - 9PM', Colors.green),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: _buildTimeSlotItem(
                    'Good Hours', '6PM - 7PM', Colors.orange),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlotItem(String label, String time, Color color) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12.0,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            time,
            style: GoogleFonts.inter(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
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
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Icon(
                  Icons.lightbulb,
                  color: Colors.purple.shade600,
                  size: 20.0,
                ),
              ),
              const SizedBox(width: 12.0),
              Text(
                'Recommendations',
                style: GoogleFonts.inter(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          ..._getRecommendations()
              .map((recommendation) => _buildRecommendationItem(recommendation))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildRecommendationItem(Map<String, dynamic> recommendation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6.0,
            height: 6.0,
            margin: const EdgeInsets.only(top: 8.0),
            decoration: BoxDecoration(
              color: Colors.purple.shade600,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Text(
              recommendation['text'] as String,
              style: GoogleFonts.inter(
                fontSize: 14.0,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getCategoryPerformance() {
    // Group selections by category and calculate performance
    final Map<String, Map<String, dynamic>> categoryData = {};

    for (final selection in selections) {
      final categoryName =
          selection.productInventory?['category']?['name'] as String? ??
              'Other';

      if (!categoryData.containsKey(categoryName)) {
        categoryData[categoryName] = {
          'name': categoryName,
          'count': 0,
          'earnings': 0,
        };
      }

      categoryData[categoryName]!['count'] =
          (categoryData[categoryName]!['count'] as int) + 1;
      categoryData[categoryName]!['earnings'] =
          (categoryData[categoryName]!['earnings'] as int) +
              selection.potentialCommission;
    }

    // Calculate percentages and sort by earnings
    final totalEarnings = categoryData.values
        .fold(0, (sum, category) => sum + (category['earnings'] as int));

    final result = categoryData.values.map((category) {
      category['percentage'] = totalEarnings > 0
          ? ((category['earnings'] as int) / totalEarnings * 100)
          : 0.0;
      return category;
    }).toList();

    result
        .sort((a, b) => (b['earnings'] as int).compareTo(a['earnings'] as int));

    return result;
  }

  List<Map<String, dynamic>> _getRecommendations() {
    final recommendations = <Map<String, dynamic>>[];

    if (selections.isEmpty) {
      recommendations.add({
        'text':
            'Start by selecting your first product to begin earning commissions.'
      });
    } else {
      final completedCount =
          selections.where((s) => s.status == 'completed').length;
      final successRate = completedCount / selections.length;

      if (successRate < 0.5) {
        recommendations.add({
          'text':
              'Focus on high-demand categories to improve your success rate.'
        });
      }

      if (earnings.isEmpty) {
        recommendations.add({
          'text':
              'Consider products with higher retail values for better commission potential.'
        });
      }

      recommendations.add({
        'text':
            'Schedule your auctions during peak hours (7PM - 9PM) for maximum engagement.'
      });

      recommendations.add({
        'text':
            'Upgrade your tier to access premium products and higher commission rates.'
      });
    }

    return recommendations;
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'electronics':
        return Colors.blue.shade600;
      case 'fashion':
        return Colors.pink.shade600;
      case 'home':
        return Colors.green.shade600;
      case 'luxury':
        return Colors.purple.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'electronics':
        return Icons.electrical_services;
      case 'fashion':
        return Icons.checkroom;
      case 'home':
        return Icons.home;
      case 'luxury':
        return Icons.diamond;
      default:
        return Icons.category;
    }
  }
}
