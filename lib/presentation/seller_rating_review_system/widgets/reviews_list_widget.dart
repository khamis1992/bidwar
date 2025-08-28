import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'dart:math' as math;

class ReviewsListWidget extends StatelessWidget {
  final List<dynamic> reviews;
  final Function(String action, String reviewId) onReviewAction;

  const ReviewsListWidget({
    super.key,
    required this.reviews,
    required this.onReviewAction,
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
            'Reviews (${reviews.length})',
            style: TextStyle(
              fontSize: 18.h,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),
          if (reviews.isEmpty)
            _buildNoReviewsState()
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                final review = reviews[index];
                return _buildReviewItem(
                    context, review, index < reviews.length - 1);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildNoReviewsState() {
    return Container(
      padding: EdgeInsets.all(40.h),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.rate_review_outlined,
              size: 64.h,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16.h),
            Text(
              'No reviews yet',
              style: TextStyle(
                fontSize: 18.h,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'This seller has not received any reviews yet.\nBe the first to share your experience!',
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

  Widget _buildReviewItem(
      BuildContext context, Map<String, dynamic> review, bool showDivider) {
    final reviewerName = review['reviewer_name'] ?? 'Anonymous';
    final reviewerAvatar = review['reviewer_avatar'];
    final overallRating =
        int.tryParse(review['overall_rating'].toString()) ?? 0;
    final reviewText = review['review_text'] ?? '';
    final createdAt = review['created_at'] ?? '';
    final isVerified = review['is_verified'] ?? false;
    final sellerResponse = review['seller_response'];
    final sellerResponseDate = review['seller_response_date'];
    final auctionContext = review['auction_context'] ?? {};
    final reviewImages = review['review_images'] as List<dynamic>? ?? [];

    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildReviewerAvatar(reviewerAvatar, reviewerName),
              SizedBox(width: 12.h),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildReviewHeader(
                        reviewerName, overallRating, createdAt, isVerified),
                    if (auctionContext.isNotEmpty) ...[
                      SizedBox(height: 4.h),
                      _buildAuctionContext(auctionContext),
                    ],
                    SizedBox(height: 8.h),
                    _buildCategoryRatings(review),
                    if (reviewText.isNotEmpty) ...[
                      SizedBox(height: 8.h),
                      Text(
                        reviewText,
                        style: TextStyle(
                          fontSize: 14.h,
                          height: 1.4,
                        ),
                      ),
                    ],
                    if (reviewImages.isNotEmpty) ...[
                      SizedBox(height: 8.h),
                      _buildReviewImages(reviewImages),
                    ],
                    SizedBox(height: 8.h),
                    _buildReviewActions(context, review['id']),
                  ],
                ),
              ),
            ],
          ),
          if (sellerResponse != null) ...[
            SizedBox(height: 12.h),
            _buildSellerResponse(sellerResponse, sellerResponseDate),
          ],
          if (showDivider) ...[
            SizedBox(height: 16.h),
            Divider(color: Colors.grey[300]),
          ],
        ],
      ),
    );
  }

  Widget _buildReviewerAvatar(String? avatarUrl, String reviewerName) {
    return Container(
      width: 40.h,
      height: 40.h,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.h),
        child: avatarUrl != null && avatarUrl.isNotEmpty
            ? Image.network(
                avatarUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildDefaultReviewerAvatar(reviewerName),
              )
            : _buildDefaultReviewerAvatar(reviewerName),
      ),
    );
  }

  Widget _buildDefaultReviewerAvatar(String reviewerName) {
    return Container(
      color: Colors.blue[100],
      child: Center(
        child: Text(
          reviewerName.isNotEmpty ? reviewerName[0].toUpperCase() : '?',
          style: TextStyle(
            fontSize: 16.h,
            fontWeight: FontWeight.bold,
            color: Colors.blue[700],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewHeader(
      String reviewerName, int rating, String createdAt, bool isVerified) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Text(
                reviewerName,
                style: TextStyle(
                  fontSize: 14.h,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (isVerified) ...[
                SizedBox(width: 4.h),
                Icon(
                  Icons.verified_user,
                  size: 14.h,
                  color: Colors.green,
                ),
              ],
            ],
          ),
        ),
        Text(
          _formatDate(createdAt),
          style: TextStyle(
            fontSize: 12.h,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildAuctionContext(Map<String, dynamic> auctionContext) {
    final itemTitle = auctionContext['item_title'] ?? '';
    final itemImage = auctionContext['item_image'];

    return Container(
      padding: EdgeInsets.all(8.h),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(6.h),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          if (itemImage != null && itemImage.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(4.h),
              child: Image.network(
                itemImage,
                width: 24.h,
                height: 24.h,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 24.h,
                  height: 24.h,
                  color: Colors.grey[300],
                  child: Icon(
                    Icons.image,
                    size: 12.h,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ),
          if (itemImage != null) SizedBox(width: 8.h),
          Expanded(
            child: Text(
              'Purchased: $itemTitle',
              style: TextStyle(
                fontSize: 12.h,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryRatings(Map<String, dynamic> review) {
    return Row(
      children: [
        Row(
          children: List.generate(5, (index) {
            final rating =
                int.tryParse(review['overall_rating'].toString()) ?? 0;
            return Icon(
              index < rating ? Icons.star : Icons.star_border,
              color: Colors.amber,
              size: 16.h,
            );
          }),
        ),
        SizedBox(width: 8.h),
        if ((review['product_quality_rating'] ?? 0) > 0 ||
            (review['shipping_speed_rating'] ?? 0) > 0 ||
            (review['communication_rating'] ?? 0) > 0) ...[
          Text(
            '•',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12.h,
            ),
          ),
          SizedBox(width: 8.h),
          _buildCategoryBadges(review),
        ],
      ],
    );
  }

  Widget _buildCategoryBadges(Map<String, dynamic> review) {
    final badges = <Widget>[];

    final productQuality =
        int.tryParse(review['product_quality_rating']?.toString() ?? '0') ?? 0;
    final shippingSpeed =
        int.tryParse(review['shipping_speed_rating']?.toString() ?? '0') ?? 0;
    final communication =
        int.tryParse(review['communication_rating']?.toString() ?? '0') ?? 0;

    if (productQuality >= 4) {
      badges.add(_buildCategoryBadge('Quality', Colors.green));
    }
    if (shippingSpeed >= 4) {
      badges.add(_buildCategoryBadge('Fast Ship', Colors.blue));
    }
    if (communication >= 4) {
      badges.add(_buildCategoryBadge('Great Chat', Colors.orange));
    }

    return Wrap(
      spacing: 4.h,
      children: badges,
    );
  }

  Widget _buildCategoryBadge(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.h, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(10.h),
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

  Widget _buildReviewImages(List<dynamic> images) {
    return Container(
      height: 60.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: math.min(images.length, 5),
        itemBuilder: (context, index) {
          final imageUrl = images[index];
          return Container(
            margin: EdgeInsets.only(right: 8.h),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6.h),
              child: Image.network(
                imageUrl,
                width: 60.h,
                height: 60.h,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 60.h,
                  height: 60.h,
                  color: Colors.grey[300],
                  child: Icon(
                    Icons.image,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildReviewActions(BuildContext context, String reviewId) {
    return Row(
      children: [
        TextButton.icon(
          onPressed: () => onReviewAction('helpful', reviewId),
          icon: Icon(Icons.thumb_up_outlined, size: 16.h),
          label: const Text('Helpful'),
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey[600],
            padding: EdgeInsets.symmetric(horizontal: 8.h),
          ),
        ),
        TextButton.icon(
          onPressed: () => onReviewAction('report', reviewId),
          icon: Icon(Icons.flag_outlined, size: 16.h),
          label: const Text('Report'),
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey[600],
            padding: EdgeInsets.symmetric(horizontal: 8.h),
          ),
        ),
      ],
    );
  }

  Widget _buildSellerResponse(String sellerResponse, String? responseDate) {
    return Container(
      margin: EdgeInsets.only(left: 52.h),
      padding: EdgeInsets.all(12.h),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8.h),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.store,
                size: 16.h,
                color: Colors.blue[700],
              ),
              SizedBox(width: 4.h),
              Text(
                'Seller Response',
                style: TextStyle(
                  fontSize: 12.h,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[700],
                ),
              ),
              const Spacer(),
              if (responseDate != null)
                Text(
                  _formatDate(responseDate),
                  style: TextStyle(
                    fontSize: 11.h,
                    color: Colors.grey[600],
                  ),
                ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            sellerResponse,
            style: TextStyle(
              fontSize: 13.h,
              color: Colors.grey[800],
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays >= 365) {
        return DateFormat('MMM yyyy').format(date);
      } else if (difference.inDays >= 30) {
        return DateFormat('MMM d').format(date);
      } else if (difference.inDays >= 1) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours >= 1) {
        return '${difference.inHours}h ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Unknown';
    }
  }
}
