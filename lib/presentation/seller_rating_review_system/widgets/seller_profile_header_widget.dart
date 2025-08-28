import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';


class SellerProfileHeaderWidget extends StatelessWidget {
  final Map<String, dynamic> sellerData;
  final Map<String, dynamic> ratingStats;

  const SellerProfileHeaderWidget({
    super.key,
    required this.sellerData,
    required this.ratingStats,
  });

  @override
  Widget build(BuildContext context) {
    final sellerName = sellerData['full_name'] ?? 'Unknown Seller';
    final profilePicture = sellerData['profile_picture_url'];
    final averageRating = ratingStats['average_rating'] ?? 0.0;
    final totalReviews = ratingStats['total_reviews'] ?? 0;
    final totalTransactions = ratingStats['total_transactions'] ?? 0;
    final responseRate = ratingStats['response_rate'] ?? 0.0;
    final joinDate = sellerData['created_at'];
    final isVerified = sellerData['is_verified'] ?? false;

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
        children: [
          Row(
            children: [
              _buildProfilePicture(profilePicture),
              SizedBox(width: 16.h),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            sellerName,
                            style: TextStyle(
                              fontSize: 20.h,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (isVerified)
                          Icon(
                            Icons.verified,
                            color: Colors.blue,
                            size: 20.h,
                          ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    _buildRatingRow(averageRating, totalReviews),
                    SizedBox(height: 8.h),
                    _buildSellerBadges(),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildStatsRow(totalTransactions, responseRate, joinDate),
        ],
      ),
    );
  }

  Widget _buildProfilePicture(String? profilePicture) {
    return Container(
      width: 80.h,
      height: 80.h,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey[300]!, width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40.h),
        child: profilePicture != null && profilePicture.isNotEmpty
            ? Image.network(
                profilePicture,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildDefaultAvatar(),
              )
            : _buildDefaultAvatar(),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: Colors.grey[200],
      child: Icon(
        Icons.person,
        size: 40.h,
        color: Colors.grey[600],
      ),
    );
  }

  Widget _buildRatingRow(double averageRating, int totalReviews) {
    return Row(
      children: [
        Row(
          children: List.generate(5, (index) {
            return Icon(
              index < averageRating.floor()
                  ? Icons.star
                  : (index < averageRating
                      ? Icons.star_half
                      : Icons.star_border),
              color: Colors.amber,
              size: 18.h,
            );
          }),
        ),
        SizedBox(width: 8.h),
        Text(
          '${averageRating.toStringAsFixed(1)} (${totalReviews} reviews)',
          style: TextStyle(
            fontSize: 14.h,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildSellerBadges() {
    return Wrap(
      spacing: 6.h,
      children: [
        _buildBadge('Top Seller', Colors.orange),
        _buildBadge('Fast Shipping', Colors.green),
        _buildBadge('Great Communication', Colors.blue),
      ],
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.h, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(12.h),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.h,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildStatsRow(
      int totalTransactions, double responseRate, String? joinDate) {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            'Transactions',
            totalTransactions.toString(),
            Icons.shopping_bag,
          ),
        ),
        Expanded(
          child: _buildStatItem(
            'Response Rate',
            '${responseRate.toStringAsFixed(0)}%',
            Icons.reply,
          ),
        ),
        Expanded(
          child: _buildStatItem(
            'Member Since',
            _formatJoinDate(joinDate),
            Icons.calendar_today,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20.h,
          color: Colors.grey[600],
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.h,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 12.h,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _formatJoinDate(String? joinDate) {
    if (joinDate == null) return 'Unknown';

    try {
      final date = DateTime.parse(joinDate);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays >= 365) {
        return '${(difference.inDays / 365).floor()} years';
      } else if (difference.inDays >= 30) {
        return '${(difference.inDays / 30).floor()} months';
      } else {
        return '${difference.inDays} days';
      }
    } catch (e) {
      return 'Unknown';
    }
  }
}
