import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../features/auctions/domain/entities/auction_entity.dart';

/// Auction Image Widget
///
/// يعرض صور المزاد مع carousel
/// يتبع قواعد BidWar للتصميم
class AuctionImageWidget extends StatefulWidget {
  final AuctionEntity auction;

  const AuctionImageWidget({super.key, required this.auction});

  @override
  State<AuctionImageWidget> createState() => _AuctionImageWidgetState();
}

class _AuctionImageWidgetState extends State<AuctionImageWidget> {
  late PageController _pageController;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images =
        widget.auction.images.isNotEmpty
            ? widget.auction.images
            : [widget.auction.mainImage]; // fallback للصورة الافتراضية

    return Container(
      width: double.infinity,
      height: 40.h,
      child: Stack(
        children: [
          // Image Carousel
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemCount: images.length,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(images[index]),
                    fit: BoxFit.cover,
                    onError: (exception, stackTrace) {
                      // معالجة خطأ تحميل الصورة
                      print('Error loading image: $exception');
                    },
                  ),
                ),
              );
            },
          ),

          // Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.5),
                  ],
                  stops: const [0.0, 0.3, 0.7, 1.0],
                ),
              ),
            ),
          ),

          // Status Badge
          Positioned(top: 4.h, left: 4.w, child: _buildStatusBadge()),

          // Featured Badge
          if (widget.auction.featured)
            Positioned(
              top: 4.h,
              right: 4.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: AppTheme.warningLight,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, size: 4.w, color: Colors.white),
                    SizedBox(width: 1.w),
                    Text(
                      'Featured',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Image Indicators (إذا كان هناك أكثر من صورة)
          if (images.length > 1)
            Positioned(
              bottom: 2.h,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children:
                    images.asMap().entries.map((entry) {
                      final index = entry.key;
                      return GestureDetector(
                        onTap: () {
                          _pageController.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: Container(
                          width: _currentImageIndex == index ? 4.w : 2.w,
                          height: 2.w,
                          margin: EdgeInsets.symmetric(horizontal: 1.w),
                          decoration: BoxDecoration(
                            color:
                                _currentImageIndex == index
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(1.w),
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color badgeColor;
    String statusText;
    IconData statusIcon;

    switch (widget.auction.status) {
      case AuctionStatus.live:
        badgeColor = AppTheme.successLight;
        statusText = 'LIVE';
        statusIcon = Icons.flash_on;
        break;
      case AuctionStatus.upcoming:
        badgeColor = AppTheme.warningLight;
        statusText = 'UPCOMING';
        statusIcon = Icons.schedule;
        break;
      case AuctionStatus.ended:
        badgeColor = AppTheme.textSecondaryLight;
        statusText = 'ENDED';
        statusIcon = Icons.flag;
        break;
      case AuctionStatus.cancelled:
        badgeColor = AppTheme.errorLight;
        statusText = 'CANCELLED';
        statusIcon = Icons.cancel;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 4.w, color: Colors.white),
          SizedBox(width: 2.w),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
