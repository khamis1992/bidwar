import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../controllers/create_auction_controller.dart';

/// Preview Card Widget
///
/// معاينة المزاد قبل الإنشاء
/// يتبع قواعد BidWar للتصميم
class PreviewCardWidget extends StatelessWidget {
  final CreateAuctionController controller;
  final VoidCallback onEdit;
  final VoidCallback onCreate;

  const PreviewCardWidget({
    super.key,
    required this.controller,
    required this.onEdit,
    required this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Text(
          'Preview Your Auction',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: AppTheme.primaryLight,
          ),
        ),

        SizedBox(height: 1.h),

        Text(
          'Review your auction details before publishing',
          style: TextStyle(
            fontSize: 12.sp,
            color: AppTheme.textSecondaryLight,
            fontWeight: FontWeight.w400,
          ),
        ),

        SizedBox(height: 4.h),

        // Preview Card (يحاكي AuctionCardWidget)
        Card(
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header مع الحالة
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatusBadge(),
                    IconButton(
                      onPressed: null, // معطل في المعاينة
                      icon: Icon(
                        Icons.bookmark_border,
                        color:
                            AppTheme.textSecondaryLight.withValues(alpha: 0.5),
                        size: 5.w,
                      ),
                    ),
                  ],
                ),

                // صورة المزاد (أو placeholder)
                Container(
                  width: double.infinity,
                  height: 25.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: AppTheme.borderLight.withValues(alpha: 0.3),
                  ),
                  child: controller.selectedImages.isNotEmpty
                      ? Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: FileImage(controller.selectedImages.first),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: _buildImageOverlay(),
                        )
                      : _buildImagePlaceholder(),
                ),

                SizedBox(height: 3.w),

                // عنوان المزاد
                Text(
                  controller.title.isNotEmpty
                      ? controller.title
                      : 'Auction Title',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: controller.title.isNotEmpty
                        ? AppTheme.primaryLight
                        : AppTheme.textSecondaryLight,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(height: 2.w),

                // معلومات البائع والفئة
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 4.w,
                      color: AppTheme.textSecondaryLight,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      'You', // البائع الحالي
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppTheme.textSecondaryLight,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Icon(
                      Icons.category_outlined,
                      size: 4.w,
                      color: AppTheme.textSecondaryLight,
                    ),
                    SizedBox(width: 1.w),
                    Expanded(
                      child: Text(
                        controller.categoryId ?? 'No Category',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppTheme.textSecondaryLight,
                          fontWeight: FontWeight.w400,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 3.w),

                // معلومات السعر
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Starting Bid',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: AppTheme.textSecondaryLight,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          '\$${controller.startingPrice}',
                          style: TextStyle(
                            fontSize: 18.sp,
                            color: AppTheme.primaryLight,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Bid Step',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: AppTheme.textSecondaryLight,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          '\$${controller.bidIncrement}',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: AppTheme.secondaryLight,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: 4.h),

        // Auction Details Summary
        _buildDetailsSummary(),

        SizedBox(height: 6.h),

        // Action Buttons
        Row(
          children: [
            // Edit Button
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onEdit,
                icon: Icon(Icons.edit),
                label: Text('Edit Details'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                ),
              ),
            ),

            SizedBox(width: 4.w),

            // Create Button
            Expanded(
              child: ElevatedButton.icon(
                onPressed: controller.isFormValid && !controller.isCreating
                    ? onCreate
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.secondaryLight,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: controller.isCreating
                    ? SizedBox(
                        width: 5.w,
                        height: 5.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Icon(Icons.publish),
                label: Text(
                  controller.isCreating ? 'Creating...' : 'Create Auction',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    final now = DateTime.now();
    final isLiveNow = controller.startTime?.isBefore(now) ?? false;

    final badgeColor =
        isLiveNow ? AppTheme.successLight : AppTheme.warningLight;
    final statusText = isLiveNow ? 'WILL BE LIVE' : 'SCHEDULED';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.w),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: badgeColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          fontSize: 9.sp,
          color: badgeColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildImageOverlay() {
    return Stack(
      children: [
        // Gradient overlay
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.3),
                ],
              ),
            ),
          ),
        ),

        // Image count badge
        if (controller.selectedImages.length > 1)
          Positioned(
            bottom: 2.w,
            right: 2.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.w),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.photo_library,
                    size: 3.w,
                    color: Colors.white,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    '${controller.selectedImages.length}',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.image_outlined,
          size: 20.w,
          color: AppTheme.borderLight,
        ),
        SizedBox(height: 2.h),
        Text(
          'No images selected',
          style: TextStyle(
            fontSize: 14.sp,
            color: AppTheme.textSecondaryLight,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          'Go back to Images tab to add photos',
          style: TextStyle(
            fontSize: 11.sp,
            color: AppTheme.textSecondaryLight,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDetailsSummary() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.borderLight,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Auction Summary',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryLight,
            ),
          ),

          SizedBox(height: 3.h),

          // Description Preview
          if (controller.description.isNotEmpty) ...[
            Text(
              'Description:',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondaryLight,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              controller.description,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppTheme.primaryLight,
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 2.h),
          ],

          // Timing Information
          if (controller.startTime != null && controller.endTime != null) ...[
            _buildSummaryRow('Starts:', _formatDateTime(controller.startTime!)),
            _buildSummaryRow('Ends:', _formatDateTime(controller.endTime!)),
            _buildSummaryRow(
              'Duration:',
              _formatDuration(controller.auctionDuration!),
            ),
            SizedBox(height: 2.h),
          ],

          // Additional Details
          if (controller.condition != null)
            _buildSummaryRow('Condition:', controller.condition!),

          if (controller.brand != null)
            _buildSummaryRow('Brand:', controller.brand!),

          if (controller.model != null)
            _buildSummaryRow('Model:', controller.model!),

          // Images Count
          _buildSummaryRow(
            'Images:',
            '${controller.selectedImages.length} image${controller.selectedImages.length != 1 ? 's' : ''}',
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 25.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppTheme.textSecondaryLight,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppTheme.primaryLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateOnly = DateTime(dateTime.year, dateTime.month, dateTime.day);

    String dateStr;
    if (dateOnly == today) {
      dateStr = 'Today';
    } else if (dateOnly == tomorrow) {
      dateStr = 'Tomorrow';
    } else {
      dateStr = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }

    final timeStr =
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

    return '$dateStr at $timeStr';
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else {
      return '${duration.inMinutes}m';
    }
  }
}
