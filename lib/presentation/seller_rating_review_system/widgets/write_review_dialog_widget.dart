import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../services/seller_rating_service.dart';

class WriteReviewDialogWidget extends StatefulWidget {
  final String sellerId;
  final VoidCallback onReviewSubmitted;

  const WriteReviewDialogWidget({
    super.key,
    required this.sellerId,
    required this.onReviewSubmitted,
  });

  @override
  State<WriteReviewDialogWidget> createState() =>
      _WriteReviewDialogWidgetState();
}

class _WriteReviewDialogWidgetState extends State<WriteReviewDialogWidget> {
  final _sellerRatingService = SellerRatingService();
  final _reviewController = TextEditingController();
  bool _isSubmitting = false;

  // Rating values
  int _overallRating = 5;
  int _productQualityRating = 5;
  int _shippingSpeedRating = 5;
  int _communicationRating = 5;
  int _streamEntertainmentRating = 5;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _sellerRatingService.submitSellerRating({
        'seller_id': widget.sellerId,
        'overall_rating': _overallRating.toString(),
        'product_quality_rating': _productQualityRating.toString(),
        'shipping_speed_rating': _shippingSpeedRating.toString(),
        'communication_rating': _communicationRating.toString(),
        'stream_entertainment_rating': _streamEntertainmentRating.toString(),
        'review_text': _reviewController.text.trim(),
      });

      widget.onReviewSubmitted();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit review: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.h),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildOverallRating(),
                      SizedBox(height: 20.h),
                      _buildCategoryRatings(),
                      SizedBox(height: 20.h),
                      _buildReviewText(),
                    ],
                  ),
                ),
              ),
            ),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(16.h),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12.h),
          topRight: Radius.circular(12.h),
        ),
      ),
      child: Row(
        children: [
          Text(
            'Write a Review',
            style: TextStyle(
              fontSize: 18.h,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: EdgeInsets.all(4.h),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(51),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                color: Colors.white,
                size: 20.h,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallRating() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overall Rating',
          style: TextStyle(
            fontSize: 16.h,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: List.generate(5, (index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _overallRating = index + 1;
                });
              },
              child: Icon(
                index < _overallRating ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 32.h,
              ),
            );
          }),
        ),
        SizedBox(height: 4.h),
        Text(
          _getRatingText(_overallRating),
          style: TextStyle(
            fontSize: 14.h,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryRatings() {
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
        _buildCategoryRatingRow(
          'Product Quality',
          Icons.inventory,
          _productQualityRating,
          (rating) => setState(() => _productQualityRating = rating),
        ),
        _buildCategoryRatingRow(
          'Shipping Speed',
          Icons.local_shipping,
          _shippingSpeedRating,
          (rating) => setState(() => _shippingSpeedRating = rating),
        ),
        _buildCategoryRatingRow(
          'Communication',
          Icons.chat,
          _communicationRating,
          (rating) => setState(() => _communicationRating = rating),
        ),
        _buildCategoryRatingRow(
          'Stream Entertainment',
          Icons.live_tv,
          _streamEntertainmentRating,
          (rating) => setState(() => _streamEntertainmentRating = rating),
        ),
      ],
    );
  }

  Widget _buildCategoryRatingRow(
    String title,
    IconData icon,
    int rating,
    Function(int) onRatingChanged,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
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
              title,
              style: TextStyle(fontSize: 14.h),
            ),
          ),
          Row(
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () => onRatingChanged(index + 1),
                child: Icon(
                  index < rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 20.h,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Review (Optional)',
          style: TextStyle(
            fontSize: 16.h,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: _reviewController,
          maxLines: 4,
          maxLength: 500,
          decoration: InputDecoration(
            hintText: 'Share your experience with this seller...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.h),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.h),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'Your review helps other buyers make informed decisions.',
          style: TextStyle(
            fontSize: 12.h,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: EdgeInsets.all(16.h),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed:
                  _isSubmitting ? null : () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ),
          SizedBox(width: 16.h),
          Expanded(
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitReview,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: EdgeInsets.symmetric(vertical: 12.h),
              ),
              child: _isSubmitting
                  ? SizedBox(
                      height: 16.h,
                      width: 16.h,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Submit Review',
                      style: TextStyle(color: Colors.white),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Very Good';
      case 5:
        return 'Excellent';
      default:
        return '';
    }
  }
}