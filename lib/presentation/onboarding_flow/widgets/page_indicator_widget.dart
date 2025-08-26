import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class PageIndicatorWidget extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback? onPageTap;

  const PageIndicatorWidget({
    super.key,
    required this.currentPage,
    required this.totalPages,
    this.onPageTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        totalPages,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: EdgeInsets.symmetric(horizontal: 1.w),
          width: index == currentPage ? 8.w : 2.w,
          height: 1.h,
          decoration: BoxDecoration(
            color: index == currentPage
                ? AppTheme.lightTheme.colorScheme.primary
                : AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
