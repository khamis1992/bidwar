import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import './auction_animation_widget.dart';

class OnboardingPageWidget extends StatelessWidget {
  final String title;
  final String description;
  final String? imageUrl;
  final bool useAnimation;
  final String? animationType;
  final bool showInteractiveElement;
  final VoidCallback? onInteraction;

  const OnboardingPageWidget({
    super.key,
    required this.title,
    required this.description,
    this.imageUrl,
    this.useAnimation = false,
    this.animationType,
    this.showInteractiveElement = false,
    this.onInteraction,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration container
            Container(
              width: 80.w,
              height: 35.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.lightTheme.colorScheme.shadow
                        .withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: useAnimation && animationType != null
                    ? AuctionAnimationWidget(
                        animationType: animationType!,
                      )
                    : imageUrl != null
                        ? CustomImageWidget(
                            imageUrl: imageUrl!,
                            width: 80.w,
                            height: 35.h,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: AppTheme.lightTheme.colorScheme.primary
                                .withValues(alpha: 0.1),
                            child: Center(
                              child: Icon(
                                Icons.image,
                                size: 10.w,
                                color: AppTheme.lightTheme.colorScheme.primary
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                          ),
              ),
            ),

            SizedBox(height: 6.h),

            // Title
            Text(
              title,
              style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 3.h),

            // Description
            Text(
              description,
              style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.7),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 4.h),

            // Interactive element (if enabled)
            if (showInteractiveElement) ...[
              _buildInteractiveElement(context),
              SizedBox(height: 2.h),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInteractiveElement(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current Price: \$12.47',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                'Next bid: +\$0.01',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: onInteraction,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.secondary,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.lightTheme.colorScheme.secondary
                        .withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: 'gavel',
                    color: AppTheme.lightTheme.colorScheme.onSecondary,
                    size: 20,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Bid Now',
                    style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
