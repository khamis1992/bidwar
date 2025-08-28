import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';

import '../../../models/recommendation.dart';

class RecommendedStreamsListWidget extends StatelessWidget {
  final List<Recommendation> recommendations;
  final Function(Recommendation) onRecommendationTapped;
  final Function(Recommendation, String, String?) onFeedback;
  final bool showDiscoveryMode;

  const RecommendedStreamsListWidget({
    Key? key,
    required this.recommendations,
    required this.onRecommendationTapped,
    required this.onFeedback,
    this.showDiscoveryMode = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (recommendations.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      padding: EdgeInsets.all(16.sp),
      itemCount: recommendations.length,
      separatorBuilder: (context, index) => SizedBox(height: 16.sp),
      itemBuilder: (context, index) {
        return _buildRecommendationCard(context, recommendations[index]);
      },
    );
  }

  Widget _buildRecommendationCard(
    BuildContext context,
    Recommendation recommendation,
  ) {
    return GestureDetector(
      onTap: () => onRecommendationTapped(recommendation),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.sp),
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
            // Image and Live Stream Indicator
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(12.sp),
                  ),
                  child: CachedNetworkImage(
                    imageUrl:
                        recommendation.auctionItem.images.isNotEmpty
                            ? recommendation.auctionItem.images.first
                            : 'https://images.unsplash.com/photo-1560472354-b33ff0c44a43',
                    height: 200.sp,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder:
                        (context, url) => Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            height: 200.sp,
                            width: double.infinity,
                            color: Colors.white,
                          ),
                        ),
                    errorWidget:
                        (context, url, error) => Container(
                          height: 200.sp,
                          width: double.infinity,
                          color: Colors.grey[100]!,
                          child: Icon(
                            Icons.image_not_supported,
                            color: Colors.grey[400]!,
                            size: 48.sp,
                          ),
                        ),
                  ),
                ),
                // Live indicator
                if (recommendation.auctionItem.status == 'live')
                  Positioned(
                    top: 12.sp,
                    left: 12.sp,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.sp,
                        vertical: 4.sp,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12.sp),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6.sp,
                            height: 6.sp,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 4.sp),
                          Text(
                            'LIVE',
                            style: Theme.of(
                              context,
                            ).textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Confidence Score
                Positioned(
                  top: 12.sp,
                  right: 12.sp,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.sp,
                      vertical: 4.sp,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(179),
                      borderRadius: BorderRadius.circular(12.sp),
                    ),
                    child: Text(
                      '${(recommendation.confidenceScore * 100).toInt()}% match',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Content
            Padding(
              padding: EdgeInsets.all(16.sp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Recommendation Type
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          recommendation.auctionItem.title,
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[900],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (showDiscoveryMode)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.sp,
                            vertical: 2.sp,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(8.sp),
                          ),
                          child: Text(
                            _formatRecommendationType(recommendation.type),
                            style: Theme.of(
                              context,
                            ).textTheme.labelSmall?.copyWith(
                              color: Colors.blue[700],
                              fontSize: 10.sp,
                            ),
                          ),
                        ),
                    ],
                  ),

                  SizedBox(height: 8.sp),

                  // Price and Time Info
                  Row(
                    children: [
                      Text(
                        '\$${recommendation.auctionItem.currentHighestBid.toStringAsFixed(0)}',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      SizedBox(width: 8.sp),
                      Text(
                        'Current bid',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const Spacer(),
                      if (recommendation.auctionItem.endTime.isAfter(
                        DateTime.now(),
                      ))
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.sp,
                            vertical: 4.sp,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange[100],
                            borderRadius: BorderRadius.circular(12.sp),
                          ),
                          child: Text(
                            _getTimeRemaining(
                              recommendation.auctionItem.endTime,
                            ),
                            style: Theme.of(
                              context,
                            ).textTheme.labelSmall?.copyWith(
                              color: Colors.orange[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),

                  SizedBox(height: 12.sp),

                  // Recommendation Reasoning
                  if (recommendation.reasoning.isNotEmpty)
                    Container(
                      padding: EdgeInsets.all(12.sp),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8.sp),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            size: 16.sp,
                            color: Theme.of(context).primaryColor,
                          ),
                          SizedBox(width: 8.sp),
                          Expanded(
                            child: Text(
                              _buildReasoningText(recommendation.reasoning),
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[700],
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),

                  SizedBox(height: 12.sp),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed:
                              () => onRecommendationTapped(recommendation),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: EdgeInsets.symmetric(vertical: 12.sp),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.sp),
                            ),
                          ),
                          child: const Text('View Details'),
                        ),
                      ),
                      SizedBox(width: 12.sp),
                      _buildFeedbackButton(context, recommendation),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackButton(
    BuildContext context,
    Recommendation recommendation,
  ) {
    return PopupMenuButton<String>(
      onSelected:
          (value) => _showFeedbackDialog(context, recommendation, value),
      itemBuilder:
          (context) => [
            const PopupMenuItem(
              value: 'like',
              child: Row(
                children: [
                  Icon(Icons.thumb_up_outlined, size: 16),
                  SizedBox(width: 8),
                  Text('Like'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'dislike',
              child: Row(
                children: [
                  Icon(Icons.thumb_down_outlined, size: 16),
                  SizedBox(width: 8),
                  Text('Not interested'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'report',
              child: Row(
                children: [
                  Icon(Icons.report_outlined, size: 16),
                  SizedBox(width: 8),
                  Text('Report'),
                ],
              ),
            ),
          ],
      child: Container(
        padding: EdgeInsets.all(12.sp),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8.sp),
        ),
        child: Icon(Icons.more_vert, size: 16.sp, color: Colors.grey[600]),
      ),
    );
  }

  void _showFeedbackDialog(
    BuildContext context,
    Recommendation recommendation,
    String feedbackType,
  ) {
    if (feedbackType == 'like') {
      onFeedback(recommendation, feedbackType, null);
      return;
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(_getFeedbackTitle(feedbackType)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Help us improve your recommendations'),
                const SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Tell us why (optional)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  maxLines: 3,
                  onSubmitted: (reason) {
                    Navigator.of(context).pop();
                    onFeedback(
                      recommendation,
                      feedbackType,
                      reason.isEmpty ? null : reason,
                    );
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onFeedback(recommendation, feedbackType, null);
                },
                child: const Text('Submit'),
              ),
            ],
          ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.sp),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.explore_outlined, size: 64.sp, color: Colors.grey[400]),
            SizedBox(height: 16.sp),
            Text(
              'No recommendations yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8.sp),
            Text(
              'Start browsing auctions to get personalized recommendations',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatRecommendationType(String type) {
    switch (type) {
      case 'similar_to_watched':
        return 'Similar';
      case 'trending_now':
        return 'Trending';
      case 'ending_soon':
        return 'Ending Soon';
      case 'new_sellers':
        return 'New Seller';
      case 'category_based':
        return 'Category Match';
      case 'price_based':
        return 'Price Match';
      default:
        return 'Recommended';
    }
  }

  String _getTimeRemaining(DateTime endTime) {
    final now = DateTime.now();
    final difference = endTime.difference(now);

    if (difference.isNegative) return 'Ended';

    if (difference.inDays > 0) {
      return '${difference.inDays}d ${difference.inHours % 24}h left';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ${difference.inMinutes % 60}m left';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m left';
    } else {
      return 'Ending now';
    }
  }

  String _buildReasoningText(Map<String, dynamic> reasoning) {
    final reasons = <String>[];

    if (reasoning['matched_categories'] != null) {
      final categories = reasoning['matched_categories'] as List;
      reasons.add('Matches your interest in ${categories.join(', ')}');
    }

    if (reasoning['similar_items_viewed'] != null) {
      reasons.add(
        'Similar to ${reasoning['similar_items_viewed']} items you viewed',
      );
    }

    if (reasoning['price_fit'] != null) {
      reasons.add('Within your preferred price range');
    }

    if (reasoning['seller_reputation'] != null) {
      reasons.add('From a highly rated seller');
    }

    return reasons.isNotEmpty
        ? reasons.first
        : 'Recommended based on your activity';
  }

  String _getFeedbackTitle(String feedbackType) {
    switch (feedbackType) {
      case 'dislike':
        return 'Not Interested';
      case 'report':
        return 'Report Issue';
      default:
        return 'Feedback';
    }
  }
}
