import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../models/recommendation.dart';

class RecommendationExplanationWidget extends StatelessWidget {
  final List<Recommendation> recommendations;

  const RecommendationExplanationWidget({
    Key? key,
    required this.recommendations,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (recommendations.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView(
      padding: EdgeInsets.all(16.h),
      children: [
        _buildOverallInsights(context),
        SizedBox(height: 24.0),
        _buildConfidenceDistribution(context),
        SizedBox(height: 24.0),
        _buildRecommendationTypes(context),
        SizedBox(height: 24.0),
        _buildTopRecommendationReasons(context),
        SizedBox(height: 24.0),
        _buildImprovementTips(context),
      ],
    );
  }

  Widget _buildOverallInsights(BuildContext context) {
    final averageConfidence = recommendations.isNotEmpty
        ? recommendations
                .map((r) => r.confidenceScore)
                .reduce((a, b) => a + b) /
            recommendations.length
        : 0.0;

    final topCategories = _getTopCategories();
    final mostCommonReason = _getMostCommonReason();

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
            'Recommendation Insights',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.grey[900],
            ),
          ),
          SizedBox(height: 16.0),
          _buildInsightRow(
            Icons.trending_up,
            'Average Match Score',
            '${(averageConfidence * 100).toInt()}%',
            _getConfidenceColor(averageConfidence),
          ),
          SizedBox(height: 12.0),
          _buildInsightRow(
            Icons.category,
            'Top Categories',
            topCategories.join(', '),
            Colors.blue[600]!,
          ),
          SizedBox(height: 12.0),
          _buildInsightRow(
            Icons.psychology,
            'Main Reason',
            mostCommonReason,
            Colors.green[600]!,
          ),
        ],
      ),
    );
  }

  Widget _buildConfidenceDistribution(BuildContext context) {
    final confidenceRanges = <String, int>{
      '90-100%': 0,
      '80-90%': 0,
      '70-80%': 0,
      '60-70%': 0,
      'Below 60%': 0,
    };

    for (final recommendation in recommendations) {
      final confidence = (recommendation.confidenceScore * 100).toInt();
      if (confidence >= 90) {
        confidenceRanges['90-100%'] = confidenceRanges['90-100%']! + 1;
      } else if (confidence >= 80) {
        confidenceRanges['80-90%'] = confidenceRanges['80-90%']! + 1;
      } else if (confidence >= 70) {
        confidenceRanges['70-80%'] = confidenceRanges['70-80%']! + 1;
      } else if (confidence >= 60) {
        confidenceRanges['60-70%'] = confidenceRanges['60-70%']! + 1;
      } else {
        confidenceRanges['Below 60%'] = confidenceRanges['Below 60%']! + 1;
      }
    }

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
            'Confidence Distribution',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.grey[900],
            ),
          ),
          SizedBox(height: 16.0),
          SizedBox(
            height: 200.0,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: confidenceRanges.values
                        .reduce((a, b) => a > b ? a : b)
                        .toDouble() +
                    1,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Colors.grey[800],
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${confidenceRanges.keys.elementAt(group.x.toInt())}\n${rod.toY.toInt()} items',
                        const TextStyle(color: Colors.white, fontSize: 12),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Text(
                            confidenceRanges.keys.elementAt(value.toInt()),
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30.h,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return Text(
                          value.toInt().toString(),
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                barGroups: confidenceRanges.entries.map((entry) {
                  final index =
                      confidenceRanges.keys.toList().indexOf(entry.key);
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.toDouble(),
                        color: _getBarColor(entry.key),
                        width: 30.h,
                        borderRadius: BorderRadius.circular(4.h),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationTypes(BuildContext context) {
    final typeCounts = <String, int>{};
    for (final recommendation in recommendations) {
      typeCounts[recommendation.type] =
          (typeCounts[recommendation.type] ?? 0) + 1;
    }

    final sortedTypes = typeCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

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
            'Recommendation Types',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.grey[900],
            ),
          ),
          SizedBox(height: 16.0),
          ...sortedTypes.map((entry) => Padding(
                padding: EdgeInsets.only(bottom: 12.0),
                child: Row(
                  children: [
                    Container(
                      width: 12.0,
                      height: 12.0,
                      decoration: BoxDecoration(
                        color: _getTypeColor(entry.key),
                        borderRadius: BorderRadius.circular(6.h),
                      ),
                    ),
                    SizedBox(width: 12.h),
                    Expanded(
                      child: Text(
                        _formatTypeName(entry.key),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.h, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: _getTypeColor(entry.key).withAlpha(26),
                        borderRadius: BorderRadius.circular(12.h),
                      ),
                      child: Text(
                        entry.value.toString(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: _getTypeColor(entry.key),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildTopRecommendationReasons(BuildContext context) {
    final reasonCounts = <String, int>{};
    for (final recommendation in recommendations) {
      final reasoning = recommendation.reasoning;
      if (reasoning['matched_categories'] != null) {
        reasonCounts['Category Match'] =
            (reasonCounts['Category Match'] ?? 0) + 1;
      }
      if (reasoning['similar_items_viewed'] != null) {
        reasonCounts['Similar Items'] =
            (reasonCounts['Similar Items'] ?? 0) + 1;
      }
      if (reasoning['price_fit'] != null) {
        reasonCounts['Price Match'] = (reasonCounts['Price Match'] ?? 0) + 1;
      }
      if (reasoning['seller_reputation'] != null) {
        reasonCounts['Seller Reputation'] =
            (reasonCounts['Seller Reputation'] ?? 0) + 1;
      }
    }

    final sortedReasons = reasonCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

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
            'Top Recommendation Factors',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.grey[900],
            ),
          ),
          SizedBox(height: 16.0),
          ...sortedReasons.take(5).map((entry) => Padding(
                padding: EdgeInsets.only(bottom: 12.0),
                child: Row(
                  children: [
                    Icon(
                      _getReasonIcon(entry.key),
                      size: 16.0,
                      color: Colors.blue,
                    ),
                    SizedBox(width: 12.h),
                    Expanded(
                      child: Text(
                        entry.key,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      '${((entry.value / recommendations.length) * 100).toInt()}%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildImprovementTips(BuildContext context) {
    final tips = <String>[];

    if (recommendations.length < 5) {
      tips.add('Browse more auctions to get better recommendations');
    }

    final avgConfidence = recommendations.isNotEmpty
        ? recommendations
                .map((r) => r.confidenceScore)
                .reduce((a, b) => a + b) /
            recommendations.length
        : 0.0;

    if (avgConfidence < 0.7) {
      tips.add(
          'Update your preferences in Settings for more accurate suggestions');
    }

    tips.add('Like or dislike recommendations to improve future suggestions');
    tips.add('Add items to your watchlist to help us learn your taste');

    return Container(
      padding: EdgeInsets.all(16.h),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12.h),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outlined,
                color: Colors.blue[600],
                size: 20.0,
              ),
              SizedBox(width: 8.h),
              Text(
                'Improvement Tips',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[900],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.0),
          ...tips.map((tip) => Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 4.0,
                      height: 4.0,
                      margin: EdgeInsets.only(top: 8.0, right: 8.h),
                      decoration: BoxDecoration(
                        color: Colors.blue[600],
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        tip,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.blue[800],
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildInsightRow(
      IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20.0),
        SizedBox(width: 12.h),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey[700],
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey[900],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 64.0,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16.0),
            Text(
              'No data to analyze yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              'Get some recommendations first to see detailed insights',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  List<String> _getTopCategories() {
    final categoryCounts = <String, int>{};
    for (final recommendation in recommendations) {
      final reasoning = recommendation.reasoning;
      if (reasoning['matched_categories'] != null) {
        final categories = reasoning['matched_categories'] as List;
        for (final category in categories) {
          categoryCounts[category.toString()] =
              (categoryCounts[category.toString()] ?? 0) + 1;
        }
      }
    }

    final sorted = categoryCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(3).map((e) => e.key).toList();
  }

  String _getMostCommonReason() {
    final reasonCounts = <String, int>{};
    for (final recommendation in recommendations) {
      final reasoning = recommendation.reasoning;
      if (reasoning['matched_categories'] != null) {
        reasonCounts['Category Match'] =
            (reasonCounts['Category Match'] ?? 0) + 1;
      }
      if (reasoning['similar_items_viewed'] != null) {
        reasonCounts['Similar Items'] =
            (reasonCounts['Similar Items'] ?? 0) + 1;
      }
      if (reasoning['price_fit'] != null) {
        reasonCounts['Price Match'] = (reasonCounts['Price Match'] ?? 0) + 1;
      }
    }

    if (reasonCounts.isEmpty) return 'Based on your activity';

    return reasonCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return Colors.green[600]!;
    if (confidence >= 0.6) return Colors.orange[600]!;
    return Colors.red[600]!;
  }

  Color _getBarColor(String range) {
    switch (range) {
      case '90-100%':
        return Colors.green[600]!;
      case '80-90%':
        return Colors.blue[600]!;
      case '70-80%':
        return Colors.orange[600]!;
      case '60-70%':
        return Colors.red[400]!;
      default:
        return Colors.red[600]!;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'similar_to_watched':
        return Colors.blue[600]!;
      case 'trending_now':
        return Colors.orange[600]!;
      case 'ending_soon':
        return Colors.red[600]!;
      case 'new_sellers':
        return Colors.green[600]!;
      case 'category_based':
        return Colors.purple[600]!;
      default:
        return Colors.grey[600]!;
    }
  }

  String _formatTypeName(String type) {
    switch (type) {
      case 'similar_to_watched':
        return 'Similar to Watched';
      case 'trending_now':
        return 'Trending Now';
      case 'ending_soon':
        return 'Ending Soon';
      case 'new_sellers':
        return 'New Sellers';
      case 'category_based':
        return 'Category Based';
      case 'price_based':
        return 'Price Based';
      default:
        return 'Other';
    }
  }

  IconData _getReasonIcon(String reason) {
    switch (reason) {
      case 'Category Match':
        return Icons.category;
      case 'Similar Items':
        return Icons.preview;
      case 'Price Match':
        return Icons.attach_money;
      case 'Seller Reputation':
        return Icons.star;
      default:
        return Icons.info;
    }
  }
}