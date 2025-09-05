import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../features/auctions/domain/entities/auction_entity.dart';

/// Auction Info Widget
///
/// يعرض معلومات المزاد الأساسية
/// يتبع قواعد BidWar للتصميم
class AuctionInfoWidget extends StatelessWidget {
  final AuctionEntity auction;

  const AuctionInfoWidget({super.key, required this.auction});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // عنوان المزاد
        Text(
          auction.title,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: AppTheme.primaryLight,
            height: 1.3,
          ),
        ),

        SizedBox(height: 2.h),

        // معلومات البائع والفئة
        Row(
          children: [
            // البائع
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: BoxDecoration(
                      color: AppTheme.borderLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.person,
                      size: 4.w,
                      color: AppTheme.textSecondaryLight,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Seller',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: AppTheme.textSecondaryLight,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          auction.sellerName,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: AppTheme.primaryLight,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(width: 4.w),

            // الفئة
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: BoxDecoration(
                      color: AppTheme.borderLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.category,
                      size: 4.w,
                      color: AppTheme.textSecondaryLight,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Category',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: AppTheme.textSecondaryLight,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          auction.categoryName,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: AppTheme.primaryLight,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        SizedBox(height: 3.h),

        // إحصائيات المزاد
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: AppTheme.borderLight.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // عدد المزايدات
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${auction.totalBids}',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.secondaryLight,
                      ),
                    ),
                    Text(
                      'Bids',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppTheme.textSecondaryLight,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // عدد المشاهدات
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${auction.viewCount}',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryLight,
                      ),
                    ),
                    Text(
                      'Views',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppTheme.textSecondaryLight,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // السعر الابتدائي
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '\$${auction.startingPrice}',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textSecondaryLight,
                      ),
                    ),
                    Text(
                      'Starting',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppTheme.textSecondaryLight,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 3.h),

        // وصف المزاد
        Text(
          'Description',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryLight,
          ),
        ),

        SizedBox(height: 1.h),

        Text(
          auction.description,
          style: TextStyle(
            fontSize: 14.sp,
            color: AppTheme.textSecondaryLight,
            fontWeight: FontWeight.w400,
            height: 1.5,
          ),
        ),

        // معلومات إضافية (إذا توفرت)
        if (_hasAdditionalInfo()) ...[
          SizedBox(height: 3.h),
          _buildAdditionalInfo(),
        ],
      ],
    );
  }

  bool _hasAdditionalInfo() {
    return auction.condition != null ||
        auction.brand != null ||
        auction.model != null ||
        (auction.specifications?.isNotEmpty ?? false);
  }

  Widget _buildAdditionalInfo() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderLight, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Item Details',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryLight,
            ),
          ),

          SizedBox(height: 2.h),

          // Condition
          if (auction.condition != null)
            _buildInfoRow('Condition', auction.condition!),

          // Brand
          if (auction.brand != null) _buildInfoRow('Brand', auction.brand!),

          // Model
          if (auction.model != null) _buildInfoRow('Model', auction.model!),

          // Specifications (إذا توفرت)
          if (auction.specifications?.isNotEmpty ?? false) ...[
            SizedBox(height: 2.h),
            Text(
              'Specifications',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryLight,
              ),
            ),
            SizedBox(height: 1.h),
            ...auction.specifications!.entries.map((entry) {
              return _buildInfoRow(entry.key, entry.value.toString());
            }).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 25.w,
            child: Text(
              '$label:',
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
}
