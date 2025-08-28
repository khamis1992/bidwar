import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class RecommendationHeaderWidget extends StatelessWidget {
  final int totalRecommendations;
  final DateTime lastUpdated;

  const RecommendationHeaderWidget({
    Key? key,
    required this.totalRecommendations,
    required this.lastUpdated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
              SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  'Personalized for You',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade900,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.0),
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withAlpha(26),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Text(
                  '$totalRecommendations recommendations',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(width: 12.0),
              Icon(
                Icons.schedule,
                size: 14,
                color: Colors.grey.shade500,
              ),
              SizedBox(width: 4.0),
              Text(
                'Updated ${_getTimeAgo(lastUpdated)}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.0),
          Text(
            'Based on your bidding history, preferences, and similar users\' activities',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return DateFormat('MMM d').format(dateTime);
    }
  }
}