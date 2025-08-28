import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class OnboardingNavigationWidget extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final VoidCallback onGetStarted;

  const OnboardingNavigationWidget({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onNext,
    required this.onSkip,
    required this.onGetStarted,
  });

  @override
  Widget build(BuildContext context) {
    final isLastPage = currentPage == totalPages - 1;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Skip button (only show if not last page)
          if (!isLastPage)
            TextButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                onSkip();
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
              ),
              child: Text(
                'Skip',
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
                    alpha: 0.6,
                  ),
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          else
            const SizedBox.shrink(),

          // Next/Get Started button
          ElevatedButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              if (isLastPage) {
                onGetStarted();
              } else {
                onNext();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
              foregroundColor: AppTheme.lightTheme.colorScheme.onSecondary,
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isLastPage ? 'Get Started' : 'Next',
                  style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 2.w),
                CustomIconWidget(
                  iconName: isLastPage ? 'login' : 'arrow_forward',
                  color: AppTheme.lightTheme.colorScheme.onSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
