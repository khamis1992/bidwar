import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';


class RatingBreakdownWidget extends StatelessWidget {
  final Map<String, dynamic> ratingStats;

  const RatingBreakdownWidget({
    super.key,
    required this.ratingStats,
  });

  @override
  Widget build(BuildContext context) {
    final totalReviews = ratingStats['total_reviews'] ?? 0;
    final averageRating = ratingStats['average_rating'] ?? 0.0;

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
          Row(
            children: [
              Text(
                'Rating Breakdown',
                style: TextStyle(
                  fontSize: 18.h,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.h, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.amber.withAlpha(26),
                  borderRadius: BorderRadius.circular(20.h),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 16.h,
                    ),
                    SizedBox(width: 4.h),
                    Text(
                      '${averageRating.toStringAsFixed(1)}',
                      style: TextStyle(
                        fontSize: 14.h,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber[800],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          if (totalReviews > 0) ...[
            _buildStarRatingBars(),
            SizedBox(height: 16.h),
            _buildCategoryRatings(),
          ] else
            _buildNoRatingsState(),
        ],
      ),
    );
  }

  Widget _buildStarRatingBars() {
    final totalReviews = ratingStats['total_reviews'] ?? 0;
    final fiveStarCount = ratingStats['five_star_count'] ?? 0;
    final fourStarCount = ratingStats['four_star_count'] ?? 0;
    final threeStarCount = ratingStats['three_star_count'] ?? 0;
    final twoStarCount = ratingStats['two_star_count'] ?? 0;
    final oneStarCount = ratingStats['one_star_count'] ?? 0;

    return Column(
      children: [
        _buildRatingBar(5, fiveStarCount, totalReviews),
        _buildRatingBar(4, fourStarCount, totalReviews),
        _buildRatingBar(3, threeStarCount, totalReviews),
        _buildRatingBar(2, twoStarCount, totalReviews),
        _buildRatingBar(1, oneStarCount, totalReviews),
      ],
    );
  }

  Widget _buildRatingBar(int stars, int count, int total) {
    final percentage = total > 0 ? (count / total) : 0.0;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Text(
            '$stars',
            style: TextStyle(
              fontSize: 14.h,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 4.h),
          Icon(
            Icons.star,
            color: Colors.amber,
            size: 16.h,
          ),
          SizedBox(width: 8.h),
          Expanded(
            flex: 5,
            child: Container(
              height: 8.h,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4.h),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: percentage,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(4.h),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 8.h),
          Expanded(
            flex: 1,
            child: Text(
              count.toString(),
              style: TextStyle(
                fontSize: 12.h,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryRatings() {
    final avgProductQuality = ratingStats['average_product_quality'] ?? 0.0;
    final avgShippingSpeed = ratingStats['average_shipping_speed'] ?? 0.0;
    final avgCommunication = ratingStats['average_communication'] ?? 0.0;
    final avgStreamEntertainment =
        ratingStats['average_stream_entertainment'] ?? 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category Ratings',
          style: TextStyle(
            fontSize: 16.h,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 12.h),
        _buildCategoryRating(
            'Product Quality', avgProductQuality, Icons.inventory),
        _buildCategoryRating(
            'Shipping Speed', avgShippingSpeed, Icons.local_shipping),
        _buildCategoryRating('Communication', avgCommunication, Icons.chat),
        _buildCategoryRating(
            'Stream Entertainment', avgStreamEntertainment, Icons.live_tv),
      ],
    );
  }

  Widget _buildCategoryRating(String category, double rating, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20.h,
            color: Colors.grey[600],
          ),
          SizedBox(width: 8.h),
          Expanded(
            child: Text(
              category,
              style: TextStyle(fontSize: 14.h),
            ),
          ),
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < rating.floor()
                    ? Icons.star
                    : (index < rating ? Icons.star_half : Icons.star_border),
                color: Colors.amber,
                size: 16.h,
              );
            }),
          ),
          SizedBox(width: 8.h),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: 14.h,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoRatingsState() {
    return Container(
      padding: EdgeInsets.all(32.h),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.star_outline,
              size: 64.h,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16.h),
            Text(
              'No ratings yet',
              style: TextStyle(
                fontSize: 18.h,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'This seller has not received any ratings yet.\nBe the first to leave a review!',
              style: TextStyle(
                fontSize: 14.h,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
